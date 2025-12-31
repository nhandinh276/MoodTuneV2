import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../ui/ui_components.dart';
import '../ui/ui_tokens.dart';
import '../ui/ui_styles.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text("Cài đặt")),
      body: ListView(
        padding: const EdgeInsets.all(UITokens.pad),
        children: [
          HeroHeader(
            title: "Cài đặt giao diện",
            subtitle: "Tuỳ chỉnh chế độ tối, theme theo mood và màu chủ đạo.",
            trailing: Icon(Icons.tune, color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 12),

          // ✅ Dark mode (Glass)
          GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
            child: SwitchListTile(
              value: app.isDarkMode,
              onChanged: (v) => context.read<AppState>().setDarkMode(v),
              title: Text(
                "Chế độ tối",
                style: UIStyles.body(
                  context,
                ).copyWith(fontWeight: FontWeight.w900),
              ),
              subtitle: Text(
                "Bật/tắt giao diện tối.",
                style: UIStyles.subtle(context),
              ),
              secondary: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: [
                      cs.primary.withOpacity(0.90),
                      cs.tertiary.withOpacity(0.90),
                    ],
                  ),
                ),
                child: const Icon(Icons.dark_mode, color: Colors.white),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // ✅ Auto theme by mood (Glass)
          GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
            child: SwitchListTile(
              value: app.autoThemeByMood,
              onChanged: (v) => context.read<AppState>().setAutoThemeByMood(v),
              title: Text(
                "Tự đổi theme theo mood",
                style: UIStyles.body(
                  context,
                ).copyWith(fontWeight: FontWeight.w900),
              ),
              subtitle: Text(
                "Mood khác nhau → màu chủ đạo khác nhau.",
                style: UIStyles.subtle(context),
              ),
              secondary: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: [
                      cs.secondary.withOpacity(0.90),
                      cs.primary.withOpacity(0.90),
                    ],
                  ),
                ),
                child: const Icon(Icons.palette_outlined, color: Colors.white),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // ✅ Accent picker (Glass)
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Chọn màu chủ đạo (thủ công)",
                  style: UIStyles.h2(context).copyWith(fontSize: 16),
                ),
                const SizedBox(height: 6),
                Text(
                  "Chạm để đổi màu theme. Nếu bật “Tự đổi theme theo mood”, màu sẽ ưu tiên theo mood.",
                  style: UIStyles.subtle(context),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _colorDot(
                      context,
                      const Color(0xFF00BCD4),
                      app.currentAccentColor,
                    ),
                    _colorDot(
                      context,
                      const Color(0xFFFFC107),
                      app.currentAccentColor,
                    ),
                    _colorDot(
                      context,
                      const Color(0xFFE91E63),
                      app.currentAccentColor,
                    ),
                    _colorDot(
                      context,
                      const Color(0xFF4CAF50),
                      app.currentAccentColor,
                    ),
                    _colorDot(
                      context,
                      const Color(0xFF3F51B5),
                      app.currentAccentColor,
                    ),
                    _colorDot(
                      context,
                      const Color(0xFFF44336),
                      app.currentAccentColor,
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ✅ API note (Glass)
          GlassCard(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: cs.surfaceContainerHighest.withOpacity(0.65),
                  ),
                  child: Icon(Icons.info_outline, color: cs.onSurfaceVariant),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Lưu ý API",
                        style: UIStyles.body(
                          context,
                        ).copyWith(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Tạo file: assets/.env (khuyến nghị)\n"
                        "và điền:\n"
                        "• SPOTIFY_CLIENT_ID\n"
                        "• SPOTIFY_CLIENT_SECRET\n"
                        "• OPENAI_API_KEY\n\n"
                        "Gợi ý: Bạn có thể dùng .env ở root, app sẽ tự fallback.",
                        style: UIStyles.subtle(context),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          Text(
            "MoodTune AI • Glass Gradient UI",
            style: UIStyles.subtle(context),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _colorDot(BuildContext context, Color c, Color current) {
    final cs = Theme.of(context).colorScheme;
    final selected = c.value == current.value;

    return InkWell(
      onTap: () => context.read<AppState>().setAccent(c),
      borderRadius: BorderRadius.circular(999),
      child: AnimatedContainer(
        duration: UITokens.normal,
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: c,
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? cs.onSurface : cs.outlineVariant,
            width: selected ? 2.2 : 1.2,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                    color: c.withOpacity(0.35),
                  ),
                ]
              : null,
        ),
        child: selected
            ? const Icon(Icons.check, color: Colors.white)
            : const SizedBox.shrink(),
      ),
    );
  }
}
