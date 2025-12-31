import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants.dart';
import '../models/mood_entry.dart';
import '../models/track.dart';

class StorageService {
  Future<void> setBool(String key, bool value) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setBool(key, value);
  }

  Future<bool> getBool(String key, {bool fallback = false}) async {
    final sp = await SharedPreferences.getInstance();
    return sp.getBool(key) ?? fallback;
  }

  Future<void> setString(String key, String value) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(key, value);
  }

  Future<String> getString(String key, {String fallback = ""}) async {
    final sp = await SharedPreferences.getInstance();
    return sp.getString(key) ?? fallback;
  }

  Future<void> setInt(String key, int value) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setInt(key, value);
  }

  Future<int> getInt(String key, {int fallback = 0}) async {
    final sp = await SharedPreferences.getInstance();
    return sp.getInt(key) ?? fallback;
  }

  Future<List<MoodEntry>> loadHistory() async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString(AppConstants.kHistory) ?? "[]";
    final list = (jsonDecode(raw) as List).cast<dynamic>();
    return list
        .map((e) => MoodEntry.fromJson((e as Map).cast<String, dynamic>()))
        .toList();
  }

  Future<void> saveHistory(List<MoodEntry> items) async {
    final sp = await SharedPreferences.getInstance();
    final raw = jsonEncode(items.map((e) => e.toJson()).toList());
    await sp.setString(AppConstants.kHistory, raw);
  }

  Future<void> cacheRecommendations(List<Track> tracks) async {
    final sp = await SharedPreferences.getInstance();
    final raw = jsonEncode(tracks.map((e) => e.toJson()).toList());
    await sp.setString(AppConstants.kCachedRecs, raw);
  }

  Future<List<Track>> loadCachedRecommendations() async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString(AppConstants.kCachedRecs);
    if (raw == null || raw.isEmpty) return [];
    final list = (jsonDecode(raw) as List).cast<dynamic>();
    return list
        .map((e) => Track.fromJson((e as Map).cast<String, dynamic>()))
        .toList();
  }
}
