import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

import '../AppLocalizations.dart';

class reportTable extends StatefulWidget {
  List reports;

  reportTable({required this.reports});
  @override
  _reportTableState createState() => _reportTableState();
}

class _reportTableState extends State<reportTable> {
  List<bool> expansionStates = [];

  @override
  void initState() {
    // TODO: implement initState
    expansionStates =
        List<bool>.generate(widget.reports.length, (index) => false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15.0),
      child: Table(
          border: TableBorder.symmetric(
              inside: BorderSide(
                  width: 0.4, color: Color.fromARGB(201, 33, 149, 243))),
          children: [
            TableRow(children: [
              TableCell(
                child: Text(
                  AppLocalizations.of(context)!.translate('Date'),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(
                      textStyle: TextStyle(
                    fontSize: 16.0,
                    color: Color.fromARGB(255, 9, 40, 52),
                  )),
                ),
              ),
              TableCell(
                child: Text(
                  AppLocalizations.of(context)!.translate('Duration'),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(
                      textStyle: TextStyle(
                    fontSize: 16.0,
                    color: Color.fromARGB(255, 9, 40, 52),
                  )),
                ),
              ),
              TableCell(
                child: Text(
                  AppLocalizations.of(context)!.translate('Intensity'),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(
                      textStyle: TextStyle(
                    fontSize: 16.0,
                    color: Color.fromARGB(255, 9, 40, 52),
                  )),
                ),
              ),
              TableCell(
                child: Text(
                  AppLocalizations.of(context)!.translate('Medication'),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(
                      textStyle: TextStyle(
                    fontSize: 16.0,
                    color: Color.fromARGB(255, 9, 40, 52),
                  )),
                ),
              ),
            ]),
            for (var report in widget.reports)
              TableRow(
                children: [
                  for (var i = 1; i <= 4; i++)
                    TableCell(
                      child: Text(
                        report[i],
                        textAlign: TextAlign.center,
                        style: GoogleFonts.nunito(
                            textStyle: TextStyle(
                          fontSize: 12.0,
                          color: Color.fromARGB(255, 9, 40, 52),
                        )),
                      ),
                    )
                ],
              )
          ]),
    );
  }
}
