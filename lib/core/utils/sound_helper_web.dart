// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;
import 'dart:js' as js;
import 'package:flutter/foundation.dart';

class SoundPlatform {
  static html.SpeechSynthesis? get _synth => html.window.speechSynthesis;
  static html.SpeechRecognition? _recognition;
  static bool _isSpeaking = false;
  static bool _isListening = false;

  static bool get isSpeaking => _isSpeaking;
  static bool get isListening => _isListening;
  static bool get isSpeechRecognitionSupported => html.SpeechRecognition.supported;

  static String _cleanTextForSpeech(String raw) {
    var text = raw;
    // Remove markdown table divider lines |---|---|
    text = text.replaceAll(RegExp(r'\|[\s\-:]+\|\n?'), ' ');
    // Remove table pipes |
    text = text.replaceAll('|', ', ');
    // Remove markdown headers ###, ##, #
    text = text.replaceAll(RegExp(r'#+\s*'), '');
    // Remove bold/italics ** or *
    text = text.replaceAll(RegExp(r'\*+'), '');
    // Remove code blocks
    text = text.replaceAll(RegExp(r'`+.*?`+'), '');
    // Remove LaTeX math $$...$$ and $...$
    text = text.replaceAll(RegExp(r'\$\$.*?\$\$'), '');
    text = text.replaceAll(RegExp(r'\$.*?\$'), '');
    // Replace multiple spaces/newlines
    text = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    return text;
  }

  static void speak(String text, {VoidCallback? onDone, VoidCallback? onError}) {
    if (_synth == null) {
      onError?.call();
      return;
    }
    stopSpeaking();

    final clean = _cleanTextForSpeech(text);
    if (clean.isEmpty) {
      onDone?.call();
      return;
    }

    try {
      final utterance = html.SpeechSynthesisUtterance(clean);
      utterance.lang = 'en-US';
      utterance.rate = 1.05;
      utterance.pitch = 1.0;

      utterance.onEnd.listen((_) {
        _isSpeaking = false;
        onDone?.call();
      });
      utterance.onError.listen((_) {
        _isSpeaking = false;
        onError?.call();
      });

      _isSpeaking = true;
      _synth!.speak(utterance);
    } catch (e) {
      _isSpeaking = false;
      onError?.call();
    }
  }

  static void stopSpeaking() {
    try {
      if (_synth != null && (_synth!.speaking ?? false)) {
        _synth!.cancel();
      }
    } catch (_) {}
    _isSpeaking = false;
  }

  static void playChime({bool isAlert = false}) {
    try {
      final code = '''
        (function() {
          try {
            var AudioCtx = window.AudioContext || window.webkitAudioContext;
            if (!AudioCtx) return;
            var ctx = new AudioCtx();
            var now = ctx.currentTime;
            var osc = ctx.createOscillator();
            var gain = ctx.createGain();
            osc.type = ${isAlert ? "'sawtooth'" : "'sine'"};
            osc.frequency.value = ${isAlert ? 440 : 880};
            gain.gain.setValueAtTime(0.08, now);
            gain.gain.exponentialRampToValueAtTime(0.001, now + ${isAlert ? 0.35 : 0.18});
            osc.connect(gain);
            gain.connect(ctx.destination);
            osc.start(now);
            osc.stop(now + ${isAlert ? 0.35 : 0.18});
          } catch(e) {}
        })();
      ''';
      js.context.callMethod('eval', [code]);
    } catch (_) {}
  }

  static void startListening({
    required Function(String text) onResult,
    required VoidCallback onDone,
    VoidCallback? onError,
  }) {
    if (!html.SpeechRecognition.supported) {
      onError?.call();
      return;
    }
    stopListening();

    try {
      final rec = html.SpeechRecognition();
      rec.continuous = false;
      rec.interimResults = true;
      rec.lang = 'en-US';

      rec.onResult.listen((event) {
        final results = event.results;
        if (results != null && results.isNotEmpty) {
          final firstResult = results[0];
          if ((firstResult.length ?? 0) > 0) {
            final transcript = firstResult.item(0).transcript;
            if (transcript != null && transcript.trim().isNotEmpty) {
              onResult(transcript.trim());
            }
          }
        }
      });

      rec.onEnd.listen((_) {
        _isListening = false;
        onDone();
      });

      rec.onError.listen((_) {
        _isListening = false;
        onError?.call();
      });

      _recognition = rec;
      _isListening = true;
      rec.start();
    } catch (e) {
      _isListening = false;
      onError?.call();
    }
  }

  static void stopListening() {
    try {
      if (_recognition != null) {
        _recognition!.stop();
      }
    } catch (_) {}
    _isListening = false;
  }
}
