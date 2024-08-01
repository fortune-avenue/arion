enum DialogBox {
  opening,
  mission,
  healthPotion,
  ragePotion,
  buildingBridge,
  finishingBridge,
  carryStone,
  energyManagement,
  killDemon,
  bossDefeated,
}

String contentDialog(DialogBox dialog) {
  switch (dialog) {
    case DialogBox.opening:
      return 'This world is full of Zombies! You need to get out of here!';
    case DialogBox.mission:
      return 'You can kill the Zombie with Sword and other Weapon that you found!';
    case DialogBox.energyManagement:
      return 'Please manage your Energy when you use the Weapon!';
    case DialogBox.buildingBridge:
      return 'Build a bridge! You need to collect 18 stones to form a bridge so you can cross this river.';
    case DialogBox.finishingBridge:
      return 'Congrats! Now you can across the River, now find a Cave to get out of here!';
    case DialogBox.carryStone:
      return 'You can only carry 6 stones, so you have to go back and forth here to build the bridge.';
    case DialogBox.healthPotion:
      return 'This Potion can increase your health! But can only be used once.';
    case DialogBox.ragePotion:
      return 'This Potion can increase your energy for 5 seconds! But can only be used once.';
    case DialogBox.killDemon:
      return 'Look! There\'s a Demon there! you have to kill it first to get out of here!';
    case DialogBox.bossDefeated:
      return 'The Demon has been killed, lets find a cave to go out of here!';
  }
}
