import 'package:flutter/material.dart';

class DividerWidget extends StatelessWidget {
  const DividerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(children: [
      SizedBox(
        height: 10,
      ),
      Divider(
        thickness: 1,
        color: Colors.brown,
      ),
      SizedBox(
        height: 10,
      ),
    ]);
  }
}
