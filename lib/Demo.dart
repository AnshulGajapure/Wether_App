import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class MyHome extends StatefulWidget {
  const MyHome({super.key});

  @override
  State<MyHome> createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHome> {
  late Size size;

  String city = "Nagpur";
  double latitude = 21.1682;
  double longitude = 79.6488;
  Map<String, dynamic>? weatherData;
  bool isLoading = false;
  final TextEditingController _controller = TextEditingController();
  bool isCelsius = true;

  Widget condition(int code) {
    switch (code) {
      case 0:
        return Image.asset(
          'assets/Clear.gif',
          width: 80,
          height: 80,
        );
      case 1:
      case 2:
      case 3:
        return Image.asset(
          'assets/Cloudy.gif',
          width: 80,
          height: 80,
        );
      case 45:
      case 48:
        return Image.asset(
          'assets/Foggy.gif',
          width: 80,
          height: 80,
        );
      case 51:
      case 53:
      case 55:
        return Image.asset(
          'assets/Drizzle.gif',
          width: 80,
          height: 80,
        );
      case 56:
      case 57:
        return Image.asset(
          'assets/Rain.gif',
          width: 80,
          height: 80,
        );
      case 61:
      case 63:
      case 65:
        return Image.asset(
          'assets/Rain.gif',
          width: 80,
          height: 80,
        );
      case 66:
      case 67:
        return Image.asset(
          'assets/Snow.gif',
          width: 80,
          height: 80,
        );
      case 71:
      case 73:
      case 75:
        return Image.asset(
          'assets/Snow.gif',
          width: 80,
          height: 80,
        );
      case 77:
        return Image.asset(
          'assets/Snow.gif',
          width: 80,
          height: 80,
        );
      case 80:
      case 81:
      case 82:
        return Image.asset(
          'assets/Rain.gif',
          width: 80,
          height: 80,
        );
      case 85:
      case 86:
        return Image.asset(
          'assets/Snow.gif',
          width: 80,
          height: 80,
        );
      case 95:
        return Image.asset(
          'assets/Thunderstorm.gif',
          width: 80,
          height: 80,
        );
      case 96:
      case 99:
        return Image.asset(
          'assets/Thunderstorm.gif',
          width: 80,
          height: 80,
        );
      default:
        return Image.asset(
          'assets/Thunderstorm.gif',
          width: 80,
          height: 80,
        );
    }
  }

  Future<void> search(String cityName) async {
    try {
      final locations = await locationFromAddress(cityName);
      if (locations.isNotEmpty) {
        final location = locations.first;
        setState(() {
          city = cityName;
          latitude = location.latitude;
          longitude = location.longitude;
        });
        await weather();
      } else {
        showError('Location not found.');
      }
    } catch (e) {
      showError("Error: Could not find location");
    }
  }

  Future<void> weather() async {
    setState(() {
      isLoading = true;
    });

    try {
      const String apiUrl = 'https://api.open-meteo.com/v1/forecast';
      final Map<String, String> queryParams = {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'hourly':
            'temperature_2m,visibility,wind_speed_120m,relative_humidity_2m',
        'current_weather': 'true',
        'timezone': 'auto',
        'daily':
            'weather_code,temperature_2m_max,temperature_2m_min,sunrise,sunset,uv_index_max',
      };
      final Uri uri = Uri.parse(apiUrl).replace(queryParameters: queryParams);

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        setState(() {
          weatherData = json.decode(response.body);
        });
      } else {
        showError('Failed to load weather data. Please try again.');
      }
    } catch (e) {
      showError('Error fetching weather: ${e.toString()}');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Widget getWeatherIcon(double temperature) {
    if (temperature < 0) {
      return Image.asset(
        'assets/snowflake.gif',
        width: 10,
        height: 10,
      );
    } else if (temperature >= 0 && temperature <= 20) {
      return Image.asset(
        'assets/sun.gif',
        width: 10,
        height: 10,
      );
    } else if (temperature > 20 && temperature <= 30) {
      return Image.asset(
        'assets/Cloudy.gif',
        width: 10,
        height: 10,
      );
    } else {
      return Image.asset(
        'assets/wind.png',
        width: 10,
        height: 10,
      );
    }
  }

  String formatTime(String time) {
    final dateTime = DateTime.parse(time);
    return DateFormat('h:mm a').format(dateTime);
  }

  @override
  void initState() {
    super.initState();
    weather();
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black12,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              physics: BouncingScrollPhysics(),
              slivers: [
                SliverAppBar(
                  expandedHeight: size.height * 0.60,
                  floating: true,
                  pinned: true,
                  stretch: true,
                  snap: false,
                  collapsedHeight: size.height * 0.2,
                  backgroundColor: Colors.black,
                  flexibleSpace: LayoutBuilder(
                    builder:
                        (BuildContext context, BoxConstraints constraints) {
                      double appBarHeight = constraints.biggest.height;
                      double collapsedHeight = kToolbarHeight;
                      double expandedHeight = size.height * 0.6;
                      double t = (appBarHeight - collapsedHeight) /
                          (expandedHeight - collapsedHeight);
                      t = t.clamp(0.0, 1.0);
                      return FlexibleSpaceBar(
                        stretchModes: const [StretchMode.zoomBackground],
                        title: Opacity(
                          opacity: 1 - t,
                          child: Center(
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(right: 60.0, top: 30),
                              child: Text(
                                weatherData != null &&
                                        weatherData?['current_weather']
                                                ?['temperature'] !=
                                            null
                                    ? "${weatherData!['current_weather']['temperature'].toStringAsFixed(1)}\u00B0${isCelsius ? 'C' : 'F'}"
                                    : "--",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 55,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        background: Opacity(
                          opacity: t,
                          child: Container(
                            height: size.height * 0.6,
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.vertical(
                                  bottom: Radius.circular(60)),
                              gradient: LinearGradient(
                                colors: [
                                  Color(0xFF6DB9F8),
                                  Color(0xFF396BC9),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 40.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const SizedBox(height: 10),
                                      SizedBox(
                                        width: size.width * 0.6,
                                        child: Center(
                                          child: TextField(
                                            controller: _controller,
                                            onSubmitted: (query) {
                                              if (query.isNotEmpty) {
                                                search(query);
                                                _controller.clear();
                                              } else {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  const SnackBar(
                                                      content: Text(
                                                          "Please enter a city name")),
                                                );
                                              }
                                            },
                                            decoration: InputDecoration(
                                              labelText: 'Search City',
                                              labelStyle: const TextStyle(
                                                  color: Colors.white),
                                              border:
                                                  const UnderlineInputBorder(),
                                              suffixIcon: _controller
                                                      .text.isNotEmpty
                                                  ? IconButton(
                                                      icon: const Icon(
                                                          Icons.clear,
                                                          color: Colors.white),
                                                      onPressed: () {
                                                        _controller.clear();
                                                      },
                                                    )
                                                  : null,
                                            ),
                                            style: const TextStyle(
                                                color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Column(
                                    children: [
                                      condition(weatherData!['daily']
                                          ['weather_code'][0]),
                                      const SizedBox(height: 10),
                                      Text(
                                        city,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    weatherData != null &&
                                            weatherData?['current_weather']
                                                    ?['temperature'] !=
                                                null
                                        ? "${weatherData!['current_weather']['temperature'].toStringAsFixed(1)}\u00B0${isCelsius ? 'C' : 'F'}"
                                        : "--",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 55,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Column(
                                        children: [
                                          Image.asset('assets/humidity.png',
                                              width: 28, height: 28),
                                          const SizedBox(height: 5),
                                          Text(
                                            weatherData != null &&
                                                    weatherData?['hourly']?[
                                                                'wind_speed_120m']
                                                            ?[0] !=
                                                        null
                                                ? "${weatherData!['hourly']['wind_speed_120m'][0]} m/s"
                                                : "N/A",
                                            style: const TextStyle(
                                                color: Colors.white),
                                          ),
                                          const Text(
                                            "Wind",
                                            style: TextStyle(
                                                color: Colors.white70,
                                                fontSize: 12),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          Image.asset('assets/wind.gif',
                                              width: 28, height: 28),
                                          const SizedBox(height: 5),
                                          Text(
                                            weatherData?['hourly']?[
                                                            'relative_humidity_2m']
                                                        ?[0] !=
                                                    null
                                                ? "${weatherData!['hourly']!['relative_humidity_2m'][0]}%"
                                                : "N/A",
                                            style: const TextStyle(
                                                color: Colors.white),
                                          ),
                                          const Text(
                                            "Humidity",
                                            style: TextStyle(
                                                color: Colors.white70,
                                                fontSize: 12),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          Image.asset('assets/view.png',
                                              width: 28, height: 28),
                                          const SizedBox(height: 5),
                                          Text(
                                            weatherData?['hourly']
                                                        ?['visibility']?[0] !=
                                                    null
                                                ? "${weatherData!['hourly']!['visibility'][0]} km"
                                                : "N/A",
                                            style: const TextStyle(
                                                color: Colors.white),
                                          ),
                                          const Text(
                                            "Visibility",
                                            style: TextStyle(
                                                color: Colors.white70,
                                                fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SliverToBoxAdapter(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.black87,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(30)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 16.0, bottom: 190),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 16),
                                  child: Text(
                                    "Today",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              height: size.height * 0.2,
                              width: size.width,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: weatherData?['hourly']
                                            ?['temperature_2m']
                                        ?.length ??
                                    0,
                                itemBuilder: (context, index) {
                                  final time = DateTime.parse(
                                      weatherData!['hourly']['time'][index]);
                                  final currentDate = DateTime.now();
                                  if (time.day != currentDate.day ||
                                      time.month != currentDate.month ||
                                      time.year != currentDate.year) {
                                    return const SizedBox();
                                  }

                                  final temperature = weatherData?['hourly']
                                      ['temperature_2m'][index];
                                  DateFormat('EEEE').format(time);
                                  final date = DateFormat('d MMM').format(time);

                                  return Container(
                                    width: 100,
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            date,
                                            style: const TextStyle(
                                              color: Colors.white70,
                                              fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                            DateFormat('h a').format(time),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 5),
                                          SizedBox(
                                            width: 50,
                                            height: 50,
                                            child: getWeatherIcon(
                                                temperature?.toDouble() ?? 0),
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                            temperature != null
                                                ? "$temperature°C"
                                                : "N/A",
                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                "Next 7 Day",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              height: size.height * 0.25,
                              width: size.width,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: 7,
                                itemBuilder: (context, index) {
                                  final dayData = weatherData?['daily'];
                                  if (dayData == null ||
                                      dayData['temperature_2m_max']?.length <=
                                          index) {
                                    return Container();
                                  }

                                  final maxTemp =
                                      dayData['temperature_2m_max'][index];
                                  final minTemp =
                                      dayData['temperature_2m_min'][index];
                                  final time =
                                      DateTime.parse(dayData['time'][index]);
                                  final day = DateFormat('EEEE').format(time);
                                  final date = DateFormat('d MMM').format(time);
                                  final temperature = weatherData?['hourly']
                                      ['temperature_2m'][index];

                                  return Container(
                                    width: 100,
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            day,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                            date,
                                            style: const TextStyle(
                                              color: Colors.white70,
                                              fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(height: 5),
                                          SizedBox(
                                            width: 50,
                                            height: 50,
                                            child: getWeatherIcon(
                                                temperature?.toDouble() ?? 0),
                                          ),
                                          const SizedBox(height: 5),
                                          Center(
                                            child: Text(
                                              "max $maxTemp°C  min $minTemp°C",
                                              style: const TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
