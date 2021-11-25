import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:simple_animations/stateless_animation/play_animation.dart';
import 'package:simple_animations/timeline_tween/timeline_tween.dart';

enum _AniProps { opacity, translateY }

class SlideFromTopAnimated extends HookWidget {
  const SlideFromTopAnimated({
    Key? key,
    this.delay = 0,
    required this.duration,
    this.space = -15.0,
    required this.child,
  }) : super(key: key);

  final int duration;
  final int delay;
  final double space;
  final Widget child;

  TimelineTween<_AniProps> _tween() => TimelineTween<_AniProps>()
    ..addScene(
      begin: Duration.zero,
      duration: Duration(milliseconds: duration),
    )
        .animate(_AniProps.opacity, tween: Tween<double>(begin: 0.0, end: 1.0))
        .animate(_AniProps.translateY,
            tween: Tween<double>(begin: 1.0, end: 0.0));

  @override
  Widget build(BuildContext context) {
    final tween = useMemoized(() => _tween());

    return PlayAnimation<TimelineValue<_AniProps>>(
      delay: Duration(milliseconds: delay),
      tween: tween,
      duration: tween.duration,
      builder: (context, child, value) => Opacity(
        opacity: value.get(_AniProps.opacity),
        child: Transform.translate(
          offset: Offset(0, space * value.get(_AniProps.translateY)),
          child: child,
        ),
      ),
      child: child,
    );
  }
}
