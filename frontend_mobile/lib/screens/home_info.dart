import 'package:flutter/material.dart';

import '../AppLocalizations.dart';
import '../widgets/overview.dart';
import '../widgets/news.dart';
import '../widgets/explanation.dart';

class infoScreen extends StatelessWidget {
  infoScreen();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 25.0, right: 10.0, left: 10.0),
      child: DefaultTabController(
          length: 3,
          initialIndex: 1,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: <
                  Widget>[
            Container(
              child: TabBar(
                labelStyle: TextStyle(fontSize:  MediaQuery.of(context).size.width / 26.0, fontFamily: "RobotoMono"),
                labelColor: Color.fromARGB(184, 75, 136, 160),
                unselectedLabelColor: Color.fromARGB(255, 9, 40, 52),
                tabs: [
                  Tab(text: AppLocalizations.of(context).translate('OverView')),
                  Tab(text: AppLocalizations.of(context).translate('News')),
                  Tab(
                      text: AppLocalizations.of(context)
                          .translate('Explanation')),
                ],
              ),
            ),
            Container(
                constraints: BoxConstraints(
                        minHeight: 350,
                        maxHeight: MediaQuery.of(context).size.height) /
                    1.35,
                decoration: BoxDecoration(
                    border: Border(
                        top: BorderSide(color: Colors.grey, width: 0.5))),
                child: TabBarView(children: <Widget>[
                  overView(),
                  news(),
                  explanation(),
                ]))
          ])),
    );
  }
}
