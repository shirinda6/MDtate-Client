import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

import '../AppLocalizations.dart';

class sessionTable extends StatefulWidget {
  List sessions;

  sessionTable({required this.sessions});
  @override
  _sessionTableState createState() => _sessionTableState();
}

class _sessionTableState extends State<sessionTable> {
  List<bool> expansionStates = [];

  @override
  void initState() {
    // TODO: implement initState
    expansionStates =
        List<bool>.generate(widget.sessions.length, (index) => false);
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
                  AppLocalizations.of(context)!.translate('SessionName'),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(
                      textStyle: TextStyle(
                    fontSize: 16.0,
                    color: Color.fromARGB(255, 9, 40, 52),
                  )),
                ),
              ),
            ]),
            for (var session in widget.sessions)
              TableRow(
                children: [
                  for (var i = 1; i <= 2; i++)
                    TableCell(
                      child: Text(
                        session[i],
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
