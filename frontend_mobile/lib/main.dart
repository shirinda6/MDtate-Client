import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import './screens/tabs_screen.dart';
import 'screens/settings.dart';
import './screens/auth_screen.dart';
import './providers/auth.dart';
import './screens/splash_screen.dart';
import './screens/edit_profile.dart';
import './screens/change_password.dart';
import './screens/privacy_policy.dart';
import './screens/terms.dart';
import 'screens/sessions_by_type.dart';
import 'screens/session_audio.dart';
import 'AppLocalizations.dart';
import './screens/notification_screen.dart';
import './screens/feedback_screen.dart';

Future<void> initSettings() async {
  SharePreferenceCache spCache = SharePreferenceCache();
  await spCache.init();
  await Settings.init(cacheProvider: spCache);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initSettings();
  await Firebase.initializeApp();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitUp,
  ]);
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: Auth(),
        ),
      ],
      child: Consumer<Auth>(
        builder: (ctx, auth, _) => MaterialApp(
          title: 'MDtate',
          theme: ThemeData(
            primarySwatch: Colors.teal,
            appBarTheme: AppBarTheme(
              color: Color.fromARGB(255, 244, 249, 251),
              iconTheme: IconThemeData(
                color: Color.fromARGB(255, 9, 40, 52),
              ),
            ),
            accentColor: Colors.grey,
            fontFamily: 'Lato',
          ),
          supportedLocales: [
            Locale('en', 'US'),
            Locale('he', 'IL')
          ], //supprt language of this app
          localeListResolutionCallback: (deviceLocale, supportedLocales) {
            //check the language of the device
            for (var dLocale in deviceLocale) {
              for (var locale in supportedLocales) {
                if (locale.languageCode == dLocale.languageCode &&
                    locale.countryCode == locale.countryCode) {
                  auth.setLanguage = dLocale;
                  return dLocale;
                }
              }
            }
            //if the language of the device not int the supported list of the app
            auth.setLanguage = supportedLocales.first;
            return supportedLocales.first;
          },
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: auth.isAuth
              ? TabsScreen()
              : FutureBuilder(
                  future: auth.tryAutoLogin(),
                  builder: (ctx, authResultSnapshot) =>
                      authResultSnapshot.connectionState ==
                              ConnectionState.waiting
                          ? SplashScreen()
                          : AuthScreen(),
                ),
          routes: {
            MySettingsScreen.routeName: (ctx) => MySettingsScreen(),
            editProfileScreen.routeName: (ctx) => editProfileScreen(),
            changePasswordScreen.routeName: (ctx) => changePasswordScreen(),
            privacyPolicyScreen.routeName: (ctx) => privacyPolicyScreen(),
            termsScreen.routeName: (ctx) => termsScreen(),
            SessionByTypeScreen.routeName: (ctx) => SessionByTypeScreen(),
            sessionAudioScreen.routeName: (ctx) => sessionAudioScreen(),
            notificationScreen.routeName: (ctx) => notificationScreen(),
            feedbackScreen.routeName: (ctx) => feedbackScreen(),
          },
        ),
      ),
    );
  }
}
