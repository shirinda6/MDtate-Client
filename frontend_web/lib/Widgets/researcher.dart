import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

import '../AppLocalizations.dart';
import './reportTable.dart';
import '../Models/DoctorModel.dart';
import './sessionsTable.dart';

class Researcher extends StatefulWidget {
  var user;
  DoctorModel? doctorModel;

  Researcher({required this.user, required this.doctorModel});
  @override
  _ResearcherState createState() => _ResearcherState();
}

class _ResearcherState extends State<Researcher> {
  List<List<String>> sessions = [];
  List<List<String>> reports = [];
  final List<Item> _data = [];

  String getType(String type) {
    if (type == '"טריפטנים"') return "Triptans";
    if (type == '"משככי כאבים משולבים"') return "Combined analgesics";
    if (type == "משככי כאבים פשוטים") return "Simple analgesics";
    return type;
  }

  @override
  void initState() {
    // TODO: implement initState
    var name = widget.user["first_name"] + " " + widget.user["last_name"];
    int countReports = widget.doctorModel!.getCountReports();
    int countSessions = widget.doctorModel!.getCountSessions();
    var attacks = widget.user["reports"];
    if (attacks.length != 0) {
      attacks = attacks.map((e) => e as Map).toList();
      for (var attack in attacks) {
        attack["datetime"] = DateFormat("yyyy-MM-dd").parse(attack["date"]);
      }
      attacks.sort((a, b) =>
          (a["datetime"] as DateTime).compareTo(b["datetime"] as DateTime));
      for (var attack in attacks) {
        // List data = [countReports];
        // List<String> data = [name];
        List<String> data = [countReports.toString()];
        // data.add(name);
        data.add(DateFormat('dd.MM.yyyy').format(attack["datetime"]));
        data.add(attack["duration"].toString());
        data.add(attack["intensity"].toString());
        data.add(getType(attack["type"]));
        reports.add(data);
      }
    }

    List<List<String>> temp = [];
    for (var event in widget.user["events"]) {
      if (event["type"].contains('Finished session:')) {
        // var data = [count];
        // List<String> data = [name];
        List<String> data = [countSessions.toString()];
        var sessionName = event["type"].substring(18, event["type"].length);
        DateTime date = DateTime.fromMillisecondsSinceEpoch(event["date"]);
        // data.add(name);
        data.add(DateFormat('dd.MM.yyyy').format(date));
        data.add(sessionName);
        temp.add(data);
      } else if (event["type"].contains('Reset Sessions')) {
        temp = [];
      }
    }
    sessions = temp;
    widget.doctorModel!.addToListReports(reports);
    widget.doctorModel!.addToListSessions(sessions);

    _data.add(Item(
        expandedValue: reportTable(reports: reports),
        headerValue: AppLocalizations.of(context)!.translate('Reports')));
    _data.add(Item(
        expandedValue: sessionTable(sessions: sessions),
        headerValue: AppLocalizations.of(context)!.translate('Sessions')));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        // padding: EdgeInsets.all(16.0),
        child: ExpansionPanelList(
          elevation: 1,
          expandedHeaderPadding: EdgeInsets.all(0),
          expansionCallback: (int index, bool isExpanded) {
            setState(() {
              _data[index].isExpanded = !isExpanded;
            });
          },
          children: _data.map<ExpansionPanel>((Item item) {
            return ExpansionPanel(
              headerBuilder: (BuildContext context, bool isExpanded) {
                return ListTile(
                  title: Text(
                    item.headerValue,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.nunito(
                        textStyle: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w700,
                      color: Color.fromARGB(255, 9, 40, 52),
                    )),
                  ),
                );
              },
              body: item.expandedValue,
              isExpanded: item.isExpanded,
            );
          }).toList(),
        ),
      ),
    );
  }
}

class Item {
  Item({
    required this.expandedValue,
    required this.headerValue,
    this.isExpanded = false,
  });

  Widget expandedValue;
  String headerValue;
  bool isExpanded;
}
