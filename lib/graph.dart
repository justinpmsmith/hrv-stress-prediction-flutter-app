import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class Graph extends StatelessWidget {
  String date;

  List<Map> mapList2 = [];
  // List<FlSpot> _values = const [];

  Graph(this.date, {Key? key}) : super(key: key);

  Future<int> fetchData() async {
    DatabaseReference ref = FirebaseDatabase.instance.ref("date/$date");
    DatabaseEvent event = await ref.once();
    var response = event.snapshot.value;
    final List<Map> mapList = [];
    // final List<Map> mapList2 = [];
    if (response != null) {
      //print(response);

      final data = response as Map<Object?, Object?>;

      data.forEach((id, predData) {
        Map temp = {id: predData};
        mapList.add(temp);
      });
      //mapList.sort(((a, b) => (b['time']).compareTo(a['time'])));
      //print(mapList);

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
      //print(mapList2);
      mapList2.sort((a, b) => DateTime.parse(date + ' ' + a['time'])
          .compareTo(DateTime.parse(date + ' ' + b['time'])));
      // print(mapList2);
      return 1;
    } else {
      print('no data available');
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    // var ml = fetchData();
    // print(ml);

    return FutureBuilder<int>(
      future: fetchData(),
      builder: (
        BuildContext context,
        AsyncSnapshot<int> snapshot,
      ) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return const Text('Error');
          } else if (snapshot.hasData && snapshot.data == 1) {
            return chart(mapList2);
          } else {
            return const Text('no data available for this date');
          }
        } else {
          return Text('State: ${snapshot.connectionState}');
        }
      },
    );
  }
}

Widget chart(List<Map> mapList2) {
  return LineChart(
    LineChartData(titlesData: FlTitlesData(), lineBarsData: [
      LineChartBarData(
          spots: mapList2.map((point) {
        print('here!!!!!!!!!!!!!!!!!');
        print(point);
        String time = point['time'].replaceAll(':', '.');
        double prediction = point['prediction'].toDouble();
        return FlSpot(double.parse(time), prediction);
      }).toList()),
    ]),
  );
}
