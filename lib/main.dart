import 'dart:async';

import 'package:flutter/material.dart';
import 'package:wear/wear.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.compact,
      ),
      home: const WatchScreen(),
    );
  }
}

class WatchScreen extends StatelessWidget {
  const WatchScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WatchShape(
      builder: (context, shape, child) {
        return AmbientMode(
          builder: (context, mode, child) {
            return TimerScreen(mode);
          },
        );
      },
    );
  }
}

class TimerScreen extends StatefulWidget {
  final WearMode mode;

  const TimerScreen(this.mode, {Key? key}) : super(key: key);

  @override
  _TimerScreenState createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  Timer? _timer; // Usar Timer? para permitir valores null
  int _count = 0;
  String _strCount = "00:00:00";
  String _status = "Start";
  Color _playButtonColor = Colors.blue; // Color inicial del botón de play
  IconData _pauseIcon = Icons.pause; // Inicializa el icono de pausa

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Center(
              child: Icon(Icons.timer, color: Colors.white),
            ),
            const SizedBox(height: 4.0),
            Center(
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  color: _strCount == "00:00:00"
                      ? Colors.grey // Color gris cuando está en 0
                      : _status == "Stop"
                          ? Colors.green // Color verde cuando está en pausa
                          : Colors.red, // Color rojo cuando comienza a contar
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
                child: Text(
                  _strCount,
                ),
              ),
            ),
            if (_status == "Start")
              IconButton(
                icon: Icon(Icons.play_arrow),
                color: _playButtonColor, // Color dinámico del botón de play
                onPressed: () {
                  setState(() {
                    _startTimer();
                    _playButtonColor =
                        Colors.green; // Cambia el color al presionar
                  });
                },
              )
            else
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.refresh),
                    color: Colors.white,
                    onPressed: () {
                      if (_timer != null) {
                        _timer?.cancel();
                        setState(() {
                          _count = 0;
                          _strCount = "00:00:00";
                          _status = "Start";
                          _playButtonColor = Colors
                              .blue; // Reinicia el color del botón de play
                          _pauseIcon =
                              Icons.pause; // Reinicia el icono de pausa
                        });
                      }
                    },
                  ),
                  IconButton(
                    icon: Icon(_pauseIcon), // Icono dinámico de pausa/reanudar
                    color: Colors.white,
                    onPressed: () {
                      if (_status == "Stop") {
                        _timer?.cancel();
                        setState(() {
                          _status = "Continue";
                          _pauseIcon =
                              Icons.play_arrow; // Cambia a icono de reanudar
                        });
                      } else if (_status == "Continue") {
                        setState(() {
                          _startTimer();
                          _pauseIcon = Icons.pause; // Cambia a icono de pausa
                        });
                      }
                    },
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  void _startTimer() {
    setState(() {
      _status = "Stop";
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _count += 1;
        int hour = _count ~/ 3600;
        int minute = (_count % 3600) ~/ 60;
        int second = (_count % 3600) % 60;
        _strCount = hour < 10 ? "0$hour" : "$hour";
        _strCount += ":";
        _strCount += minute < 10 ? "0$minute" : "$minute";
        _strCount += ":";
        _strCount += second < 10 ? "0$second" : "$second";
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
