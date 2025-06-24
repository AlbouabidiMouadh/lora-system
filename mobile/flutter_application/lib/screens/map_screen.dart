import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_application/models/pump.dart';
import 'package:flutter_application/screens/pump_control_screen.dart';
import 'package:flutter_application/screens/sensor_screen.dart';
import 'package:flutter_application/services/pump_service.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:visibility_detector/visibility_detector.dart';

import 'package:collection/collection.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});
  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final AbstractPumpService _pumpService = PumpService();
  List<Pump> _pumps = [];
  final MapController _mapController = MapController();
  final PopupController _popupLayerController = PopupController();
  LatLng? _currentLocation;
  final List<Marker> _markers = [];

  static const LatLng _kInitialPosition = LatLng(48.8566, 2.3522); // Paris
  static const double _kInitialZoom = 5.0;
  static const double _kSensorZoom = 15.0;

  static const double _kMaxZoom = 18.0;
  static const double _kMinZoom = 3.0;

  Timer? _refreshTimer;
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    _loadPumps();
    // Do not start timer here; let visibility detector handle it
  }

  void _handleVisibilityChanged(VisibilityInfo info) {
    final visible = info.visibleFraction > 0.5;
    if (visible && !_isVisible) {
      _isVisible = true;
      _startAutoRefresh();
    } else if (!visible && _isVisible) {
      _isVisible = false;
      _refreshTimer?.cancel();
      _refreshTimer = null;
    }
  }

  void _startAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (mounted) {
        _loadPumps();
      }
    });
  }

  Future<void> _loadPumps() async {
    final pumps = await _pumpService.getAllPumps();
    setState(() {
      _pumps = pumps;
      if (_pumps.isNotEmpty) {
        _currentLocation = LatLng(
          _pumps.first.latitude,
          _pumps.first.longitude,
        );
      }
      _updateMarkers();
      if (_currentLocation != null) {
        _moveCameraToLocation(_currentLocation!);
      }
    });
  }

  void _updateMarkers() {
    _markers.clear();
    for (final pump in _pumps) {
      _markers.add(
        Marker(
          key: ValueKey('pump_marker_${pump.id}'),
          point: LatLng(pump.latitude, pump.longitude),
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
    _popupLayerController.dispose();
    _refreshTimer?.cancel();
    super.dispose();
  }

  Widget _buildPopupWidget(BuildContext context, Marker marker) {
    final pump = _pumps.firstWhereOrNull(
      (p) =>
          marker.point.latitude == p.latitude &&
          marker.point.longitude == p.longitude,
    );
    if (pump == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Text("Loading data..."),
        ),
      );
    }
    final lastSensor =
        (pump.sensors.isNotEmpty)
            ? pump.sensors.reduce(
              (a, b) =>
                  a.timestamp?.isAfter(b.timestamp ?? DateTime.now()) ?? false
                      ? a
                      : b,
            )
            : null;
    return Card(
      color: Colors.grey[900]?.withOpacity(0.9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              pump.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            if (lastSensor != null) ...[
              Text(
                "Temperature: ${lastSensor.temperature.toStringAsFixed(1)}°C",
                style: const TextStyle(color: Colors.white),
              ),
              Text(
                "Humidity: ${lastSensor.humidity.toStringAsFixed(1)}%",
                style: const TextStyle(color: Colors.white),
              ),
              Text(
                "Moisture: ${lastSensor.waterCapacity.toStringAsFixed(1)}%",
                style: const TextStyle(color: Colors.white),
              ),
            ] else ...[
              const Text(
                "No sensor data",
                style: TextStyle(color: Colors.white),
              ),
            ],
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(
                  Icons.analytics,
                  color: Colors.white,
                  size: 18,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => SensorScreen(pumpId: pump.id),
                    ),
                  );
                },
                label: const Text('See Sensor Data'),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.water, color: Colors.white, size: 18),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PumpControlScreen(pumpId: pump.id),
                    ),
                  );
                },
                label: const Text('Go to Pump Control'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: const Key('map-screen-visibility'),
      onVisibilityChanged: _handleVisibilityChanged,
      child: Scaffold(
        appBar: AppBar(
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF3FA34D), Color(0xFF4C5D4D)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          title: const Text('Sensor Map'),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadPumps,
              tooltip: 'Refresh',
            ),
          ],
        ),
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
            _pumps.isEmpty
                ? const FloatingActionButton(
                  onPressed: null,
                  child: CircularProgressIndicator(),
                )
                : null,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }
}
