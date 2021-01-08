import 'package:flutter/material.dart';
import 'package:json_http_test/src/screens/routes.dart';
import 'package:json_http_test/src/screens/weather_screen.dart';
import 'package:json_http_test/src/utils/constants.dart';
import 'package:json_http_test/src/utils/converters.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'src/themes.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

FlutterLocalNotificationsPlugin localNotificationsPlugin =
FlutterLocalNotificationsPlugin();
void main() {
  runApp(AppStateContainer(child: WeatherApp()));
}

void initializeNotifications() async {
  var initializeAndroid = AndroidInitializationSettings('ic_launcher');
  var initializeIOS = IOSInitializationSettings();
  var initSettings = InitializationSettings(initializeAndroid, initializeIOS);
  await localNotificationsPlugin.initialize(initSettings);
}
Future singleNotification(
    DateTime datetime, String message, String subtext, int hashcode,
    {String sound}) async {
  var androidChannel = AndroidNotificationDetails(
    'channel-id',
    'channel-name',
    'channel-description',
    importance: Importance.Max,
    priority: Priority.Max,
  );

  var iosChannel = IOSNotificationDetails();
  var platformChannel = NotificationDetails(androidChannel, iosChannel);

  localNotificationsPlugin.schedule(
      hashcode, message, subtext, datetime, platformChannel,
      payload: hashcode.toString());
}

class WeatherApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Weather App',
      theme: AppStateContainer.of(context).theme,

      home: WeatherScreen(),
      routes: Routes.mainRoute,
    );
  }
}



class AppStateContainer extends StatefulWidget {
  final Widget child;

  AppStateContainer({@required this.child});

  @override
  _AppStateContainerState createState() => _AppStateContainerState();

  static _AppStateContainerState of(BuildContext context) {
    return (context.inheritFromWidgetOfExactType(_InheritedStateContainer)
            as _InheritedStateContainer)
        .data;
  }
}

class _AppStateContainerState extends State<AppStateContainer> {
  ThemeData _theme = Themes.getTheme(Themes.DARK_THEME_CODE);
  int themeCode = Themes.DARK_THEME_CODE;
  TemperatureUnit temperatureUnit = TemperatureUnit.celsius;


  @override
  initState() {
    super.initState();
    SharedPreferences.getInstance().then((sharedPref) {
      setState(() {
        themeCode = sharedPref.getInt(CONSTANTS.SHARED_PREF_KEY_THEME) ??
            Themes.DARK_THEME_CODE;
        temperatureUnit = TemperatureUnit.values[
            sharedPref.getInt(CONSTANTS.SHARED_PREF_KEY_TEMPERATURE_UNIT) ??
                TemperatureUnit.celsius.index];
        this._theme = Themes.getTheme(themeCode);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    print(theme.accentColor);
    return _InheritedStateContainer(
      data: this,
      child: widget.child,
    );
  }

  ThemeData get theme => _theme;

  updateTheme(int themeCode) {
    setState(() {
      _theme = Themes.getTheme(themeCode);
      this.themeCode = themeCode;
    });
    SharedPreferences.getInstance().then((sharedPref) {
      sharedPref.setInt(CONSTANTS.SHARED_PREF_KEY_THEME, themeCode);
    });
  }

  updateTemperatureUnit(TemperatureUnit unit) {
    setState(() {
      this.temperatureUnit = unit;
    });
    SharedPreferences.getInstance().then((sharedPref) {
      sharedPref.setInt(CONSTANTS.SHARED_PREF_KEY_TEMPERATURE_UNIT, unit.index);
    });
  }
}

class _InheritedStateContainer extends InheritedWidget {
  final _AppStateContainerState data;

  const _InheritedStateContainer({
    Key key,
    @required this.data,
    @required Widget child,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(_InheritedStateContainer oldWidget) => true;
}
