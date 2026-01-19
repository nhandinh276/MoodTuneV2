import '../core/http_client.dart';
import '../core/utils.dart';
import '../models/mood.dart';
import '../models/track.dart';

class AudiusService {
  final HttpClient http;
  AudiusService({required this.http});

  // bạn có thể đặt tên app bất kỳ (Audius yêu cầu app_name)
  static const String appName = "MoodTune";

  // fallback host nếu không lấy được danh sách
  static const String _fallbackHost = "https://discoveryprovider.audius.co";

  String _host = _fallbackHost;

  Future<void> bootstrap() async {
    // Audius: GET https://api.audius.co -> { data: [hosts...] }
    try {
      final uri = Uri.parse("https://api.audius.co");
      final json = await http.getJson(uri);
      final data = (json["data"] as List?) ?? [];
      if (data.isNotEmpty) {
        // chọn host đầu tiên
        _host = safeString(data.first);
        if (_host.isEmpty) _host = _fallbackHost;
      }
    } catch (_) {
      _host = _fallbackHost;
    }
  }

  String get host => _host;

  // mapping mood -> query/tag để search Audius
  String _moodQuery(MoodType mood) {
    switch (mood) {
      case MoodType.happy:
        return "happy upbeat pop";
      case MoodType.calm:
        return "chill calm ambient";
      case MoodType.sad:
        return "sad emotional piano";
      case MoodType.angry:
        return "angry rock metal";
      case MoodType.anxious:
        return "relax breathe calm";
      case MoodType.focus:
        return "focus study lofi";
      case MoodType.energetic:
        return "energetic edm dance";
      case MoodType.romantic:
        return "romantic love rnb";
      case MoodType.bored:
        return "party dance hits";
    }
  }

  Future<List<Track>> searchTracks(String query, {int limit = 20}) async {
    if (query.trim().isEmpty) return [];
    final uri = Uri.https(Uri.parse(_host).host, "/v1/tracks/search", {
      "query": query,
      "limit": limit.toString(),
      "app_name": appName,
    });

    final jsonAny = await http.getAnyJson(uri);
    final map = (jsonAny as Map).cast<String, dynamic>();
    final data = (map["data"] as List?) ?? [];

    final tracks = <Track>[];
    for (final item in data) {
      final t = Track.fromAudius(
        (item as Map).cast<String, dynamic>(),
        host: _host,
        appName: appName,
      );
      if (t.id.isNotEmpty) tracks.add(t);
    }

    // loại trùng
    final seen = <String>{};
    final out = <Track>[];
    for (final t in tracks) {
      if (seen.contains(t.id)) continue;
      seen.add(t.id);
      out.add(t);
    }
    return out;
  }

  Future<List<Track>> recommendByMood(MoodType mood, {int limit = 20}) async {
    final q = _moodQuery(mood);

    // cố gắng lấy nhiều hơn để có lựa chọn
    final list = await searchTracks(q, limit: 40);

    // lấy tối đa limit
    return list.take(limit).toList();
  }
}
