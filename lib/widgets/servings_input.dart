import 'package:flutter/material.dart';

class ServingsInput extends StatelessWidget {
  final ValueNotifier<int> notifier;

  const ServingsInput({super.key, required this.notifier});

  void _increment() {
    notifier.value++;
  }

  void _decrement() {
    if (notifier.value > 1) {
      notifier.value--;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: notifier,
      builder: (context, servings, child) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              '$servings servings',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton.outlined(
                  onPressed: _decrement,
                  icon: Icon(Icons.remove),
                ),
                IconButton.outlined(
                  onPressed: _increment,
                  icon: Icon(Icons.add),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
