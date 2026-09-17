import 'package:google_mlkit_translation/google_mlkit_translation.dart';

enum NewsCategory { politics, economics, sports, investment }

extension NewsCategoryLabel on NewsCategory {
  String get label {
    switch (this) {
      case NewsCategory.politics:
        return 'Politics';
      case NewsCategory.economics:
        return 'Economics';
      case NewsCategory.sports:
        return 'Sports';
      case NewsCategory.investment:
        return 'Investment';
    }
  }

  /// Google News topic slug for the RSS "section/topic" endpoint.
  /// Investment has no dedicated topic, so it's built as a search query instead.
  String? get googleNewsTopic {
    switch (this) {
      case NewsCategory.politics:
        return 'NATION';
      case NewsCategory.economics:
        return 'BUSINESS';
      case NewsCategory.sports:
        return 'SPORTS';
      case NewsCategory.investment:
        return null;
    }
  }
}

enum TargetLanguage { english, japanese }

extension TargetLanguageInfo on TargetLanguage {
  String get label => this == TargetLanguage.english ? 'English' : '日本語';

  TranslateLanguage get mlkitLanguage => this == TargetLanguage.english
      ? TranslateLanguage.english
      : TranslateLanguage.japanese;
}

class Country {
  final String name;
  final String localName;

  /// Google News interface language, e.g. "ja", "en-US", "pt-BR".
  final String hl;

  /// Google News edition/country code, e.g. "JP", "US".
  final String gl;

  /// Google News ceid combo, e.g. "JP:ja".
  final String ceid;

  /// Local-language word for "investment", used to build the investment search feed.
  final String investmentKeyword;

  /// ML Kit source language used to translate this country's headlines.
  final TranslateLanguage mlkitSourceLanguage;

  const Country({
    required this.name,
    required this.localName,
    required this.hl,
    required this.gl,
    required this.ceid,
    required this.investmentKeyword,
    required this.mlkitSourceLanguage,
  });
}

class Region {
  final String name;
  final List<Country> countries;

  const Region({required this.name, required this.countries});
}
