import 'package:audioapp/screens/SignupScreen.dart';
import 'package:audioapp/screens/tabsScreen.dart';
import 'package:audioapp/utils/dimensions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
 WidgetsFlutterBinding.ensureInitialized();
 await Firebase.initializeApp(
  options: FirebaseOptions(
          apiKey: 'AIzaSyAsbWNPQQLLzXTsMJPcf9wvyrFRAorre0E',
          appId: '1:686525289113:android:929a20e9b2108841d89e08',
          messagingSenderId: '686525289113',
          projectId: 'audiomusic-ebba6',
          storageBucket: 'audiomusic-ebba6.appspot.com',
        )
      );
runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My App',
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (ctx, snapshot) {
          if (snapshot.hasData) {
            return const TabsScreen();
          }
          return const TabsScreen();
        },
      ),
    );
  }
}


// import 'package:audioapp/screens/musicprovider.dart';
// import 'package:audioapp/screens/tabsScreen.dart';
// import 'package:audioapp/utils/dimensions.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// Future<void> main() async {
//  WidgetsFlutterBinding.ensureInitialized();
//  await Firebase.initializeApp(
//   options: FirebaseOptions(
//           apiKey: 'AIzaSyAsbWNPQQLLzXTsMJPcf9wvyrFRAorre0E',
//           appId: '1:686525289113:android:929a20e9b2108841d89e08',
//           messagingSenderId: '686525289113',
//           projectId: 'audiomusic-ebba6',
//           storageBucket: 'audiomusic-ebba6.appspot.com',
//         )
//       );
//  runApp(
//     ChangeNotifierProvider(
//       create: (_) => AudioPlayerState(),
//       child: MyApp(),
//     ),
//   );
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     SizeConfig().init(context);
//     return MaterialApp(
//       title: 'My App',
//       home: TabsScreen(),
//     );
//   }
// }