import 'package:flutter/material.dart';

import '../data/regions_data.dart';
import '../models.dart';
import '../services/news_service.dart';
import '../services/translation_service.dart';
import '../widgets/news_row.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TargetLanguage _target = TargetLanguage.english;
  final _newsService = NewsService();
  final _translationService = TranslationService();

  @override
  void dispose() {
    _translationService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('World News Marquee'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Center(
              child: DropdownButton<TargetLanguage>(
                value: _target,
                dropdownColor: Theme.of(context).colorScheme.primary,
                style: const TextStyle(color: Colors.white),
                underline: const SizedBox.shrink(),
                items: TargetLanguage.values
                    .map((t) => DropdownMenuItem(value: t, child: Text(t.label)))
                    .toList(),
                onChanged: (t) {
                  if (t != null) setState(() => _target = t);
                },
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView.builder(
          itemCount: kRegions.length,
          itemBuilder: (context, index) => NewsRow(
            region: kRegions[index],
            targetLanguage: _target,
            newsService: _newsService,
            translationService: _translationService,
          ),
        ),
      ),
    );
  }
}
