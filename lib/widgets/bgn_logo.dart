import 'package:flutter/material.dart';

import '../core/constants/app_theme.dart';

class BgnLogo extends StatelessWidget {
  const BgnLogo({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'BGN',
          style: TextStyle(
            color: AppTheme.navy,
            fontSize: compact ? 28 : 34,
            fontWeight: FontWeight.w900,
            height: 0.92,
            letterSpacing: 0,
          ),
        ),
        Container(
          width: compact ? 70 : 84,
          height: 1.5,
          margin: const EdgeInsets.only(top: 5, bottom: 3),
          color: AppTheme.gold,
        ),
        Text(
          'REAL ESTATE',
          style: TextStyle(
            color: AppTheme.navy,
            fontSize: compact ? 8 : 10,
            fontWeight: FontWeight.w700,
            letterSpacing: compact ? 2.2 : 3,
          ),
        ),
      ],
    );
  }
}
