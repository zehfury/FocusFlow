import 'package:flutter/material.dart';

sealed class AppRadii {
  AppRadii._();

  static const Radius xs = Radius.circular(10);
  static const Radius sm = Radius.circular(14);
  static const Radius md = Radius.circular(18);
  static const Radius lg = Radius.circular(24);

  static const BorderRadius card = BorderRadius.all(md);
  static const BorderRadius sheet = BorderRadius.vertical(top: lg);
  static const BorderRadius pill = BorderRadius.all(Radius.circular(999));
}

