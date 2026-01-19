import '../core/utils.dart';

class Track {
  final String id;
  final String name;
  final String artist;
  final String album;
  final String imageUrl;

  // ✅ Full stream url (Audius)
  final String streamUrl;

  // Link mở ngoài (Audius page)
  final String externalUrl;

  // nguồn: "audius"
  final String source;

  const Track({
    required this.id,
    required this.name,
    required this.artist,
    required this.album,
    required this.imageUrl,
    required this.streamUrl,
    required this.externalUrl,
    required this.source,
  });

  bool get canPlay => streamUrl.trim().isNotEmpty;

  Track copyWith({
    String? id,
    String? name,
    String? artist,
    String? album,
    String? imageUrl,
    String? streamUrl,
    String? externalUrl,
    String? source,
  }) {
    return Track(
      id: id ?? this.id,
      name: name ?? this.name,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      imageUrl: imageUrl ?? this.imageUrl,
      streamUrl: streamUrl ?? this.streamUrl,
      externalUrl: externalUrl ?? this.externalUrl,
      source: source ?? this.source,
    );
  }

  // ✅ Parse từ Audius track object
  factory Track.fromAudius(
    Map<String, dynamic> json, {
    required String host,
    required String appName,
  }) {
    final id = safeString(json["id"]);
    final title = safeString(json["title"]);
    final artist = safeString(json["user"]?["name"]);
    final album = safeString(json["playlist_name"]); // thường rỗng
    final artwork = (json["artwork"] as Map?)?.cast<String, dynamic>() ?? {};
    final imageUrl = safeString(artwork["480x480"]).isNotEmpty
        ? safeString(artwork["480x480"])
        : safeString(artwork["150x150"]);

    // stream endpoint (full)
    final streamUrl = Uri.https(Uri.parse(host).host, "/v1/tracks/$id/stream", {
      "app_name": appName,
    }).toString();

    // external (Audius web)
    final permalink = safeString(json["permalink"]);
    final externalUrl = permalink.isNotEmpty
        ? "https://audius.co$permalink"
        : "";

    return Track(
      id: id,
      name: title.isEmpty ? "Unknown" : title,
      artist: artist.isEmpty ? "Unknown" : artist,
      album: album,
      imageUrl: imageUrl,
      streamUrl: streamUrl,
      externalUrl: externalUrl,
      source: "audius",
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "artist": artist,
    "album": album,
    "imageUrl": imageUrl,
    "streamUrl": streamUrl,
    "externalUrl": externalUrl,
    "source": source,
  };

  factory Track.fromJson(Map<String, dynamic> json) => Track(
    id: safeString(json["id"]),
    name: safeString(json["name"]),
    artist: safeString(json["artist"]),
    album: safeString(json["album"]),
    imageUrl: safeString(json["imageUrl"]),
    streamUrl: safeString(json["streamUrl"]),
    externalUrl: safeString(json["externalUrl"]),
    source: safeString(json["source"], fallback: "audius"),
  );
}
