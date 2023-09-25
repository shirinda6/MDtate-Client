import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:dropdown_formfield/dropdown_formfield.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gradient_borders/gradient_borders.dart';

import '../providers/auth.dart';
import '../models/UserModel.dart';
import '../models/http_exception.dart';
import '../Constants.dart';
import '../AppLocalizations.dart';

class dialogFirstReport extends StatefulWidget {
  static const routeName = '/dialog-first-report';
  var ctx;

  dialogFirstReport(this.ctx);

  @override
  _dialogFirstReportState createState() => _dialogFirstReportState();
}

class _dialogFirstReportState extends State<dialogFirstReport> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  UserModel _user = UserModel();
  //the variables of that save the input
  var duration = 0;
  double intensity = 0;
  var avgAttack = '';
  double containerHeight = 0.0;
  bool switchValue = false;

  var avgMedication = '';
  var take_medition = false;
  var medition = "";
  var meditionOther = "";
  var newReport = {};

  //the values for the selection in dropdown
  var count = [
    {
      "display": "1",
      "value": "1",
    },
    {
      "display": "2",
      "value": "2",
    },
    {
      "display": "3",
      "value": "3",
    },
    {
      "display": "4",
      "value": "4",
    },
    {
      "display": "5",
      "value": "5",
    },
    {
      "display": "6",
      "value": "6",
    },
    {
      "display": "7",
      "value": "7",
    },
    {
      "display": "8",
      "value": "8",
    },
    {
      "display": "9",
      "value": "9",
    },
    {
      "display": "10",
      "value": "10",
    },
    {
      "display": "11",
      "value": "11",
    },
    {
      "display": "12",
      "value": "12",
    },
    {
      "display": "13",
      "value": "13",
    },
    {
      "display": "14",
      "value": "14",
    },
    {
      "display": "15",
      "value": "15",
    },
    {
      "display": "16",
      "value": "16",
    },
    {
      "display": "17",
      "value": "17",
    },
    {
      "display": "18",
      "value": "18",
    },
    {
      "display": "19",
      "value": "19",
    },
    {
      "display": "20",
      "value": "20",
    },
    {
      "display": "21",
      "value": "21",
    },
    {
      "display": "22",
      "value": "22",
    },
    {
      "display": "23",
      "value": "23",
    },
    {
      "display": "24",
      "value": "24",
    },
    {
      "display": "25",
      "value": "25",
    },
    {
      "display": "26",
      "value": "26",
    },
    {
      "display": "27",
      "value": "27",
    },
    {
      "display": "28",
      "value": "28",
    },
    {
      "display": "29",
      "value": "29",
    },
    {
      "display": "30",
      "value": "30",
    },
  ];

  @override
  void initState() {
    _user = Provider.of<Auth>(context, listen: false)
        .usermodel; //get the object of the user
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
    var url = Uri.parse(BASE_URL);
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
    newReport["datetime"] = DateFormat("yyyy-MM-dd").parse(newReport["date"]);
    Navigator.pop(widget.ctx, "first"); //return to reports srceen
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
          decoration: InputDecoration(
            labelText: AppLocalizations.of(context).translate('Other'),
          ),
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
        ),
        DropDownFormField(
          titleText: AppLocalizations.of(context).translate('NumOfDaysTookMed'),
          hintText: AppLocalizations.of(context).translate('ChooseOne'),
          value: avgMedication,
          validator: (value) {
            if (value == null)
              return AppLocalizations.of(context).translate('ProvideAmount');
          },
          onSaved: (value) {
            setState(() {
              avgMedication = value;
            });
          },
          onChanged: (value) {
            setState(() {
              avgMedication = value;
            });
          },
          dataSource: count,
          textField: 'display',
          valueField: 'value',
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
            AppLocalizations.of(context).translate('firestReportTitle'),
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
                  alignment: Alignment.center,
                  padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                  child: DropDownFormField(
                    //choose the amount of attacks
                    titleText:
                        AppLocalizations.of(context).translate('AmountAttack'),
                    hintText:
                        AppLocalizations.of(context).translate('ChooseOne'),
                    value: avgAttack,
                    validator: (value) {
                      if (value == null)
                        return AppLocalizations.of(context)
                            .translate('ProvideAmount');
                    },
                    onSaved: (value) {
                      setState(() {
                        avgAttack = value;
                      });
                    },
                    onChanged: (value) {
                      setState(() {
                        avgAttack = value;
                      });
                    },
                    dataSource: count,
                    textField: 'display',
                    valueField: 'value',
                  ),
                ),
                Divider(
                  thickness: 1,
                ),
                AutoSizeText(
                  AppLocalizations.of(context).translate('AvgDurationAttack'),
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(
                      textStyle: TextStyle(
                          fontSize: 14.0,
                          color: Color.fromARGB(217, 33, 38, 38),
                          fontWeight: FontWeight.bold)),
                ),
                Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.only(top: 15.0, bottom: 10.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    //choose the average duration of the attacks
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
                  AppLocalizations.of(context).translate('AvgIntensityAttack'),
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
                  padding: EdgeInsets.only(
                    top: 7.0,
                    bottom: 4.0,
                  ),
                  child: Slider(
                    //choose the average intensity of the attacks
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
