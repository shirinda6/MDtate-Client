import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth.dart';
import '../AppLocalizations.dart';
import '../NotificationService.dart';
import 'package:google_fonts/google_fonts.dart';

class notificationScreen extends StatefulWidget {
  static const routeName = '/notification-screen';

  @override
  _notificationScreenState createState() => _notificationScreenState();

  notificationScreen();
}

class _notificationScreenState extends State<notificationScreen> {
  List<String>
      notifications; //each elemenet before manipulation is "hh:mm true" or "hh:mm false"
  List<bool> isActive =
      []; //A list that represents for each notification whether it is active or not
  List<String> time =
      []; //A list that represents the time for each notification

  @override
  void initState() {
    notifications = Provider.of<Auth>(context, listen: false).getNotifications;
    //pass over the list and split the time and active from the string
    for (String str in notifications) {
      var split = str.split(" ");
      if (split[1] == "true")
        isActive.add(true);
      else
        isActive.add(false);
      var t = "";
      //if the hour is between 00-9, add 0 first
      if (split[0].substring(0, split[0].indexOf(":")).length == 1)
        t = "0" + split[0].substring(0, split[0].indexOf(":")) + ":";
      else
        t = split[0].substring(0, split[0].indexOf(":")) + ":";
      //if the minutes is 0, add 0
      if (split[0].substring(split[0].indexOf(":") + 1) == "0")
        t += "00";
      else
        t += split[0].substring(split[0].indexOf(":") + 1);
      time.add(t);
    }
    super.initState();
  }

//When the user wants to change a notification to active or not
  void changeActive(value, index) async {
    var newN = time[index];
    var spilt = time[index].split(":");
    int hour = int.parse(spilt[0]);
    int min = int.parse(spilt[1]);
    int id = hour * 100 + min;
    NotificationService notificationService = NotificationService();
    await notificationService.init();
    await notificationService.requestIOSPermissions();
    if (isActive[index] == true) {
      //if change the notification to off
      newN += " false";
      notificationService.cancelNotification(id);
    } else {
      //if to change the notification to active
      newN += " true";
      notificationService.scheduleNotification(
          id,
          AppLocalizations.of(context).translate('NotificationTitleSession'),
          AppLocalizations.of(context).translate('NotificationBodySession'),
          hour,
          min);
    }
    Provider.of<Auth>(context, listen: false).editNotification(
        notifications[index],
        newN); //save the change in the userModel and in the device
    setState(() {
      isActive[index] = value;
    });
  }

//if the user want to delete notification
  void deleteNotification(index) async {
    //if it was active, first need to cancel the notification
    if (isActive[index]) {
      NotificationService notificationService = NotificationService();
      await notificationService.init();
      await notificationService.requestIOSPermissions();
      var spilt = time[index].split(":");
      int id = int.parse(spilt[0]) * 100 + int.parse(spilt[1]);
      notificationService.cancelNotification(id);
    }
    Provider.of<Auth>(context, listen: false).deleteNotification(notifications[
        index]); //save the change in the userModel and in the device

    setState(() {
      time.removeAt(index);
      isActive.removeAt(index);
    });
  }

//add new notification
  void addNotification() async {
    //choose the time of the notification
    final TimeOfDay picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: 00, minute: 00),
    );

    var hour = picked.hour;
    var min = picked.minute;
    int id = hour * 100 + min;
    NotificationService notificationService = NotificationService();
    await notificationService.init();
    await notificationService.requestIOSPermissions();
    notificationService.scheduleNotification(
        //create the notification
        id,
        AppLocalizations.of(context).translate('NotificationTitleSession'),
        AppLocalizations.of(context).translate('NotificationBodySession'),
        hour,
        min);
    //save it in the lists of the time and active
    var t = "";
    if (hour < 10)
      t = "0" + hour.toString() + ":";
    else
      t = "$hour:";
    if (min < 10)
      t += "0" + min.toString();
    else
      t += "$min";

    setState(() {
      time.add(t);
      t += " true";
      Provider.of<Auth>(context, listen: false).addNotification(t);
      isActive.add(true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 244, 249, 251),
      appBar: AppBar(
        elevation: 0,
        title: Text(AppLocalizations.of(context).translate('Notification'),
            style: GoogleFonts.nunito(
              textStyle: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
                color: Color.fromARGB(255, 9, 40, 52),
              ),
            )),
      ),
      body: Container(
        child: SingleChildScrollView(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: MediaQuery.of(context).size.height - 200,
              child: time.isEmpty
                  ? Container()
                  : ListView.builder(
                      itemBuilder: (context, index) {
                        return Card(
                          child: ListTile(
                              title: Text(time[index]),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Switch(
                                    //change the active of the notification
                                    value: isActive[index],
                                    activeColor: Colors.blue,
                                    onChanged: (bool value) {
                                      changeActive(value, index);
                                    },
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  IconButton(
                                      //button for delete the notification
                                      onPressed: () =>
                                          deleteNotification(index),
                                      icon: Icon(Icons.delete))
                                ],
                              )),
                        );
                      },
                      itemCount: notifications.length,
                    ),
            ),
            Container(
              margin:
                  const EdgeInsets.only(top: 10.0, right: 15.0, bottom: 15.0),
              alignment: Alignment.bottomRight,
              child: FloatingActionButton(
                //button for adding new notifiaction
                backgroundColor: Color.fromARGB(184, 75, 136, 160),
                elevation: 10.0,
                child: Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 35,
                ),
                onPressed: () {
                  addNotification();
                },
              ),
            ),
          ],
        )),
      ),
    );
  }
}
