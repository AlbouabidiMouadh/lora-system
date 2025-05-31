import 'package:flutter/material.dart';
import 'package:flutter_application/Models/sensor_reading.dart';
import 'package:flutter_application/Services/api_service.dart';
import 'package:intl/intl.dart';

class TemperatureScreen extends StatefulWidget {
  const TemperatureScreen({super.key});

  @override
  State<TemperatureScreen> createState() => TemperatureScreenState();
}

class TemperatureScreenState extends State<TemperatureScreen> {
  final ApiService _apiService = ApiService();

  List<SensorReading> _sensorReadings = [];
  bool _isLoading = false;
  String? _errorMessage;

  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
  }

  DateTime _getStartDate() {
    return DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
  }

  DateTime _getEndDate() {
    return DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
    ).add(const Duration(days: 1));
  }

  Future<void> _fetchSensorData() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _sensorReadings = [];
    });

    final DateTime startDate = _getStartDate();
    final DateTime endDate = _getEndDate();

    try {
      final List<SensorReading> data = await _apiService.fetchSensorReadings(
        startDate: startDate,
        endDate: endDate,
      );

      setState(() {
        data.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        _sensorReadings = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load data.\n${e.toString()}';
        _isLoading = false;
      });
      debugPrint('Error fetching sensor data in screen: $e');
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked;

    DateTime firstDateLimit = DateTime(2020, 1, 1);
    DateTime lastDateLimit = DateTime.now();

    picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: firstDateLimit,
      lastDate: lastDateLimit,
      helpText: 'Select Date',
    );

    if (picked == null || picked == _selectedDate) {
      return;
    }

    setState(() {
      _selectedDate = picked!;
    });
  }

  @override
  Widget build(BuildContext context) {
    String selectedDateString = DateFormat('yyyy-MM-dd').format(_selectedDate);

    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color primaryColor = colorScheme.primary;
    final Color onPrimaryColor = colorScheme.onPrimary;
    final Color surfaceColor = colorScheme.surface;

    const Color tempColor = Colors.redAccent;
    const Color humidityColor = Colors.blueAccent;
    const Color moistureColor = Colors.brown;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Historical Sensor Data',
          style: TextStyle(color: Colors.white),
        ),
        elevation: 4,
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.green[500],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: InkWell(
                    onTap: _isLoading ? null : () => _selectDate(context),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Selected Date',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(35.0),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 16,
                        ),
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              selectedDateString,
                              style: Theme.of(
                                context,
                              ).textTheme.titleMedium?.copyWith(fontSize: 16),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Icon(Icons.calendar_today, color: Colors.green[500]),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 1,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _fetchSensorData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(192, 44, 176, 70),
                      foregroundColor: onPrimaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(35.0),
                      ),
                      elevation: 5.0,
                      shadowColor: Colors.black,
                    ),
                    child:
                        _isLoading
                            ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                color: Colors.grey[100],
                              ),
                            )
                            : const Text(
                              'Search',
                              style: TextStyle(fontSize: 16),
                            ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            Expanded(
              child:
                  _isLoading
                      ? Center(
                        child: CircularProgressIndicator(color: primaryColor),
                      )
                      : _errorMessage != null
                      ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            _errorMessage!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: colorScheme.error,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      )
                      : _sensorReadings.isEmpty
                      ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(18.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.sensors_outlined,
                                size: 60,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No sensor data found for ${DateFormat('yyyy-MM-dd').format(_selectedDate)}.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Select a different date or check your sensor data source.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      : ListView.builder(
                        itemCount: _sensorReadings.length,
                        itemBuilder: (context, index) {
                          final reading = _sensorReadings[index];

                          String formattedTimestamp = DateFormat(
                            'yyyy-MM-dd HH:mm:ss',
                          ).format(reading.timestamp.toLocal());

                          return Card(
                            margin: const EdgeInsets.symmetric(
                              vertical: 5.0,
                              horizontal: 0,
                            ),
                            elevation: 7,
                            shadowColor: Colors.greenAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(40.0),
                            ),
                            color: const Color.fromARGB(213, 250, 250, 250),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 14.0,
                                horizontal: 16.0,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              'Temperature',
                                              style: Theme.of(
                                                context,
                                              ).textTheme.bodySmall?.copyWith(
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              '${reading.temperature.toStringAsFixed(1)}°C',
                                              style: Theme.of(
                                                context,
                                              ).textTheme.titleMedium?.copyWith(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: tempColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      Expanded(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              'Humidity',
                                              style: Theme.of(
                                                context,
                                              ).textTheme.bodySmall?.copyWith(
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              '${reading.humidity.toStringAsFixed(1)}%',
                                              style: Theme.of(
                                                context,
                                              ).textTheme.titleMedium?.copyWith(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: humidityColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      Expanded(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              'Moisture',
                                              style: Theme.of(
                                                context,
                                              ).textTheme.bodySmall?.copyWith(
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              '${reading.moisture.toStringAsFixed(1)}%',
                                              style: Theme.of(
                                                context,
                                              ).textTheme.titleMedium?.copyWith(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: moistureColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Divider(height: 16, thickness: 0.5),

                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      'Recorded at: $formattedTimestamp',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodySmall?.copyWith(
                                        color: Colors.grey[600],
                                        fontSize: 12,
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
    );
  }
}
