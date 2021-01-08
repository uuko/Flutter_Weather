import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:json_http_test/src/screens/routes.dart';


import '../../main.dart';
import 'WeatherBloc.dart';
import 'WeatherModel.dart';
import 'WeatherRepo.dart';


enum OptionsMenu {  settings }


class WeatherScreen extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        routes: Routes.mainRoute,
        theme: ThemeData(
          // This is the theme of your application.
          //
          // Try running your application with "flutter run". You'll see the
          // application has a blue toolbar. Then, without quitting the app, try
          // changing the primarySwatch below to Colors.green and then invoke
          // "hot reload" (press "r" in the console where you ran "flutter run",
          // or simply save your changes to "hot reload" in a Flutter IDE).
          // Notice that the counter didn't reset back to zero; the application
          // is not restarted.
          backgroundColor: AppStateContainer.of(context).theme.primaryColor,
        ),
        home:MyHome()
    );
  }

}



class MyHome extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
   return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: AppStateContainer.of(context).theme.primaryColor,
        elevation: 0,
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              DateFormat('EEEE, d MMMM yyyy').format(DateTime.now()),
              style: TextStyle(
                  color: AppStateContainer.of(context)
                      .theme
                      .accentColor
                      .withAlpha(80),
                  fontSize: 14),
            )
          ],
        ),
        actions: <Widget>[
          PopupMenuButton<OptionsMenu>(
              child: Icon(
                Icons.more_vert,
                color: AppStateContainer.of(context).theme.accentColor,
              ),
              onSelected:  (OptionsMenu item) {
                Navigator.of(context).pushNamed("/settings");
              } ,
              itemBuilder: (context) => <PopupMenuEntry<OptionsMenu>>[
                PopupMenuItem<OptionsMenu>(
                  value: OptionsMenu.settings,
                  child: Text("settings"),
                ),
              ])
        ],
      ),
     backgroundColor: AppStateContainer.of(context).theme.primaryColor,
      body: BlocProvider(
        builder: (context) => WeatherBloc(WeatherRepo()),
        child: SearchPage(),
      ),
    );
  }


}
class SearchPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final weatherBloc = BlocProvider.of<WeatherBloc>(context);
    var cityController = TextEditingController();

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[


        Center(
            child: Container(
              child: FlareActor("assets/WorldSpin.flr", fit: BoxFit.contain, animation: "roll",),
              height: 300,
              width: 300,
            )
        ),



        BlocBuilder<WeatherBloc, WeatherState>(
          builder: (context, state){
            if(state is WeatherIsNotSearched)
              return Container(
                padding: EdgeInsets.only(left: 32, right: 32,),
                child: Column(
                  children: <Widget>[
                    Text("Search Weather", style: TextStyle(fontSize: 40, fontWeight: FontWeight.w500, color: AppStateContainer.of(context).theme.accentColor),),
                    Text("Instanly", style: TextStyle(fontSize: 40, fontWeight: FontWeight.w200, color: AppStateContainer.of(context).theme.accentColor),),
                    SizedBox(height: 24,),
                    TextFormField(
                      controller: cityController,

                      decoration: InputDecoration(

                        prefixIcon: Icon(Icons.search, color: AppStateContainer.of(context).theme.primaryColor,),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            borderSide: BorderSide(
                                color: Colors.pinkAccent,
                                style: BorderStyle.solid
                            )
                        ),

                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            borderSide: BorderSide(
                                color: Colors.blue,
                                style: BorderStyle.solid
                            )
                        ),

                        hintText: "City Name",
                        hintStyle: TextStyle(color:Colors.white30),

                      ),
                      style: TextStyle(color:Colors.pinkAccent),

                    ),

                    SizedBox(height: 20,),
                    Container(
                      width: double.infinity,
                      height: 50,
                      child: FlatButton(
                        shape: new RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                        onPressed: (){
                          weatherBloc.add(FetchWeather(cityController.text));
                        },
                        color: Colors.lightBlue,
                        child: Text("Search", style: TextStyle(color: Colors.white70, fontSize: 16),),

                      ),
                    )

                  ],
                ),
              );
            else if(state is WeatherIsLoading)
              return Center(child : CircularProgressIndicator());
            else if(state is WeatherIsLoaded)
              return ShowWeather(state.getWeather, cityController.text);
            else
              return Text("Error",style: TextStyle(color: Colors.white),);
          },
        )

      ],
    );
  }
}

class ShowWeather extends StatelessWidget {
  WeatherModel weather;
  final city;

  ShowWeather(this.weather, this.city);

  @override
  Widget build(BuildContext context) {
    initializeNotifications();
    DateTime now = DateTime.now().toUtc().add(
      Duration(seconds: 1),
    );
    var topText="";
    if(weather.getTemp>20) {
      topText = "溫度適宜";
    }
    else if(weather.getTemp<20 && weather.getTemp>10){
      topText = "穿多點，有點冷";
    }
    else if(weather.getTemp<10){
      topText = "超超超超超級冷哦，請包成粽子吧";
    }
     singleNotification(
        now,
        topText,
        weather.getTemp.toString()+"度",
        98123871,
    );
    return Container(
        padding: EdgeInsets.only(right: 32, left: 32, top: 10),
        child: Column(
          children: <Widget>[
            Text(city,style: TextStyle(color: AppStateContainer.of(context).theme.accentColor, fontSize: 30, fontWeight: FontWeight.bold),),
            SizedBox(height: 10,),

            Text(weather.getTemp.round().toString()+"C",style: TextStyle(color: AppStateContainer.of(context).theme.accentColor, fontSize: 50),),
            Text("Temprature",style: TextStyle(color: AppStateContainer.of(context).theme.accentColor, fontSize: 14),),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Text(weather.getMinTemp.round().toString()+"C",style: TextStyle(color: AppStateContainer.of(context).theme.accentColor, fontSize: 30),),
                    Text("Min Temprature",style: TextStyle(color: AppStateContainer.of(context).theme.accentColor, fontSize: 14),),
                  ],
                ),
                Column(
                  children: <Widget>[
                    Text(weather.getMaxTemp.round().toString()+"C",style: TextStyle(color: AppStateContainer.of(context).theme.accentColor, fontSize: 30),),
                    Text("Max Temprature",style: TextStyle(color: AppStateContainer.of(context).theme.accentColor, fontSize: 14),),
                  ],
                ),
              ],
            ),
            SizedBox(
              height: 20,
            ),

            Container(
              width: double.infinity,
              height: 50,
              child: FlatButton(
                shape: new RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                onPressed: () async{
                  BlocProvider.of<WeatherBloc>(context).add(ResetWeather());

                },
                color: Colors.lightBlue,
                child: Text("Search", style: TextStyle(color: AppStateContainer.of(context).theme.accentColor, fontSize: 16),),

              ),
            )
          ],
        )
    );
  }
}