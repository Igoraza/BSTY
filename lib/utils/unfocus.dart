import 'package:flutter/material.dart';

class Unfocus extends StatelessWidget {
  const Unfocus({
    Key? key,
    required this.child,
  }) : super(key: key);
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        behavior: HitTestBehavior.opaque,

        /// [ removes focus from textfield when tapped outside ]
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: child);
  }
}
