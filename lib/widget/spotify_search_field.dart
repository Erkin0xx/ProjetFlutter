import 'package:flutter/material.dart';
import '../services/spotify_api.dart';

class SpotifySearchField extends StatefulWidget {
  final Function(Map<String, String>) onTrackSelected;

  const SpotifySearchField({super.key, required this.onTrackSelected});

  @override
  State<SpotifySearchField> createState() => _SpotifySearchFieldState();
}

class _SpotifySearchFieldState extends State<SpotifySearchField> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, String>> _results = [];
  Map<String, String>? _selectedTrack;
  bool _isSearching = false;

  Future<void> _search(String query) async {
    if (query.trim().length < 2) return;

    setState(() => _isSearching = true);
    final results = await SpotifyApi.searchTracks(query);
    setState(() {
      _results = results.take(6).toList();
      _isSearching = false;
    });
  }

  void _selectTrack(Map<String, String> track) {
    setState(() {
      _selectedTrack = track;
      _controller.text = "${track['name']} — ${track['artist']}";
      _results.clear();
    });
    widget.onTrackSelected(track);
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? Colors.grey[900] : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          alignment: Alignment.centerRight,
          children: [
            TextField(
              controller: _controller,
              onChanged: (text) {
                setState(() => _selectedTrack = null); // reset track
                _search(text);
              },
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                hintText: "Rechercher un morceau",
                hintStyle: TextStyle(color: Colors.grey[500]),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: bgColor,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade700),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade700),
                ),
              ),
            ),
            if (_selectedTrack != null &&
                _selectedTrack!['image'] != null &&
                _selectedTrack!['image']!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.network(
                    _selectedTrack!['image']!,
                    width: 38,
                    height: 38,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (_isSearching)
          const Center(child: CircularProgressIndicator())
        else if (_results.isNotEmpty)
          Container(
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[850] : Colors.grey[100],
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _results.length,
              itemBuilder: (context, index) {
                final track = _results[index];
                return ListTile(
                  onTap: () => _selectTrack(track),
                  leading: track['image'] != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.network(
                            track['image']!,
                            width: 46,
                            height: 46,
                            fit: BoxFit.cover,
                          ),
                        )
                      : const Icon(Icons.music_note, size: 32),
                  title: Text(
                    track['name'] ?? '',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text(track['artist'] ?? ''),
                );
              },
            ),
          ),
      ],
    );
  }
}
