import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:age_calculator/age_calculator.dart';
import 'package:to_csv/to_csv.dart' as exportCSV;
import 'package:google_fonts/google_fonts.dart';

import '../AppLocalizations.dart';
import '../main.dart';
import '../Constants.dart';
import '../Models/DoctorModel.dart';
import '../Widgets/doctor.dart';
import '../Widgets/researcher.dart';
import './auth_screen.dart';

class MainTable extends StatefulWidget {
  static const routeName = '/main-table';
  DoctorModel? doctorModel;

  MainTable({this.doctorModel});
  @override
  _MainTableState createState() => _MainTableState();
}

class _MainTableState extends State<MainTable> {
  var _valueDropdownLanguage;
  var users = [];
  List<bool> expansionStates = [];
  String? id;

  //open dialog if there is error from the server in the register ot login
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.translate('ErrorOccurred')),
        content: Text(message),
        actions: <Widget>[
          ElevatedButton(
            child: Text(AppLocalizations.of(context)!.translate('OK')),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          )
        ],
      ),
    );
  }

  Future<void> getUsers() async {
    final url = Uri.parse(BASE_URL + 'api/web/get_users');
    try {
      final response = await http.get(
        //called the server
        url,
        headers: {
          "x-access-token": widget.doctorModel!.accessToken ?? "",
        },
      );
      final responseData = json.decode(response.body);
      if (response.statusCode != 200) {
        //check if there is an error from the server
        _showErrorDialog(responseData['message']);
        return;
      }
      users =
          responseData["users"].map((e) => e as Map<String, dynamic>).toList();
      expansionStates = List<bool>.generate(users.length, (index) => false);
      print(users);
    } catch (error) {
      throw error;
    }
  }

  void initGet() async {
    await getUsers();
  }

  @override
  void initState() {
    // TODO: implement initState
    // initGet();
    users = widget.doctorModel!.users!;
    users = users.map((e) => e as Map<String, dynamic>).toList();
    expansionStates = List<bool>.generate(users.length, (index) => false);
    id = ', id: ${widget.doctorModel!.doctor_id}';
    super.initState();
  }

  //get the age of the user from the birthday
  int getAge(String birthday) {
    DateDuration duration;
    duration = AgeCalculator.age(DateTime.parse(birthday));
    return duration.years;
  }

  String getGender(int gender) {
    String g = "";
    switch (gender) {
      case 1:
        g = AppLocalizations.of(context)!.translate('Male');
        break;
      case 2:
        g = AppLocalizations.of(context)!.translate('Female');
        break;
      case 3:
        g = AppLocalizations.of(context)!.translate('Genderqueer');
        break;
    }
    return g;
  }

  String getGreeting() {
    var hour = DateTime.now().hour;
    if (hour >= 6 && hour < 12)
      return AppLocalizations.of(context)!.translate('GoodMorning');
    else if (hour >= 12 && hour < 18)
      return AppLocalizations.of(context)!.translate('GoodAfternoon');
    else if (hour >= 18 && hour < 0)
      return AppLocalizations.of(context)!.translate('GoodEvening');
    else
      return AppLocalizations.of(context)!.translate('GoodNight');
  }

  void downloadToCSV(String type) {
    List<String> header;
    List<List<String>> data;
    if (type == "Reports") {
      header = ["No.", "Date", "Duration", "Intensity", "Medication"];
      data = widget.doctorModel!.getLstForCSVReports();
    } else {
      header = ["No.", "Date", "Session's name"];
      data = widget.doctorModel!.getLstForCSVSessions();
    }
    List<List<String>> csvData = [header, ...data];
    exportCSV.myCSV(header, csvData);
  }

  @override
  Widget build(BuildContext context) {
    var f = AppLocalizations.of(context)!.locale.languageCode;
    if (f == 'en') {
      _valueDropdownLanguage = 'English';
    } else {
      _valueDropdownLanguage = "עברית";
    }

    final deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 9, 40, 52),
        title: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            // mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${getGreeting()} ${widget.doctorModel!.firstName} ${widget.doctorModel!.doctor_id == "" ? "" : id}',
                    style: GoogleFonts.nunito(
                        textStyle: TextStyle(
                      fontSize: 24.0,
                      color: Color.fromARGB(255, 228, 217, 206),
                    )),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (widget.doctorModel!.doctor_id == "")
                      DropdownButton(
                        dropdownColor: Color.fromARGB(255, 9, 40, 52),
                        hint: Text(
                          AppLocalizations.of(context)!
                              .translate('DownloadCSV'),
                          style: GoogleFonts.nunito(
                              textStyle: TextStyle(
                            fontSize: 16.0,
                            color: Color.fromARGB(255, 228, 217, 206),
                          )),
                        ),
                        items: <DropdownMenuItem<String>>[
                          DropdownMenuItem(
                            child: Text(
                              AppLocalizations.of(context)!
                                  .translate('Reports'),
                              style: GoogleFonts.nunito(
                                  textStyle: TextStyle(
                                fontSize: 16.0,
                                color: Color.fromARGB(255, 228, 217, 206),
                              )),
                            ),
                            value: 'Reports',
                          ),
                          DropdownMenuItem(
                            child: Text(
                              AppLocalizations.of(context)!
                                  .translate('Sessions'),
                              style: GoogleFonts.nunito(
                                  textStyle: TextStyle(
                                fontSize: 16.0,
                                color: Color.fromARGB(255, 228, 217, 206),
                              )),
                            ),
                            value: 'Sessions',
                          ),
                        ],
                        underline: SizedBox(
                          height: 0,
                        ),
                        onChanged: (value) {
                          downloadToCSV(value.toString());
                        },
                      ),
                    InkWell(
                      child: Text(
                        AppLocalizations.of(context)!.translate('Logout'),
                        style: GoogleFonts.nunito(
                            textStyle: TextStyle(
                          fontSize: 24.0,
                          color: Color.fromARGB(255, 228, 217, 206),
                        )),
                      ),
                      onTap: () {
                        Navigator.of(context)
                            .pushReplacementNamed(AuthScreen.routeName);
                      },
                    )
                    // DropdownButton(
                    //   dropdownColor: Color.fromARGB(255, 9, 40, 52),
                    //   value: _valueDropdownLanguage,
                    //   items: <DropdownMenuItem<String>>[
                    //     DropdownMenuItem(
                    //       child: Text(
                    //         'English',
                    //         style: GoogleFonts.nunito(
                    //             textStyle: TextStyle(
                    //           fontSize: 16.0,
                    //           color: Color.fromARGB(255, 228, 217, 206),
                    //         )),
                    //       ),
                    //       value: 'English',
                    //     ),
                    //     DropdownMenuItem(
                    //         child: Text(
                    //           'עברית',
                    //           style: GoogleFonts.nunito(
                    //               textStyle: TextStyle(
                    //             fontSize: 16.0,
                    //             color: Color.fromARGB(255, 228, 217, 206),
                    //           )),
                    //         ),
                    //         value: 'עברית'),
                    //   ],
                    //   underline: SizedBox(
                    //     height: 0,
                    //   ),
                    //   onChanged: (value) {
                    //     Locale l;
                    //     if (value == 'English') {
                    //       l = Locale('en', 'US');
                    //     } else {
                    //       l = Locale('he', 'IL');
                    //     }
                    //     setState(() {
                    //       MyApp.of(context)!.setLocale(l);
                    //       AppLocalizations.of(context)!.changeLocale(l);
                    //     });
                    //   },
                    // ),
                  ],
                ),
              ),
            ]),
      ),
      body: Container(
        color: Color.fromARGB(255, 244, 249, 251),
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(35.0),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Row(
                    children: [
                      if (widget.doctorModel!.doctor_id != "")
                        Expanded(
                          child: Text(
                            AppLocalizations.of(context)!
                                .translate('PatientName'),
                            style: GoogleFonts.nunito(
                                textStyle: TextStyle(
                              fontSize: 18.0,
                              color: Color.fromARGB(255, 9, 40, 52),
                            )),
                          ),
                        ),
                      Expanded(
                        child: Text(
                          AppLocalizations.of(context)!.translate('Age'),
                          style: GoogleFonts.nunito(
                              textStyle: TextStyle(
                            fontSize: 18.0,
                            color: Color.fromARGB(255, 9, 40, 52),
                          )),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          AppLocalizations.of(context)!.translate('Gender'),
                          style: GoogleFonts.nunito(
                              textStyle: TextStyle(
                            fontSize: 18,
                            color: Color.fromARGB(255, 9, 40, 52),
                          )),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          AppLocalizations.of(context)!.translate('Email'),
                          style: GoogleFonts.nunito(
                              textStyle: TextStyle(
                            fontSize: 18,
                            color: Color.fromARGB(255, 9, 40, 52),
                          )),
                        ),
                      ),
                    ],
                  ),
                ),
                if (users.length != 0)
                  ExpansionPanelList(
                    elevation: 2,
                    expandedHeaderPadding: EdgeInsets.all(0),
                    expansionCallback: (int index, bool isExpanded) {
                      setState(() {
                        expansionStates[index] = !isExpanded;
                      });
                    },
                    children: List<ExpansionPanel>.generate(
                      users.length,
                      (index) => ExpansionPanel(
                        headerBuilder: (BuildContext context, bool isExpanded) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                if (widget.doctorModel!.doctor_id != "")
                                  Expanded(
                                    child: Text(
                                      '${users[index]["first_name"]} ${users[index]["last_name"]}',
                                      style: GoogleFonts.nunito(
                                          textStyle: TextStyle(
                                        fontSize: 16.0,
                                        color: Color.fromARGB(255, 9, 40, 52),
                                      )),
                                    ),
                                  ),
                                Expanded(
                                  child: Text(
                                    users[index]["birthday"] == null
                                        ? ""
                                        : getAge(users[index]["birthday"])
                                            .toString(),
                                    style: GoogleFonts.nunito(
                                        textStyle: TextStyle(
                                      fontSize: 16.0,
                                      color: Color.fromARGB(255, 9, 40, 52),
                                    )),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    '${getGender(users[index]["gender"])}',
                                    style: GoogleFonts.nunito(
                                        textStyle: TextStyle(
                                      fontSize: 16.0,
                                      color: Color.fromARGB(255, 9, 40, 52),
                                    )),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    users[index]["email"],
                                    style: GoogleFonts.nunito(
                                        textStyle: TextStyle(
                                      fontSize: 16.0,
                                      color: Color.fromARGB(255, 9, 40, 52),
                                    )),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        body: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              widget.doctorModel!.doctor_id != ""
                                  ? Doctor(user: users[index])
                                  : Researcher(
                                      user: users[index],
                                      doctorModel: widget.doctorModel,
                                    )
                            ],
                          ),
                        ),
                        isExpanded: expansionStates[index],
                      ),
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
