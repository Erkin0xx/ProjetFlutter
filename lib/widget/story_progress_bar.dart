import 'package:flutter/material.dart';

class StoryProgressBar extends StatelessWidget {
  final int currentIndex;
  final int total;
  final Animation<double> animation;

  const StoryProgressBar({
    super.key,
    required this.currentIndex,
    required this.total,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(total, (index) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: index < currentIndex
                    ? 1
                    : index == currentIndex
                        ? animation.value
                        : 0,
                backgroundColor: Colors.white24,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                minHeight: 4,
              ),
            ),
          ),
        );
      }),
    );
  }
}
