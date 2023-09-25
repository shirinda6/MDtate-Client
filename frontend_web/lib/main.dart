import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';

import 'Screens/auth_screen.dart';
import 'AppLocalizations.dart';
import 'Screens/main_table.dart';
import 'auth.dart';

void main() async {
  // WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  // final Future<FirebaseApp> _initialization = Firebase.initializeApp();
  @override
  _MyAppState createState() => _MyAppState();

  static _MyAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>();
}

class _MyAppState extends State<MyApp> {
  Locale _locale = Locale('en', 'US');

  void setLocale(Locale value) {
    setState(() {
      _locale = value;
    });
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        supportedLocales: [Locale('en', 'US'), Locale('he', 'IL')],
        locale: _locale,
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: AuthScreen(),
        // FutureBuilder(
        //   future: widget._initialization,
        //   builder: (context, snapshot) {
        //     if (snapshot.connectionState == ConnectionState.done) {
        //       return AuthScreen();
        //     }
        //     if (snapshot.hasError) {
        //       // Display an error message or handle the error gracefully
        //       return Scaffold(
        //         body: Center(
        //           child: Text('Firebase initialization failed.'),
        //         ),
        //       );
        //     }
        //     return Scaffold(
        //       body: Center(
        //         child: CircularProgressIndicator(),
        //       ),
        //     );
        //   },
        // ),
        routes: {
          MainTable.routeName: (ctx) => MainTable(),
          AuthScreen.routeName: (ctx) => AuthScreen(),
        });
  }
}

// class MainLayout extends StatefulWidget {
//   const MainLayout();

//   @override
//   _MainLayoutState createState() => _MainLayoutState();
// }

// class _MainLayoutState extends State<MainLayout> {
//   @override
//   Widget build(BuildContext context) {
//     // bool auth = Provider.of<Auth>(context).isAuth;

//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         actions: [
//           PopupMenuButton(itemBuilder: (context) {
//             return [
//               PopupMenuItem<int>(
//                 value: 0,
//                 child: Text("English"),
//               ),
//               PopupMenuItem<int>(
//                 value: 2,
//                 child: Text("עברית"),
//               ),
//             ];
//           }, onSelected: (value) {
//             Locale l = Locale('he', 'IL');
//             if (value == 0) {
//               l = Locale('en', 'US');
//             } else if (value == 1) {
//               l = Locale('he', 'IL');
//             }

//             MyApp.of(context)!.setLocale(l);
//             AppLocalizations.changeLocale(l);
//           }),
//         ],
//       ),
//       body: AuthScreen(),
//     );
//   }
// }
