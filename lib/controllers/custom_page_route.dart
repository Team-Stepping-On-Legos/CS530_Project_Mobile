import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomPageRoute<T> extends PageRoute<T> {
  CustomPageRoute(this.child, this.type);
  final Widget child;
  final String type;

  @override
  Color? get barrierColor => Colors.indigo.withAlpha(20);

  @override
  String? get barrierLabel => '';

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 800);

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    if (type.contains("curved")) {
      return FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.linear),
        child: child,
      );
    } else {
      const begin = Offset(-1.0, 0.0);
      const end = Offset.zero;
      final tween = Tween(begin: begin, end: end);
      final offsetAnimation = animation.drive(tween);

      return SlideTransition(
        position: offsetAnimation,
        child: child,
      );
    }
  }
}
