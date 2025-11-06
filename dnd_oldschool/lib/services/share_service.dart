import 'package:share_plus/share_plus.dart';

class ShareService {
  static Future<void> shareContent({
    required String text,
    String? subject,
  }) async {
    try {
      await Share.share(
        text,
        subject: subject,
      );
    } catch (e) {
      throw Exception('Error sharing content: $e');
    }
  }
}