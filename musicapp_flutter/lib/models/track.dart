import 'package:hive/hive.dart';

part 'track.g.dart';

/// Represents a single song, mirroring the shape of the iTunes Search API
/// result (and, by extension, the Java backend's TrackDto). Used uniformly
/// for search results, favorites, playlist entries, recently-played items
/// and AI chat recommendations.
@HiveType(typeId: 0)
class Track extends HiveObject {
  @HiveField(0)
  final int trackId;

  @HiveField(1)
  final String? trackName;

  @HiveField(2)
  final String? artistName;

  @HiveField(3)
  final String? collectionName;

  /// Raw 100x100 artwork URL as returned by iTunes.
  @HiveField(4)
  final String? artworkUrl100;

  @HiveField(5)
  final String? previewUrl;

  @HiveField(6)
  final double? trackPrice;

  @HiveField(7)
  final double? collectionPrice;

  @HiveField(8)
  final String? currency;

  @HiveField(9)
  final String? primaryGenreName;

  @HiveField(10)
  final String? releaseDate;

  @HiveField(11)
  final int? trackTimeMillis;

  @HiveField(12)
  final String? trackViewUrl;

  @HiveField(13)
  final String? country;

  const Track({
    required this.trackId,
    this.trackName,
    this.artistName,
    this.collectionName,
    this.artworkUrl100,
    this.previewUrl,
    this.trackPrice,
    this.collectionPrice,
    this.currency,
    this.primaryGenreName,
    this.releaseDate,
    this.trackTimeMillis,
    this.trackViewUrl,
    this.country,
  });

  /// iTunes only gives 100x100 artwork by default; the web app upscales
  /// this to 600x600 by string-replacing the size segment of the URL.
  String? get artworkUrlHigh {
    if (artworkUrl100 == null) return null;
    return artworkUrl100!.replaceAll('100x100bb', '600x600bb');
  }

  bool get isPurchasable => trackPrice != null && trackPrice! > 0;

  double? get effectivePrice {
    if (trackPrice != null && trackPrice! > 0) return trackPrice;
    if (collectionPrice != null && collectionPrice! > 0) return collectionPrice;
    return null;
  }

  factory Track.fromJson(Map<String, dynamic> json) {
    return Track(
      trackId: (json['trackId'] as num).toInt(),
      trackName: json['trackName'] as String?,
      artistName: json['artistName'] as String?,
      collectionName: json['collectionName'] as String?,
      artworkUrl100: json['artworkUrl100'] as String?,
      previewUrl: json['previewUrl'] as String?,
      trackPrice: (json['trackPrice'] as num?)?.toDouble(),
      collectionPrice: (json['collectionPrice'] as num?)?.toDouble(),
      currency: json['currency'] as String?,
      primaryGenreName: json['primaryGenreName'] as String?,
      releaseDate: json['releaseDate'] as String?,
      trackTimeMillis: (json['trackTimeMillis'] as num?)?.toInt(),
      trackViewUrl: json['trackViewUrl'] as String?,
      country: json['country'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'trackId': trackId,
      'trackName': trackName,
      'artistName': artistName,
      'collectionName': collectionName,
      'artworkUrl100': artworkUrl100,
      'previewUrl': previewUrl,
      'trackPrice': trackPrice,
      'collectionPrice': collectionPrice,
      'currency': currency,
      'primaryGenreName': primaryGenreName,
      'releaseDate': releaseDate,
      'trackTimeMillis': trackTimeMillis,
      'trackViewUrl': trackViewUrl,
      'country': country,
    };
  }

  Track copyWith({String? previewUrl}) {
    return Track(
      trackId: trackId,
      trackName: trackName,
      artistName: artistName,
      collectionName: collectionName,
      artworkUrl100: artworkUrl100,
      previewUrl: previewUrl ?? this.previewUrl,
      trackPrice: trackPrice,
      collectionPrice: collectionPrice,
      currency: currency,
      primaryGenreName: primaryGenreName,
      releaseDate: releaseDate,
      trackTimeMillis: trackTimeMillis,
      trackViewUrl: trackViewUrl,
      country: country,
    );
  }

  @override
  bool operator ==(Object other) => other is Track && other.trackId == trackId;

  @override
  int get hashCode => trackId.hashCode;
}
