import 'package:clipboard/clipboard.dart';

class ClipboardService {
  static Future<void> copyToClipboard(String text) async {
    await FlutterClipboard.copy(text);
  }

  static Future<String> getFromClipboard() async {
    return await FlutterClipboard.paste();
  }
}
