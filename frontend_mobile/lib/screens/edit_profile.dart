import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'dart:async';
import 'dart:io';
import 'package:http_parser/http_parser.dart';
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';

import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:toggle_switch/toggle_switch.dart';

import '../providers/auth.dart';
import '../models/UserModel.dart';
import '../Constants.dart';
import '../AppLocalizations.dart';
import '../Permission/PermissionHandlerPermissionService.dart';

class editProfileScreen extends StatefulWidget {
  static const routeName = '/edit-profile';

  @override
  _editProfileScreenState createState() => _editProfileScreenState();

  editProfileScreen();
}

class _editProfileScreenState extends State<editProfileScreen> {
  UserModel _user = UserModel();
  final _dateController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey();
  ImagePicker image = ImagePicker();
  String email = "";

  @override
  void initState() {
    _user = Provider.of<Auth>(context, listen: false)
        .usermodel; //get the object of the user
    email = _user.email;
    _dateController.text = _user.birthday != null
        ? DateFormat('yyyy-MM-dd').format(_user.birthday)
        : ''; //init the text input of birthday if there is
    super.initState();
  }

  //open dialog if there is error from the server in the register ot login
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(context).translate('ErrorOccurred')),
        content: Text(message),
        actions: <Widget>[
          ElevatedButton(
            child: Text(AppLocalizations.of(context).translate('OK')),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          )
        ],
      ),
    );
  }

//the function check validation and save the changes
  Future<void> _save(BuildContext ctx) async {
    if (!_formKey.currentState.validate()) {
      return;
    }
    _formKey.currentState.save();
    String birthday = _user.birthday != null
        ? DateFormat('yyyy-MM-dd').format(_user.birthday)
        : '';
    var url, response, responseData;
    try {
      if (email != _user.email) {
        //if the user change his email
        url = Uri.parse(BASE_URL);
        response = await http.post(
          url,
        );
        responseData = json.decode(response.body);
        if (response.statusCode != 200) {
          //check if there is an error from the server
          _showErrorDialog(responseData['message']);
          return;
        }
        //the server return a new token for the user
      }

      url = Uri.parse(BASE_URL);
      //save the new password in the server
      response = await http.post(
        url,
      );
      responseData = json.decode(response.body);
      if (response.statusCode != 200) {
        //check if there is an error from the server
        _showErrorDialog(responseData['message']);
        return;
      }
      //save the changes in the user's object
      Provider.of<Auth>(context, listen: false).setUpdate = response.body;
      Navigator.of(ctx).pop(); //return to the settings screen
    } catch (error) {
      throw error;
    }
  }

//function that return a widget of the gender selection
  Widget _genderWidget() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 35.0),
      child: Neumorphic(
        style: NeumorphicStyle(
            depth: NeumorphicTheme.embossDepth(context),
            boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(20))),
        child: ToggleSwitch(
          minWidth: MediaQuery.of(context).size.width / 3.9,
          minHeight: 60.0,
          initialLabelIndex: _user.gender - 1,
          activeFgColor: Colors.white,
          inactiveBgColor: Color.fromARGB(255, 224, 235, 239),
          totalSwitches: 3,
          icons: [
            Icons.male_outlined,
            Icons.female_outlined,
            Icons.transgender_outlined,
          ],
          iconSize: 25.0,
          borderWidth: 1.0,
          borderColor: [Color.fromARGB(255, 255, 255, 255)],
          activeBgColors: [
            [Color.fromARGB(255, 101, 178, 241)],
            [Color.fromARGB(255, 249, 128, 168)],
            [Color.fromARGB(255, 229, 125, 248)]
          ],
          onToggle: (index) {
            if (index == 0) {
              _user.gender = 1;
            } else if (index == 1) {
              _user.gender = 2;
            } else
              _user.gender = 3;
          },
        ),
      ),
    );
  }

//upload new profile image
  getgall(BuildContext ctx) async {
    PermissionHandlerPermissionService per =
        PermissionHandlerPermissionService();
    var hasPermission = await per.handlePhotosPermission(ctx);
    if (hasPermission) {
      // check if there is permission to open the gallery
      var img = await image.getImage(source: ImageSource.gallery);
      if (img == null) {
        return;
      }
      File imageFile = File(img.path);
      var name = path.basename(imageFile.path);
      var uri = Uri.parse(BASE_URL);
      try {
        var request = http.MultipartRequest("POST", uri);
        //the image convert from file to bytes for sending it to the server
        var multipartFile = await http.MultipartFile.fromBytes(
            "recfile", imageFile.readAsBytesSync(),
            filename: name, contentType: MediaType.parse("image/*"));

        request.files.add(multipartFile);
        var response = await request.send();
        var body = await response.stream.bytesToString();
        var responseData = json.decode(body);
        if (response.statusCode != 200) {
          _showErrorDialog(responseData['message']);
          return;
        }
        var profile_image = responseData["profile_image"];
        Provider.of<Auth>(context, listen: false).setUpdate = body;
        setState(() {
          _user.profile_image =
              profile_image; //Change the image displayed on the page
        });
      } catch (error) {
        throw error;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color.fromARGB(255, 244, 249, 251),
        appBar: AppBar(
            elevation: 0,
            title: Text(
              AppLocalizations.of(context).translate('EditProfile'),
              style: GoogleFonts.nunito(
                textStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0,
                  color: Color.fromARGB(255, 9, 40, 52),
                ),
              ),
              textAlign: TextAlign.center,
            ),
            actions: <Widget>[
              IconButton(
                icon: Icon(
                  Icons.save,
                  color: Color.fromARGB(255, 9, 40, 52),
                ),
                onPressed: () => _save(context),
              )
            ]),
        body: Form(
          key: _formKey,
          child: ListView(
              padding: EdgeInsets.symmetric(vertical: 25.0, horizontal: 5.0),
              children: [
                Container(
                  alignment: Alignment.center,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      //the profile image ofthe user
                      CircleAvatar(
                        radius: MediaQuery.of(context).size.width / 5,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(
                            MediaQuery.of(context).size.width / 3,
                          ),
                          child: _user.profile_image == null
                              ? Icon(
                                  Icons.image,
                                  size: 30,
                                )
                              : Image.network(
                                  _user.profile_image,
                                  fit: BoxFit.cover,
                                ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: -0.5,
                        child: GestureDetector(
                          //upload new image
                          onTap: () {
                            getgall(context);
                          },
                          child: CircleAvatar(
                              radius: 20.0,
                              backgroundColor:
                                  Color.fromARGB(180, 116, 151, 184),
                              child: Icon(
                                Icons.camera_alt,
                                size: 30.0,
                                color: Color.fromARGB(235, 255, 255, 255),
                              )),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10.0),
                Padding(
                  padding:
                      EdgeInsets.symmetric(vertical: 5.0, horizontal: 30.0),
                  child: Neumorphic(
                    margin: EdgeInsets.only(
                        left: 2.0, right: 12.0, top: 10, bottom: 4),
                    style: NeumorphicStyle(
                        depth: NeumorphicTheme.embossDepth(context),
                        boxShape: NeumorphicBoxShape.roundRect(
                            BorderRadius.circular(20))),
                    child: TextFormField(
                      //text input for the first name of the user
                      initialValue: _user.first_name,
                      decoration: InputDecoration(
                        labelText:
                            AppLocalizations.of(context).translate('FirstName'),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 55,
                          vertical: 15,
                        ),
                      ),
                      keyboardType: TextInputType.name,
                      validator: (value) {
                        if (value.isEmpty)
                          return AppLocalizations.of(context)
                              .translate('ProvideFirstName');
                      },
                      onSaved: (value) {
                        _user.first_name = value;
                      },
                    ),
                  ),
                ),
                Padding(
                  padding:
                      EdgeInsets.symmetric(vertical: 5.0, horizontal: 30.0),
                  child: Neumorphic(
                    margin:
                        EdgeInsets.only(left: 2, right: 12, top: 10, bottom: 4),
                    style: NeumorphicStyle(
                        depth: NeumorphicTheme.embossDepth(context),
                        boxShape: NeumorphicBoxShape.roundRect(
                            BorderRadius.circular(20))),
                    child: TextFormField(
                      //text input for the last name of the user
                      initialValue: _user.last_name,
                      decoration: InputDecoration(
                        labelText:
                            AppLocalizations.of(context).translate('LastName'),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 55,
                          vertical: 15,
                        ),
                      ),

                      keyboardType: TextInputType.name,
                      validator: (value) {
                        if (value.isEmpty)
                          return AppLocalizations.of(context)
                              .translate('ProvideLastName');
                      },
                      onSaved: (value) {
                        _user.last_name = value;
                      },
                    ),
                  ),
                ),
                Padding(
                  padding:
                      EdgeInsets.symmetric(vertical: 5.0, horizontal: 30.0),
                  child: Neumorphic(
                    margin:
                        EdgeInsets.only(left: 2, right: 12, top: 10, bottom: 4),
                    style: NeumorphicStyle(
                        depth: NeumorphicTheme.embossDepth(context),
                        boxShape: NeumorphicBoxShape.roundRect(
                            BorderRadius.circular(20))),
                    child: TextFormField(
                      //text input for the email of the user
                      initialValue: email,
                      decoration: InputDecoration(
                        labelText:
                            AppLocalizations.of(context).translate('Email'),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 55,
                          vertical: 15,
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value.isEmpty || !value.contains('@')) {
                          return AppLocalizations.of(context)
                              .translate('InvalidEmail');
                        }
                      },
                      onSaved: (value) {
                        email = value;
                      },
                    ),
                  ),
                ),
                Padding(
                  padding:
                      EdgeInsets.symmetric(vertical: 5.0, horizontal: 30.0),
                  child: Neumorphic(
                    margin:
                        EdgeInsets.only(left: 2, right: 12, top: 10, bottom: 4),
                    padding: EdgeInsets.only(left: 15.0, right: 15.0),
                    style: NeumorphicStyle(
                        depth: NeumorphicTheme.embossDepth(context),
                        boxShape: NeumorphicBoxShape.roundRect(
                            BorderRadius.circular(20))),
                    child: TextFormField(
                        //text input for the birthday of the user
                        controller: _dateController,
                        decoration: InputDecoration(
                            labelText: AppLocalizations.of(context)
                                .translate('Birthday'),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 0,
                              vertical: 15,
                            ),
                            icon: Icon(Icons.calendar_today)),
                        readOnly: true,
                        onTap: () async {
                          DateTime pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(1920),
                              lastDate: DateTime.now());
                          if (pickedDate != null) {
                            String formattedDate =
                                DateFormat('yyyy-MM-dd').format(pickedDate);

                            setState(() {
                              _user.birthday = pickedDate;
                              _dateController.text = formattedDate;
                            });
                          } else {
                            _dateController.text = _user.birthday != null
                                ? DateFormat('yyyy-MM-dd')
                                    .format(_user.birthday)
                                : '';
                          }
                        }),
                  ),
                ),
                _genderWidget()
              ]),
        ));
  }
}
