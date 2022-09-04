import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:liquid_progress_indicator/liquid_progress_indicator.dart';
import 'package:provider/provider.dart';
import 'package:weather_app/provider/weather_provider.dart';
import 'package:weather_app/utils/location_service.dart';

import '../utils/constrant.dart';
import '../utils/helper_function.dart';
import '../utils/text_style.dart';
import '../widgets/Item_sun_time.dart';

class WeatherPage extends StatefulWidget {
  static const String routeName = '/weather';
  const WeatherPage({Key? key,}) : super(key: key);

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  late WeatherProvider provider;
  bool isFirst = true;
  @override
  void didChangeDependencies() {
    if (isFirst) {
      provider = Provider.of<WeatherProvider>(context);
      _detectLocation();

      isFirst = false;
    }
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      backgroundColor: Colors.blueGrey.shade300,
      appBar: AppBar(
        elevation: 2,
        backgroundColor: Colors.transparent,
        title: const Text('Weather'),
        actions: [
          IconButton(onPressed: () {
            _detectLocation();
          }, icon: const Icon(Icons.location_on)),
          IconButton(
              onPressed: () async {
                final result = await showSearch(
                    context: context, delegate: _CitySearchDelegate());
                if (result != null && result.isNotEmpty) {
                  provider.convertCityToLatLong(result:result,onErr: (msg){
                    showMsg(context, msg);
                  });
                }
              },
              icon: const Icon(Icons.search)),
        ],
      ),
      body: Container(

        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("images/bg7.jpg"),
            repeat: ImageRepeat.repeat ,
            colorFilter: ColorFilter.mode(Colors.black38, BlendMode.darken),
            opacity: (0.4),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: provider.hasDataLocated
              ? ListView(
                  padding:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
                  children: [
                    _currentWeatherSection(),
                    _forecastWeatherSection(),
                  ],
                )
              : //const Text('Please wait'),
          LiquidLinearProgressIndicator(
            value: 0.10, // Defaults to 0.5.
            valueColor: AlwaysStoppedAnimation(Colors.lightBlueAccent), // Defaults to the current Theme's accentColor.
            backgroundColor: Colors.transparent, // Defaults to the current Theme's backgroundColor.
            borderColor: Colors.transparent,
            borderWidth: 5.0,
            borderRadius: 12.0,
            direction: Axis.vertical, // The direction the liquid moves (Axis.vertical = bottom to top, Axis.horizontal = left to right). Defaults to Axis.horizontal.
            center: Text("Loading...", style: TextStyle(fontSize: 30, color: Colors.deepOrange),),
          ),

          //EasyLoading.show(status: 'Loading'),
        ),
      ),
    );
  }

  void _detectLocation() async {
   try{
     final position = await determinePosition();
     provider.setNewLocation(position.latitude, position.longitude);
     provider.setTempUnit(await provider.getTempUnitPreferenceValue());
     provider.getWeatherData();
   }catch(e){
     showMsg(context, e.toString());
   }
  }

  Widget _currentWeatherSection() {
    final current = provider.currentResponseModel;
    return Column(
      children: [
        SwitchListTile(
          activeThumbImage:  AssetImage('images/c4.jpg'),
          inactiveThumbImage:  AssetImage('images/f2.png'),
          controlAffinity: ListTileControlAffinity.leading,
            value: provider.isFahrenheit,
            onChanged: (value) async {
              provider.setTempUnit(value);
              await provider.setTempUnitPreferenceValue(value);
              provider.getWeatherData();
            }),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              getFormattedDateTime(
                current!.dt!,
                'MMM dd, yyyy',
              ),
              style: txtDateBig18,
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              '${current.name}, ${current.sys!.country}',
              style: txtAddress25,
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
            ],
          ),
        ),
        Image.network(
          '$iconPrefix${current.weather![0].icon}$iconSuffix',
          fit: BoxFit.cover,
        ),
        Text(
          '${current.main!.temp!.round()}$degree${provider.unitSymbol}',
          style: txtTempBig80,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${current.weather![0].description}',
              style: txtNormal16White22,
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Feels like ${current.main!.feelsLike}$degree${provider.unitSymbol}',
              style: txtNormal16White70,
            ),
          ],
        ),

        const SizedBox(
          height: 20,
        ),

        Wrap(
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  'Humidity ${current.main!.humidity}% ',
                  style: txtNormal16,
                ),
                // Text(
                //   'Humidity ${current.base}% ',
                //   style: txtNormal16,
                // ),
                Divider(
                  color: Colors.black,
                  thickness: 2,
                ),
                Text(
                  'Pressure ${current.main!.pressure}hPa ',
                  style: txtNormal16,
                ),
              ],
            ),
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  'Visibility ${current.visibility}m ',
                  style: txtNormal16,
                ),
                Divider(
                  color: Colors.black,
                  thickness: 2,
                ),
                Text(
                  'Wind Speed ${current.wind!.speed}m/s ',
                  style: txtNormal16,
                ),
              ],
            ),
          ],
        ),
        const SizedBox(
          height: 20,
        ),
        Wrap(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Text('Sunrise', style: txtNormal16White70,),
                    Image.asset('images/sunrise2.png', height: 80, width: 80,),
                    Text(
                      '${getFormattedDateTime(current.sys!.sunrise!, 'hh:mm a')}',
                      style: txtNormal16White70,
                    ),

                  ],
                ),
                Divider(
                  color: Colors.black,
                  thickness: 2,
                ),
                Column(
                  children: [
                    Text('Sunset', style: txtNormal16White70,),
                    Image.asset('images/sunset2.png', height: 80, width: 80,),
                    Text(
                      '${getFormattedDateTime(current.sys!.sunset!, 'hh:mm a')}',
                      style: txtNormal16White70,
                    ),

                  ],
                ),
              ],
            ),

          ],
      ),
        SizedBox(height: 20,),
      ],

    );
  }

  Widget _forecastWeatherSection() {
    final forecastList = provider.forecastResponseModel!.list;
    return SizedBox(
      height: MediaQuery.of(context).size.height*0.31,
      width: MediaQuery.of(context).size.width,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: forecastList!.length,
        itemBuilder: (context, index) => Card(
          color: Colors.transparent,
          elevation: 15,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  getFormattedDateTime(forecastList[index].dt!, 'E MMM d'),
                  style: TextStyle(fontSize: 25, color: Colors.white),
                ),

                Text(
                  getFormattedDateTime(forecastList[index].dt!, ' hh:mm a'),
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
                Column(
                  children: [
                    Image.network(
                      '$iconPrefix${forecastList[index].weather![0].icon}$iconSuffix',
                      height: 70,
                      width: 70,
                      fit: BoxFit.cover,
                    ),
                    Text('${forecastList[index].main!.temp!.round()}$degree${provider.unitSymbol} / ${forecastList[index].main!.feelsLike}$degree${provider.unitSymbol}',
                      style: TextStyle(fontSize: 22, color: Colors.white),),
                    //Text('${forecastList[index].main!.temp!.round()}$degree / ${forecastList[index].main!.temp!.round()}$degree${provider.unitSymbol}'),
                  ],
                ),
                Text('${forecastList[index].main!.humidity}%',
                  style: TextStyle(fontSize: 20, color: Colors.white),),

                Text(forecastList[index].weather![0].description.toString(),
                  style: TextStyle(fontSize: 20, color: Colors.white),),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CitySearchDelegate extends SearchDelegate<String> {
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
          onPressed: () {
            query = '';
          },
          icon: const Icon(Icons.clear))
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    IconButton(onPressed: () {}, icon: const Icon(Icons.arrow_back));
  }

  @override
  Widget buildResults(BuildContext context) {
    // final filterList=q
    if (query.isNotEmpty && query != null) {}

    return ListTile(
      leading: Icon(Icons.search),
      title: Text(query),
      onTap: (){
        close(context, query);
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final filterList = query.isEmpty
        ? cities
        : cities
            .where((element) => element.toLowerCase() == query.toLowerCase())
            .toList();
    return ListView.builder(
      itemCount: filterList.length,
      itemBuilder: (context, index) => ListTile(onTap: (){
        query=filterList[index];
        close(context, query);
      },
        title: Text(filterList[index],

        ),

      ),
    );
  }
}
