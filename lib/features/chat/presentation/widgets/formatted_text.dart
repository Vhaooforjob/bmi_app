import 'package:flutter/material.dart';

class FormattedText extends StatelessWidget {
  final String text;
  final TextStyle? style;

  const FormattedText(this.text, {super.key, this.style});

  @override
  Widget build(BuildContext context) {
    final spans = <TextSpan>[];
    final parts = text.split(
      RegExp(r'(\*\*.*?\*\*|\*.*?\*|```.*?```)', dotAll: true),
    );

    for (final part in parts) {
      if (part.startsWith("**") && part.endsWith("**")) {
        spans.add(
          TextSpan(
            text: part.substring(2, part.length - 2),
            style: (style ?? const TextStyle()).copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      } else if (part.startsWith("*") && part.endsWith("*")) {
        spans.add(
          TextSpan(
            text: part.substring(1, part.length - 1),
            style: (style ?? const TextStyle()).copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      } else if (part.startsWith("```") && part.endsWith("```")) {
        spans.add(
          TextSpan(
            text: part.substring(3, part.length - 3),
            style: (style ?? const TextStyle()).copyWith(
              fontFamily: "monospace",
              backgroundColor: Colors.black12,
            ),
          ),
        );
      } else {
        spans.add(TextSpan(text: part, style: style));
      }
    }

    return RichText(
      text: TextSpan(
        style: DefaultTextStyle.of(context).style.merge(style),
        children: spans,
      ),
      softWrap: true,
    );
  }
}
