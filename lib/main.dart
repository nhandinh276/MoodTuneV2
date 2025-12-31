import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'state/app_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Ưu tiên assets/.env (đúng như Settings đang hướng dẫn)
  // ✅ Fallback sang ".env" nếu bạn để file ở root
  try {
    await dotenv.load(fileName: "assets/.env");
  } catch (_) {
    await dotenv.load(fileName: ".env");
  }

  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState()..bootstrap(),
      child: const MoodTuneApp(),
    ),
  );
}
