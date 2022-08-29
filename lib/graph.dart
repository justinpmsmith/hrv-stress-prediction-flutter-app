import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:convert';

import 'package:intl/intl.dart';

class Graph extends StatelessWidget {
  String date;

  Graph(this.date, {Key? key}) : super(key: key);

  Future<void> fetchData() async {
    DatabaseReference ref = FirebaseDatabase.instance.ref("date/$date");
    DatabaseEvent event = await ref.once();
    var response = event.snapshot.value;

    if (response != null) {
      //print(response);

      final data = response as Map<Object?, Object?>;
      final List<Map> mapList = [];
      final List<Map> mapList2 = [];

      data.forEach((id, predData) {
        Map temp = {id: predData};
        mapList.add(temp);
      });
      //mapList.sort(((a, b) => (b['time']).compareTo(a['time'])));
      // print(mapList);

      mapList.forEach((element) {
        var el = element as Map<dynamic, dynamic>;
        el.forEach((key, value) {
          Map temp2 = {
            'time': value['time'],
            'prediction': value['prediction']
          };
          mapList2.add(temp2);
        });
      });
      print(mapList2);
      mapList2.sort((a, b) => DateTime.parse(date + ' ' + a['time'])
          .compareTo(DateTime.parse(date + ' ' + b['time'])));
      print(mapList2);

      var time = [];
      var predictions = [];

      mapList2.forEach((element) {
        time.add(element['time']);
        predictions.add(element['prediction']);
      });
      print(time);
      print(predictions);
    } else {
      print('no data available');
    }
  }

  @override
  Widget build(BuildContext context) {
    fetchData();

    return Text(date);
  }
}
