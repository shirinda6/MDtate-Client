import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../providers/auth.dart';
import '../widgets/dialog_report.dart';
import '../widgets/dialog_first_report.dart';
import '../widgets/list_reports_day.dart';
import '../AppLocalizations.dart';

class Calender extends StatefulWidget {
  static const routeName = 'calender';
  var reports = null;
  var firstReport = null;
  var sessions = null;

  Calender(this.reports, this.firstReport, this.sessions);

  @override
  _CalenderState createState() => _CalenderState();
}

class _CalenderState extends State<Calender> {
  var viewSessionPage = false; //if show the session pageg or not
  Map<DateTime, List> _events =
      {}; //map that the key is the date of the event and the value is list with all the events that happend (report, med and session)
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDate;
  List reportsForDay =
      []; //list with the reports that happend int the date that chosen
  Locale language;
  List seesionsForDay =
      []; //list with the sessions that happend int the date that chosen
  bool showList =
      false; //if open the list of the date or dialog to add new report

  @override
  void initState() {
    viewSessionPage = Provider.of<Auth>(context, listen: false).getViewSession;
    language = Provider.of<Auth>(context, listen: false).getLanguage;
    //add report and med to _events
    for (var date in widget.reports.keys) {
      for (var report in widget.reports[date]) {
        DateTime d = DateTime.utc(date.year, date.month, date.day);
        if (!_events.keys.contains(d)) _events[d] = [];
        _events[d].add("report");
        if (report.keys.contains("type") && report["type"] != "")
          _events[d].add("med");
      }
    }
    //add session to _events
    for (var date in widget.sessions.keys) {
      for (var session in widget.sessions[date]) {
        DateTime d = DateTime.utc(date.year, date.month, date.day);
        if (!_events.keys.contains(d)) _events[d] = [];
        _events[d].add("session");
      }
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: SafeArea(
        child: Padding(
          padding:
              const EdgeInsets.only(bottom: 15, top: 5.0, right: 15, left: 15),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 3,
                        blurRadius: 5,
                        offset: Offset(0, 2),
                      ),
                    ],
                    borderRadius: BorderRadius.circular(20)),
                width: double.infinity,
                child: TableCalendar(
                  firstDay: DateTime(1970),
                  lastDay: DateTime.now(),
                  focusedDay: _focusedDay,
                  headerStyle: HeaderStyle(
                    formatButtonVisible: false,
                  ),
                  onDaySelected: (selectedDay, focusedDay) async {
                    //when the user click on a certain day in calender
                    if (!isSameDay(_selectedDate, selectedDay)) {
                      var d = DateTime(
                          selectedDay.year, selectedDay.month, selectedDay.day);
                      setState(() {
                        _selectedDate = selectedDay;
                        _focusedDay = focusedDay;
                        //check if there are reports in that date.
                        //if yes, set the list reportsForDay and showList to true
                        if (_events.keys.contains(selectedDay)) {
                          showList = true;
                          if (widget.reports.keys.contains(d))
                            reportsForDay = widget.reports[d];
                          else
                            reportsForDay = [];
                          //check if there are sessions in that date. if yes, set the list seesionsForDay
                          if (widget.sessions.keys.contains(d))
                            seesionsForDay = widget.sessions[d];
                          else
                            seesionsForDay = [];
                        } else
                          showList = false;
                      });
                      //open dialog for that date.
                      //if showList is true -> open the list of the reports and sessions
                      //else, check if the user fill the init report.
                      //if yes -> open dialog to add new report. else -> open dialog to fill the init report
                      await showDialog(
                          context: context,
                          builder: (context) => Dialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: showList
                                  ? ListReports(
                                      context, reportsForDay, seesionsForDay, d)
                                  : widget.firstReport == null
                                      ? dialogFirstReport(context)
                                      : dialogReport(null, context, d))).then(
                          (value) async {
                        //if the dialog that open is the init report, open now the dialog to add new report in that date
                        if (value == "first") {
                          await showDialog(
                            context: context,
                            builder: (context) => Dialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: dialogReport(null, context, d),
                            ),
                          );
                        }
                      });
                      //after close the dialog, update widget.reports and the _events in the new list of the date
                      var reports = Provider.of<Auth>(context, listen: false)
                          .getLastReport(d);
                      if (reports != null) {
                        widget.reports[d] = reports;
                        setState(() {
                          _events[selectedDay] = [];
                          for (var report in reports) {
                            _events[selectedDay].add("report");
                            if (report.keys.contains("type") &&
                                report["type"] != "")
                              _events[selectedDay].add("med");
                          }
                          if (widget.sessions.keys.contains(d))
                            for (var session in widget.sessions[d]) {
                              _events[selectedDay].add("session");
                            }
                        });
                      }
                      setState(() {
                        DateTime now = DateTime.now();
                        Duration oneDay = Duration(days: 1);
                        _selectedDate = now.add(oneDay);
                      });
                    }
                  },
                  calendarBuilders: CalendarBuilders(
                    //each event in _events, represent in the calender by color
                    //medicaition=red, headache=blue, session=green
                    singleMarkerBuilder: (context, date, event) {
                      Color cor = Color.fromARGB(255, 36, 88, 209);
                      if (event == "med")
                        cor = Color.fromARGB(255, 255, 77, 77);
                      if (event == "session")
                        cor = Color.fromARGB(255, 31, 179, 93);
                      return Container(
                        decoration:
                            BoxDecoration(shape: BoxShape.circle, color: cor),
                        width: 7.0,
                        height: 7.0,
                        margin: const EdgeInsets.symmetric(horizontal: 1.5),
                      );
                    },
                  ),
                  locale: language
                      .languageCode, //the calender will be in the language of the app
                  eventLoader: (day) {
                    return _events[day] ?? [];
                  },
                ),
              ),
              Row(
                //legend of the colors in the calender
                children: [
                  Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12.0, vertical: 20.0),
                      width: 14.0,
                      height: 14.0,
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 36, 88, 209),
                        shape: BoxShape.circle,
                      )),
                  Text(
                    AppLocalizations.of(context).translate('Headache'),
                    style: TextStyle(
                        fontFamily: "Laso",
                        fontSize: 16.0,
                        color: Color.fromARGB(255, 9, 40, 52)),
                  ),
                  Container(
                      margin: const EdgeInsets.symmetric(horizontal: 12.0),
                      width: 14.0,
                      height: 14.0,
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 255, 77, 77),
                        shape: BoxShape.circle,
                      )),
                  Text(AppLocalizations.of(context).translate('Medication'),
                      style: TextStyle(
                          fontFamily: "Laso",
                          fontSize: 16.0,
                          color: Color.fromARGB(255, 9, 40, 52))),
                  if (viewSessionPage == false)
                    Container(
                        margin: const EdgeInsets.symmetric(horizontal: 12.0),
                        width: 14.0,
                        height: 14.0,
                        decoration: BoxDecoration(
                          color: Color.fromARGB(255, 31, 179, 93),
                          shape: BoxShape.circle,
                        )),
                  if (viewSessionPage == false)
                    Text(AppLocalizations.of(context).translate('Session'),
                        style: TextStyle(
                            fontFamily: "Laso",
                            fontSize: 16.0,
                            color: Color.fromARGB(255, 9, 40, 52)))
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
