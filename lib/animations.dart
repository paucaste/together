// lottie_widgets.dart

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LikeAnimation extends StatelessWidget {
  final AnimationController? controller;
  final Size size;

  LikeAnimation({this.controller, required this.size});

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      'assets/like.json',
      controller: controller,
      width: size.width,
      height: size.height,
      fit: BoxFit.fill,
      onLoaded: (composition) {
        controller?.duration = composition.duration;
      },
    );
  }
}

class HeartIconWithAnimation extends StatefulWidget {
  @override
  _HeartIconWithAnimationState createState() => _HeartIconWithAnimationState();
}

class _HeartIconWithAnimationState extends State<HeartIconWithAnimation>
    with TickerProviderStateMixin {
  bool _isLiked = false;
  bool _isAnimating = false;
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(duration: Duration(milliseconds: 500), vsync: this)
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              if (mounted) {
                setState(() {
                  _isAnimating = false;
                  _isLiked = true;
                });
              }
            }
          });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (!_isAnimating && !_isLiked) {
          setState(() {
            _isAnimating = true;
          });
          _controller.forward(); // Se inicia la animación aquí
        }
      },
      child: _buildChild(),
    );
  }

  // Tamaño base
  final double iconSize = 24.0;

  Widget _buildChild() {
    // Factor para hacer la animación más grande que el ícono
    final double scaleFactor = 3;
    final double animationSize = iconSize * scaleFactor;
    if (_isAnimating) {
      return LikeAnimation(
          controller: _controller, size: Size(animationSize, animationSize));
    } else if (_isLiked) {
      return Icon(Icons.favorite, color: Colors.red, size: iconSize);
    } else {
      return Icon(Icons.favorite_border, size: iconSize);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

// Puedes agregar más widgets de animaciones Lottie aquí, por ejemplo:
/*
class AnotherAnimation extends StatelessWidget {
  final double width;
  final double height;

  AnotherAnimation({this.width = 100, this.height = 100});

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      'assets/another_animation.json',
      width: width,
      height: height,
      fit: BoxFit.fill,
    );
  }
}
*/
