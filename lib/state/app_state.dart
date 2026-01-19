import 'dart:math';
import 'package:flutter/material.dart';
import '../core/date_utils.dart';

import '../core/constants.dart';
import '../models/mood.dart';
import '../models/mood_analysis.dart';
import '../models/mood_entry.dart';
import '../models/track.dart';
import '../services/community_service.dart';
import '../services/openai_service.dart';
import '../services/storage_service.dart';
import '../core/http_client.dart';

// ✅ NEW
import '../services/audius_service.dart';

class AppState extends ChangeNotifier {
  final storage = StorageService();
  final openai = OpenAIService();
  final community = CommunityService();

  // ✅ NEW: Audius music provider
  late final audius = AudiusService(http: HttpClient());

  bool isBootstrapped = false;

  bool isDarkMode = false;
  bool autoThemeByMood = true;

  Color currentAccentColor = const Color(0xFF00BCD4);

  MoodType? selectedMood;
  MoodAnalysis? lastAnalysis;

  List<Track> recommendations = [];
  List<MoodEntry> history = [];

  bool loading = false;
  String? error;

  Future<void> bootstrap() async {
    isDarkMode = await storage.getBool(AppConstants.kDarkMode, fallback: false);
    autoThemeByMood = await storage.getBool(
      AppConstants.kAutoThemeByMood,
      fallback: true,
    );

    final accentRaw = await storage.getInt(
      AppConstants.kLastAccent,
      fallback: currentAccentColor.value,
    );
    currentAccentColor = Color(accentRaw);

    history = await storage.loadHistory();

    // load cached recommendations for offline
    final cached = await storage.loadCachedRecommendations();
    if (cached.isNotEmpty) {
      recommendations = cached;
    }

    // ✅ bootstrap Audius host
    await audius.bootstrap();

    isBootstrapped = true;
    notifyListeners();
  }

  Future<void> setDarkMode(bool v) async {
    isDarkMode = v;
    await storage.setBool(AppConstants.kDarkMode, v);
    notifyListeners();
  }

  Future<void> setAutoThemeByMood(bool v) async {
    autoThemeByMood = v;
    await storage.setBool(AppConstants.kAutoThemeByMood, v);
    notifyListeners();
  }

  Future<void> setAccent(Color c) async {
    currentAccentColor = c;
    await storage.setInt(AppConstants.kLastAccent, c.value);
    notifyListeners();
  }

  void _applyMoodThemeIfEnabled(MoodType mood) {
    if (!autoThemeByMood) return;
    final m = Mood.byType(mood);
    currentAccentColor = m.color;
  }

  // 1 track for today
  Track? getTodayPick() {
    if (recommendations.isEmpty) return null;
    final today = formatDateKey(DateTime.now());
    final seed = today.codeUnits.fold<int>(0, (p, c) => p + c);
    final idx = seed % recommendations.length;
    return recommendations[idx];
  }

  MoodType moodFromQuiz({
    required int energyChoice,
    required int vibeChoice,
    required int socialChoice,
  }) {
    if (energyChoice == 2 && vibeChoice == 2) return MoodType.energetic;
    if (energyChoice == 0 && vibeChoice == 0) return MoodType.calm;
    if (vibeChoice == 0 && socialChoice == 0) return MoodType.sad;
    if (vibeChoice == 2 && socialChoice == 2) return MoodType.happy;
    if (energyChoice == 1 && vibeChoice == 1) return MoodType.focus;
    return MoodType.anxious;
  }

  Future<void> recommendFromMood(MoodType mood) async {
    selectedMood = mood;
    lastAnalysis = MoodAnalysis(
      mood: mood,
      valence: 0.5,
      energy: 0.5,
      tags: const ["mood-picker"],
      activity: "Nghe 1 bài và hít thở sâu 3 lần.",
      summary: "Gợi ý nhạc dựa trên cảm xúc bạn chọn.",
    );

    _applyMoodThemeIfEnabled(mood);
    await setAccent(currentAccentColor);

    await _loadRecommendationsByMood(mood);
  }

  Future<void> recommendFromText(String text) async {
    _setLoading(true);
    error = null;
    try {
      final analysis = await openai.analyzeMoodFromText(text);
      selectedMood = analysis.mood;
      lastAnalysis = analysis;

      _applyMoodThemeIfEnabled(analysis.mood);
      await setAccent(currentAccentColor);

      await _loadRecommendationsByMood(analysis.mood);

      // nếu AI có tags -> search thêm trên Audius
      if (analysis.tags.isNotEmpty && recommendations.length < 10) {
        final q = analysis.tags.take(3).join(" ");
        final extra = await audius.searchTracks(q, limit: 20);

        final merged = [...recommendations];
        for (final t in extra) {
          if (!merged.any((x) => x.id == t.id)) merged.add(t);
          if (merged.length >= AppConstants.maxTracks) break;
        }
        recommendations = merged;
        await storage.cacheRecommendations(recommendations);
      }
    } catch (e) {
      error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _loadRecommendationsByMood(MoodType mood) async {
    _setLoading(true);
    error = null;
    try {
      final tracks = await audius.recommendByMood(
        mood,
        limit: AppConstants.maxTracks,
      );

      recommendations = tracks;
      await storage.cacheRecommendations(tracks);
    } catch (e) {
      error = e.toString();

      final cached = await storage.loadCachedRecommendations();
      if (cached.isNotEmpty) {
        recommendations = cached;
      }
    } finally {
      _setLoading(false);
    }
  }

  Future<void> saveToHistory({
    required Track track,
    required String note,
  }) async {
    final mood = selectedMood ?? MoodType.calm;
    final analysis =
        lastAnalysis ??
        MoodAnalysis(
          mood: mood,
          valence: 0.5,
          energy: 0.5,
          tags: const [],
          activity: "Uống nước.",
          summary: "Lưu từ chế độ mood.",
        );

    final entry = MoodEntry(
      id: "${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(9999)}",
      createdAt: DateTime.now(),
      mood: mood.name,
      note: note,
      analysis: analysis.toJson(),
      track: track,
    );

    history = [entry, ...history];
    await storage.saveHistory(history);
    notifyListeners();
  }

  Future<void> deleteHistory(String id) async {
    history = history.where((e) => e.id != id).toList();
    await storage.saveHistory(history);
    notifyListeners();
  }

  Future<void> shareAnonymous({
    required Track track,
    required String caption,
  }) async {
    final mood = selectedMood ?? MoodType.calm;
    final title = "Mood: ${mood.name} • ${track.name}";
    final body =
        "Artist: ${track.artist}\nCaption: $caption\nLink: ${track.externalUrl}";
    await community.postAnonymous(title: title, body: body);
  }

  void _setLoading(bool v) {
    loading = v;
    notifyListeners();
  }
}
