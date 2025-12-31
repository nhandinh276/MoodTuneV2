import '../core/utils.dart';

class Track {
  final String id;
  final String name;
  final String artist;
  final String album;
  final String imageUrl;
  final String previewUrl;
  final String externalUrl;

  const Track({
    required this.id,
    required this.name,
    required this.artist,
    required this.album,
    required this.imageUrl,
    required this.previewUrl,
    required this.externalUrl,
  });

  bool get hasPreview => previewUrl.trim().isNotEmpty;

  Track copyWith({
    String? id,
    String? name,
    String? artist,
    String? album,
    String? imageUrl,
    String? previewUrl,
    String? externalUrl,
  }) {
    return Track(
      id: id ?? this.id,
      name: name ?? this.name,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      imageUrl: imageUrl ?? this.imageUrl,
      previewUrl: previewUrl ?? this.previewUrl,
      externalUrl: externalUrl ?? this.externalUrl,
    );
  }

  factory Track.fromSpotify(Map<String, dynamic> json) {
    final id = safeString(json['id']);
    final name = safeString(json['name']);
    final artists = (json['artists'] as List?) ?? [];
    final artist = artists.isNotEmpty
        ? safeString((artists.first as Map)['name'])
        : "Unknown";
    final albumObj = (json['album'] as Map?)?.cast<String, dynamic>() ?? {};
    final album = safeString(albumObj['name']);
    final images = (albumObj['images'] as List?) ?? [];
    final imageUrl = images.isNotEmpty
        ? safeString((images.first as Map)['url'])
        : "";
    final previewUrl = safeString(json['preview_url']);
    final externalUrl = safeString((json['external_urls'] as Map?)?['spotify']);

    return Track(
      id: id,
      name: name,
      artist: artist,
      album: album,
      imageUrl: imageUrl,
      previewUrl: previewUrl,
      externalUrl: externalUrl,
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "artist": artist,
    "album": album,
    "imageUrl": imageUrl,
    "previewUrl": previewUrl,
    "externalUrl": externalUrl,
  };

  factory Track.fromJson(Map<String, dynamic> json) => Track(
    id: safeString(json["id"]),
    name: safeString(json["name"]),
    artist: safeString(json["artist"]),
    album: safeString(json["album"]),
    imageUrl: safeString(json["imageUrl"]),
    previewUrl: safeString(json["previewUrl"]),
    externalUrl: safeString(json["externalUrl"]),
  );
}
