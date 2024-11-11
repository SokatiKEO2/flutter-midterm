import 'package:flutter/material.dart';
import 'package:image_gradient/image_gradient.dart';
import 'package:audioplayers/audioplayers.dart';

class AnimatedBalloonWidget extends StatefulWidget {
  @override
  _AnimatedBalloonWidgetState createState() => _AnimatedBalloonWidgetState();
}

class _AnimatedBalloonWidgetState extends State<AnimatedBalloonWidget>
    with TickerProviderStateMixin {
  late AnimationController _controllerFloatUp;
  late AnimationController _controllerGrowSize;
  late AnimationController _controllerRotate;
  late AnimationController _controllerPulse;
  late Animation<double> _animationFloatUp;
  late Animation<double> _animationGrowSize;
  late Animation<double> _animationRotate;
  late Animation<double> _animationPulse;
  late AudioPlayer _audioPlayer;
  Offset _balloonPosition = Offset(0, 0);
  Offset _dragStart = Offset(0, 0);

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _controllerFloatUp =
        AnimationController(duration: Duration(seconds: 8), vsync: this);
    _controllerGrowSize =
        AnimationController(duration: Duration(seconds: 4), vsync: this);
    _controllerRotate =
        AnimationController(duration: Duration(seconds: 2), vsync: this);
    _controllerPulse =
        AnimationController(duration: Duration(seconds: 1), vsync: this);

    _animationRotate = Tween(begin: -0.1, end: 0.1).animate(
      CurvedAnimation(
        parent: _controllerRotate,
        curve: Curves.easeInOut,
      ),
    );

    _animationPulse = Tween(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(
        parent: _controllerPulse,
        curve: Curves.easeInOut,
      ),
    );

    _controllerRotate.repeat(reverse: true);
    _controllerPulse.repeat(reverse: true);

    _controllerFloatUp.addStatusListener((status) {
      if (status == AnimationStatus.forward) {
        _audioPlayer.play('assets/images/wind-blowing-sfx-12809.mp3');
      } else if (status == AnimationStatus.completed) {
        _audioPlayer.stop();
      }
    });
  }

  @override
  void dispose() {
    _controllerFloatUp.dispose();
    _controllerGrowSize.dispose();
    _controllerRotate.dispose();
    _controllerPulse.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double _balloonHeight = MediaQuery.of(context).size.height / 2;
    double _balloonWidth = MediaQuery.of(context).size.height / 3;
    double _balloonBottomLocation =
        MediaQuery.of(context).size.height - _balloonHeight;

    _animationFloatUp = Tween(begin: _balloonBottomLocation, end: 0.0).animate(
        CurvedAnimation(
            parent: _controllerFloatUp, curve: Curves.fastOutSlowIn));

    _animationGrowSize = Tween(begin: 50.0, end: _balloonWidth).animate(
        CurvedAnimation(
            parent: _controllerGrowSize, curve: Curves.elasticInOut));

    if (!_controllerFloatUp.isAnimating) {
      _controllerFloatUp.forward();
      _controllerGrowSize.forward();
    }

    return AnimatedBuilder(
      animation: Listenable.merge([
        _animationFloatUp,
        _animationGrowSize,
        _animationRotate,
        _animationPulse
      ]),
      builder: (context, child) {
        return GestureDetector(
          onPanStart: (details) {
            _dragStart = details.localPosition;
          },
          onPanUpdate: (details) {
            setState(() {
              _balloonPosition = _balloonPosition + (details.localPosition - _dragStart);
              _dragStart = details.localPosition;
              _balloonPosition = Offset(
                _balloonPosition.dx.clamp(
                    0.0, MediaQuery.of(context).size.width - _balloonWidth),
                _balloonPosition.dy.clamp(
                    0.0, MediaQuery.of(context).size.height - _balloonHeight),
              );
            });
          },
          onPanEnd: (details) {

          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start ,
            children: [
              Image.asset(
                'assets/images/cloud.png',
                width: MediaQuery.of(context).size.width / 5,
                height: MediaQuery.of(context).size.height / 5,
                fit: BoxFit.cover,
              ),
              Transform.rotate(
                angle: _animationRotate.value,
                child: Container(
                  margin: EdgeInsets.only(
                    top: _animationFloatUp.value + _balloonPosition.dy,
                    left: _balloonPosition.dx,
                  ),
                  width: (_animationGrowSize.value * _animationPulse.value)
                      .clamp(50.0, _balloonWidth),
                  height: (_balloonHeight * _animationPulse.value)
                      .clamp(50.0, _balloonHeight),
                  child: ImageGradient(
                    image: Image.asset(
                        'assets/images/BeginningGoogleFlutter-Balloon.png'),
                    gradient: LinearGradient(
                      colors: [
                        Colors.redAccent.withOpacity(1),
                        Colors.yellowAccent.withOpacity(0.7)
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              ),
              ClipOval(
                child: Container(
                  width: (_animationGrowSize.value * 0.6)
                      .clamp(20.0, _balloonWidth * 0.6),
                  height: (_animationGrowSize.value * 0.2)
                      .clamp(10.0, _balloonHeight * 0.2),
                  color: Colors.grey.withOpacity(0.5),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
