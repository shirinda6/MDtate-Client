import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

import './list_reports_day.dart';
import '../AppLocalizations.dart';

class Calender extends StatefulWidget {
  var sessions;
  var reports;

  Calender({required this.sessions, required this.reports});
  @override
  _CalenderState createState() => _CalenderState();
}

class _CalenderState extends State<Calender> {
  DateTime _focusedDay = DateTime.now();
  Map<DateTime, List> _events = {};
  DateTime? _selectedDate;
  bool showList = false;
  List reportsForDay = [];
  List seesionsForDay = [];
  Locale? language;

  @override
  void initState() {
    language = AppLocalizations.of(context)!.locale;
    for (var date in widget.reports.keys) {
      for (var report in widget.reports[date]) {
        DateTime d = DateTime.utc(date.year, date.month, date.day);
        if (!_events.keys.contains(d)) _events[d] = [];
        _events[d]!.add("report");
        if (report.keys.contains("type") && report["type"] != "")
          _events[d]!.add("med");
      }
    }
    for (var date in widget.sessions.keys) {
      for (var session in widget.sessions[date]) {
        DateTime d = DateTime.utc(date.year, date.month, date.day);
        if (!_events.keys.contains(d)) _events[d] = [];
        _events[d]!.add("session");
      }
    }

    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: TableCalendar(
        firstDay: DateTime(1970),
        lastDay: DateTime.now(),
        focusedDay: _focusedDay,
        locale: language!.languageCode,
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
        ),
        onDaySelected: (selectedDay, focusedDay) async {
          //when the user click on a certain day in calender
          if (!isSameDay(_selectedDate, selectedDay)) {
            var d =
                DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
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
            if (showList == true)
              await showDialog(
                  context: context,
                  builder: (context) => Dialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: ListReports(
                          context, reportsForDay, seesionsForDay, d)));
          }
        },
        calendarBuilders: CalendarBuilders(
          //each event in _events, represent in the calender by color
          //medicaition=red, headache=blue, session=green
          singleMarkerBuilder: (context, date, event) {
            Color cor = Color.fromARGB(255, 36, 88, 209);
            if (event == "med") cor = Color.fromARGB(255, 255, 77, 77);
            if (event == "session") cor = Color.fromARGB(255, 31, 179, 93);
            return Container(
              decoration: BoxDecoration(shape: BoxShape.circle, color: cor),
              width: 5.0,
              height: 5.0,
              margin: const EdgeInsets.symmetric(horizontal: 1.1),
            );
          },
        ),
        eventLoader: (day) {
          return _events[day] ?? [];
        },
      ),
    );
  }
}
