import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class Weather extends StatefulWidget {
  const Weather({Key? key}) : super(key: key);

  @override
  _WeatherState createState() => _WeatherState();
}

class _WeatherState extends State<Weather> {
  String city = "Nagpur";
  double latitude = 21.1682;
  double longitude = 79.6488;
  Map<String, dynamic>? weatherData;
  bool isLoading = false;
  final TextEditingController _controller = TextEditingController();
  bool isCelsius = true;

  String condition(int code) {
    switch (code) {
      case 0:
        return "Clear sky";
      case 1:
      case 2:
      case 3:
        return "Mainly clear, partly cloudy, and overcast";
      case 45:
      case 48:
        return "Fog or depositing rime fog";
      case 51:
      case 53:
      case 55:
        return "Drizzle";
      case 56:
      case 57:
        return "Freezing drizzle";
      case 61:
      case 63:
      case 65:
        return "Rain";
      case 66:
      case 67:
        return "Freezing rain";
      case 71:
      case 73:
      case 75:
        return "Snow fall";
      case 77:
        return "Snow grains";
      case 80:
      case 81:
      case 82:
        return "Rain showers";
      case 85:
      case 86:
        return "Snow showers";
      case 95:
        return "Thunderstorm";
      case 96:
      case 99:
        return "Thunderstorm with hail";
      default:
        return "Unknown weather condition";
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
      final String apiUrl = 'https://api.open-meteo.com/v1/forecast';
      final Map<String, String> queryParams = {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'hourly': 'temperature_2m,visibility',
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

  IconData getWeatherIcon(double temperature) {
    if (temperature < 0) {
      return Icons.ac_unit;
    } else if (temperature >= 0 && temperature <= 20) {
      return Icons.cloud;
    } else if (temperature > 20 && temperature <= 30) {
      return Icons.wb_sunny;
    } else {
      return Icons.thermostat;
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

  late Size size;

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        padding: EdgeInsets.only(top: 30),
        height: size.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF1E3A8A),
              Color(0xFF2563EB),
              Color(0xFF60A5FA),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : weatherData == null
                    ? const Center(
                        child: Text(
                          "No data available",
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: _controller,
                            onSubmitted: (query) {
                              if (query.isNotEmpty) {
                                search(query);
                                _controller.clear();
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text("Please enter a city name")),
                                );
                              }
                            },
                            decoration: InputDecoration(
                              labelText: 'Search City',
                              labelStyle: const TextStyle(color: Colors.white),
                              border: const UnderlineInputBorder(),
                              suffixIcon: _controller.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear,
                                          color: Colors.white),
                                      onPressed: () {
                                        _controller.clear();
                                      },
                                    )
                                  : null,
                            ),
                            style: const TextStyle(color: Colors.white),
                          ),
                          const SizedBox(height: 20),
                          Center(
                            child: Text(
                              "📍 $city",
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Center(
                            child: Icon(
                              getWeatherIcon(weatherData!['hourly']
                                      ['temperature_2m'][0]
                                  .toDouble()),
                              size: 100,
                              color: Colors.yellowAccent,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Center(
                            child: Text(
                              "${weatherData!['hourly']['temperature_2m'][0]}°${isCelsius ? 'C' : 'F'}",
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 55,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Center(
                            child: Text(
                              condition(
                                  weatherData!['daily']['weather_code'][0]),
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 16),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Sunrise: ${formatTime(weatherData!['daily']['sunrise'][0])}",
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 16),
                              ),
                              Text(
                                "Sunset: ${formatTime(weatherData!['daily']['sunset'][0])}",
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 16),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Max Temp: ${weatherData!['daily']['temperature_2m_max'][0]}°C",
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 16),
                              ),
                              Text(
                                "Min Temp: ${weatherData!['daily']['temperature_2m_min'][0]}°C",
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 16),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Center(
                            child: Text(
                              "Max UV Index: ${weatherData!['daily']['uv_index_max'][0]}",
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 16),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Center(
                            child: Text(
                              weatherData?['hourly']?['visibility']?[0] != null
                                  ? "Visibility: ${weatherData!['hourly']!['visibility'][0]} km"
                                  : "Visibility: N/A",
                              style: const TextStyle(
                                  fontSize: 16, color: Colors.white70),
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            height: 150,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: weatherData?['hourly']
                                          ?['temperature_2m']
                                      ?.length ??
                                  0,
                              itemBuilder: (context, index) {
                                final temperature = weatherData?['hourly']
                                    ?['temperature_2m']?[index];
                                final time = DateTime.parse(
                                    weatherData!['hourly']['time'][index]);
                                final day = DateFormat('EEEE').format(time);
                                final date = DateFormat('d MMM').format(time);
                                final weatherIcon = getWeatherIcon(
                                    temperature?.toDouble() ?? 0);

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
                                        Text(
                                          DateFormat('h a').format(time),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Icon(
                                          weatherIcon,
                                          size: 30,
                                          color: Colors.white,
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          temperature != null
                                              ? "${temperature}°C"
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
                        ],
                      ),
          ),
        ),
      ),
    );
  }
}
