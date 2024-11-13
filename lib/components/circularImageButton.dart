import 'package:flutter/material.dart';

class CircularImageButton extends StatelessWidget {
  final String labelText;
  final List<Color> buttonColor;
  final VoidCallback onPressed;

  const CircularImageButton({
    super.key,
    required this.buttonColor,
    required this.labelText,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(50.0),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: ClipOval(
        child: Container(
          width: 300.0,
          // Width of the button
          height: 300.0,
          // Height of the button
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: buttonColor,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),

          // Background color
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Center vertically
            children: [
              const Icon(
                size: 50,
                Icons.touch_app_outlined,
                color: Colors.white,
              ),
              Text(
                labelText,
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center, // Center text horizontally
              ),
            ],
          ),
        ),
      ),
    );
  }
}
