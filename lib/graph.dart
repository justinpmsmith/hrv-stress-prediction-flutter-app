import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class Graph extends StatelessWidget {
  String date;

  Graph(this.date, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
// Get the data once
    // FirebaseDatabase database = FirebaseDatabase.instance;
    // DatabaseReference ref = FirebaseDatabase.instance.ref("date/$date");
    //print(ref);
    // Future<DatabaseEvent> event = ref.once();
    // print(event);

    return Text(date);
  }
}
