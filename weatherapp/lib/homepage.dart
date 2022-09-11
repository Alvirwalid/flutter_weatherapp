import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:jiffy/jiffy.dart';
import 'package:weatherapp/model/model.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Map<String, dynamic>? weatherMap;
  Map<String, dynamic>? forecastMap;
  double? fahren;
  int? currentIndex;

  ///
  late Position position;
//
  _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    position = await Geolocator.getCurrentPosition();

    print('positioned is ${position.latitude} and ${position.longitude}');
    fetchData();
  }

//////////////
  @override
  void initState() {
// TODO: implement initState
    _determinePosition();
    super.initState();
  }

//////////////////////////
///////
  fetchData() async {
    String weatherapi =
        'https://api.openweathermap.org/data/2.5/weather?lat=${position.latitude}&lon=${position.longitude}&appid=a09f2a6292c60b6aec53dd4fe7eb61d4';
    String forecastapi =
        'https://api.openweathermap.org/data/2.5/forecast?lat=${position.latitude}&lon=${position.longitude}&appid=a09f2a6292c60b6aec53dd4fe7eb61d4';

    var weatherrespons = await http.get(Uri.parse(weatherapi));
    var forecastrespons = await http.get(Uri.parse(forecastapi));

    var weatherData = jsonDecode(weatherrespons.body);
    var forecastData = jsonDecode(forecastrespons.body);

    setState(() {
      weatherMap = Map<String, dynamic>.from(weatherData);
      forecastMap = Map<String, dynamic>.from(forecastData);
    });

    fahren = (weatherMap!['main']['temp'] - 32);

    print('weather data= ${weatherrespons.body}');
    print('forecast data= ${forecastrespons.body}');
    print('$fahren');
  }

  var celsious;
  var feellikes;

  @override
  Widget build(BuildContext context) {
    var queryData = MediaQuery.of(context);
    if (weatherMap == null) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    } else {
      celsious = weatherMap!['main']['temp'] - 273.15;
      feellikes = weatherMap!['main']['feels_like'] - 273.15;
    }
    return Scaffold(
      backgroundColor: Color(0xff0E0A15),
      appBar: AppBar(
// toolbarHeight: 45,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leadingWidth: 200,

        leading: Padding(
          padding: const EdgeInsets.only(left: 8, top: 8, bottom: 8),
          child: Column(
            children: [
              Text(
                '${Jiffy(DateTime.now()).format("MMM do yy,h:mm")}',
                style: myStyle(clr: Colors.white, fs: 14),
              )
            ],
          ),
        ),
        actions: [
          Container(
            width: 140,
            height: 35,
            decoration: BoxDecoration(
                border: Border.all(width: 1, color: Colors.white),
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(12)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(
                  Icons.location_on,
                  color: Colors.white,
                ),
                weatherMap == null
                    ? CircularProgressIndicator()
                    : Text(
                        '${weatherMap!['name']}',
                        style: myStyle(clr: Colors.white, fs: 16),
                      )
              ],
            ),
          ),
          SizedBox(
            width: 30,
          )
        ],
      ),
      body: weatherMap == null
          ? CircularProgressIndicator()
          : Container(
              padding: EdgeInsets.all(16),
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 40,
                  ),
                  Container(
                    height: 45.h,
                    width: 100.w,
                    decoration: BoxDecoration(
                        color: Color(0xff0A0F1B),
                        borderRadius: BorderRadius.circular(13)),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned(
                          //top: 10,
                          child: Column(
                            children: [
                              SizedBox(
                                height: 10,
                              ),
                              Container(
                                alignment: Alignment.center,
                                width: double.infinity,
                                color: Colors.transparent,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 20.w,
                                    ),
                                    Text(
                                      '${celsious.toStringAsFixed(1)} °C',
                                      style: myStyle(
                                          clr: Colors.white,
                                          fs: 28,
                                          fw: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 8.h,
                              ),
                              Container(
                                height: 30.h,
                                color: Colors.transparent,
                                child: CustomScrollView(
                                  primary: true,
                                  slivers: <Widget>[
                                    SliverPadding(
                                      padding: const EdgeInsets.all(20),
                                      sliver: SliverGrid.count(
                                        crossAxisSpacing: 10,
                                        mainAxisSpacing: 10,
                                        crossAxisCount: 3,
                                        children: <Widget>[
                                          Container(
                                            padding: EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              color: Color(0xff0F1324),
                                            ),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  ' ${feellikes.toStringAsFixed(0)} °C',
                                                  style: myStyle(
                                                      clr: Colors.white,
                                                      fs: 16),
                                                ),
                                                Text(
                                                  'Feels like ',
                                                  style: myStyle(
                                                      clr: Colors.white,
                                                      fs: 16),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              color: Color(0xff0F1324),
                                            ),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  ' ${weatherMap!['main']['humidity']} °C',
                                                  style: myStyle(
                                                      clr: Colors.white,
                                                      fs: 16),
                                                ),
                                                Text(
                                                  'Humidity',
                                                  style: myStyle(
                                                      clr: Colors.white,
                                                      fs: 16),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              color: Color(0xff0F1324),
                                            ),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  'The sky ',
                                                  style: myStyle(
                                                      clr: Colors.white,
                                                      fs: 16),
                                                ),
                                                Text(
                                                  '${weatherMap!['weather'][0]['main']} ',
                                                  style: myStyle(
                                                      clr: Colors.white,
                                                      fs: 16),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              color: Color(0xff0F1324),
                                            ),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  '${weatherMap!['wind']['speed']} KM\\h',
                                                  style: myStyle(
                                                      clr: Colors.white,
                                                      fs: 16),
                                                ),
                                                Text(
                                                  'Wind',
                                                  style: myStyle(
                                                      clr: Colors.white,
                                                      fs: 16),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              color: Color(0xff0F1324),
                                            ),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  '${Jiffy(DateTime.fromMicrosecondsSinceEpoch(weatherMap!['sys']['sunrise'])).format('h:mm a')}',
                                                  style: myStyle(
                                                      clr: Colors.white,
                                                      fs: 16),
                                                ),
                                                Text(
                                                  'Sunrise',
                                                  style: myStyle(
                                                      clr: Colors.white,
                                                      fs: 16),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              color: Color(0xff0F1324),
                                            ),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  'Wind',
                                                  style: myStyle(
                                                      clr: Colors.white,
                                                      fs: 16),
                                                ),
                                                Text(
                                                  '${weatherMap!['wind']['speed']} KM\\h',
                                                  style: myStyle(
                                                      clr: Colors.white,
                                                      fs: 16),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          top: -30,
                          child: Image.asset(
                            './asset/image/weather.png',
                            width: 40.w,
                            //height: 5.h,
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Expanded(
                      flex: 2,
                      child: Container(
                        padding: EdgeInsets.all(16),
                        width: 100.w,
                        // height: 80.h,
                        // color: Colors.red,
                        child: ListView.separated(
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                            separatorBuilder: (context, index) {
                              return SizedBox(
                                width: 3,
                              );
                            },
                            itemCount: forecastMap!.length,
                            itemBuilder: (context, index) {
                              return InkWell(
                                onTap: () {
                                  setState(() {
                                    currentIndex = index;
                                  });
                                },
                                child: Container(
                                  width: 27.w,
                                  decoration: BoxDecoration(
                                      color: currentIndex == index
                                          ? Color(0xff0A0F1B)
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(12)),
                                  child: Card(
                                    color: Colors.transparent,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          '${Jiffy(forecastMap!['list'][0]['dt_txt']).format('EEE h:mm a')}',
                                          style: myStyle(
                                              clr: Colors.white, fs: 12.dp),
                                        ),
                                        Image.network(
                                            'http://openweathermap.org/img/wn/${forecastMap!['list'][index]['weather'][0]['icon']}@2x.png'),
                                        Text(
                                          '${(forecastMap!['list'][index]['main']['temp'] - 273.15).toStringAsFixed(1)} °C',
                                          style: myStyle(
                                              clr: Colors.white,
                                              fs: 22,
                                              fw: FontWeight.w500),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }),
                      ))
                ],
              ),
            ),
    );
  }
}
