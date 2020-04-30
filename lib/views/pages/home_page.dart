import 'package:complex_ui/views/screens/drawer_screen.dart';
import 'package:complex_ui/views/screens/home_creen.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final double maxSlide = 225.0;
  bool _canBeDragged = true;
  AnimationController _animationController;

  @override
  void initState() {
    super.initState();

    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 250));
  }

  void _toggle() => _animationController.isDismissed
      ? _animationController.forward()
      : _animationController.reverse();

  void _onDragStart(DragStartDetails details) {
    bool isDragOpenFromLeft =
        _animationController.isDismissed && details.globalPosition.dx < 0;
    bool isDragCloseFromRight =
        _animationController.isCompleted && details.globalPosition.dx > 0;
    _canBeDragged = isDragOpenFromLeft || isDragCloseFromRight;
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (_canBeDragged) {
      double delta = details.primaryDelta / maxSlide;
      _animationController.value += delta;
    }
  }

  void _onDragEnd(DragEndDetails details) {
    if (_animationController.isDismissed || _animationController.isCompleted)
      return;
    if (details.velocity.pixelsPerSecond.dx.abs() >= 365.0) {
      double visualVelocity = details.velocity.pixelsPerSecond.dx /
          MediaQuery.of(context).size.width;
      _animationController.fling(velocity: visualVelocity);
    } else if (_animationController.value < 0.5) {
      close();
      Drawer();
    } else {
      open();
    }
  }

  /// Starts an animation to open the drawer.
  ///
  /// Typically called by [ScaffoldState.openDrawer].
  void open() {
    _animationController.fling(velocity: 1.0);
  }

  /// Starts an animation to close the drawer.
  void close() {
    _animationController.fling(velocity: -1.0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragStart: _onDragStart,
      onHorizontalDragUpdate: _onDragUpdate,
      onHorizontalDragEnd: _onDragEnd,
      onTap: _toggle,
      child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, _) {
            double slide = maxSlide * _animationController.value;
            double scale = 1 - (_animationController.value * 0.3);
            return Stack(
              children: <Widget>[
                DrawerScreen(),
                Transform(
                    transform: Matrix4.identity()
                      ..translate(slide)
                      ..scale(scale),
                    alignment: Alignment.centerLeft,
                    child: HomeScreen())
              ],
            );
          }),
    );
  }
}
