import 'dart:async';
import 'dart:ui';
import 'package:android_device_info/android_device_info.dart';
import 'package:audioplayers/audio_cache.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int batteryRingLevel = 90;
  getRingLevel() async {
    final prefs = await SharedPreferences.getInstance();
    batteryRingLevel = prefs.getInt('batteryRingLevel') ?? 90;
    Timer.periodic(Duration(minutes: 2), (timer) async {
      var batteryInfo = await AndroidDeviceInfo().getBatteryInfo();
      if (batteryInfo['isDeviceCharging'] && batteryInfo['batteryPercentage'] >= batteryRingLevel) audioPlayer.play('ChargingCompleted.mp3');
    });
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getRingLevel();
  }

  AudioCache audioPlayer = AudioCache(prefix: 'audio/');
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.black54,
            elevation: 0,
            title: Text('Chargie'),
            shape: BeveledRectangleBorder(borderRadius: BorderRadius.only(bottomRight: Radius.circular(25.0))),
          ),
          body: Container(
            margin: EdgeInsets.fromLTRB(20, 20, 20, 20),
            child: ListView(
              physics: BouncingScrollPhysics(),
              children: <Widget>[
                Text(
                  'HOW IT WORKS ?\n\n1. The alarm will ring from $batteryRingLevel% battery level onwards.\n2. Alarm will continue every 2 minutes, if not unplugged.\n3. Open the app while charging.',
                ),
                Text('\n\n'),
                Text(
                  'IMPORTANT NOTE \n\n1. The alarm can delay few minutes.\n2. Delaying is done to prevent app from draining the battery.',
                ),
                Text('\n\n'),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('ALARM LEVEL'),
                    Text(batteryRingLevel.toString() + '%'),
                  ],
                ),
                CupertinoSlider(
                  onChanged: (double value) async {
                    final prefs = await SharedPreferences.getInstance();
                    batteryRingLevel = value.toInt();
                    prefs.setInt('batteryRingLevel', batteryRingLevel.toInt());
                    setState(() {});
                  },
                  value: batteryRingLevel.toDouble(),
                  min: 40,
                  max: 100,
                ),
                Row(
                  children: [
                    Text('TEST '),
                    IconButton(icon: Icon(Icons.volume_up_rounded), onPressed: () => audioPlayer.play('ChargingCompleted.mp3')),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
