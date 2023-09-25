import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

import '../providers/auth.dart';
import '../models/UserModel.dart';
import '../models/http_exception.dart';
import '../Constants.dart';
import 'package:gradient_borders/gradient_borders.dart';
import '../AppLocalizations.dart';
import 'package:auto_size_text/auto_size_text.dart';

class dialogReport extends StatefulWidget {
  static const routeName = '/dialog-report';
  var report;
  var ctx;
  var date;

  dialogReport(this.report, this.ctx, this.date);

  @override
  _dialogReportState createState() => _dialogReportState();
}

class _dialogReportState extends State<dialogReport> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  UserModel _user = UserModel();
  final _dateController = TextEditingController();
  //the variables of that save the input
  var duration = 1;
  double intensity = 0;
  double containerHeight = 0.0;
  bool switchValue = false;
  var take_medition = false;
  var medition = "";
  var meditionOther = "";
  var newReport = {
    "date": DateTime.now(),
    "duration": 1,
    "intensity": 0,
  };

  @override
  void initState() {
    _user = Provider.of<Auth>(context, listen: false)
        .usermodel; //get the object of the user
    _dateController.text =
        widget.date != null ? DateFormat('yyyy-MM-dd').format(widget.date) : '';
    newReport["date"] = _dateController.text;

    super.initState();
  }

  Future<void> _save(BuildContext ctx) async {
    if (!_formKey.currentState.validate()) {
      return;
    }
    if (take_medition == true && (medition == "" && meditionOther == ""))
      return;
    _formKey.currentState.save();
    //fill the map that send to the server
    var url;
    if (widget.report !=
        null) //if he user want to edit report attack or add new one
      url = Uri.parse(BASE_URL);
    else
      url = Uri.parse(BASE_URL);
    try {
      final response = await http.post(
        //save the attack in the server
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(newReport),
      );
      final responseData = json.decode(response.body);
      if (response.statusCode != 200) {
        //check if there is eror from the server
        throw HttpException(responseData['message']);
      }
    } catch (error) {
      throw error;
    }

    // if (take_medition == false) newReport.remove("type");
    newReport["datetime"] = DateFormat("yyyy-MM-dd").parse(newReport["date"]);
    if (widget.report == null)
      Provider.of<Auth>(context, listen: false)
          .addReport(newReport, newReport["datetime"]);
    Navigator.pop(widget.ctx, newReport);
  }

//funtcion that return widget of the types of medication that the user can select if hw took medication
  Widget showTypes() {
    return Column(
      children: [
        RadioListTile(
          dense: true,
          activeColor: Color.fromARGB(192, 0, 150, 135),
          title: Text(
            AppLocalizations.of(context).translate('SimpleAnalgesics'),
            style: GoogleFonts.nunito(
                textStyle: TextStyle(
              fontSize: 12.0,
              color: Color.fromARGB(217, 33, 38, 38),
            )),
          ),
          value: "Simple analgesics",
          groupValue: medition,
          onChanged: (value) {
            setState(() {
              medition = value.toString();
            });
          },
        ),
        RadioListTile(
          activeColor: Color.fromARGB(192, 0, 150, 135),
          title: Text(
            AppLocalizations.of(context).translate('CombinedAnalgesics'),
            style: GoogleFonts.nunito(
                textStyle: TextStyle(
              fontSize: 12.0,
              color: Color.fromARGB(217, 33, 38, 38),
            )),
          ),
          value: "Combined analgesics",
          groupValue: medition,
          onChanged: (value) {
            setState(() {
              medition = value.toString();
            });
          },
        ),
        RadioListTile(
          activeColor: Color.fromARGB(192, 0, 150, 135),
          title: Text(
            AppLocalizations.of(context).translate('Triptans'),
            style: GoogleFonts.nunito(
                textStyle: TextStyle(
              fontSize: 12.0,
              color: Color.fromARGB(217, 33, 38, 38),
            )),
          ),
          value: "Triptans",
          groupValue: medition,
          onChanged: (value) {
            setState(() {
              medition = value.toString();
            });
          },
        ),
        TextFormField(
          initialValue: widget.report != null ? meditionOther : "",
          decoration: InputDecoration(labelText: 'Other'),
          maxLength: 20,
          style: GoogleFonts.nunito(
              textStyle: TextStyle(
            fontSize: 12.0,
            color: Color.fromARGB(217, 33, 38, 38),
          )),
          validator: (value) {
            if (value != "" && !value.contains(RegExp('^[a-zA-Z]+')))
              return AppLocalizations.of(context).translate('OnlyLetters');
          },
          onSaved: (value) {
            meditionOther = value;
          },
        )
      ],
    );
  }

  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.65 + containerHeight,
      width: MediaQuery.of(context).size.width,
      color: Color.fromARGB(217, 255, 255, 255),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color.fromARGB(217, 255, 255, 255),
          elevation: 0.0,
          title: AutoSizeText(
            AppLocalizations.of(context).translate('reportTitle'),
            maxLines: 1,
            style: GoogleFonts.nunito(
              textStyle: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
                color: Color.fromARGB(255, 9, 40, 52),
              ),
            ),
            textAlign: TextAlign.center,
          ),
        ),
        body: Container(
          color: Color.fromARGB(217, 255, 255, 255),
          padding: EdgeInsets.only(top: 5.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                Container(
                  child: TextFormField(
                      //choose the date of the attack
                      controller: _dateController,
                      decoration: InputDecoration(
                          labelText:
                              AppLocalizations.of(context).translate('Date'),
                          icon: Icon(Icons.calendar_today)),
                      readOnly: true,
                      onTap: () async {
                        DateTime pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now());
                        if (pickedDate != null) {
                          String formattedDate =
                              DateFormat('yyyy-MM-dd').format(pickedDate);

                          setState(() {
                            newReport["date"] = formattedDate;
                            _dateController.text = formattedDate;
                          });
                        } else {
                          _dateController.text = newReport["date"] != null
                              ? DateFormat('yyyy-MM-dd')
                                  .format(newReport["date"])
                              : '';
                        }
                      }),
                ),
                SizedBox(
                  height: 4.0,
                ),
                Divider(
                  thickness: 2,
                ),
                SizedBox(
                  height: 5.0,
                ),
                AutoSizeText(
                  AppLocalizations.of(context).translate('DurationAttack'),
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(
                      textStyle: TextStyle(
                          fontSize: 14.0,
                          color: Color.fromARGB(217, 33, 38, 38),
                          fontWeight: FontWeight.bold)),
                ),
                Container(
                  //choose the duration of the attack
                  alignment: Alignment.center,
                  padding: EdgeInsets.only(top: 15.0, bottom: 10.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      duration != 0
                          ? IconButton(
                              icon: Icon(Icons.remove,
                                  size: 35.0,
                                  color: Color.fromARGB(216, 0, 150, 135)),
                              onPressed: () => setState(() => duration--),
                            )
                          : Container(),
                      SizedBox(
                        width: 5.0,
                      ),
                      Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.only(
                            top: 10.0, bottom: 10.0, right: 12.0, left: 12.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5.0),
                          border: GradientBoxBorder(
                            width: 4.0,
                            gradient: LinearGradient(colors: [
                              Color.fromARGB(184, 75, 136, 160),
                              Color.fromARGB(247, 210, 210, 249),
                            ]),
                          ),
                        ),
                        child: Text(
                          duration.toString(),
                          style: TextStyle(fontSize: 20.0),
                        ),
                      ),
                      SizedBox(
                        width: 5.0,
                      ),
                      duration != 10
                          ? IconButton(
                              icon: Icon(
                                Icons.add,
                                size: 35.0,
                                color: Color.fromARGB(216, 0, 150, 135),
                              ),
                              onPressed: () => setState(() => duration++))
                          : Container(),
                    ],
                  ),
                ),
                Divider(
                  thickness: 2,
                ),
                AutoSizeText(
                  AppLocalizations.of(context).translate('IntensityAttack'),
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(
                      textStyle: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(217, 33, 38, 38),
                  )),
                ),
                Container(
                  //choose the intensity of the attack
                  padding: EdgeInsets.only(
                    top: 7.0,
                    bottom: 4.0,
                  ),
                  child: Slider(
                    min: 0.0,
                    max: 10.0,
                    divisions: 10,
                    value: intensity,
                    activeColor: Color.fromARGB(216, 0, 150, 135),
                    label: intensity.round().toString(),
                    onChanged: (value) {
                      setState(() {
                        intensity = value;
                      });
                    },
                  ),
                ),
                Divider(
                  thickness: 2,
                ),
                AutoSizeText(
                  AppLocalizations.of(context).translate('UseMedForAttack'),
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(
                      textStyle: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(217, 33, 38, 38),
                  )),
                ),
                Switch(
                  //if the user use medication in that attack
                  value: take_medition,
                  activeColor: Colors.red,
                  onChanged: (bool value) {
                    // This is called when the user toggles the switch.
                    setState(() {
                      take_medition = value;
                      switchValue = value;
                      if (switchValue) {
                        containerHeight =
                            MediaQuery.of(context).size.height * 0.4;
                      } else {
                        containerHeight =
                            0.0; // Reset the height when switch is released
                      }
                    });
                  },
                ),
                take_medition == true
                    ? showTypes()
                    : SizedBox(
                        height: 4.0,
                      ),
                Container(
                  alignment: Alignment.bottomRight,
                  child: FloatingActionButton.extended(
                    backgroundColor: Color.fromARGB(245, 197, 226, 223),
                    foregroundColor: Colors.black,
                    onPressed: () {
                      _save(context);
                    },
                    label: Text(AppLocalizations.of(context).translate('Save')),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
