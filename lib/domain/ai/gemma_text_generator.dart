import 'package:flutter_gemma/flutter_gemma.dart';

import 'llm_text_generator.dart';

/// On-device [LlmTextGenerator] backed by `flutter_gemma` (Gemma 3 1B).
///
/// The model file (~550 MB) is downloaded once from Hugging Face on first use
/// and cached on the device. After that it runs fully offline — no API key, no
/// per-message cost. Downloading a gated Gemma model needs a FREE Hugging Face
/// token (just to accept Google's licence); pass it at build time with
/// `--dart-define=HUGGINGFACE_TOKEN=hf_xxx`. The token is only used for the
/// one-time download, never at inference time.
class GemmaTextGenerator implements LlmTextGenerator {
  GemmaTextGenerator({
    this.modelUrl = _defaultModelUrl,
    this.huggingFaceToken =
        const String.fromEnvironment('HUGGINGFACE_TOKEN'),
    this.maxTokens = 1024,
  });

  /// Gemma 3 1B (instruction-tuned, 4-bit) — the smallest, fastest Gemma.
  static const String _defaultModelUrl =
      'https://huggingface.co/litert-community/Gemma3-1B-IT/resolve/main/'
      'Gemma3-1B-IT_multi-prefill-seq_q4_ekv4096.litertlm';

  final String modelUrl;
  final String huggingFaceToken;
  final int maxTokens;

  InferenceModel? _model;
  bool _installed = false;

  /// Downloads + installs the model if it isn't already on the device. Surface
  /// [onProgress] (0–100) in a download UI. Safe to call repeatedly.
  Future<void> ensureInstalled({void Function(int percent)? onProgress}) async {
    if (_installed) return;
    await FlutterGemma.installModel(modelType: ModelType.gemmaIt)
        .fromNetwork(modelUrl, token: huggingFaceToken)
        .withProgress((percent) => onProgress?.call(percent))
        .install();
    _installed = true;
  }

  /// Loads the model into memory (after install). Called lazily by [generate].
  Future<void> warmUp() async {
    await ensureInstalled();
    _model ??= await FlutterGemma.getActiveModel(
      maxTokens: maxTokens,
      preferredBackend: PreferredBackend.gpu,
    );
  }

  @override
  Future<bool> isReady() async => _installed && _model != null;

  @override
  Future<String> generate(String prompt, {String? systemInstruction}) async {
    await warmUp();
    final chat = await _model!.createChat(
      systemInstruction: systemInstruction,
    );
    await chat.addQueryChunk(Message.text(text: prompt, isUser: true));
    final response = await chat.generateChatResponse();
    // Sync responses come back as a TextResponse for normal text generation.
    return response is TextResponse ? response.token : '';
  }

  Future<void> dispose() async {
    await _model?.close();
    _model = null;
  }
}
