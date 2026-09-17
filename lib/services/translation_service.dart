import 'package:google_mlkit_translation/google_mlkit_translation.dart';

/// Wraps ML Kit's on-device translator. Models are downloaded once per
/// language (small, a few dozen MB) and then translation runs fully offline.
class TranslationService {
  final _modelManager = OnDeviceTranslatorModelManager();
  final Map<String, OnDeviceTranslator> _translators = {};

  Future<void> _ensureModelsDownloaded(List<TranslateLanguage> languages) async {
    for (final lang in languages) {
      final downloaded = await _modelManager.isModelDownloaded(lang.bcpCode);
      if (!downloaded) {
        await _modelManager.downloadModel(lang.bcpCode, isWifiRequired: false);
      }
    }
  }

  Future<List<String>> translateAll(
    List<String> texts,
    TranslateLanguage source,
    TranslateLanguage target,
  ) async {
    if (source == target) return texts;

    final key = '${source.bcpCode}->${target.bcpCode}';
    var translator = _translators[key];
    if (translator == null) {
      await _ensureModelsDownloaded([source, target]);
      translator = OnDeviceTranslator(sourceLanguage: source, targetLanguage: target);
      _translators[key] = translator;
    }

    final results = <String>[];
    for (final text in texts) {
      try {
        results.add(await translator.translateText(text));
      } catch (_) {
        results.add(text); // fall back to original text if translation fails
      }
    }
    return results;
  }

  Future<void> dispose() async {
    for (final t in _translators.values) {
      await t.close();
    }
    _translators.clear();
  }
}
