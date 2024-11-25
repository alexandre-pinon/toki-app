import 'package:flutter/material.dart';

class DividerWithText extends StatelessWidget {
  final String text;

  const DividerWithText(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Divider()),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text(text, style: Theme.of(context).textTheme.labelLarge),
        ),
        Expanded(child: Divider()),
      ],
    );
  }
}
