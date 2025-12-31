import '../core/http_client.dart';
import '../core/utils.dart';

class PreviewService {
  final HttpClient http;
  PreviewService({required this.http});

  /// ✅ Fallback preview 30s từ Deezer (thường có preview mp3).
  /// Trả về url mp3 preview hoặc null nếu không tìm thấy.
  Future<String?> findDeezerPreviewUrl({
    required String trackName,
    required String artistName,
  }) async {
    final q = 'track:"$trackName" artist:"$artistName"';

    final uri = Uri.https("api.deezer.com", "/search", {"q": q, "limit": "10"});

    try {
      final json = await http.getJson(uri);
      final data = (json["data"] as List?) ?? [];
      if (data.isEmpty) return null;

      // Deezer trả về: data[i].preview
      for (final item in data) {
        final map = (item as Map).cast<String, dynamic>();
        final preview = safeString(map["preview"]);
        if (preview.trim().isNotEmpty) return preview;
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
