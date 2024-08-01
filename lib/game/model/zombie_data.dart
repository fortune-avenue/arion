import 'package:flutter/material.dart';

class ZombieData {
  final totalZombie = ValueNotifier<int>(0);
  final totalZombieKilled = ValueNotifier<int>(0);
  final maxTotalZombie = ValueNotifier<int>(10);

  bool get canSpawnZombie => totalZombie.value < maxTotalZombie.value;
}
