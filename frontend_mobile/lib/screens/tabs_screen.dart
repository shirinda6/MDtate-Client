import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unicons/unicons.dart';
import 'home_info.dart';
import 'Sessions_screan.dart';
import './settings.dart';
import './personal_screen.dart';
import '../providers/auth.dart';
import '../AppLocalizations.dart';
import '../Permission/PermissionHandlerPermissionService.dart';
import '../NotificationService.dart';
import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';

class TabsScreen extends StatefulWidget {
  TabsScreen();

  @override
  _TabsScreenState createState() => _TabsScreenState();
}

class _TabsScreenState extends State<TabsScreen> {
  Locale language;
  var auto = false;
  final _pageController = PageController(initialPage: 0);
  var isDone = false; //represent if the notifications have already been set
  int maxCount = 4;
  List<Widget> bottomBarPages = [];
  var viewSessionPage =
      true; //if view the page of session or not- get that from the server. false= display, true= not display

  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

//set notification to remind to the user to fill out a report in 8:30 pm
  Future<void> setNotificationForReport(BuildContext ctx) async {
    PermissionHandlerPermissionService per =
        PermissionHandlerPermissionService();
    var hasPermission = await per.handleNotificationPermission(ctx);
    if (hasPermission) {
      //check if there is permission to send notifications
      NotificationService notificationService = NotificationService();
      notificationService.init().then((value) {
        notificationService.requestIOSPermissions().then((value) {
          notificationService.scheduleNotification(
              0,
              AppLocalizations.of(context).translate('TitleNotification'),
              AppLocalizations.of(context).translate('BodyNotification'),
              20,
              30);

          scheduleNotification(ctx);
        });
      });
    }
    isDone = true;
  }

//set notifications that the user add for listen the session
  Future<void> scheduleNotification(BuildContext ctx) async {
    NotificationService notificationService = NotificationService();
    List notifications =
        Provider.of<Auth>(context, listen: false).getNotifications;
    notificationService.init().then((value) =>
        notificationService.requestIOSPermissions().then((value) async {
          for (String n in notifications) {
            var split = n.split(" ");
            var time = split[0].split(":");
            if (split[1] != "true") continue;
            int hour = int.parse(time[0]);
            int min = int.parse(time[1]);
            int id = hour * 100 + min;
            notificationService.scheduleNotification(
                id,
                AppLocalizations.of(ctx).translate('NotificationTitleSession'),
                AppLocalizations.of(ctx).translate('NotificationBodySession'),
                hour,
                min);
          }
        }));
  }

  @override
  void initState() {
    language = Provider.of<Auth>(context, listen: false).getLanguage;
    auto = Provider.of<Auth>(context, listen: false).isautoLogin;

    viewSessionPage = Provider.of<Auth>(context, listen: false).getViewSession;
    //What pages will be in the app
    //it change according the viewSessionPage
    if (viewSessionPage == false) {
      bottomBarPages = [
        infoScreen(),
        SessionScreen(),
        PersonalScreen(language.languageCode),
        MySettingsScreen(),
      ];
    } else {
      maxCount = 3;
      bottomBarPages = [
        infoScreen(),
        PersonalScreen(language.languageCode),
        MySettingsScreen(),
      ];
    }
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!auto && isDone == false) {
        setNotificationForReport(context);
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //set notifications if the user just enter to the app
    // if (!auto && isDone == false) {
    //   setNotificationForReport(context);
    // }

    return Scaffold(
      body: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: bottomBarPages),
      extendBody: true,
      backgroundColor: Color.fromARGB(255, 244, 249, 251),
      bottomNavigationBar: (bottomBarPages.length <= maxCount)
          ? AnimatedNotchBottomBar(
              showBlurBottomBar: true,
              blurOpacity: 0.5,
              blurFilterX: 6.0,
              blurFilterY: 10.0,
              pageController: _pageController,
              showLabel: true,
              notchColor: Color.fromARGB(255, 96, 156, 225),
              bottomBarItems: [
                const BottomBarItem(
                  inActiveItem: Icon(
                    UniconsLine.info_circle,
                    color: Color.fromARGB(217, 33, 38, 38),
                  ),
                  activeItem: Icon(
                    UniconsLine.info_circle,
                    color: Color.fromARGB(217, 33, 38, 38),
                  ),
                  itemLabel: 'Info',
                ),
                if (viewSessionPage == false)
                  const BottomBarItem(
                    inActiveItem: Icon(
                      UniconsLine.record_audio,
                      color: Color.fromARGB(217, 33, 38, 38),
                    ),
                    activeItem: Icon(
                      UniconsLine.record_audio,
                      color: Color.fromARGB(217, 33, 38, 38),
                    ),
                    itemLabel: 'Session',
                  ),
                const BottomBarItem(
                  inActiveItem: Icon(
                    UniconsLine.user,
                    color: Color.fromARGB(217, 33, 38, 38),
                  ),
                  activeItem: Icon(
                    UniconsLine.user,
                    color: Color.fromARGB(217, 33, 38, 38),
                  ),
                  itemLabel: 'Personal',
                ),
                const BottomBarItem(
                  inActiveItem: Icon(
                    UniconsLine.setting,
                    color: Color.fromARGB(217, 33, 38, 38),
                  ),
                  activeItem: Icon(
                    UniconsLine.setting,
                    color: Color.fromARGB(217, 33, 38, 38),
                  ),
                  itemLabel: 'Setting',
                ),
              ],
              onTap: (index) {
                _pageController.jumpToPage(
                  index,
                );
              },
            )
          : null,
    );
  }
}
