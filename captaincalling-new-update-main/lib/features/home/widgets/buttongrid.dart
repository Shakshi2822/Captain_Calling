import 'package:flutter/material.dart';

class ButtonGrid extends StatelessWidget {
  final Function(String) onButtonTap;

  const ButtonGrid({super.key, required this.onButtonTap});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true, // This will make the grid not take up the entire height
      childAspectRatio:
          2.0, // Adjust the aspect ratio to make buttons smaller or larger
      children: [
        _buildButton(context, 'Create Team'),
        _buildButton(context, 'Article'),
        _buildButton(context, 'Join Team'),
        _buildButton(context, 'My Teams'),
        // Add more buttons as needed
      ],
    );
  }

  Widget _buildButton(BuildContext context, String title) {
    return GestureDetector(
      onTap: () => onButtonTap(title),
      child: Card(
        elevation: 5,
        margin: const EdgeInsets.all(8),
        child: Center(
          child: Text(title, style: const TextStyle(fontSize: 16)),
        ),
      ),
    );
  }
}
