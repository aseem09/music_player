import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

void main() => runApp(MyApp());


bool _onTap=false;

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Loader();
  }
}

class Loader extends StatefulWidget {

  @override
  _LoaderState createState() => _LoaderState();
}

class _LoaderState extends State<Loader> with SingleTickerProviderStateMixin {
  AnimationController controller;
  Animation<double> animation_rotation;
  Animation<double> animation_radius_in;
  Animation<double> animation_radius_out;

  Animation<double> animation1_radius_in;
  Animation<double> animation1_radius_out;

  Animation<double> animation2_radius_in;
  Animation<double> animation2_radius_out;
  final double initialRadius = 80;
  double radius = 50;
  double radius1 = 50;
  double radius2 = 50;



  @override
  void initState() {
    super.initState();

    controller =
        AnimationController(vsync: this, duration: new Duration(seconds: 5));

    animation_rotation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(0, 1, curve: Curves.linear),
      ),
    );

    animation_radius_in = Tween<double>(
      begin: 1,
      end: 0,
    ).animate(CurvedAnimation(
        parent: controller,
        curve: Interval(0.5, 1.0, curve: Curves.elasticIn)));
    animation_radius_out = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
        parent: controller,
        curve: Interval(0.0, 0.5, curve: Curves.elasticOut)));

    animation1_radius_in = Tween<double>(
      begin: 5/8,
      end: 0,
    ).animate(CurvedAnimation(
        parent: controller,
        curve: Interval(0.5, 1.0, curve: Curves.elasticInOut)));
    animation1_radius_out = Tween<double>(
      begin: 0,
      end: 5/8,
    ).animate(CurvedAnimation(
        parent: controller,
        curve: Interval(0.0, 0.5, curve: Curves.elasticInOut)));

    animation2_radius_in = Tween<double>(
      begin: 0.25,
      end: 0,
    ).animate(CurvedAnimation(
        parent: controller, curve: Interval(0.5, 1.0, curve: Curves.bounceIn)));
    animation2_radius_out = Tween<double>(
      begin: 0,
      end: 0.25,
    ).animate(CurvedAnimation(
        parent: controller,
        curve: Interval(0.0, 0.5, curve: Curves.bounceOut)));

    controller.addListener(() {
      setState(() {
        if (controller.value >= 0.5 && controller.value <= 1.0) {
          radius = animation_radius_in.value * initialRadius + 100;
          radius1 = (animation1_radius_in.value) * initialRadius + 100;
          radius2 = (animation2_radius_in.value) * initialRadius + 100;
        } else if (controller.value >= 0 && controller.value <= 0.5) {
          radius = animation_radius_out.value * initialRadius + 100;
          radius1 = (animation1_radius_out.value) * initialRadius + 100;
          radius2 = (animation2_radius_out.value) * initialRadius + 100;
        }

        if (controller.value >= 0.5 && controller.value <= 1.0) {
          radius = animation_radius_in.value * initialRadius + 100;
          radius1 = (animation1_radius_in.value) * initialRadius + 100;
          radius2 = (animation2_radius_in.value) * initialRadius + 100;
        } else if (controller.value >= 0 && controller.value <= 0.5) {
          radius = animation_radius_out.value * initialRadius + 100;
          radius1 = (animation1_radius_out.value) * initialRadius + 100;
          radius2 = (animation2_radius_out.value) * initialRadius + 100;
        }

        if (controller.value >= 0.5 && controller.value <= 1.0) {
          radius = animation_radius_in.value * initialRadius + 100;
          radius1 = (animation1_radius_in.value) * initialRadius + 100;
          radius2 = (animation2_radius_in.value) * initialRadius + 100;
        } else if (controller.value >= 0 && controller.value <= 0.5) {
          radius = animation_radius_out.value * initialRadius + 100;
          radius1 = (animation1_radius_out.value) * initialRadius + 100;
          radius2 = (animation2_radius_out.value) * initialRadius + 100;
        }
      });
    });
    controller.repeat();
  }

  double rad = 15;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      width: 100,
      child: Center(
        child: RotationTransition(
          turns: animation_rotation,
          child: Stack(
            children: <Widget>[
              /* Dot(
                radius: 30,
                color: Colors.black12,
              ),*/
              Transform.translate(
                offset: Offset(radius1 * cos(0), radius1 * sin(0)),
                child: Dot(
                  radius: rad,
                  color: Colors.red[900],
                ),
              ),
              Transform.translate(
                offset: Offset(radius1 * cos(pi / 4), radius1 * sin(pi / 4)),
                child: Dot(
                  radius: rad,
                  color: Colors.red[900],
                ),
              ),
              Transform.translate(
                offset: Offset(radius1 * cos(pi / 2), radius1 * sin(pi / 2)),
                child: Dot(
                  radius: rad,
                  color: Colors.red[900],
                ),
              ),
              Transform.translate(
                offset: Offset(
                    radius1 * cos(3 * pi / 4), radius1 * sin(3 * pi / 4)),
                child: Dot(
                  radius: rad,
                  color: Colors.red[900],
                ),
              ),
              Transform.translate(
                offset: Offset(radius1 * cos(pi), radius1 * sin(pi)),
                child: Dot(
                  radius: rad,
                  color: Colors.red[900],
                ),
              ),
              Transform.translate(
                offset: Offset(
                    radius1 * cos(5 * pi / 4), radius1 * sin(5 * pi / 4)),
                child: Dot(
                  radius: rad,
                  color: Colors.red[900],
                ),
              ),
              Transform.translate(
                offset: Offset(
                    radius1 * cos(3 * pi / 2), radius1 * sin(3 * pi / 2)),
                child: Dot(
                  radius: rad,
                  color: Colors.red[900],
                ),
              ),
              Transform.translate(
                offset: Offset(
                    radius1 * cos(7 * pi / 4), radius1 * sin(7 * pi / 4)),
                child: Dot(
                  radius: rad,
                  color: Colors.red[900],
                ),
              ),
              Transform.translate(
                offset: Offset(radius * cos(pi / 12), radius * sin(pi / 12)),
                child: Dot(
                  radius: rad,
                  color: Colors.blue[800],
                ),
              ),
              Transform.translate(
                offset: Offset(
                    radius * cos(4 * pi / 12), radius * sin(4 * pi / 12)),
                child: Dot(
                  radius: rad,
                  color: Colors.blue[800],
                ),
              ),
              Transform.translate(
                offset: Offset(
                    radius * cos(7 * pi / 12), radius * sin(7 * pi / 12)),
                child: Dot(
                  radius: rad,
                  color: Colors.blue[800],
                ),
              ),
              Transform.translate(
                offset: Offset(
                    radius * cos(10 * pi / 12), radius * sin(10 * pi / 12)),
                child: Dot(
                  radius: rad,
                  color: Colors.blue[800],
                ),
              ),
              Transform.translate(
                offset: Offset(
                    radius * cos(13 * pi / 12), radius * sin(13 * pi / 12)),
                child: Dot(
                  radius: rad,
                  color: Colors.blue[800],
                ),
              ),
              Transform.translate(
                offset: Offset(
                    radius * cos(16 * pi / 12), radius * sin(16 * pi / 12)),
                child: Dot(
                  radius: rad,
                  color: Colors.blue[800],
                ),
              ),
              Transform.translate(
                offset: Offset(
                    radius * cos(19 * pi / 12), radius * sin(19 * pi / 12)),
                child: Dot(
                  radius: rad,
                  color: Colors.blue[800],
                ),
              ),
              Transform.translate(
                offset: Offset(
                    radius * cos(22 * pi / 12), radius * sin(22 * pi / 12)),
                child: Dot(
                  radius: rad,
                  color: Colors.blue[800],
                ),
              ),
              /*   Transform.translate(
                offset: Offset(
                    radius * cos(25 * pi / 12), radius * sin(25 * pi / 12)),
                child: Dot(
                  radius: rad,
                  color: Colors.b,
                ),
              ),*/
              Transform.translate(
                offset: Offset(
                    radius2 * cos(2 * pi / 12), radius2 * sin(2 * pi / 12)),
                child: Dot(
                  radius: rad,
                  color: Colors.amber[700],
                ),
              ),
              Transform.translate(
                offset: Offset(
                    radius2 * cos(5 * pi / 12), radius2 * sin(5 * pi / 12)),
                child: Dot(
                  radius: rad,
                  color: Colors.amber[700],
                ),
              ),
              Transform.translate(
                offset: Offset(
                    radius2 * cos(8 * pi / 12), radius2 * sin(8 * pi / 12)),
                child: Dot(
                  radius: rad,
                  color: Colors.amber[700],
                ),
              ),
              Transform.translate(
                offset: Offset(
                    radius2 * cos(11 * pi / 12), radius2 * sin(11 * pi / 12)),
                child: Dot(
                  radius: rad,
                  color: Colors.amber[700],
                ),
              ),
              Transform.translate(
                offset: Offset(
                    radius2 * cos(14 * pi / 12), radius2 * sin(14 * pi / 12)),
                child: Dot(
                  radius: rad,
                  color: Colors.amber[700],
                ),
              ),
              Transform.translate(
                offset: Offset(
                    radius2 * cos(17 * pi / 12), radius2 * sin(17 * pi / 12)),
                child: Dot(
                  radius: rad,
                  color: Colors.amber[700],
                ),
              ),
              Transform.translate(
                offset: Offset(
                    radius2 * cos(20 * pi / 12), radius2 * sin(20 * pi / 12)),
                child: Dot(
                  radius: rad,
                  color: Colors.amber[700],
                ),
              ),
              Transform.translate(
                offset: Offset(
                    radius2 * cos(23 * pi / 12), radius2 * sin(23 * pi / 12)),
                child: Dot(
                  radius: rad,
                  color: Colors.amber[700],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Dot extends StatelessWidget {

  final double radius;
  final Color color;

  Dot({this.radius, this.color});

  @override
  Widget build(BuildContext context) {
    return Center(
      /* child: Container(
        width: this.radius,
        height: this.radius,
        decoration: BoxDecoration(
          color: this.color,
          shape: BoxShape.circle,
        ),
      ),*/
      child: smartShape(),
    );
  }
  int count=0;
  smartShape(){
    if(_onTap){
      count++;
      _onTap=false;
    }
    if(count%2==0){
      return Star();
    }
    else{
      return Cirle();
    }
  }
  Star(){
    return Stack(
      children: <Widget>[
        new Icon(
          Icons.star,
          color: this.color,
          size: 27,
        ),
        new Icon(
          Icons.star,
          color: Colors.black.withOpacity(0.25),
          size: 27,
        ),
      ],
    );
  }
  Cirle(){
    return Stack(
      children: <Widget>[
        new Icon(
          Icons.star,
          color: this.color,
          size: 27,
        ),
        new Icon(
          Icons.star,
          color: Colors.black.withOpacity(0.25),
          size: 27,
        ),
      ],
    );
  }
}
