import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:unicons/unicons.dart';

import '../providers/auth.dart';
import '../widgets/dialog_report.dart';
import '../AppLocalizations.dart';

class ListReports extends StatefulWidget {
  static const routeName = '/list-reports';
  var ctx;
  List reports;
  var date;
  List seesions;

  ListReports(this.ctx, this.reports, this.seesions, this.date);

  @override
  _ListReportsState createState() => _ListReportsState();
}

//return widjet of the title
Column _buildTitleSection({@required title, @required subTitle}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Padding(
        padding: const EdgeInsets.only(left: 5.0, top: 4.0),
        child: AutoSizeText(
          '$title',
          style: TextStyle(
              fontSize: 22, fontWeight: FontWeight.bold, fontFamily: "Lato"),
        ),
      ),
      if (subTitle != "")
        Padding(
          padding: const EdgeInsets.only(left: 5.0, bottom: 14.0, top: 3.0),
          child: AutoSizeText(
            '$subTitle',
            maxLines: 1,
            style: TextStyle(fontSize: 16, color: Colors.black45),
          ),
        )
    ],
  );
}

//return the type of the medication the user take in spesific report
String getType(index, reports, context) {
  if (!reports[index].keys.contains("type") || reports[index]["type"] == "")
    return "";
  var type = reports[index]["type"];
  if (type == "Simple analgesics" || type == "משככי כאבים פשוטים")
    return AppLocalizations.of(context).translate('SimpleAnalgesics');
  else if (type == "Combined analgesics" || type == "משככי כאבים משולבים")
    return AppLocalizations.of(context).translate('CombinedAnalgesics');
  else if (type == "Triptans" || type == "טריפטנים")
    return AppLocalizations.of(context).translate('Triptans');
  else
    type;
}

class _ListReportsState extends State<ListReports> {
  @override
  Widget build(BuildContext context) {
    return Container(
       decoration: BoxDecoration(
                    color:Color.fromARGB(255,244, 249, 251),
                    borderRadius: BorderRadius.circular(25)),
        padding: const EdgeInsets.only(left:5.0,right: 5.0,top:10),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildTitleSection(
                        title: AppLocalizations.of(context)
                            .translate('Reports'), // todo -add date
                        subTitle: AppLocalizations.of(context)
                            .translate('EditOrNewReports')),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding:EdgeInsets.symmetric(vertical: 2.0, horizontal: 20.0),
                        alignment: Alignment.bottomRight,
                        child: FloatingActionButton(
                          backgroundColor: Colors.white,
                          elevation: 10.0,
                          child: Icon(
                            UniconsLine.plus,
                            color: Color.fromARGB(255, 9, 40, 52),
                            size: 22,
                          ),
                          onPressed: () async {
                            //the user click button to add report
                            var val = await showDialog(
                                //dialog for add report pop up
                                
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    content: dialogReport(
                                        null, context, widget.date));
                                });
                            setState(() {
                              if (val != null) {
                                //add the new report to the list and sort it again for display
                                if (widget.reports.isEmpty)
                                  widget.reports.add(val);
                              }
                            });
                          },
                        ),
                      ),
                    ],
                  )
                ],
              ),
              if (widget.reports
                  .isNotEmpty) //show the list of reports only if is not empty
                Container(
                  height: widget.reports.length * 105.0,
                  padding: const EdgeInsets.all(10),
                  child: ListView.builder(
                    itemBuilder: (ctx, index) {
                      return Card(
                        elevation: 3,
                        
                        color:Color.fromARGB(255, 199, 219, 242),
                            shape: RoundedRectangleBorder(
                            side: const BorderSide(
                                color:Color.fromARGB(252, 108, 165, 229),
                                width: 1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                        child: ListTile(
                      
                          title: AutoSizeText(
                            //the intensity and the duration of the report
                            "${AppLocalizations.of(context).translate('Intensity')} :  ${widget.reports[index]["intensity"]}   ${AppLocalizations.of(context).translate('Duration')} :  ${widget.reports[index]["duration"]}",
                            maxLines: 1,
                            style: GoogleFonts.nunito(
                                fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 10.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  //the medication of the report
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    if (widget.reports[index].keys
                                            .contains("type") &&
                                        widget.reports[index]["type"] != "")
                                      Icon(
                                        Icons.medical_services_outlined,
                                        color:
                                            Color.fromARGB(255, 255, 138, 120),
                                      ),
                                    Text("  "),
                                    AutoSizeText(
                                      getType(index, widget.reports, context),
                                      style: GoogleFonts.nunito(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          trailing: Container(
                            width: 30.0,
                            height: 30.0,
                            child: FloatingActionButton(
                              backgroundColor: Color.fromARGB(255,244, 249, 251),
                              elevation: 5.0,
                              child: Icon(
                                Icons.edit,
                                color: Color.fromARGB(169, 9, 40, 52),
                                size: 15,
                              ),
                              mini: true,
                              onPressed: () async {
                                //if the user want to edit the report
                                var val = await showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                           shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                      
                                          content: dialogReport(
                                              widget.reports[index],
                                              context,
                                              widget.date));
                                    });

                                setState(() {
                                  //save the updated report
                                  if (val != null) {
                                    widget.reports[index] = val;
                                    Provider.of<Auth>(context, listen: false)
                                        .editReport(
                                            val, val["datetime"], index);
                                  }
                                });
                              },
                            ),
                          ),
                        ),
                      );
                    },
                    itemCount: widget.reports.length,
                  ),
                ),
              if (widget
                  .seesions.isNotEmpty) //show sessions if the list not empty
                _buildTitleSection(
                    title:
                        AppLocalizations.of(context).translate('SessionTitle'),
                    subTitle: ""),
              if (widget.seesions.isNotEmpty)
                Container(
                  height: widget.seesions.length * 80.0,
                  padding: const EdgeInsets.all(15),
                  child: ListView.builder(
                    itemBuilder: (ctx, index) {
                      return Card(
                          elevation: 3,              
                           shape: RoundedRectangleBorder(
                            side: const BorderSide(
                                color: Color.fromARGB(221, 82, 175, 120),
                                width: 1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                        shadowColor: Colors.grey.withOpacity(0.5),
                        color: Color.fromARGB(255, 211, 241, 220),
                        child: ListTile(      
                       
                          title: AutoSizeText(
                            "${widget.seesions[index]["sessionName"]}",
                            maxLines: 2,
                            style: GoogleFonts.nunito(
                                textStyle: TextStyle(fontSize: 14.0),
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      );
                    },
                    itemCount: widget.seesions.length,
                  ),
                ),
            ],
          ),
        ));
  }
}
