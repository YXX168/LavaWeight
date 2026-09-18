import 'package:flutter/material.dart';
import '../theme/lava_theme.dart';

class MoodSelector extends StatelessWidget {
  final String? selectedMood;
  final ValueChanged<String?> onMoodSelected;

  const MoodSelector({
    super.key,
    required this.selectedMood,
    required this.onMoodSelected,
  });

  static const List<Map<String, String>> _moods = [
    {'key': 'great', 'label': '⚡ 充满活力'},
    {'key': 'good', 'label': '✨ 状态不错'},
    {'key': 'neutral', 'label': '🌱 平平常常'},
    {'key': 'tired', 'label': '🌙 有点疲劳'},
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _moods.map((mood) {
        final isSelected = selectedMood == mood['key'];
        return GestureDetector(
          onTap: () {
            onMoodSelected(isSelected ? null : mood['key']);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0x52FF2A85) : LavaTheme.glassFill,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected
                    ? LavaTheme.lavaPeach
                    : LavaTheme.glassBorderSubtle,
                width: 1.0,
              ),
              boxShadow: isSelected ? LavaTheme.buttonGlowShadow : null,
            ),
            child: Text(
              mood['label']!,
              style: TextStyle(
                color: isSelected
                    ? LavaTheme.textPrimary
                    : LavaTheme.textSecondary,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
