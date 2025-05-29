import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';

class SensorDataPage extends StatefulWidget {
  const SensorDataPage({super.key});
  @override
  State<SensorDataPage> createState() => _SensorDataPageState();
}

class _SensorDataPageState extends State<SensorDataPage> {
  late WebSocketChannel channel;
  Map<String, dynamic>? sensorData;

  final MapController _mapController = MapController();
  final PopupController _popupLayerController = PopupController();
  LatLng? _currentLocation;
  final List<Marker> _markers = [];

  static const LatLng _kInitialPosition = LatLng(48.8566, 2.3522); // Paris
  static const double _kInitialZoom = 5.0;
  static const double _kSensorZoom = 15.0;

  static const double _kMaxZoom = 18.0;
  static const double _kMinZoom = 3.0;

  @override
  void initState() {
    super.initState();
    _connectWebSocket();
  }

  void _connectWebSocket() {
    final wsUrl = Uri.parse('ws://10.0.2.2:8000/ws/sensors/');
    channel = WebSocketChannel.connect(wsUrl);

    channel.stream.listen(
      (message) {
        print('Received: $message');
        try {
          final decodedData = jsonDecode(message);
          if (decodedData is Map<String, dynamic> &&
              decodedData.containsKey('latitude') &&
              decodedData.containsKey('longitude') &&
              decodedData.containsKey('temperature') &&
              decodedData.containsKey('humidity')) {
            setState(() {
              sensorData = decodedData;
              final lat =
                  sensorData!['latitude'] is String
                      ? double.tryParse(sensorData!['latitude'])
                      : sensorData!['latitude'].toDouble();
              final lon =
                  sensorData!['longitude'] is String
                      ? double.tryParse(sensorData!['longitude'])
                      : sensorData!['longitude'].toDouble();

              if (lat != null && lon != null) {
                _currentLocation = LatLng(lat, lon);
                _updateMarkers();
                _moveCameraToLocation(_currentLocation!);
                _popupLayerController.hideAllPopups();
              } else {
                print('Error: Could not parse latitude/longitude');
              }
            });
          } else {
            print('Error: Received data missing required fields.');
          }
        } catch (e) {
          print('Error decoding JSON: $e');
        }
      },
      onError: (error) {
        print('WebSocket Error: $error');
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('WebSocket Error: $error')));
        }
      },
      onDone: () {
        print('WebSocket Closed');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('WebSocket connection closed')),
          );
        }
      },
    );
  }

  void _updateMarkers() {
    _markers.clear();
    if (_currentLocation != null && sensorData != null) {
      _markers.add(
        Marker(
          key: const ValueKey('sensor_marker'),
          point: _currentLocation!,
          width: 40.0,
          height: 40.0,
          child: const Icon(Icons.location_pin, color: Colors.blue, size: 40.0),
        ),
      );
    }
  }

  void _moveCameraToLocation(LatLng location) {
    _mapController.move(location, _kSensorZoom);
  }

  void _zoomIn() {
    final currentZoom = _mapController.camera.zoom;
    if (currentZoom < _kMaxZoom) {
      _mapController.move(_mapController.camera.center, currentZoom + 1.0);
    }
  }

  void _zoomOut() {
    final currentZoom = _mapController.camera.zoom;
    if (currentZoom > _kMinZoom) {
      _mapController.move(_mapController.camera.center, currentZoom - 1.0);
    }
  }

  @override
  void dispose() {
    channel.sink.close();
    _popupLayerController.dispose();
    super.dispose();
  }

  Widget _buildPopupWidget(BuildContext context, Marker marker) {
    if (sensorData == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Text("Loading data..."),
        ),
      );
    }
    return Card(
      color: Colors.grey[900]?.withOpacity(0.9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Sensor",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Humidity", style: TextStyle(color: Colors.white70)),
                const SizedBox(width: 20),
                Text(
                  "${sensorData!['humidity']}%",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Temperature",
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(width: 20),
                Text(
                  "${sensorData!['temperature'].toString().replaceAll('.', ',')}°C",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sensor Map'), centerTitle: true),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentLocation ?? _kInitialPosition,
              initialZoom:
                  _currentLocation != null ? _kSensorZoom : _kInitialZoom,
              maxZoom: _kMaxZoom,
              minZoom: _kMinZoom,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.drag | InteractiveFlag.flingAnimation,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.app',
              ),
              PopupMarkerLayer(
                options: PopupMarkerLayerOptions(
                  popupController: _popupLayerController,
                  markers: _markers,
                  popupDisplayOptions: PopupDisplayOptions(
                    builder: _buildPopupWidget,
                    snap: PopupSnap.markerTop,
                  ),
                  markerTapBehavior: MarkerTapBehavior.togglePopup(),
                ),
              ),
            ],
          ),
          // Boutons de zoom
          Positioned(
            bottom: 20,
            right: 20,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                FloatingActionButton(
                  heroTag: "zoomInButton",
                  mini: true,
                  onPressed: _zoomIn,
                  child: const Icon(Icons.add),
                ),
                const SizedBox(height: 8),
                FloatingActionButton(
                  heroTag: "zoomOutButton",
                  mini: true,
                  onPressed: _zoomOut,
                  child: const Icon(Icons.remove),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton:
          sensorData == null
              ? const FloatingActionButton(
                onPressed: null,
                child: CircularProgressIndicator(),
              )
              : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
