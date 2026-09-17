import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';

import '../models.dart';

/// Fetches headlines from Google News' per-country/per-category RSS feeds.
/// Google News aggregates local outlets in the country's own language, which
/// is exactly the "local language" source this app needs, for every region.
class NewsService {
  static Uri buildFeedUrl(Country country, NewsCategory category) {
    final topic = category.googleNewsTopic;
    if (topic != null) {
      return Uri.parse(
        'https://news.google.com/rss/headlines/section/topic/$topic'
        '?hl=${country.hl}&gl=${country.gl}&ceid=${country.ceid}',
      );
    }
    // No dedicated "investment" topic exists, so fall back to a keyword search
    // in the country's own language.
    final query = Uri.encodeComponent(country.investmentKeyword);
    return Uri.parse(
      'https://news.google.com/rss/search?q=$query'
      '&hl=${country.hl}&gl=${country.gl}&ceid=${country.ceid}',
    );
  }

  Future<List<String>> fetchHeadlines(
    Country country,
    NewsCategory category, {
    int limit = 12,
  }) async {
    final url = buildFeedUrl(country, category);
    final response = await http.get(
      url,
      headers: {'User-Agent': 'Mozilla/5.0 (Android 14; Mobile) WorldNewsMarquee/1.0'},
    ).timeout(const Duration(seconds: 12));

    if (response.statusCode != 200) {
      throw Exception('Feed request failed: HTTP ${response.statusCode}');
    }

    final document = XmlDocument.parse(response.body);
    final titles = document
        .findAllElements('item')
        .map((item) => item.getElement('title')?.innerText.trim() ?? '')
        .where((t) => t.isNotEmpty)
        .map(_stripSourceSuffix)
        .take(limit)
        .toList();

    if (titles.isEmpty) {
      throw Exception('No headlines returned for ${country.name} / ${category.label}');
    }
    return titles;
  }

  /// Google News appends " - <Source Name>" to every title; strip it so the
  /// marquee shows a clean headline.
  static String _stripSourceSuffix(String title) {
    final parts = title.split(' - ');
    if (parts.length > 1 && parts.last.length <= 40) {
      return parts.sublist(0, parts.length - 1).join(' - ');
    }
    return title;
  }
}
