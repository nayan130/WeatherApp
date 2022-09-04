import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'page/weather_page.dart';
import 'provider/weather_provider.dart';


void main() {
  runApp(ChangeNotifierProvider(
      create: (BuildContext context) =>WeatherProvider(),
      child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
       fontFamily: 'MerriweatherSans',
        primarySwatch: Colors.blue,
      ),
     initialRoute: WeatherPage.routeName,
      routes: {
        WeatherPage.routeName:(_)=>WeatherPage(),

      },
    );
  }
}

