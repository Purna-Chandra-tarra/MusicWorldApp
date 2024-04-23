import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';

enum AudioProcessingState {
  none, // New constant
  stopped,
  connecting,
  buffering,
  ready,
  completed,
  skippingToNext, // New constant
  skippingToPrevious, // New constant
  seeking, // New constant
}

class AudioPlayerTask extends BackgroundAudioTask {
  late AudioPlayer _player;
  late AudioProcessingState _skipState;
  late Seeker _seeker;
  late StreamSubscription<PlaybackEvent> _eventSubscription;

  List<MediaItem> _queue = [];
  List<MediaItem> get queue => _queue;
  int? get index => _player.currentIndex;

  MediaItem? get mediaItem => index == null ? null : queue[index!];

  @override
  Future<void> onStart(Map<String, dynamic>? params) async {
    _player = AudioPlayer();
    _loadMediaItemsIntoQueue(params);

    await _setAudioSession();

    _propagateEventsFromAudioPlayerToAudioServiceClients();
    _performSpecialProcessingForStateTransitions();
    await _loadQueue();
  }

  void _loadMediaItemsIntoQueue(Map<String, dynamic>? params) {
    _queue.clear();
    final List mediaItems = params!['data'];
    for (var item in mediaItems) {
      final mediaItem = MediaItem(
        id: item['id'],
        album: item['album'],
        title: item['title'],
        artist: item['artist'],
      );
      _queue.add(mediaItem);
    }
  }

  Future<void> _setAudioSession() async {
    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration.music());
  }

  void _propagateEventsFromAudioPlayerToAudioServiceClients() {
    _eventSubscription = _player.playbackEventStream.listen((event) {
      _broadcastState();
    });
  }

  void _performSpecialProcessingForStateTransitions() {
    _player.processingStateStream.listen((state) {
      switch (state) {
        case ProcessingState.completed:
          onPause();
          break;
        case ProcessingState.ready:
          _skipState = AudioProcessingState.none;
          break;
        default:
          break;
      }
    });
  }

  Future<void> _loadQueue() async {
    AudioServiceBackground.setQueue(queue);
    try {
      await _player.setAudioSource(
        ConcatenatingAudioSource(
          children:
              queue.map((item) => AudioSource.uri(Uri.parse(item.id))).toList(),
        ),
      );
      _player.durationStream.listen((duration) {
        _updateQueueWithCurrentDuration(duration);
      });
    } catch (e) {
      print('Error: $e');
    }
  }

  void _updateQueueWithCurrentDuration(Duration? duration) {
    if (duration == null) return;
    final songIndex = _player.currentIndex;
    if (songIndex == null || songIndex >= queue.length) return;
    final modifiedMediaItem = queue[songIndex].copyWith(duration: duration);
    queue[songIndex] = modifiedMediaItem;
    AudioServiceBackground.setMediaItem(queue[songIndex]);
    AudioServiceBackground.setQueue(queue);
  }
  

  @override
  Future<void> onSkipToQueueItem(String mediaId) async {
    final newIndex = queue.indexWhere((item) => item.id == mediaId);
    if (newIndex == -1) return;
    _skipState = newIndex > index!
        ? AudioProcessingState.skippingToNext
        : AudioProcessingState.skippingToPrevious;
    _player.seek(Duration.zero, index: newIndex);
    AudioServiceBackground.sendCustomEvent('skip to $newIndex');
  }

  @override
  Future<void> onPlay() => _player.play();

  @override
  Future<void> onPause() => _player.pause();

  @override
  Future<void> onSeekTo(Duration position) => _player.seek(position);

  @override
  Future<void> onFastForward() => _seekRelative(fastForwardInterval);

  @override
  Future<void> onRewind() => _seekRelative(-rewindInterval);

  @override
  Future<void> onSeekForward(bool begin) async => _seekContinuously(begin, 1);

  @override
  Future<void> onSeekBackward(bool begin) async => _seekContinuously(begin, -1);

  @override
  Future<void> onStop() async {
    await _player.dispose();
    await _eventSubscription.cancel();
    await _broadcastState();
    await super.onStop();
  }

  @override
  Future<void> onCustomAction(String type, dynamic mediaId) async {
    if (type == 'updateMedia') {
      final newIndex = queue.indexWhere((item) => item.id == mediaId);
      if (newIndex == -1) return;
      _player.seek(Duration.zero, index: newIndex);

      if (!_player.playing) _player.play();

      AudioServiceBackground.sendCustomEvent('goto to $newIndex');
    }
  }

  /// Jumps away from the current position by [offset].
  Future<void> _seekRelative(Duration offset) async {
    var newPosition = _player.position + offset;
    // Make sure we don't jump out of bounds.
    if (newPosition < Duration.zero) newPosition = Duration.zero;
    if (newPosition > mediaItem!.duration!) newPosition = mediaItem!.duration!;
    // Perform the jump via a seek.
    await _player.seek(newPosition);
  }

  /// Begins or stops a continuous seek in [direction]. After it begins it will
  /// continue seeking forward or backward by 10 seconds within the audio, at
  /// intervals of 1 second in app time.
  void _seekContinuously(bool begin, int direction) {
    _seeker?.stop();
    if (begin) {
      _seeker = Seeker(_player, Duration(seconds: 10 * direction),
          Duration(seconds: 1), mediaItem!)
        ..start();
    }
  }

  Future<void> _broadcastState() async {
    await AudioServiceBackground.setState(
      controls: [
        MediaControl.skipToPrevious,
        if (_player.playing) MediaControl.pause else MediaControl.play,
        MediaControl.stop,
        MediaControl.skipToNext,
      ],
      systemActions: [
        //MediaAction.seekTo,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      ],
      androidCompactActions: [0, 1, 3],
     // processingState: _getProcessingState(),
      playing: _player.playing,
      position: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
    );
  }

  AudioProcessingState _getProcessingState() {
    if (_skipState != AudioProcessingState.none) return _skipState;
    switch (_player.processingState) {
      case ProcessingState.idle:
        return AudioProcessingState.stopped;
      case ProcessingState.loading:
        return AudioProcessingState.connecting;
      case ProcessingState.buffering:
        return AudioProcessingState.buffering;
      case ProcessingState.ready:
        return AudioProcessingState.ready;
      case ProcessingState.completed:
        return AudioProcessingState.completed;
      default:
        throw Exception("Invalid state: ${_player.processingState}");
    }
  }
}

class Seeker {
  final AudioPlayer player;
  final Duration positionInterval;
  final Duration stepInterval;
  final MediaItem mediaItem;
  bool _running = false;

  Seeker(
    this.player,
    this.positionInterval,
    this.stepInterval,
    this.mediaItem,
  );

  void start() async {
    _running = true;
    while (_running) {
      Duration newPosition = player.position + positionInterval;
      if (newPosition < Duration.zero) newPosition = Duration.zero;
      if (newPosition > mediaItem.duration!) newPosition = mediaItem.duration!;
      player.seek(newPosition);
      await Future.delayed(stepInterval);
    }
  }

  void stop() {
    _running = false;
  }
}
