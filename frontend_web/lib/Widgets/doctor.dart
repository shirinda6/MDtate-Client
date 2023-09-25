import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'calender.dart';
import 'graphIntensityVSDuration.dart';
import 'graphFrequesncyVSSessions.dart';

class Doctor extends StatefulWidget {
  var user;

  Doctor({required this.user});
  @override
  _DoctorState createState() => _DoctorState();
}

class _DoctorState extends State<Doctor> {
  var sessions = {};
  var reports = {};

  @override
  void initState() {
    // TODO: implement initState
    var attacks = widget.user["reports"];
    attacks = attacks.map((e) => e as Map).toList();
    for (var attack in attacks) {
      var date = DateFormat("yyyy-MM-dd").parse(attack["date"]);
      attack["datetime"] =
          DateTime(date.year, date.month, date.day, 0, 0, 0, 0, 0);
      if (reports.keys.contains(attack["datetime"])) {
        reports[attack["datetime"]].add(attack);
      } else {
        reports[attack["datetime"]] = [attack];
      }
    }

    var temp_sessions = [];
    for (var event in widget.user["events"]) {
      if (event["type"].contains('Finished session:')) {
        var sessionName = event["type"].substring(18, event["type"].length);
        DateTime date = DateTime.fromMillisecondsSinceEpoch(event["date"]);
        temp_sessions.add({
          "date": DateTime(date.year, date.month, date.day, 0, 0, 0, 0, 0),
          "sessionName": sessionName
        });
      } else if (event["type"].contains('Reset Sessions')) {
        temp_sessions = [];
      }
    }

    for (var session in temp_sessions) {
      if (sessions.keys.contains(session["date"])) {
        sessions[session["date"]].add(session);
      } else {
        sessions[session["date"]] = [session];
      }
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
   

    return Container(
      height:MediaQuery.of(context).size.height*0.75,
      padding: EdgeInsets.all(1.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        mainAxisSize: MainAxisSize.min, 

        children: [
            
          Expanded(
              child: Calender(reports: reports, sessions: sessions),
            ),
          
          Expanded(
            child: graphIntensityVSDuration(reports: reports),
          ),
          Expanded(
            child:
                graphFrequesncyVSSessions(reports: reports, sessions: sessions),
          ),
        ],
      ),
    );
  }
}
