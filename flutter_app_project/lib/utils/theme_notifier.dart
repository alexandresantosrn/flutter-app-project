import 'package:flutter/material.dart';

/// Notifier global usado para alternar ThemeMode em runtime.
final ValueNotifier<ThemeMode> themeModeNotifier =
    ValueNotifier(ThemeMode.light);
