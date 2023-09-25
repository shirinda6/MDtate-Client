import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:date_util/date_util.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:auto_size_text/auto_size_text.dart';

import '../providers/auth.dart';
import '../AppLocalizations.dart';
import './messageInGraph.dart';

//class that show in the graph
//x= month or day. y=duration/intensity/frequency/session
class ChartData {
  ChartData(this.x, this.y);
  final String x;
  final double y;
}

class Graph extends StatefulWidget {
  static const routeName = '/tab-reports';
  var reports = null;
  var sessions = null;

  Graph(this.reports, this.sessions);

  @override
  _GraphState createState() => _GraphState();
}

class _GraphState extends State<Graph> {
  var viewSessionPage = false; //if show the session pageg or not
  var reports;
  //duration, intensity, frequency, session are the list of the all months or days
  //while the sub are the sub of lists of what show now in the graph
  List<ChartData> duration = [];
  List<ChartData> duration_sub = [];
  List<ChartData> intensity = [];
  List<ChartData> intensity_sub = [];
  List<ChartData> frequency = [];
  List<ChartData> frequency_sub = [];
  List<ChartData> session = [];
  List<ChartData> session_sub = [];
  //maps of all the duration,intensity,frequency,session
  //the key is the year, the value is list of the month
  //for each month, it is map as well.
  //the key is the day and the value is the count/avarage. key=0, is the count/avg for the all months
  var allReportDuration = {};
  var allReportIntensity = {};
  var allReportFrequency = {};
  var allSessions = {};
  //the list of the years that have
  List<int> yearsGraph1 = [];
  List<int> yearsGraph2 = [];
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
  var showYearGraph1;
  var showYearGraph2;
  //the indexes of the sub lists
  var minGraph1 = 0, maxGraph1 = 3;
  var minGraph2 = 0, maxGraph2 = 3;
  //if the graph show the months of the year and not spesific month
  var isMonthsGraph1 = true;
  var isMonthsGraph2 = true;
  //how many days are in the month when the user switch to show spesific month
  var numberDaysGraph1 = 0;
  var numberDaysGraph2 = 0;
  //how many months in the years. if the showYear is contemporary, so we show until the current month
  var numberMonthsGraph1 = 12;
  var numberMonthsGraph2 = 12;
  //the name of the month when the user switch to show spesific month
  var monthNameGraph1 = '';
  var monthNameGraph2 = '';
  Locale language;
  bool isDisplay = false;

//set the list of ChartData for the first graph to show year
//it is call in the initState or when the user choose other year
  void switchYearGraph1(year) {
    isMonthsGraph1 = true;
    duration = [];
    intensity = [];

    DateTime today = DateTime.now();
    //if the showYear is contemporary, so we show until the current month
    if (today.year == year) {
      numberMonthsGraph1 = today.month;
    } else
      numberMonthsGraph1 = 12;
    List months = monthsEn;
    if (language.languageCode == 'he') months = monthHe;
    minGraph1 = 0;
    maxGraph1 = 3;
    //if the numbers of graph is less then3
    if (numberMonthsGraph1 < maxGraph1) numberMonthsGraph1 = maxGraph1;
    //create the ChartData from the data allReportDuration and allReportIntensity
    for (var i = 1; i <= numberMonthsGraph1; i++) {
      if (allReportDuration[year].keys.contains(i)) {
        duration.add(ChartData(months[i - 1], allReportDuration[year][i][0]));
        intensity.add(ChartData(months[i - 1], allReportIntensity[year][i][0]));
      } else {
        duration.add(ChartData(months[i - 1], 0));
        intensity.add(ChartData(months[i - 1], 0));
      }
    }

    //set the sub lists that show in the graph
    setState(() {
      duration_sub = duration.getRange(minGraph1, maxGraph1).toList();
      intensity_sub = intensity.getRange(minGraph1, maxGraph1).toList();
    });
  }

//set the list of ChartData for the second graph to show year
  void switchYearGraph2(year) {
    isMonthsGraph2 = true;
    frequency = [];
    session = [];

    DateTime today = DateTime.now();
    if (today.year == year) {
      numberMonthsGraph2 = today.month;
    } else
      numberMonthsGraph2 = 12;
    List months = monthsEn;
    if (language.languageCode == 'he') months = monthHe;
    minGraph2 = 0;
    maxGraph2 = 3;
    if (numberMonthsGraph2 < maxGraph2) numberMonthsGraph2 = maxGraph2;
    for (var i = 1; i <= numberMonthsGraph2; i++) {
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
      frequency_sub = frequency.getRange(minGraph2, maxGraph2).toList();
      session_sub = session.getRange(minGraph2, maxGraph2).toList();
    });
  }

  @override
  void initState() {
    viewSessionPage = Provider.of<Auth>(context, listen: false).getViewSession;
    language = Provider.of<Auth>(context, listen: false).getLanguage;
    reports = Provider.of<Auth>(context, listen: false).getReports;
    var display = Provider.of<Auth>(context, listen: false).DisplayMessage;
    //there is dialog that open to explain to the user that he can click on the months in graph
    if (display == false) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return MessageGraphDialog();
          },
        );
      });
    }
    var count = 0;
    var lastMonth = 0;
    var lastYear = 0;
    var month;
    var year;
    var init = false;
    if (reports.length != 0) {
      var sumD = 0;
      var sumI = 0;
      //sort the reports by date
      List<MapEntry<dynamic, dynamic>> listMappedEntries =
          reports.entries.toList();
      listMappedEntries.sort((a, b) => a.key.compareTo(b.key));
      reports = Map.fromEntries(listMappedEntries);
      for (var date in reports.keys) {
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
          allReportDuration[lastYear][lastMonth][0] = sumD / count;
          allReportIntensity[lastYear][lastMonth][0] = sumI / count;
          allReportFrequency[lastYear][lastMonth][0] = count;
          lastMonth = month;
          lastYear = year;
          sumD = 0;
          sumI = 0;
          count = 0;
        }
        //if date is new year, create map in the dictionaries, and add to the lists years
        if (!allReportDuration.keys.contains(year)) {
          allReportDuration[year] = {};
          allReportIntensity[year] = {};
          allReportFrequency[year] = {};
          yearsGraph1.add(year);
          yearsGraph2.add(year);
        }
        //if date is new month,create map in the dictionaries
        if (!allReportDuration[year].keys.contains(month)) {
          allReportDuration[year][month] = {};
          allReportIntensity[year][month] = {};
          allReportFrequency[year][month] = {};
        }
        var c = 0;
        var sd = 0;
        var si = 0;
        for (var report in reports[date]) {
          c++;
          sd += int.parse(report["duration"]);
          si += int.parse(report["intensity"]);
          count++;
          sumD += int.parse(report["duration"]);
          sumI += int.parse(report["intensity"]);
        }
        //add the day avarage of the day in the dictionaries
        allReportDuration[year][month][day] = sd / c;
        allReportIntensity[year][month][day] = si / c;
        allReportFrequency[year][month][day] = c;
      }
      //add the day avarage of the month in the dictionaries
      allReportDuration[lastYear][lastMonth][0] = sumD / count;
      allReportIntensity[lastYear][lastMonth][0] = sumI / count;
      allReportFrequency[lastYear][lastMonth][0] = count;
      showYearGraph1 = yearsGraph1.last;
      switchYearGraph1(showYearGraph1);
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
          if (!yearsGraph2.contains(year)) yearsGraph2.add(year);
        }
        if (!allSessions[year].keys.contains(month)) {
          allSessions[year][month] = {};
        }
        count += sessions[date].length;
        //add the day count of the day in the dictionaries
        allSessions[year][month][day] = sessions[date].length;
      }
      //add the day avarage of the month in the dictionaries
      allSessions[lastYear][lastMonth][0] = count;
      showYearGraph2 = yearsGraph2.last;
      switchYearGraph2(showYearGraph2);
    }
    super.initState();
  }

//move forward in the graph, by change the sub lists
  void nextRange(int graph) {
    if (graph == 1) {
      if (isMonthsGraph1) {
        minGraph1++;
        maxGraph1++;
      } else {
        minGraph1 += 1;
        maxGraph1 += 1;
      }
      setState(() {
        duration_sub = duration.getRange(minGraph1, maxGraph1).toList();
        intensity_sub = intensity.getRange(minGraph1, maxGraph1).toList();
      });
    }

    if (graph == 2) {
      if (isMonthsGraph2) {
        minGraph2++;
        maxGraph2++;
      } else {
        minGraph2 += 1;
        maxGraph2 += 1;
      }
      setState(() {
        frequency_sub = frequency.getRange(minGraph2, maxGraph2).toList();
        session_sub = session.getRange(minGraph2, maxGraph2).toList();
      });
    }
  }

//move backwards in the graph, by change the sub lists
  void backRange(int graph) {
    if (graph == 1) {
      if (isMonthsGraph1) {
        minGraph1--;
        maxGraph1--;
      } else {
        minGraph1 -= 1;
        maxGraph1 -= 1;
      }
      setState(() {
        duration_sub = duration.getRange(minGraph1, maxGraph1).toList();
        intensity_sub = intensity.getRange(minGraph1, maxGraph1).toList();
      });
    }

    if (graph == 2) {
      if (isMonthsGraph2) {
        minGraph2--;
        maxGraph2--;
      } else {
        minGraph2 -= 1;
        maxGraph2 -= 1;
      }
      setState(() {
        frequency_sub = frequency.getRange(minGraph2, maxGraph2).toList();
        session_sub = session.getRange(minGraph2, maxGraph2).toList();
      });
    }
  }

//set the list of ChartData for the first graph to show spesific month
//it is call when the user choose click on month in the axis
  void switchToMonthGraph1(month) {
    var m;
    List months = monthsFullEn;
    if (language.languageCode == 'he') {
      months = monthHe;
      m = monthHe.indexOf(month) + 1;
    } else
      m = monthsEn.indexOf(month) + 1;
    //if there aren't reports in that month so not swith
    if (!allReportDuration[showYearGraph1].keys.contains(m)) return;
    monthNameGraph1 = months.elementAt(m - 1);
    isMonthsGraph1 = false;
    var dateUtility = DateUtil();
    //check how days in that month
    numberDaysGraph1 = dateUtility.daysInMonth(m, showYearGraph1);
    DateTime today = DateTime.now();
    if (today.year == showYearGraph1 &&
        today.month == m &&
        today.day < numberDaysGraph1) {
      numberDaysGraph1 = today.day;
    }
    duration = [];
    intensity = [];
    minGraph1 = 0;
    maxGraph1 = 7;
    //if the numbers of graph is less then 3
    if (numberDaysGraph1 < maxGraph1) numberDaysGraph1 = maxGraph1;
    //create the data for x axis
    var days = [for (var i = 1; i <= numberDaysGraph1; i++) i.toString()];
    //create the ChartData from the data allReportDuration and allReportIntensity
    for (var i = 1; i <= numberDaysGraph1; i++) {
      if (allReportDuration[showYearGraph1][m].keys.contains(i)) {
        duration.add(
            ChartData(days[i - 1], allReportDuration[showYearGraph1][m][i]));
        intensity.add(
            ChartData(days[i - 1], allReportIntensity[showYearGraph1][m][i]));
      } else {
        duration.add(ChartData(days[i - 1], 0));
        intensity.add(ChartData(days[i - 1], 0));
      }
    }
    //set the sub lists that show in the graph
    setState(() {
      duration_sub = duration.getRange(minGraph1, maxGraph1).toList();
      intensity_sub = intensity.getRange(minGraph1, maxGraph1).toList();
    });
  }

//set the list of ChartData for the second graph to show spesific month
  void switchToMonthGraph2(month) {
    var m;
    List months = monthsFullEn;
    if (language.languageCode == 'he') {
      months = monthHe;
      m = monthHe.indexOf(month) + 1;
    } else
      m = monthsEn.indexOf(month) + 1;
    if (!allReportFrequency[showYearGraph2].keys.contains(m) &&
        !allSessions[showYearGraph2].keys.contains(m)) return;
    monthNameGraph2 = months.elementAt(m - 1);
    isMonthsGraph2 = false;
    var dateUtility = DateUtil();
    numberDaysGraph2 = dateUtility.daysInMonth(m, showYearGraph2);
    DateTime today = DateTime.now();
    if (today.year == showYearGraph2 &&
        today.month == m &&
        today.day < numberDaysGraph2) {
      numberDaysGraph2 = today.day;
    }
    frequency = [];
    session = [];
    minGraph2 = 0;
    maxGraph2 = 7;
    if (numberDaysGraph2 < maxGraph2) numberDaysGraph2 = maxGraph2;
    var days = [for (var i = 1; i <= numberDaysGraph2; i++) i.toString()];
    for (var i = 1; i <= numberDaysGraph2; i++) {
      if (allReportFrequency.keys.contains(showYearGraph2) &&
          allReportFrequency[showYearGraph2].keys.contains(m) &&
          allReportFrequency[showYearGraph2][m].keys.contains(i)) {
        frequency.add(ChartData(
            days[i - 1], allReportFrequency[showYearGraph2][m][i].toDouble()));
      } else {
        frequency.add(ChartData(days[i - 1], 0));
      }
      if (allSessions.keys.contains(showYearGraph2) &&
          allSessions[showYearGraph2].keys.contains(m) &&
          allSessions[showYearGraph2][m].keys.contains(i)) {
        session.add(ChartData(
            days[i - 1], allSessions[showYearGraph2][m][i].toDouble()));
      } else {
        session.add(ChartData(days[i - 1], 0));
      }
    }
    setState(() {
      frequency_sub = frequency.getRange(minGraph2, maxGraph2).toList();
      session_sub = session.getRange(minGraph2, maxGraph2).toList();
    });
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
                padding: const EdgeInsets.only(
                    top: 5, bottom: 5.0, left: 10.0, right: 10.0),
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
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.only(top: 5.0, bottom: 2.0),
                      child: AutoSizeText(
                        ' ${AppLocalizations.of(context).translate('graphTitle1')}',
                        maxLines: 1,
                        style: GoogleFonts.nunito(
                            textStyle: TextStyle(
                          fontSize: 18.0,
                          color: Color.fromARGB(255, 9, 40, 52),
                        )),
                      ),
                    ),
                    Divider(
                      thickness: 2,
                    ),
                    isMonthsGraph1 == false
                        ? Container(
                            padding: EdgeInsets.only(left: 20.0, right: 20.0),
                            margin: EdgeInsets.only(top: 5.0),
                            child: OutlinedButton(
                              onPressed: (() =>
                                  switchYearGraph1(showYearGraph1)),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.arrow_back, size: 30),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 5.0),
                                    child: Text(
                                      monthNameGraph1,
                                      style: GoogleFonts.nunito(
                                          textStyle: TextStyle(
                                              fontSize: 18.0,
                                              color: Color.fromARGB(
                                                  217, 33, 38, 38),
                                              fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                  SizedBox(width: 5),
                                ],
                              ),
                            ))
                        : Container(),
                    isMonthsGraph1
                        ? Container(
                            padding: EdgeInsets.only(left: 30.0, right: 30.0),
                            margin: EdgeInsets.only(top: 5.0),
                            child: DropdownButton(
                                dropdownColor:
                                    Color.fromARGB(255, 244, 249, 251),
                                borderRadius: BorderRadius.circular(30),
                                value: showYearGraph1,
                                style: GoogleFonts.nunito(
                                    textStyle: TextStyle(
                                        fontSize: 17.0,
                                        fontWeight: FontWeight.bold)),
                                items: yearsGraph1.map((int value) {
                                  return new DropdownMenuItem<int>(
                                    value: value,
                                    alignment: AlignmentDirectional.centerStart,
                                    child: new Text(
                                      value.toString(),
                                      style: GoogleFonts.nunito(
                                          textStyle: TextStyle(
                                              fontSize: 17.0,
                                              color: Color.fromARGB(
                                                  217, 33, 38, 38),
                                              fontWeight: FontWeight.bold)),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (newYear) {
                                  showYearGraph1 = newYear;
                                  switchYearGraph1(showYearGraph1);
                                }),
                          )
                        : Container(),
                    SfCartesianChart(
                        primaryXAxis: CategoryAxis(
                            labelStyle: GoogleFonts.comfortaa(
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                                color: Colors.black)),
                        primaryYAxis: NumericAxis(
                            labelStyle: GoogleFonts.comfortaa(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: Colors.black),
                            title: AxisTitle(
                                text: AppLocalizations.of(context)
                                    .translate('Duration'),
                                textStyle: GoogleFonts.comfortaa(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w400,
                                    color: Color.fromARGB(255, 221, 137, 63)))),
                        axes: [
                          NumericAxis(
                              name: 'yAxis',
                              labelStyle: GoogleFonts.comfortaa(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black),
                              title: AxisTitle(
                                  text: AppLocalizations.of(context)
                                      .translate('Intensity'),
                                  textStyle: GoogleFonts.comfortaa(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w400,
                                    color: Color.fromARGB(255, 195, 50, 86),
                                  )),
                              opposedPosition: true)
                        ],
                        onAxisLabelTapped: (AxisLabelTapArgs args) {
                          if (isMonthsGraph1) switchToMonthGraph1(args.text);
                        },
                        tooltipBehavior: TooltipBehavior(
                          enable: true,
                        ),
                        series: <ChartSeries<ChartData, dynamic>>[
                          SplineSeries<ChartData, dynamic>(
                              dataSource: duration_sub,
                              xValueMapper: (ChartData data, _) => data.x,
                              yValueMapper: (ChartData data, _) => data.y,
                              markerSettings: MarkerSettings(isVisible: true),
                              name: AppLocalizations.of(context)
                                  .translate('Duration'),
                              color: Color.fromARGB(255, 219, 148, 90)),
                          SplineSeries<ChartData, dynamic>(
                              dataSource: intensity_sub,
                              xValueMapper: (ChartData data, _) => data.x,
                              yValueMapper: (ChartData data, _) => data.y,
                              markerSettings: MarkerSettings(isVisible: true),
                              name: AppLocalizations.of(context)
                                  .translate('Intensity'),
                              color: Color.fromARGB(255, 195, 50, 86),
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
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            border: Border.all(
                              color: Color.fromARGB(255, 244, 249, 251),
                            ),
                          ),
                          child: minGraph1 !=
                                  0 //if the minGraph1=0 the button not display
                              ? new IconButton(
                                  icon: new Icon(
                                    Icons.arrow_back_ios_new,
                                    color: Color.fromARGB(255, 29, 73, 91),
                                  ),
                                  onPressed: () => backRange(1),
                                  splashColor:
                                      Color.fromARGB(230, 226, 214, 187),
                                )
                              : Container(),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            border: Border.all(
                              color: Color.fromARGB(255, 244, 249, 251),
                            ),
                          ),
                          child: ((maxGraph1 != numberMonthsGraph1 &&
                                      isMonthsGraph1) ||
                                  isMonthsGraph1 == false &&
                                      numberDaysGraph1 !=
                                          maxGraph1) //if to show the forward button
                              ? Directionality(
                                  textDirection: TextDirection.ltr,
                                  child: new IconButton(
                                    icon: new Icon(
                                      Icons.arrow_forward_ios,
                                      color: Color.fromARGB(255, 29, 73, 91),
                                    ),
                                    onPressed: () => nextRange(1),
                                    splashColor:
                                        Color.fromARGB(230, 226, 214, 187),
                                  ),
                                )
                              : Container(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 25.0,
              ),
              if (viewSessionPage == false)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(
                      top: 5, bottom: 5.0, left: 10.0, right: 10.0),
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
                          ' ${AppLocalizations.of(context).translate('graphTitle2')}',
                          maxLines: 1,
                          style: GoogleFonts.nunito(
                              textStyle: TextStyle(
                            fontSize: 18.0,
                            color: Color.fromARGB(255, 9, 40, 52),
                          )),
                        ),
                      ),
                      Divider(
                        thickness: 2,
                      ),
                      if (isMonthsGraph2 == false)
                        Container(
                            padding: EdgeInsets.only(left: 20.0, right: 20.0),
                            margin: EdgeInsets.only(top: 5.0),
                            child: OutlinedButton(
                              onPressed: (() =>
                                  switchYearGraph2(showYearGraph2)),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.arrow_back, size: 30),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 5.0),
                                    child: Text(
                                      monthNameGraph2,
                                      style: GoogleFonts.nunito(
                                          textStyle: TextStyle(
                                              fontSize: 15.0,
                                              color: Color.fromARGB(
                                                  217, 33, 38, 38),
                                              fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                  SizedBox(width: 5),
                                ],
                              ),
                            ))
                      else
                        Container(
                          padding: EdgeInsets.only(left: 30.0, right: 30.0),
                          margin: EdgeInsets.only(top: 10.0),
                          child: DropdownButton(
                              borderRadius: BorderRadius.circular(20),
                              value: showYearGraph2,
                              style: GoogleFonts.nunito(
                                  textStyle: TextStyle(
                                      fontSize: 17.0,
                                      fontWeight: FontWeight.bold)),
                              items: yearsGraph2.map((int value) {
                                return new DropdownMenuItem<int>(
                                  value: value,
                                  alignment: AlignmentDirectional.centerStart,
                                  child: new Text(
                                    value.toString(),
                                    style: GoogleFonts.nunito(
                                        textStyle: TextStyle(
                                            fontSize: 17.0,
                                            color:
                                                Color.fromARGB(217, 33, 38, 38),
                                            fontWeight: FontWeight.bold)),
                                  ),
                                );
                              }).toList(),
                              onChanged: (newYear) {
                                showYearGraph2 = newYear;
                                switchYearGraph2(showYearGraph2);
                              }),
                        ),
                      SfCartesianChart(
                          primaryXAxis: CategoryAxis(
                              labelStyle: GoogleFonts.comfortaa(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black)),
                          primaryYAxis: NumericAxis(
                              labelStyle: GoogleFonts.comfortaa(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black),
                              title: AxisTitle(
                                  text: AppLocalizations.of(context)
                                      .translate('Session'),
                                  textStyle: GoogleFonts.comfortaa(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w400,
                                      color:
                                          Color.fromARGB(255, 76, 50, 223)))),
                          axes: [
                            NumericAxis(
                                name: 'yAxis',
                                labelStyle: GoogleFonts.comfortaa(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black),
                                title: AxisTitle(
                                    text: AppLocalizations.of(context)
                                        .translate('Frequency'),
                                    textStyle: GoogleFonts.comfortaa(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w500,
                                      color: Color.fromARGB(255, 84, 211, 118),
                                    )),
                                opposedPosition: true)
                          ],
                          onAxisLabelTapped: (AxisLabelTapArgs args) {
                            if (isMonthsGraph2) switchToMonthGraph2(args.text);
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
                                name: AppLocalizations.of(context)
                                    .translate('Session'),
                                color: Color.fromARGB(255, 76, 50, 223)),
                            ColumnSeries<ChartData, dynamic>(
                                dataSource: frequency_sub,
                                xValueMapper: (ChartData data, _) => data.x,
                                yValueMapper: (ChartData data, _) => data.y,
                                markerSettings: MarkerSettings(isVisible: true),
                                name: AppLocalizations.of(context)
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
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              border: Border.all(
                                color: Color.fromARGB(255, 244, 249, 251),
                              ),
                            ),
                            child: minGraph2 != 0
                                ? new IconButton(
                                    icon: new Icon(
                                      Icons.arrow_back_ios_new,
                                      color: Color.fromARGB(255, 29, 73, 91),
                                    ),
                                    onPressed: () => backRange(2),
                                    splashColor:
                                        Color.fromARGB(230, 226, 214, 187),
                                  )
                                : Container(),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              border: Border.all(
                                color: Color.fromARGB(255, 244, 249, 251),
                              ),
                            ),
                            child: ((maxGraph2 != numberMonthsGraph2 &&
                                        isMonthsGraph2) ||
                                    isMonthsGraph2 == false &&
                                        numberDaysGraph2 != maxGraph2)
                                ? Directionality(
                                    textDirection: TextDirection.ltr,
                                    child: new IconButton(
                                      icon: new Icon(
                                        Icons.arrow_forward_ios,
                                        color: Color.fromARGB(255, 29, 73, 91),
                                      ),
                                      onPressed: () => nextRange(2),
                                      splashColor:
                                          Color.fromARGB(230, 226, 214, 187),
                                    ),
                                  )
                                : Container(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
