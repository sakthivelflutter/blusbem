import 'package:flutter/material.dart';

class TruncatedText extends StatelessWidget {
  final String text;
  final double maxWidth;
  final TextStyle textStyle;

  TruncatedText({
    required this.text,
    required this.maxWidth,
    required this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    String truncatedText = _truncateText(text, maxWidth, textStyle);
    return Text(
      truncatedText,
      style: textStyle,
    );
  }

  String _truncateText(String text, double maxWidth, TextStyle textStyle) {
    // Use TextPainter to measure text width
    TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: textStyle,),
      
      maxLines: 1,
      textDirection: TextDirection.rtl,
      
    );

    int index = 0;
    // Iterate over characters, stopping when the width exceeds maxWidth
    while (index < text.length) {
      textPainter.text = TextSpan(text: text.substring(0, index + 1), style: textStyle);
      textPainter.layout(); // Layout to calculate width

      // If the calculated width is greater than the allowed width, stop
      if (textPainter.width > maxWidth) {
        break;
      }
      index++;
    }

    // Return the text up to the last valid index (without breaking words)
    return text.substring(0, index);
  }
}