import 'package:audioapp/data/dummydata.dart';
import 'package:audioapp/models/language.dart';
import 'package:audioapp/models/songsmodel.dart';
import 'package:audioapp/screens/homescreen.dart';
import 'package:audioapp/utils/selectlanguage.dart';
import 'package:flutter/material.dart';

class LanguageScreen extends StatelessWidget {
  final void Function(Song song) onToggleFavorite;
  const LanguageScreen({super.key, required this.onToggleFavorite});
 void _selectLanguage(BuildContext context, Language language) {

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => HomeScreen(language: language,),
      ),
    );
  }
 @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
       // actions: [
          // IconButton(
          //   onPressed: () {
          //     FirebaseAuth.instance.signOut();
          //   },
          //   icon: Icon(
          //     Icons.exit_to_app,
          //     color: Theme.of(context).colorScheme.primary,
          //   ),
          // ),
       // ],
      ),
      body: GridView(
        padding: const EdgeInsets.all(24),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 3 / 2,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
        ),
        children: [
          for (final language in availableLanguages)
            LanguageGridItem(language: language, onSelectLanguage: (){_selectLanguage(context, language);},)
        ],
      ),
    );
  }
}
