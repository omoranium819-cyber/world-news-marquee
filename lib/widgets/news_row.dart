import 'dart:async';

import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';

import '../models.dart';
import '../services/news_service.dart';
import '../services/translation_service.dart';

/// One region's line: a country picker, a category picker, and a scrolling
/// marquee of that country/category's (translated) headlines.
class NewsRow extends StatefulWidget {
  final Region region;
  final TargetLanguage targetLanguage;
  final NewsService newsService;
  final TranslationService translationService;

  const NewsRow({
    super.key,
    required this.region,
    required this.targetLanguage,
    required this.newsService,
    required this.translationService,
  });

  @override
  State<NewsRow> createState() => _NewsRowState();
}

class _NewsRowState extends State<NewsRow> {
  late Country _country;
  NewsCategory _category = NewsCategory.politics;
  List<String> _rawHeadlines = [];
  String _displayText = 'Loading...';
  bool _loading = true;
  int _requestId = 0;

  @override
  void initState() {
    super.initState();
    _country = widget.region.countries.first;
    _loadNews();
    Timer.periodic(const Duration(minutes: 10), (_) => _loadNews());
  }

  @override
  void didUpdateWidget(covariant NewsRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.targetLanguage != widget.targetLanguage) {
      _retranslate();
    }
  }

  Future<void> _loadNews() async {
    if (!mounted) return;
    final myRequestId = ++_requestId;
    setState(() => _loading = true);
    try {
      final headlines = await widget.newsService.fetchHeadlines(_country, _category);
      if (myRequestId != _requestId || !mounted) return;
      _rawHeadlines = headlines;
      await _retranslate();
    } catch (e) {
      if (myRequestId != _requestId || !mounted) return;
      setState(() {
        _loading = false;
        _displayText = 'Could not load news for ${_country.name} right now.';
      });
    }
  }

  Future<void> _retranslate() async {
    if (_rawHeadlines.isEmpty || !mounted) return;
    final myRequestId = _requestId;
    try {
      final translated = await widget.translationService.translateAll(
        _rawHeadlines,
        _country.mlkitSourceLanguage,
        widget.targetLanguage.mlkitLanguage,
      );
      if (myRequestId != _requestId || !mounted) return;
      setState(() {
        _loading = false;
        _displayText = translated.join('     •     ');
      });
    } catch (e) {
      if (myRequestId != _requestId || !mounted) return;
      setState(() {
        _loading = false;
        _displayText = _rawHeadlines.join('     •     ');
      });
    }
  }

  void _onCountryChanged(Country? country) {
    if (country == null || country == _country) return;
    setState(() => _country = country);
    _loadNews();
  }

  void _onCategoryChanged(NewsCategory? category) {
    if (category == null || category == _category) return;
    setState(() => _category = category);
    _loadNews();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              SizedBox(
                width: 88,
                child: Text(
                  widget.region.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Expanded(
                child: DropdownButton<Country>(
                  isExpanded: true,
                  value: _country,
                  underline: const SizedBox.shrink(),
                  style: const TextStyle(fontSize: 12, color: Colors.black87),
                  items: widget.region.countries
                      .map((c) => DropdownMenuItem(
                            value: c,
                            child: Text('${c.name} (${c.localName})', overflow: TextOverflow.ellipsis),
                          ))
                      .toList(),
                  onChanged: _onCountryChanged,
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: DropdownButton<NewsCategory>(
                  isExpanded: true,
                  value: _category,
                  underline: const SizedBox.shrink(),
                  style: const TextStyle(fontSize: 12, color: Colors.black87),
                  items: NewsCategory.values
                      .map((c) => DropdownMenuItem(value: c, child: Text(c.label)))
                      .toList(),
                  onChanged: _onCategoryChanged,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh, size: 18),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: _loading ? null : _loadNews,
              ),
            ],
          ),
          const SizedBox(height: 4),
          SizedBox(
            height: 26,
            child: _loading && _rawHeadlines.isEmpty
                ? const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Loading...', style: TextStyle(fontSize: 13)),
                  )
                : Marquee(
                    key: ValueKey(_displayText),
                    text: _displayText,
                    style: const TextStyle(fontSize: 14),
                    scrollAxis: Axis.horizontal,
                    blankSpace: 60,
                    velocity: 40,
                    pauseAfterRound: const Duration(seconds: 1),
                    startPadding: 10,
                  ),
          ),
        ],
      ),
    );
  }
}
