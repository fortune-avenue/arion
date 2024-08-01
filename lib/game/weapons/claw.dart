import 'package:arion/game/actors/player.dart';
import 'package:arion/game/enum/direction.dart';
import 'package:arion/game/game.dart';
import 'package:arion/game/routes/gameplay.dart';
import 'package:arion/game/utils/sound_effect.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';

class Claw extends SpriteAnimationComponent
    with
        HasGameReference<ArionGame>,
        HasAncestor<Gameplay>,
        CollisionCallbacks {
  Claw({super.position, required this.direction})
      : super(size: Vector2.all(32.0));

  final Direction direction;

  late final SpriteAnimation _clawDownAnimation;
  late final SpriteAnimation _clawLeftAnimation;
  late final SpriteAnimation _clawUpAnimation;
  late final SpriteAnimation _clawRightAnimation;
  late final SpriteAnimation _clawIdleAnimation;

  final double _animationSpeed = 0.05;

  // claw attack point
  double attackPoint = 10.0;

  final attackSpeed = 0.8; // Attack speed in seconds

  @override
  Future<void> onLoad() async {
    super.onLoad();
    // remove after finish
    removeOnFinish = true;

    // add the hitbox so that we can collapse with other
    await add(
      RectangleHitbox.relative(
        Vector2.all(1),
        parentSize: size,
        anchor: Anchor.center,
      ),
    );

    // load the animation
    await _loadAnimations().then((_) => {animation = _clawIdleAnimation});
  }

  @override
  void update(double dt) {
    /// when claw show, show the animation and the position added by 20
    /// so it not showing inside the body player, but outside instead
    switch (direction) {
      case Direction.down:
        animation = _clawDownAnimation;
        position = Vector2(0, 20);
        break;
      case Direction.up:
        animation = _clawUpAnimation;
        position = Vector2(0, -20);
        break;
      case Direction.left:
        animation = _clawLeftAnimation;
        position = Vector2(-20, 0);
        break;
      case Direction.right:
        animation = _clawRightAnimation;
        position = Vector2(20, 0);
        break;
      case Direction.upLeft:
        animation = _clawLeftAnimation;
        position = Vector2(-20, 0);
        break;
      case Direction.upRight:
        animation = _clawRightAnimation;
        position = Vector2(20, 0);
        break;
      case Direction.downRight:
        animation = _clawRightAnimation;
        position = Vector2(20, 0);
        break;
      case Direction.downLeft:
        animation = _clawLeftAnimation;
        position = Vector2(-20, 0);
        break;
      case Direction.idle:
        animation = _clawIdleAnimation;
        position = Vector2(0, 20);
        break;
    }
    super.update(dt);
  }

  // load the animation
  Future<void> _loadAnimations() async {
    final spriteSheet = SpriteSheet(
      image: (await game.images.load('claw_zombie_spritesheet_2.png')),
      srcSize: Vector2(29.0, 32.0),
    );

    _clawDownAnimation = spriteSheet.createAnimation(
      row: 0,
      stepTime: _animationSpeed,
      to: 4,
      loop: false,
    );

    _clawLeftAnimation = spriteSheet.createAnimation(
      row: 1,
      stepTime: _animationSpeed,
      to: 4,
      loop: false,
    );

    _clawUpAnimation = spriteSheet.createAnimation(
      row: 2,
      stepTime: _animationSpeed,
      to: 4,
      loop: false,
    );

    _clawRightAnimation = spriteSheet.createAnimation(
      row: 3,
      stepTime: _animationSpeed,
      to: 4,
      loop: false,
    );

    _clawIdleAnimation = spriteSheet.createAnimation(
      row: 0,
      stepTime: _animationSpeed,
      to: 4,
      loop: false,
    );
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);

    if (other is Player) {
      // if collapse with zombie, call attacked and send the attack point
      if (game.playerData.isAlive) {
        other.attacked(attackPoint);
        SoundEffect.play(
          SoundEffect.zombieAttack,
          volume: 0.5,
        );
      }
    }
  }
}
