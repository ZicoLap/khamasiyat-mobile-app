import 'package:flutter/services.dart';

/// Platform share. Injectable for tests.
class PitchShareActions {
  const PitchShareActions();

  static const _channel = MethodChannel('khamasiyat/share');

  Future<void> shareText(String text) async {
    try {
      await _channel.invokeMethod<void>('shareText', text);
    } on MissingPluginException {
      await Clipboard.setData(ClipboardData(text: text));
    }
  }
}
