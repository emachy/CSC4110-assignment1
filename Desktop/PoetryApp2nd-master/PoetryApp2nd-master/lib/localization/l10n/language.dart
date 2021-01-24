// Author: Khaled
// This class returns all of the languages that can be translated to when the user presses the translation button.

class Language {
  final int id;
  final String flag;
  final String name;
  final String languageCode;

  Language(this.id, this.flag, this.name,
      this.languageCode); // This grabs the language's id, its flag, its name, and language code.  This modifies what the list looks
  // like on the GUI.

  static List<Language> languageList() {
    return <Language>[
      Language(1, "🇺🇸", "English", "en"),
      Language(2, "🇾🇪", "اَلْعَرَبِيَّةُ‎", "ar"),
      Language(3, "🇮🇷", "فارسی", "fa"),
      Language(4, "🇹🇷", "Türkçe", "tr"),
    ];
  }
}
