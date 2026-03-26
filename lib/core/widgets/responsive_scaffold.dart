import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';

/// A simple, consistent layout wrapper:
/// - Adds safe padding
/// - Constrains content width on large screens
class ResponsiveScaffoldBody extends StatelessWidget {
  const ResponsiveScaffoldBody({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.xl),
    this.maxWidth = 560,
  });

  final Widget child;
  final EdgeInsets padding;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}

