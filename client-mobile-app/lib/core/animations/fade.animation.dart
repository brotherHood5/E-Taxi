import 'package:flutter/material.dart';
import 'package:simple_animations/simple_animations.dart';

enum AniProps { opacity, translateY }

class FadeAnimation extends StatelessWidget {
  final double delay;
  final Widget child;

  FadeAnimation({required this.delay, required this.child});

  @override
  Widget build(BuildContext context) {
    final movieTween = MovieTween()
      ..scene(
              begin: const Duration(milliseconds: 0),
              end: const Duration(milliseconds: 500))
          .tween(AniProps.opacity, Tween(begin: 0.0, end: 1.0))
      ..scene(
              begin: const Duration(milliseconds: 0),
              end: const Duration(milliseconds: 500))
          .tween(AniProps.translateY, Tween(begin: -30.0, end: 0.0),
              curve: Curves.easeOut);
    // final tween = MultiTween<AniProps>()
    //   ..add(AniProps.opacity, 0.0.tweenTo(1.0), 500.milliseconds)
    //   ..add(AniProps.translateY, (-30.0).tweenTo(0.0), 500.milliseconds,
    //       Curves.easeOut);

    return PlayAnimationBuilder<Movie>(
      delay: Duration(milliseconds: (500 * delay).round()),
      duration: movieTween.duration,
      tween: movieTween,
      child: child,
      builder: (context, value, child) => Opacity(
        opacity: value.get(AniProps.opacity),
        child: Transform.translate(
            offset: Offset(0, value.get(AniProps.translateY)), child: child),
      ),
    );
  }
}
