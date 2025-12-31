import 'dart:convert';
import 'package:http/http.dart' as http;

import '../core/env.dart';
import '../core/utils.dart';
import '../core/constants.dart';
import 'storage_service.dart';

class SpotifyAuthService {
  final StorageService storage;

  SpotifyAuthService(this.storage);

  Future<String> getValidAccessToken() async {
    final cached = await storage.getString(AppConstants.kSpotifyToken);
    final expiresAt = await storage.getInt(AppConstants.kSpotifyTokenExpiresAt);

    final now = DateTime.now().millisecondsSinceEpoch;
    if (cached.isNotEmpty && expiresAt > now + 30 * 1000) {
      return cached;
    }

    final clientId = Env.spotifyClientId;
    final clientSecret = Env.spotifyClientSecret;
    if (clientId.isEmpty || clientSecret.isEmpty) {
      throw Exception(
        "Missing SPOTIFY_CLIENT_ID / SPOTIFY_CLIENT_SECRET in .env",
      );
    }

    final basic = base64BasicAuth(clientId, clientSecret);

    final res = await http.post(
      Uri.parse("https://accounts.spotify.com/api/token"),
      headers: {
        "Authorization": "Basic $basic",
        "Content-Type": "application/x-www-form-urlencoded",
      },
      body: "grant_type=client_credentials",
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception("Spotify token error: ${res.statusCode} - ${res.body}");
    }

    final json = jsonDecode(res.body) as Map<String, dynamic>;
    final token = safeString(json["access_token"]);
    final expiresIn = (json["expires_in"] is num)
        ? (json["expires_in"] as num).toInt()
        : 3600;
    final expAt = DateTime.now().millisecondsSinceEpoch + expiresIn * 1000;

    await storage.setString(AppConstants.kSpotifyToken, token);
    await storage.setInt(AppConstants.kSpotifyTokenExpiresAt, expAt);

    return token;
  }
}
