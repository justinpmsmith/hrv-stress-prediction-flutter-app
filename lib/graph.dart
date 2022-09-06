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

  double _minX = 0;
  double _maxX = 0;

  // ignore: non_constant_identifier_names
  List<FlSpot> GetValues() => mapList2.map((point) {
        String dateTime = date + ' ' + point['time'];
        double time =
            DateTime.parse(dateTime).millisecondsSinceEpoch.toDouble();
        double prediction = point['prediction'].toDouble();

        return FlSpot(time, prediction);
      }).toList();

  LineChartBarData _lineBarData() {
    return LineChartBarData(
      spots: GetValues(),
    );
  }

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

      mapList2.sort((a, b) => DateTime.parse(date + ' ' + a['time'])
          .compareTo(DateTime.parse(date + ' ' + b['time'])));

      String dateTime = date + ' ' + mapList2[0]['time'];
      _minX = DateTime.parse(dateTime).millisecondsSinceEpoch.toDouble();

      dateTime = date + ' ' + mapList2[mapList2.length - 1]['time'];
      _maxX = DateTime.parse(dateTime).millisecondsSinceEpoch.toDouble();
      return 1;
    } else {
      print('no data available');
      return 0;
    }
  }

  SideTitles get _bottomTitles => SideTitles(
        interval: (_maxX - _minX) / 6,
        showTitles: true,
        getTitlesWidget: (value, meta) {
          final DateTime datetime =
              DateTime.fromMillisecondsSinceEpoch(value.toInt());

          if (value.toDouble() < _maxX) {
            return Text(DateFormat.Hm().format(datetime));
          } else {
            return Text('');
          }
        },
      );

  Widget chart(List<Map> mapList2) {
    return LineChart(LineChartData(
        titlesData: FlTitlesData(
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(sideTitles: _bottomTitles)),
        lineBarsData: [
          LineChartBarData(spots: GetValues()),
        ]));
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
