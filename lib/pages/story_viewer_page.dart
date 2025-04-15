import 'dart:io';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/story_model.dart';
import '../models/user_model.dart';

class StoryViewerPage extends StatefulWidget {
  final List<Map<String, dynamic>> stories;
  final int initialIndex;

  const StoryViewerPage({
    super.key,
    required this.stories,
    this.initialIndex = 0,
  });

  @override
  State<StoryViewerPage> createState() => _StoryViewerPageState();
}

class _StoryViewerPageState extends State<StoryViewerPage>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AudioPlayer _audioPlayer;
  late AnimationController _progressController;
  int _currentIndex = 0;

  List<Map<String, dynamic>> get currentUserStories {
    final currentUserId = widget.stories[_currentIndex]['user'].id;
    return widget.stories
        .where((story) => story['user'].id == currentUserId)
        .toList();
  }

  int get localIndexInUserStories {
    final story = widget.stories[_currentIndex];
    return currentUserStories.indexOf(story);
  }

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _pageController = PageController(initialPage: widget.initialIndex);
    _currentIndex = widget.initialIndex;
    _setupAnimation();
    _playCurrentStory();
  }

  void _setupAnimation() {
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _goToNextStory();
        }
      });

    _progressController.forward(from: 0);
  }

  Future<void> _playCurrentStory() async {
    final story = widget.stories[_currentIndex]['story'] as StoryModel;
    final track = story.spotifyTrack;
    final url = track?['previewUrl'];

    print("🔊 Lecture de la story n°$_currentIndex");
    print("🎵 Titre : ${track?['name']}");
    print("👤 Artiste : ${track?['artist']}");
    print("🔗 URL : $url");

    if (url != null && url.isNotEmpty) {
      try {
        await _audioPlayer.stop();
        await _audioPlayer.play(UrlSource(url));
        print("🎧 Lecture lancée ✅");

        _audioPlayer.onPlayerStateChanged.listen((state) {
          print("🟢 PlayerState : $state");
        });
      } catch (e) {
        print("❌ Erreur audio : $e");
      }
    } else {
      print("⚠️ Pas de preview disponible.");
    }
  }

  void _goToNextStory() {
    final isLast = _currentIndex == widget.stories.length - 1;
    final nextUserSame = !isLast &&
        widget.stories[_currentIndex + 1]['user'].id ==
            widget.stories[_currentIndex]['user'].id;

    if (nextUserSame) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pop(context);
    }
  }

  void _onPageChanged(int index) async {
    await _audioPlayer.stop();
    _progressController.stop();
    _progressController.reset();

    setState(() => _currentIndex = index);

    _setupAnimation();
    _playCurrentStory();
  }

  @override
  void dispose() {
    _progressController.dispose();
    _audioPlayer.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final story = widget.stories[_currentIndex]['story'] as StoryModel;
    final user = widget.stories[_currentIndex]['user'] as UserModel;
    final track = story.spotifyTrack;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemCount: widget.stories.length,
            itemBuilder: (context, index) {
              final story = widget.stories[index]['story'] as StoryModel;
              return Image.file(
                File(story.mediaPath),
                fit: BoxFit.cover,
              );
            },
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 16, 12, 10),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: user.avatarUrl != null
                            ? FileImage(File(user.avatarUrl!))
                            : null,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        user.username,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, color: Colors.white),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: List.generate(currentUserStories.length, (i) {
                      final isCurrent = i == localIndexInUserStories;
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: AnimatedBuilder(
                            animation: _progressController,
                            builder: (_, __) => LinearProgressIndicator(
                              value: isCurrent
                                  ? _progressController.value
                                  : i < localIndexInUserStories
                                      ? 1
                                      : 0,
                              color: Colors.white,
                              backgroundColor: Colors.white24,
                              minHeight: 4,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),

                // 🎵 Info musique (avec miniature)
                if (track != null && track['name'] != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 16, top: 12),
                    child: Row(
                      children: [
                        if (track['image'] != null &&
                            track['image']!.isNotEmpty)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: Image.network(
                              track['image']!,
                              width: 32,
                              height: 32,
                              fit: BoxFit.cover,
                            ),
                          ),
                        const SizedBox(width: 8),
                        const Icon(Icons.music_note,
                            color: Colors.white, size: 20),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            "${track['name']} — ${track['artist']}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontStyle: FontStyle.italic,
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
