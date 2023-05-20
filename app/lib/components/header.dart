import 'package:flutter/material.dart';

class Header extends StatelessWidget {
  const Header({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white, width: 3),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Text('ChatGlobe', style: Theme.of(context).textTheme.headlineMedium),
      ],
    );
  }
}
