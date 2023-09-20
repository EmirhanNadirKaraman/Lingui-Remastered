class UserLanguages {
  final List<String> learnedLanguageCodes;
  final List<String> allLanguageCodes;

  const UserLanguages(
      {required this.allLanguageCodes, required this.learnedLanguageCodes});

  factory UserLanguages.fromJson(Map<String, dynamic> json) {
    final learnedLanguages = <String>[];
    for (final language in json['learned_languages']) {
      learnedLanguages.add(language);
    }
    final allLanguages = <String>[];
    for (final language in json['all_languages']) {
      allLanguages.add(language);
    }
    return UserLanguages(
        allLanguageCodes: allLanguages, learnedLanguageCodes: learnedLanguages);
  }
}
