import 'package:flutter_dotenv/flutter_dotenv.dart';

class SpotifyConfig {
  static String get clientId => dotenv.env['SPOTIFY_CLIENT_ID'] ?? '';
  static String get clientSecret => dotenv.env['SPOTIFY_CLIENT_SECRET'] ?? '';
  static String get redirectUri => dotenv.env['SPOTIFY_REDIRECT_URI'] ?? '';
}
