import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
// import 'package:date_util/date_util.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:auto_size_text/auto_size_text.dart';

import '../AppLocalizations.dart';
// import './messageInGraph.dart';

//class that show in the graph
//x= month or day. y=duration/intensity
class ChartData {
  ChartData(this.x, this.y);
  final String x;
  final double y;
}

class graphIntensityVSDuration extends StatefulWidget {
  static const routeName = '/tab-reports';
  var reports = null;

  graphIntensityVSDuration({required this.reports});

  @override
  _graphIntensityVSDurationState createState() =>
      _graphIntensityVSDurationState();
}

class _graphIntensityVSDurationState extends State<graphIntensityVSDuration> {
  //duration, intensity are the list of the all months or days
  //while the sub are the sub of lists of what show now in the graph
  List<ChartData> duration = [];
  List<ChartData> duration_sub = [];
  List<ChartData> intensity = [];
  List<ChartData> intensity_sub = [];
  //maps of all the duration,intensity,frequency,session
  //the key is the year, the value is list of the month
  //for each month, it is map as well.
  //the key is the day and the value is the count/avarage. key=0, is the count/avg for the all months
  var allReportDuration = {};
  var allReportIntensity = {};
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

//set the list of ChartData for the first graph to show year
//it is call in the initState or when the user choose other year
  void switchYearGraph(year) {
    isMonthsGraph = true;
    duration = [];
    intensity = [];

    DateTime today = DateTime.now();
    //if the showYear is contemporary, so we show until the current month
    if (today.year == year) {
      numberMonthsGraph = today.month;
    } else
      numberMonthsGraph = 12;
    List months = monthsEn;
    if (language == 'he') months = monthHe;
    minGraph = 0;
    maxGraph = 3;
    //if the numbers of graph is less then3
    if (numberMonthsGraph < maxGraph) numberMonthsGraph = maxGraph;
    //create the ChartData from the data allReportDuration and allReportIntensity
    for (var i = 1; i <= numberMonthsGraph; i++) {
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
      duration_sub = duration.getRange(minGraph, maxGraph).toList();
      intensity_sub = intensity.getRange(minGraph, maxGraph).toList();
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
          allReportDuration[lastYear][lastMonth][0] = sumD / count;
          allReportIntensity[lastYear][lastMonth][0] = sumI / count;
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
          yearsGraph.add(year);
        }
        //if date is new month,create map in the dictionaries
        if (!allReportDuration[year].keys.contains(month)) {
          allReportDuration[year][month] = {};
          allReportIntensity[year][month] = {};
        }
        var c = 0;
        var sd = 0;
        var si = 0;
        for (var report in widget.reports[date]) {
          c++;
          if (report["duration"] is String) {
            sd += int.parse(report["duration"]);
            si += int.parse(report["intensity"]);
            count++;
            sumD += int.parse(report["duration"]);
            sumI += int.parse(report["intensity"]);
          } else {
            sd += report["duration"] as int;
            si += report["intensity"] as int;
            count++;
            sumD += report["duration"] as int;
            sumI += report["intensity"] as int;
          }
        }
        //add the day avarage of the day in the dictionaries
        allReportDuration[year][month][day] = sd / c;
        allReportIntensity[year][month][day] = si / c;
      }
      //add the day avarage of the month in the dictionaries
      allReportDuration[lastYear][lastMonth][0] = sumD / count;
      allReportIntensity[lastYear][lastMonth][0] = sumI / count;
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
      duration_sub = duration.getRange(minGraph, maxGraph).toList();
      intensity_sub = intensity.getRange(minGraph, maxGraph).toList();
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
      duration_sub = duration.getRange(minGraph, maxGraph).toList();
      intensity_sub = intensity.getRange(minGraph, maxGraph).toList();
    });
  }

//set the list of ChartData for the first graph to show spesific month
//it is call when the user choose click on month in the axis
  void switchToMonthGraph(month) {
    var m;
    List months = monthsFullEn;
    if (language == 'he') {
      months = monthHe;
      m = monthHe.indexOf(month) + 1;
    } else
      m = monthsEn.indexOf(month) + 1;
    //if there aren't reports in that month so not swith
    if (!allReportDuration[showYearGraph].keys.contains(m)) return;
    monthNameGraph = months.elementAt(m - 1);
    isMonthsGraph = false;
    numberDaysGraph = DateTime(showYearGraph, m + 1, 0).day;
    DateTime today = DateTime.now();
    if (today.year == showYearGraph &&
        today.month == m &&
        today.day < numberDaysGraph) {
      numberDaysGraph = today.day;
    }
    duration = [];
    intensity = [];
    minGraph = 0;
    maxGraph = 7;
    //if the numbers of graph is less then 3
    if (numberDaysGraph < maxGraph) numberDaysGraph = maxGraph;
    //create the data for x axis
    var days = [for (var i = 1; i <= numberDaysGraph; i++) i.toString()];
    //create the ChartData from the data allReportDuration and allReportIntensity
    for (var i = 1; i <= numberDaysGraph; i++) {
      if (allReportDuration[showYearGraph][m].keys.contains(i)) {
        duration.add(
            ChartData(days[i - 1], allReportDuration[showYearGraph][m][i]));
        intensity.add(
            ChartData(days[i - 1], allReportIntensity[showYearGraph][m][i]));
      } else {
        duration.add(ChartData(days[i - 1], 0));
        intensity.add(ChartData(days[i - 1], 0));
      }
    }
    //set the sub lists that show in the graph
    setState(() {
      duration_sub = duration.getRange(minGraph, maxGraph).toList();
      intensity_sub = intensity.getRange(minGraph, maxGraph).toList();
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
            width: double.infinity,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.only(top: 5.0, bottom: 2.0),
                  child: AutoSizeText(
                    ' ${AppLocalizations.of(context)!.translate('graphTitle1')}',
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
                isMonthsGraph == false
                    ? Container(
                        padding: EdgeInsets.only(left: 20.0, right: 20.0),
                        margin: EdgeInsets.only(top: 2.0),
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
                                          color:
                                              Color.fromARGB(217, 33, 38, 38),
                                          fontWeight: FontWeight.bold)),
                                ),
                              ),
                              SizedBox(width: 2),
                            ],
                          ),
                        ))
                    : Container(),
                isMonthsGraph
                    ? Container(
                        padding: EdgeInsets.only(left: 20.0, right: 20.0),
                        // margin: EdgeInsets.only(top: 2.0),
                        child: DropdownButton(
                            dropdownColor: Color.fromARGB(255, 244, 249, 251),
                            borderRadius: BorderRadius.circular(20),
                            value: showYearGraph,
                            style: GoogleFonts.nunito(
                                textStyle: TextStyle(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.bold)),
                            items: yearsGraph.map((int value) {
                              return new DropdownMenuItem<int>(
                                value: value,
                                alignment: AlignmentDirectional.centerStart,
                                child: new Text(
                                  value.toString(),
                                  style: GoogleFonts.nunito(
                                      textStyle: TextStyle(
                                          fontSize: 14.0,
                                          color:
                                              Color.fromARGB(217, 33, 38, 38),
                                          fontWeight: FontWeight.bold)),
                                ),
                              );
                            }).toList(),
                            onChanged: (newYear) {
                              showYearGraph = newYear;
                              switchYearGraph(showYearGraph);
                            }),
                      )
                    : Container(),
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
                                .translate('Duration'),
                            textStyle: GoogleFonts.comfortaa(
                                fontSize: 15,
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
                              text: AppLocalizations.of(context)!
                                  .translate('Intensity'),
                              textStyle: GoogleFonts.comfortaa(
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                                color: Color.fromARGB(255, 195, 50, 86),
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
                      SplineSeries<ChartData, dynamic>(
                          dataSource: duration_sub,
                          xValueMapper: (ChartData data, _) => data.x,
                          yValueMapper: (ChartData data, _) => data.y,
                          markerSettings: MarkerSettings(isVisible: true),
                          name: AppLocalizations.of(context)!
                              .translate('Duration'),
                          color: Color.fromARGB(255, 219, 148, 90)),
                      SplineSeries<ChartData, dynamic>(
                          dataSource: intensity_sub,
                          xValueMapper: (ChartData data, _) => data.x,
                          yValueMapper: (ChartData data, _) => data.y,
                          markerSettings: MarkerSettings(isVisible: true),
                          name: AppLocalizations.of(context)!
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
                     
                      // decoration: BoxDecoration(
                      //   borderRadius: BorderRadius.circular(50),
                      //   border: Border.all(
                      //     color: Color.fromARGB(255, 244, 249, 251),
                      //   ),
                      // ),
                      child: minGraph !=
                              0 //if the minGraph=0 the button not display
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
                                  numberDaysGraph !=
                                      maxGraph) //if to show the forward button
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
