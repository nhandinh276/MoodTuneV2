import 'dart:convert';

String base64BasicAuth(String clientId, String clientSecret) {
  final raw = "$clientId:$clientSecret";
  return base64Encode(utf8.encode(raw));
}

double clamp01(double v) {
  if (v < 0) return 0;
  if (v > 1) return 1;
  return v;
}

String safeString(dynamic v, {String fallback = ""}) {
  if (v == null) return fallback;
  if (v is String) return v;
  return v.toString();
}
