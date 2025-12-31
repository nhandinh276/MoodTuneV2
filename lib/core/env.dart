import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  static String get spotifyClientId => dotenv.env['SPOTIFY_CLIENT_ID'] ?? '';

  static String get spotifyClientSecret =>
      dotenv.env['SPOTIFY_CLIENT_SECRET'] ?? '';

  static String get openAiApiKey => dotenv.env['OPENAI_API_KEY'] ?? '';
}
