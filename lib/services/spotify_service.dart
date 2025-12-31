// lib/services/spotify_service.dart
import '../models/mood.dart';
import '../models/track.dart';
import '../core/constants.dart';
import '../core/http_client.dart';
import '../core/utils.dart';
import 'spotify_auth_service.dart';

class SpotifyService {
  final SpotifyAuthService auth;
  final HttpClient http;

  SpotifyService({required this.auth, required this.http});

  static const List<String> _safeSeeds = [
    "pop",
    "dance",
    "edm",
    "rock",
    "metal",
    "punk",
    "hip-hop",
    "r-n-b",
    "soul",
    "indie",
    "acoustic",
    "ambient",
    "chill",
    "piano",
    "classical",
    "jazz",
    "blues",
    "reggae",
    "latin",
    "k-pop",
    "j-pop",
  ];

  Map<String, dynamic> _moodProfile(MoodType mood, {bool timeBoost = false}) {
    double energy = 0.5;
    double valence = 0.5;
    List<String> genres = const ["pop", "dance", "indie"];

    switch (mood) {
      case MoodType.happy:
        energy = 0.75;
        valence = 0.85;
        genres = const ["pop", "dance", "edm"];
        break;
      case MoodType.calm:
        energy = 0.25;
        valence = 0.60;
        genres = const ["ambient", "acoustic", "chill"];
        break;
      case MoodType.sad:
        energy = 0.25;
        valence = 0.25;
        genres = const ["piano", "acoustic", "indie"];
        break;
      case MoodType.angry:
        energy = 0.85;
        valence = 0.25;
        genres = const ["rock", "metal", "punk"];
        break;
      case MoodType.anxious:
        energy = 0.35;
        valence = 0.40;
        genres = const ["ambient", "chill", "acoustic"];
        break;
      case MoodType.focus:
        energy = 0.40;
        valence = 0.55;
        genres = const ["classical", "ambient", "piano"];
        break;
      case MoodType.energetic:
        energy = 0.90;
        valence = 0.75;
        genres = const ["edm", "dance", "pop"];
        break;
      case MoodType.romantic:
        energy = 0.45;
        valence = 0.75;
        genres = const ["r-n-b", "soul", "indie"];
        break;
      case MoodType.nostalgic:
        energy = 0.35;
        valence = 0.55;
        genres = const ["indie", "acoustic", "jazz"];
        break;
      case MoodType.bored:
        energy = 0.70;
        valence = 0.65;
        genres = const ["pop", "dance", "hip-hop"];
        break;
    }

    if (timeBoost) {
      final hour = DateTime.now().hour;
      if (hour >= 5 && hour < 11) {
        energy = clamp01(energy + 0.1);
        valence = clamp01(valence + 0.05);
      } else if (hour >= 22 || hour < 5) {
        energy = clamp01(energy - 0.1);
      }
    }

    final filtered = genres.where((g) => _safeSeeds.contains(g)).toList();
    genres = filtered.isEmpty ? const ["pop", "dance", "indie"] : filtered;

    return {"energy": energy, "valence": valence, "genres": genres};
  }

  /// ✅ Loại trùng theo id, đồng thời ưu tiên bài có preview_url lên đầu
  List<Track> _dedupeAndPreferPlayable(List<Track> input, int max) {
    final seen = <String>{};
    final playable = <Track>[];
    final nonPlayable = <Track>[];

    for (final t in input) {
      if (t.id.isEmpty) continue;
      if (seen.contains(t.id)) continue;
      seen.add(t.id);

      if (t.previewUrl.trim().isNotEmpty) {
        playable.add(t);
      } else {
        nonPlayable.add(t);
      }
    }

    final merged = <Track>[...playable, ...nonPlayable];
    return merged.take(max).toList();
  }

  void _merge(List<Track> base, List<Track> extra, int max) {
    final seen = base.map((e) => e.id).toSet();
    for (final t in extra) {
      if (base.length >= max) break;
      if (t.id.isEmpty) continue;
      if (seen.contains(t.id)) continue;
      seen.add(t.id);
      base.add(t);
    }
  }

  Future<List<Track>> recommendByMood(
    MoodType mood, {
    bool timeBoost = true,
  }) async {
    final token = await auth.getValidAccessToken();
    final profile = _moodProfile(mood, timeBoost: timeBoost);

    final genres = (profile["genres"] as List<String>).take(3).toList();
    final energy = profile["energy"] as double;
    final valence = profile["valence"] as double;

    final need = AppConstants.maxTracks;
    final raw = <Track>[];

    // 1) Try recommendations (lấy nhiều hơn để có cơ hội có preview)
    final recUri = Uri.https("api.spotify.com", "/v1/recommendations", {
      "limit": "50",
      "seed_genres": genres.join(","),
      "market": "US",
      "target_energy": energy.toStringAsFixed(2),
      "target_valence": valence.toStringAsFixed(2),
    });

    try {
      final json = await http.getJson(
        recUri,
        headers: {"Authorization": "Bearer $token"},
      );
      final tracksJson = (json["tracks"] as List?) ?? [];
      final tracks = tracksJson
          .map((e) => Track.fromSpotify((e as Map).cast<String, dynamic>()))
          .toList();
      raw.addAll(tracks);
    } catch (_) {
      // ignore -> fallback search
    }

    // 2) fallback search (để luôn có danh sách)
    final moodLabel = Mood.byType(mood).label;
    final queries = <String>[
      "$moodLabel music",
      "${genres.first} music",
      "$moodLabel ${genres.first}",
      "$moodLabel acoustic",
      "$moodLabel chill",
      "top hits",
      "today hits",
    ];

    for (final q in queries) {
      if (raw.length >= 120) break; // giới hạn tránh gọi quá nhiều
      try {
        final extra = await searchTracks(q, limit: 50);
        _merge(raw, extra, 200);
      } catch (_) {
        // bỏ qua query lỗi
      }
    }

    // ✅ Quan trọng: KHÔNG lọc bỏ bài không preview.
    // -> Ưu tiên preview trước để nghe trong app,
    // -> Bài không preview vẫn hiện để người dùng bấm “Mở Spotify”.
    final finalList = _dedupeAndPreferPlayable(raw, need);

    return finalList;
  }

  Future<List<Track>> searchTracks(String query, {int limit = 20}) async {
    final token = await auth.getValidAccessToken();

    final uri = Uri.https("api.spotify.com", "/v1/search", {
      "q": query,
      "type": "track",
      "limit": limit.toString(),
      "market": "US",
    });

    final json = await http.getJson(
      uri,
      headers: {"Authorization": "Bearer $token"},
    );
    final items = (((json["tracks"] as Map?)?["items"]) as List?) ?? [];

    return items
        .map((e) => Track.fromSpotify((e as Map).cast<String, dynamic>()))
        .toList();
  }

  /// ✅ Tìm 1 track có preview gần giống (cùng tên / artist)
  Future<Track?> findPlayableAlternative(Track original) async {
    final q = "${original.name} ${original.artist}".trim();
    final list = await searchTracks(q, limit: 50);

    // Ưu tiên bài có preview
    for (final t in list) {
      if (t.previewUrl.trim().isNotEmpty) return t;
    }
    return null;
  }
}
