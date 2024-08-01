
import 'package:arion/game/utils/app_theme.dart';
import 'package:flutter/widgets.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  const CustomButton({
    Key? key,
    required this.text,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset(
            'assets/images/ui/Button.png',
            width: MediaQuery.of(context).size.width * 0.12,
            fit: BoxFit.fitWidth,
          ),
          Positioned(
            bottom: 20,
            child: Text(
              text.toUpperCase(),
              style: AppTheme.headline3,
            ),
          )
        ],
      ),
    );
  }
}
