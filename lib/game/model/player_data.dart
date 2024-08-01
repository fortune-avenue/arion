import 'package:flutter/material.dart';

class PlayerData {
  final health = ValueNotifier<double>(400);
  var timer = 0.0;

  bool get isAlive => health.value > 0;
}
