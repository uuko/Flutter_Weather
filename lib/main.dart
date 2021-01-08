import 'package:flutter/material.dart';
import 'package:json_http_test/src/screens/routes.dart';
import 'package:json_http_test/src/screens/weather_screen.dart';
import 'package:json_http_test/src/utils/constants.dart';
import 'package:json_http_test/src/utils/converters.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'src/themes.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';


void main() {
  runApp(AppStateContainer(child: WeatherApp()));
}

/**
*   發通知
* */
FlutterLocalNotificationsPlugin localNotificationsPlugin =
FlutterLocalNotificationsPlugin();
void initializeNotifications() async {
  var initializeAndroid = AndroidInitializationSettings('ic_launcher');
  var initializeIOS = IOSInitializationSettings();
  var initSettings = InitializationSettings(initializeAndroid, initializeIOS);
  await localNotificationsPlugin.initialize(initSettings);
}
Future singleNotification(DateTime datetime, String message, String subtext, int hashcode, {String sound}) async {
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


/**
 *   第一頁路由
 * */
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



/**
*InheritedWidget給整個Widget tree 訪問同個狀態(state)的權限。
 **/

/**
* 在BLoC中，您可以通過使用BlocBuilder<MyBloc, MyBlocState>和當前add事件來根據當前BlocState構建窗口小部件，
 * 並BlocProvider.of<MyBloc>(context)更改事件以更改該值。

    使用InheritedWidgets，您可以通過獲取當前狀態context.inheritFromWidgetOfExactType(MyInheritedWidget)。
    但是InheritedWidgets是不可變的（標記了字段final）。您只能通過重建整個窗口小部件來更改狀態。
    這就是為什麼InheritedWidget主要用於東西，很少變動：Theme，MediaQuery，Localization等。
* */
class AppStateContainer extends StatefulWidget {
  final Widget child;

  AppStateContainer({@required this.child});

  @override
  _AppStateContainerState createState() => _AppStateContainerState();

//  of 是拿共用資料的
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
