import 'package:flutter/material.dart';
import '../theme/lava_theme.dart';

void showNotice(BuildContext context, String message) {
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

Future<bool> confirmAction(
  BuildContext context, {
  required String title,
  required String message,
  String confirm = '确认',
}) async =>
    await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(confirm),
          ),
        ],
      ),
    ) ??
    false;

class Metric extends StatelessWidget {
  final String label;
  final String value;
  const Metric(this.label, this.value, {super.key});
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        label,
        style: const TextStyle(color: LavaTheme.textSecondary, fontSize: 12),
      ),
      const SizedBox(height: 7),
      Text(
        value,
        style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w500),
      ),
    ],
  );
}
