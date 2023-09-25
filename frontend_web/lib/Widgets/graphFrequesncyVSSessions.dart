import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
// import 'package:date_util/date_util.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:auto_size_text/auto_size_text.dart';

import '../AppLocalizations.dart';
// import './messageInGraph.dart';

//class that show in the graph
//x= month or day. y=frequency/session
class ChartData {
  ChartData(this.x, this.y);
  final String x;
  final double y;
}

class graphFrequesncyVSSessions extends StatefulWidget {
  static const routeName = '/tab-reports';
  var reports = null;
  var sessions = null;

  graphFrequesncyVSSessions({required this.sessions, required this.reports});

  @override
  _graphFrequesncyVSSessionsState createState() =>
      _graphFrequesncyVSSessionsState();
}

class _graphFrequesncyVSSessionsState extends State<graphFrequesncyVSSessions> {
  //frequency, session are the list of the all months or days
  //while the sub are the sub of lists of what show now in the graph
  List<ChartData> frequency = [];
  List<ChartData> frequency_sub = [];
  List<ChartData> session = [];
  List<ChartData> session_sub = [];
  //maps of all the frequency,session
  //the key is the year, the value is list of the month
  //for each month, it is map as well.
  //the key is the day and the value is the count/avarage. key=0, is the count/avg for the all months
  var allReportFrequency = {};
  var allSessions = {};
  //the list of the years that have
  List<int> yearsGraph = [];
  List monthsEn = [
    "Jan",
    "Feb",
    "Mar",
    "Apr",
    "May",
    "Jun",
    "Jul",
    "Aug",
    "Sep",
    "Oct",
    "Nov",
    "Dec"
  ];
  List monthsFullEn = [
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December"
  ];
  List monthHe = [
    "ינואר",
    "פברואר",
    "מרץ",
    "אפריל",
    "מאי",
    "יוני",
    "יולי",
    "אוגוסט",
    "ספטמבר",
    "אוקטובר",
    "נובמבר",
    "דצמבר"
  ];
  //what year show in the graph
  var showYearGraph;
  //the indexes of the sub lists
  var minGraph = 0, maxGraph = 3;
  //if the graph show the months of the year and not spesific month
  var isMonthsGraph = true;
  //how many days are in the month when the user switch to show spesific month
  var numberDaysGraph = 0;
  //how many months in the years. if the showYear is contemporary, so we show until the current month
  var numberMonthsGraph = 12;
  //the name of the month when the user switch to show spesific month
  var monthNameGraph = '';
  String? language;
  bool isDisplay = false;

//set the list of ChartData for the second graph to show year
//it is call in the initState or when the user choose other year
  void switchYearGraph(year) {
    isMonthsGraph = true;
    frequency = [];
    session = [];

    DateTime today = DateTime.now();
    if (today.year == year) {
      numberMonthsGraph = today.month;
    } else
      numberMonthsGraph = 12;
    List months = monthsEn;
    if (language == 'he') months = monthHe;
    minGraph = 0;
    maxGraph = 3;
    if (numberMonthsGraph < maxGraph) numberMonthsGraph = maxGraph;
    for (var i = 1; i <= numberMonthsGraph; i++) {
      if (allReportFrequency.keys.contains(year) &&
          allReportFrequency[year].keys.contains(i)) {
        frequency.add(ChartData(
            months[i - 1], allReportFrequency[year][i][0].toDouble()));
      } else {
        frequency.add(ChartData(months[i - 1], 0));
      }
      if (allSessions.keys.contains(year) &&
          allSessions[year].keys.contains(i)) {
        session
            .add(ChartData(months[i - 1], allSessions[year][i][0].toDouble()));
      } else {
        session.add(ChartData(months[i - 1], 0));
      }
    }

    setState(() {
      frequency_sub = frequency.getRange(minGraph, maxGraph).toList();
      session_sub = session.getRange(minGraph, maxGraph).toList();
    });
  }

  @override
  void initState() {
    language = AppLocalizations.of(context)!.locale.languageCode;
    var count = 0;
    var lastMonth = 0;
    var lastYear = 0;
    var month;
    var year;
    var init = false;
    if (widget.reports.length != 0) {
      var sumD = 0;
      var sumI = 0;
      //sort the reports by date
      List<MapEntry<dynamic, dynamic>> listMappedEntries =
          widget.reports.entries.toList();
      listMappedEntries.sort((a, b) => a.key.compareTo(b.key));
      widget.reports = Map.fromEntries(listMappedEntries);
      for (var date in widget.reports.keys) {
        year = date.year;
        month = date.month;
        var day = date.day;
        if (init == false) {
          lastMonth = month;
          lastYear = year;
          init = true;
        }
        //If it has moved to another month, then update the dictionaries
        if (lastMonth != month) {
          allReportFrequency[lastYear][lastMonth][0] = count;
          lastMonth = month;
          lastYear = year;
          sumD = 0;
          sumI = 0;
          count = 0;
        }
        //if date is new year, create map in the dictionaries, and add to the lists years
        if (!allReportFrequency.keys.contains(year)) {
          allReportFrequency[year] = {};
          yearsGraph.add(year);
        }
        //if date is new month,create map in the dictionaries
        if (!allReportFrequency[year].keys.contains(month)) {
          allReportFrequency[year][month] = {};
        }
        var c = 0;
        var sd = 0;
        var si = 0;
        for (var report in widget.reports[date]) {
          c++;
          count++;
        }
        //add the day avarage of the day in the dictionaries
        allReportFrequency[year][month][day] = c;
      }
      //add the day avarage of the month in the dictionaries
      allReportFrequency[lastYear][lastMonth][0] = count;
    }
    if (widget.sessions.length != 0) {
      count = 0;
      lastMonth = 0;
      lastYear = 0;
      month;
      year;
      init = false;
      List<MapEntry<dynamic, dynamic>> listMappedEntries =
          widget.sessions.entries.toList();
      listMappedEntries.sort((a, b) => a.key.compareTo(b.key));
      var sessions = Map.fromEntries(listMappedEntries);
      for (var date in sessions.keys) {
        year = date.year;
        month = date.month;
        var day = date.day;
        if (init == false) {
          lastMonth = month;
          lastYear = year;
          init = true;
        }
        if (lastMonth != month) {
          allSessions[lastYear][lastMonth][0] = count;
          lastMonth = month;
          lastYear = year;
          count = 0;
        }
        if (!allSessions.keys.contains(year)) {
          allSessions[year] = {};
          if (!yearsGraph.contains(year)) yearsGraph.add(year);
        }
        if (!allSessions[year].keys.contains(month)) {
          allSessions[year][month] = {};
        }
        count += widget.sessions[date].length as int;
        //add the day count of the day in the dictionaries
        allSessions[year][month][day] = sessions[date].length;
      }
      //add the day avarage of the month in the dictionaries
      allSessions[lastYear][lastMonth][0] = count;
      showYearGraph = yearsGraph.last;
      switchYearGraph(showYearGraph);
    }
    super.initState();
  }

//move forward in the graph, by change the sub lists
  void nextRange() {
    if (isMonthsGraph) {
      minGraph++;
      maxGraph++;
    } else {
      minGraph += 1;
      maxGraph += 1;
    }
    setState(() {
      frequency_sub = frequency.getRange(minGraph, maxGraph).toList();
      session_sub = session.getRange(minGraph, maxGraph).toList();
    });
  }

//move backwards in the graph, by change the sub lists
  void backRange() {
    if (isMonthsGraph) {
      minGraph--;
      maxGraph--;
    } else {
      minGraph -= 1;
      maxGraph -= 1;
    }
    setState(() {
      frequency_sub = frequency.getRange(minGraph, maxGraph).toList();
      session_sub = session.getRange(minGraph, maxGraph).toList();
    });
  }

//set the list of ChartData for the second graph to show spesific month
//it is call when the user choose click on month in the axis
  void switchToMonthGraph(month) {
    var m;
    List months = monthsFullEn;
    if (language == 'he') {
      months = monthHe;
      m = monthHe.indexOf(month) + 1;
    } else
      m = monthsEn.indexOf(month) + 1;
    if (!allReportFrequency[showYearGraph].keys.contains(m) &&
        !allSessions[showYearGraph].keys.contains(m)) return;
    monthNameGraph = months.elementAt(m - 1);
    isMonthsGraph = false;
    numberDaysGraph = DateTime(showYearGraph, m + 1, 0).day;
    DateTime today = DateTime.now();
    if (today.year == showYearGraph &&
        today.month == m &&
        today.day < numberDaysGraph) {
      numberDaysGraph = today.day;
    }
    frequency = [];
    session = [];
    minGraph = 0;
    maxGraph = 7;
    if (numberDaysGraph < maxGraph) numberDaysGraph = maxGraph;
    var days = [for (var i = 1; i <= numberDaysGraph; i++) i.toString()];
    for (var i = 1; i <= numberDaysGraph; i++) {
      if (allReportFrequency.keys.contains(showYearGraph) &&
          allReportFrequency[showYearGraph].keys.contains(m) &&
          allReportFrequency[showYearGraph][m].keys.contains(i)) {
        frequency.add(ChartData(
            days[i - 1], allReportFrequency[showYearGraph][m][i].toDouble()));
      } else {
        frequency.add(ChartData(days[i - 1], 0));
      }
      if (allSessions.keys.contains(showYearGraph) &&
          allSessions[showYearGraph].keys.contains(m) &&
          allSessions[showYearGraph][m].keys.contains(i)) {
        session.add(ChartData(
            days[i - 1], allSessions[showYearGraph][m][i].toDouble()));
      } else {
        session.add(ChartData(days[i - 1], 0));
      }
    }
    setState(() {
      frequency_sub = frequency.getRange(minGraph, maxGraph).toList();
      session_sub = session.getRange(minGraph, maxGraph).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: SafeArea(
        child: Padding(
          padding:
              const EdgeInsets.only( top: 2.0, right: 10, left: 10),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.only(
                top: 5, bottom: 5.0, left: 8.0, right: 8.0),
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
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.only(top: 5.0, bottom: 2.0),
                  child: AutoSizeText(
                    ' ${AppLocalizations.of(context)!.translate('graphTitle2')}',
                    maxLines: 1,
                    style: GoogleFonts.nunito(
                        textStyle: TextStyle(
                      fontSize: 16.0,
                      color: Color.fromARGB(255, 9, 40, 52),
                    )),
                  ),
                ),
                Divider(
                  thickness: 1,
                ),
                if (isMonthsGraph == false)
                  Container(
                      padding: EdgeInsets.only(left: 20.0, right: 20.0),
                      // margin: EdgeInsets.only(top: 2.0),
                      child: OutlinedButton(
                        onPressed: (() => switchYearGraph(showYearGraph)),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.arrow_back, size: 20),
                            Padding(
                              padding: const EdgeInsets.only(left: 5.0),
                              child: Text(
                                monthNameGraph,
                                style: GoogleFonts.nunito(
                                    textStyle: TextStyle(
                                        fontSize: 14.0,
                                        color: Color.fromARGB(217, 33, 38, 38),
                                        fontWeight: FontWeight.bold)),
                              ),
                            ),
                            SizedBox(width: 2),
                          ],
                        ),
                      ))
                else
                  Container(
                    padding: EdgeInsets.only(left: 20.0, right: 20.0),
                    // margin: EdgeInsets.only(top: 2.0),
                    child: DropdownButton(
                        borderRadius: BorderRadius.circular(20),
                        value: showYearGraph,
                        style: GoogleFonts.nunito(
                            textStyle: TextStyle(
                                fontSize: 14.0, fontWeight: FontWeight.bold)),
                        items: yearsGraph.map((int value) {
                          return new DropdownMenuItem<int>(
                            value: value,
                            alignment: AlignmentDirectional.centerStart,
                            child: new Text(
                              value.toString(),
                              style: GoogleFonts.nunito(
                                  textStyle: TextStyle(
                                      fontSize: 14.0,
                                      color: Color.fromARGB(217, 33, 38, 38),
                                      fontWeight: FontWeight.bold)),
                            ),
                          );
                        }).toList(),
                        onChanged: (newYear) {
                          showYearGraph = newYear;
                          switchYearGraph(showYearGraph);
                        }),
                  ),
                SfCartesianChart(
                    primaryXAxis: CategoryAxis(
                        labelStyle: GoogleFonts.comfortaa(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Colors.black)),
                    primaryYAxis: NumericAxis(
                        labelStyle: GoogleFonts.comfortaa(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Colors.black),
                        title: AxisTitle(
                            text: AppLocalizations.of(context)!
                                .translate('Session'),
                            textStyle: GoogleFonts.comfortaa(
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                                color: Color.fromARGB(255, 76, 50, 223)))),
                    axes: [
                      NumericAxis(
                          name: 'yAxis',
                          labelStyle: GoogleFonts.comfortaa(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Colors.black),
                          title: AxisTitle(
                              text: AppLocalizations.of(context)!
                                  .translate('Frequency'),
                              textStyle: GoogleFonts.comfortaa(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: Color.fromARGB(255, 84, 211, 118),
                              )),
                          opposedPosition: true)
                    ],
                    onAxisLabelTapped: (AxisLabelTapArgs args) {
                      if (isMonthsGraph) switchToMonthGraph(args.text);
                    },
                    tooltipBehavior: TooltipBehavior(
                      enable: true,
                    ),
                    series: <ChartSeries<ChartData, dynamic>>[
                      ColumnSeries<ChartData, dynamic>(
                          dataSource: session_sub,
                          xValueMapper: (ChartData data, _) => data.x,
                          yValueMapper: (ChartData data, _) => data.y,
                          markerSettings: MarkerSettings(isVisible: true),
                          name: AppLocalizations.of(context)!
                              .translate('Session'),
                          color: Color.fromARGB(255, 76, 50, 223)),
                      ColumnSeries<ChartData, dynamic>(
                          dataSource: frequency_sub,
                          xValueMapper: (ChartData data, _) => data.x,
                          yValueMapper: (ChartData data, _) => data.y,
                          markerSettings: MarkerSettings(isVisible: true),
                          name: AppLocalizations.of(context)!
                              .translate('Frequency'),
                          color: Color.fromARGB(255, 84, 211, 118),
                          //Bind the x-axis to secondary x-axis.
                          xAxisName: 'xAxis',

                          //Bind the y-axis to secondary y-axis.
                          yAxisName: 'yAxis')
                    ]),
                Row(
                  textDirection: TextDirection.ltr,

                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      // decoration: BoxDecoration(
                      //   borderRadius: BorderRadius.circular(50),
                      //   border: Border.all(
                      //     color: Color.fromARGB(255, 244, 249, 251),
                      //   ),
                      // ),
                      child: minGraph != 0
                          ? new IconButton(
                              icon: new Icon(
                                Icons.arrow_back_ios_new,
                                size: 15.0,
                                color: Color.fromARGB(255, 29, 73, 91),
                              ),
                              onPressed: () => backRange(),
                              splashColor: Color.fromARGB(230, 226, 214, 187),
                            )
                          : Container(),
                    ),
                    Container(
                      // decoration: BoxDecoration(
                      //   borderRadius: BorderRadius.circular(50),
                      //   border: Border.all(
                      //     color: Color.fromARGB(255, 244, 249, 251),
                      //   ),
                      // ),
                      child: ((maxGraph != numberMonthsGraph &&
                                  isMonthsGraph) ||
                              isMonthsGraph == false &&
                                  numberDaysGraph != maxGraph)
                          ? Directionality(
                              textDirection: TextDirection.ltr,
                              child: new IconButton(
                                icon: new Icon(
                                  Icons.arrow_forward_ios,
                                  size: 15.0,
                                  color: Color.fromARGB(255, 29, 73, 91),
                                ),
                                onPressed: () => nextRange(),
                                splashColor: Color.fromARGB(230, 226, 214, 187),
                              ),
                            )
                          : Container(),
                    ),
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
