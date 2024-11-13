import 'package:flutter/material.dart';


class CircularIconButton extends StatelessWidget {
  final Color buttonColor;
  final String icon;
  final String label;
  final String currentTime;
  final VoidCallback? onPressed;

  const CircularIconButton({
    super.key,
    this.buttonColor = Colors.transparent,
    required this.icon,
    required this.label,
    required this.currentTime,
    this.onPressed
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: onPressed,
        child: Column( // Use Column to stack icon and text
          mainAxisSize: MainAxisSize.min, // Minimize the height of the column
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: buttonColor,
              child:Image.asset(icon),
            ),
            const SizedBox(height: 4), // Spacing between icon and text
            Text(
              label,
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 14,
                fontWeight:FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4), // Spacing between icon and text
             Text(
              currentTime,
              style:const TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight:FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}