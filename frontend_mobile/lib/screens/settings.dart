import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:babstrap_settings_screen/babstrap_settings_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';

import '../providers/auth.dart';
import './edit_profile.dart';
import './change_password.dart';
import './privacy_policy.dart';
import './terms.dart';
import '../AppLocalizations.dart';
import '../Constants.dart';
import '../Permission/PermissionHandlerPermissionService.dart';
import './notification_screen.dart';
import './feedback_screen.dart';

class CustomTextStyle {
  static const TextStyle nameOfTextStyle = TextStyle(
    fontSize: 20,
    color: Color.fromARGB(255, 18, 60, 75),
    fontWeight: FontWeight.bold,
  );
}

class MySettingsScreen extends StatelessWidget {
  static const routeName = '/settings';

  MySettingsScreen();

//the funtion the sign out the user
  Future<void> _signout(context) async {
    Navigator.pop(context);
    try {
      await Provider.of<Auth>(context, listen: false).logout();
    } catch (error) {
      const errorMessage = 'Could not logout you. Please try again later.';
      _showErrorDialog(errorMessage, context);
    }
  }

//open dialog if there is error from the server in the register ot login
  void _showErrorDialog(String message, BuildContext context) {
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

  Future<void> _resetSession(context) async {
    var _user = Provider.of<Auth>(context, listen: false)
        .usermodel; //get the object of the user
    try {
      final url = Uri.parse(BASE_URL);
      final response = await http.get(
        url,
        headers: {},
      );
      final responseData = json.decode(response.body);
      if (response.statusCode != 200) {
        //check if there is an error from the server
        _showErrorDialog(responseData['message'], context);
        return;
      }
      Provider.of<Auth>(context, listen: false).resertSession();
      Navigator.of(context).pop();
    } catch (error) {
      throw error;
    }
  }

  @override
  Widget build(BuildContext context) {
    var viewSessionPage = Provider.of<Auth>(context, listen: false)
        .getViewSession; //if show the session pageg or not
    return Container(
      padding: const EdgeInsets.only(
          top: 40.0, right: 15.0, left: 15.0, bottom: 80.0),
      color: Color.fromARGB(255, 244, 249, 251),
      child: SingleChildScrollView(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              mainAxisSize: MainAxisSize.min,
              children: [
            SettingsGroup(
                settingsGroupTitle:
                    "  ${AppLocalizations.of(context).translate('Account')}",
                settingsGroupTitleStyle: CustomTextStyle.nameOfTextStyle,
                iconItemSize: 20,
                items: [
                  SettingsItem(
                    //move to the edit profile sreen
                    onTap: () {
                      Navigator.of(context)
                          .pushNamed(editProfileScreen.routeName);
                    },
                    icons: Icons.edit,
                    iconStyle: IconStyle(
                      iconsColor: Color.fromARGB(255, 20, 69, 87),
                      withBackground: true,
                      backgroundColor: Colors.white,
                    ),
                    title: AppLocalizations.of(context).translate('Profile'),
                    titleStyle: TextStyle(
                      color: Color.fromARGB(255, 20, 69, 87),
                    ),
                    subtitle: AppLocalizations.of(context)
                        .translate('EditProfileButton'),
                  ),
                  SettingsItem(
                    onTap: () {
                      //move to change password screen
                      Navigator.of(context)
                          .pushNamed(changePasswordScreen.routeName);
                    },
                    icons: Icons.lock,
                    iconStyle: IconStyle(
                      iconsColor: Color.fromARGB(255, 20, 69, 87),
                      withBackground: true,
                      backgroundColor: Colors.white,
                    ),
                    title: AppLocalizations.of(context).translate('Privacy'),
                    titleStyle: TextStyle(
                      color: Color.fromARGB(255, 20, 69, 87),
                    ),
                    subtitle: AppLocalizations.of(context)
                        .translate('ChangePassword'),
                  ),
                  SettingsItem(
                    //logout from the app
                    onTap: () => {
                      showDialog(
                          //open dialog to verify that the user want to logout
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.0)),
                                title: Text(
                                    AppLocalizations.of(context)
                                        .translate('Logout'),
                                    style: GoogleFonts.nunito(
                                        textStyle: TextStyle(
                                            fontSize: 22.0,
                                            fontWeight: FontWeight.bold))),
                                content: Container(
                                    height: 120,
                                    child: Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                              AppLocalizations.of(context)
                                                  .translate('LogoutMakeSure'),
                                              style: GoogleFonts.nunito(
                                                textStyle:
                                                    TextStyle(fontSize: 16.0),
                                              )),
                                          SizedBox(
                                            height: 15.0,
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: [
                                              TextButton(
                                                child: Text(
                                                    AppLocalizations.of(context)
                                                        .translate('Cancel'),
                                                    style: GoogleFonts.nunito(
                                                      textStyle: TextStyle(
                                                        fontSize: 16.0,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Color.fromARGB(
                                                            255, 96, 156, 225),
                                                      ),
                                                    )),
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                              ),
                                              TextButton(
                                                child: Text(
                                                    AppLocalizations.of(context)
                                                        .translate('Logout'),
                                                    style: GoogleFonts.nunito(
                                                      textStyle: TextStyle(
                                                          fontSize: 16.0,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Color.fromARGB(
                                                              255,
                                                              96,
                                                              156,
                                                              225)),
                                                    )),
                                                onPressed: () =>
                                                    _signout(context),
                                              )
                                            ],
                                          ),
                                        ],
                                      ),
                                    )));
                          })
                    },
                    icons: Icons.logout,
                    iconStyle: IconStyle(
                      iconsColor: Color.fromARGB(255, 20, 69, 87),
                      withBackground: true,
                      backgroundColor: Colors.white,
                    ),
                    title: AppLocalizations.of(context).translate('Logout'),
                    titleStyle: TextStyle(
                      color: Color.fromARGB(255, 20, 69, 87),
                    ),
                  ),
                ]),
            SettingsGroup(
                settingsGroupTitle:
                    "  ${AppLocalizations.of(context).translate('General')}",
                settingsGroupTitleStyle: CustomTextStyle.nameOfTextStyle,
                items: [
                  SettingsItem(
                    onTap: () async {
                      //move to notifications page
                      //first check if there is permission to send notifications
                      PermissionHandlerPermissionService per =
                          PermissionHandlerPermissionService();
                      var hasPermission =
                          await per.handleNotificationPermission(context);
                      if (hasPermission)
                        Navigator.of(context)
                            .pushNamed(notificationScreen.routeName);
                    },
                    icons: Icons.notifications,
                    iconStyle: IconStyle(
                      iconsColor: Color.fromARGB(255, 20, 69, 87),
                      withBackground: true,
                      backgroundColor: Colors.white,
                    ),
                    title:
                        AppLocalizations.of(context).translate('Notfication'),
                    titleStyle: TextStyle(
                      color: Color.fromARGB(255, 20, 69, 87),
                    ),
                    subtitle: AppLocalizations.of(context)
                        .translate('SetNotfication'),
                  ),
                  // SettingsItem(
                  //   onTap: () {},
                  //   icons: Icons.volume_up,
                  //   iconStyle: IconStyle(
                  //     iconsColor: Color.fromARGB(255, 20, 69, 87),
                  //     withBackground: true,
                  //     backgroundColor: Colors.white,
                  //   ),
                  //   title: AppLocalizations.of(context).translate('Sound'),
                  //   titleStyle: TextStyle(
                  //     color: Color.fromARGB(255, 20, 69, 87),
                  //   ),
                  //   subtitle:
                  //       AppLocalizations.of(context).translate('SetSound'),
                  // ),
                  if (viewSessionPage == false)
                    SettingsItem(
                      onTap: () {
                        //if the user reset the sessions
                        showDialog(
                            //open dialog to verify that the user want to reset
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(20.0)),
                                  title: Text(
                                      AppLocalizations.of(context)
                                          .translate('ResetSession'),
                                      style: GoogleFonts.nunito(
                                          textStyle: TextStyle(
                                              fontSize: 22.0,
                                              fontWeight: FontWeight.bold))),
                                  content: Container(
                                    height: 120,
                                    child: Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: Column(
                                          children: [
                                            Text(
                                                AppLocalizations.of(context)
                                                    .translate('ResetMakeSure'),
                                                style: GoogleFonts.nunito(
                                                    textStyle: TextStyle(
                                                        fontSize: 16.0))),
                                            SizedBox(height: 15.0),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              children: [
                                                TextButton(
                                                  child: Text(
                                                      AppLocalizations.of(
                                                              context)
                                                          .translate('Cancel'),
                                                      style: GoogleFonts.nunito(
                                                        textStyle: TextStyle(
                                                          fontSize: 16.0,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Color.fromARGB(
                                                              255,
                                                              96,
                                                              156,
                                                              225),
                                                        ),
                                                      )),
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                ),
                                                TextButton(
                                                  child: Text(
                                                      AppLocalizations.of(
                                                              context)
                                                          .translate('Reset'),
                                                      style: GoogleFonts.nunito(
                                                        textStyle: TextStyle(
                                                          fontSize: 16.0,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Color.fromARGB(
                                                              255,
                                                              96,
                                                              156,
                                                              225),
                                                        ),
                                                      )),
                                                  onPressed: () =>
                                                      _resetSession(context),
                                                )
                                              ],
                                            ),
                                          ],
                                        )),
                                  ));
                            });
                      },
                      icons: Icons.video_call,
                      iconStyle: IconStyle(
                        iconsColor: Color.fromARGB(255, 20, 69, 87),
                        withBackground: true,
                        backgroundColor: Colors.white,
                      ),
                      title: AppLocalizations.of(context).translate('Reset'),
                      titleStyle: TextStyle(
                        color: Color.fromARGB(255, 20, 69, 87),
                      ),
                      subtitle: AppLocalizations.of(context)
                          .translate('ResetSession'),
                    ),
                ]),
            SettingsGroup(
                settingsGroupTitle:
                    "  ${AppLocalizations.of(context).translate('Support')}",
                settingsGroupTitleStyle: CustomTextStyle.nameOfTextStyle,
                items: [
                  SettingsItem(
                    onTap: () {
                      Navigator.of(context).pushNamed(feedbackScreen.routeName);
                    },
                    icons: Icons.feedback,
                    iconStyle: IconStyle(
                      iconsColor: Color.fromARGB(255, 20, 69, 87),
                      withBackground: true,
                      backgroundColor: Colors.white,
                    ),
                    title: AppLocalizations.of(context).translate('Feedback'),
                    titleStyle: TextStyle(
                      color: Color.fromARGB(255, 20, 69, 87),
                    ),
                    subtitle:
                        AppLocalizations.of(context).translate('SendReport'),
                  ),
                  SettingsItem(
                    onTap: () {
                      Navigator.of(context)
                          .pushNamed(privacyPolicyScreen.routeName);
                    },
                    icons: Icons.privacy_tip,
                    iconStyle: IconStyle(
                      iconsColor: Color.fromARGB(255, 20, 69, 87),
                      withBackground: true,
                      backgroundColor: Colors.white,
                    ),
                    title: AppLocalizations.of(context).translate('Policy'),
                    titleStyle: TextStyle(
                      color: Color.fromARGB(255, 20, 69, 87),
                    ),
                  ),
                  SettingsItem(
                    onTap: () {
                      Navigator.of(context).pushNamed(termsScreen.routeName);
                    },
                    icons: Icons.privacy_tip,
                    iconStyle: IconStyle(
                      iconsColor: Color.fromARGB(255, 20, 69, 87),
                      withBackground: true,
                      backgroundColor: Colors.white,
                    ),
                    title: AppLocalizations.of(context).translate('Term'),
                    titleStyle: TextStyle(
                      color: Color.fromARGB(255, 20, 69, 87),
                    ),
                  ),
                ]),
          ])),
    );
  }
}
