import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

sealed class RouteTransitions {
  RouteTransitions._();

  static CustomTransitionPage<void> fadeSlide({
    required GoRouterState state,
    required Widget child,
  }) {
    return CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 260),
      reverseTransitionDuration: const Duration(milliseconds: 220),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved =
            CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
        final offsetTween =
            Tween<Offset>(begin: const Offset(0, 0.03), end: Offset.zero);
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: curved.drive(offsetTween),
            child: child,
          ),
        );
      },
    );
  }

  static NoTransitionPage<void> none({
    required GoRouterState state,
    required Widget child,
  }) {
    return NoTransitionPage<void>(key: state.pageKey, child: child);
  }
}

