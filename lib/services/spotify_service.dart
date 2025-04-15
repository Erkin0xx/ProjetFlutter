import 'package:spotify/spotify.dart';
import 'spotify_config.dart';

class SpotifyService {
  static late final SpotifyApi spotify;

  static Future<void> init() async {
    final credentials = SpotifyApiCredentials(
      SpotifyConfig.clientId,
      SpotifyConfig.clientSecret,
    );

    spotify = SpotifyApi(credentials);
  }
}
