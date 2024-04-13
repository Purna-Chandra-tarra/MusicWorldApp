import 'package:audioapp/models/language.dart';
import 'package:flutter/material.dart';

class LanguageGridItem extends StatelessWidget {
  final Language language;
  const LanguageGridItem({super.key, required this.language, required this.onSelectLanguage});
  final void Function() onSelectLanguage;
 @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onSelectLanguage,
      splashColor: Theme.of(context).primaryColor,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              language.color.withOpacity(0.55),
              language.color.withOpacity(0.9),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Text(
          language.title,
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
                color: Theme.of(context).colorScheme.onBackground,
              ),
        ),
      ),
    );
  }
}
