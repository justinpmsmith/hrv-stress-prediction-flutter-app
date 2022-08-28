// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:polar/polar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'graph.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(home: MyApp()));
}

/// Example app
class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static const identifier = '45308B23';

  final polar = Polar();
  final logs = ['Service started'];
  var connected = false;
  var date = '';
  DateFormat dateFormat = DateFormat("yyyy-MM-dd");
  int init = 0;

  FirebaseDatabase database = FirebaseDatabase.instance;

  @override
  void initState() {
    super.initState();

    //polar.heartRateStream.listen((e) => log('Heart rate: ${e.data.hr}'));
    polar.heartRateStream
        .listen((e) => post('${e.data.rrs}')); //'RR: ${e.data.rrs}')
    //polar.batteryLevelStream.listen((e) => log('Battery: ${e.level}'));
    polar.streamingFeaturesReadyStream.listen((e) {
      if (e.features.contains(DeviceStreamingFeature.ecg)) {
        polar.startEcgStreaming(e.identifier);
        //.listen((e) => log('ECG data: ${e.samples}'));
      }
    });
    polar.deviceConnectingStream.listen((_) => log('Device connecting'));
    polar.deviceConnectedStream.listen((_) => log('Device connected'));
    polar.deviceDisconnectedStream.listen((_) => log('Device disconnected'));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Stress Tracker'),
          actions: [
            IconButton(
              icon: const Icon(Icons.stop),
              onPressed: () {
                log('Disconnecting from device: $identifier');
                polar.disconnectFromDevice(identifier);
              },
            ),
            IconButton(
              icon: const Icon(Icons.play_arrow),
              onPressed: () {
                log('Connecting to device: $identifier');
                polar.connectToDevice(identifier);
              },
            ),
          ],
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(15.0),
              width: double.infinity,
              height: 400,
              child: Card(
                child: date == '' ? Text("No date chosen") : Graph(date),
                elevation: 5,
              ),
            ),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
              Container(
                  //padding: const EdgeInsets.all(20.0),
                  child: RaisedButton(
                child: Text('Pick Date'),
                onPressed: presentDatePicker,
              )),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(date == '' ? "No date chosen" : date),
              )
            ])
          ],
        ),
      ),
    );
  }

  void post(String pos) async {
    const url = 'http://1a58-34-121-14-122.ngrok.io/rrs';

    final response =
        await http.post(Uri.parse(url), body: json.encode({'rrs': pos}));
    log(pos);
  }

  void presentDatePicker() {
    print('test');
    showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2022),
            lastDate: DateTime.now())
        .then((pickedDate) {
      if (pickedDate != null) {
        print('hello');
        setState(() {
          date = dateFormat.format(pickedDate);
        });
      }
    });
  }

  void log(String log) {
    // ignore: avoid_print
    print(log);
    setState(() {
      logs.add(log);
    });
  }
}
