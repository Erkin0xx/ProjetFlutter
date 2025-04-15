import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class SpotifyApi {
  static String _clientId = dotenv.env['SPOTIFY_CLIENT_ID'] ?? '';
  static String _clientSecret = dotenv.env['SPOTIFY_CLIENT_SECRET'] ?? '';
  static String _token = '';

  static Future<void> authenticate() async {
    final credentials = base64.encode(utf8.encode('$_clientId:$_clientSecret'));

    final response = await http.post(
      Uri.parse('https://accounts.spotify.com/api/token'),
      headers: {
        'Authorization': 'Basic $credentials',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {'grant_type': 'client_credentials'},
    );

    if (response.statusCode != 200) {
      throw Exception('Erreur authentification Spotify');
    }

    final data = json.decode(response.body);
    _token = data['access_token'];
  }

  static Future<List<Map<String, String>>> searchTracks(String query) async {
    if (_token.isEmpty) await authenticate();

    final uri = Uri.parse(
        'https://api.spotify.com/v1/search?q=$query&type=track&limit=10');

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $_token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Erreur lors de la recherche Spotify');
    }

    final data = json.decode(response.body);
    final List<dynamic> items = data['tracks']['items'];

    return items.map<Map<String, String>>((track) {
      final map = track as Map<String, dynamic>;

      return {
        'name': map['name'] ?? 'Inconnu',
        'artist': (map['artists']?[0]?['name']) ?? 'Inconnu',
        'previewUrl': map['preview_url'] ?? '',
        'image': (map['album']?['images']?[0]?['url']) ?? '',
      };
    }).toList();
  }
}
