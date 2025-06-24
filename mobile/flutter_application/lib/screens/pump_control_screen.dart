import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_application/models/pump.dart';
import 'package:flutter_application/models/pump_status.dart';
import 'package:flutter_application/services/pump_service.dart';
import 'package:flutter_application/services/auth_service.dart';

class PumpControlScreen extends StatefulWidget {
  final String pumpId;
  const PumpControlScreen({super.key, required this.pumpId});

  @override
  State<PumpControlScreen> createState() => _PumpControlScreenState();
}

class _PumpControlScreenState extends State<PumpControlScreen> {
  final PumpService _pumpService = PumpService();
  Pump? _pump;
  bool? _currentPumpState;
  bool _isProcessing = false;
  String? _errorMessage;
  Timer? _pollingTimer;

  DateTime? _lastActivatedTime;

  Timer? _countdownTimer;

  bool? _pendingPumpState;
  DateTime? _pendingStateTime;
  final Duration _pendingGracePeriod = const Duration(seconds: 8);

  @override
  void initState() {
    super.initState();
    _fetchPump();
    _loadLastActivatedTime();
    // _startPolling will be called after fetching pump
  }

  Future<void> _fetchPump() async {
    final pump = await _pumpService.getPumpById(widget.pumpId);
    if (mounted) {
      setState(() {
        _pump = pump;
        _currentPumpState = pump?.status == PumpStatus.on;
      });
      _startPolling();
    }
  }

  Future<void> _loadLastActivatedTime() async {
    final authService = AuthService();
    final time = await authService.getLastPumpActivatedTime(widget.pumpId);
    setState(() {
      _lastActivatedTime = time;
    });
  }

  Future<void> _saveLastActivatedTime(DateTime time) async {
    final authService = AuthService();
    await authService.saveLastPumpActivatedTime(widget.pumpId, time);
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      final now = DateTime.now();
      if (!_isProcessing && mounted) {
        _fetchPumpStatus(showLoading: false);
      }
    });
  }

  Future<void> _fetchPumpStatus({bool showLoading = true}) async {
    if (_isProcessing && showLoading) return;
    if (mounted && showLoading) {
      setState(() {
        _isProcessing = true;
        _errorMessage = null;
      });
    }
    try {
      final latestPump = await _pumpService.getPumpById(widget.pumpId);
      final now = DateTime.now();
      bool inPending = false;
      if (_pendingPumpState != null && _pendingStateTime != null) {
        inPending =
            now.difference(_pendingStateTime!).inMilliseconds <
            _pendingGracePeriod.inMilliseconds;
      }
      setState(() {
        _pump = latestPump;
        // If in pending window and backend disagrees, ignore backend
        if (inPending &&
            latestPump?.status ==
                (_pendingPumpState! ? PumpStatus.off : PumpStatus.on)) {
          debugPrint("Ignoring backend status during grace period");
        } else {
          _currentPumpState = latestPump?.status == PumpStatus.on;
          _errorMessage = null;
          if (_pendingPumpState != null &&
              _currentPumpState == _pendingPumpState) {
            _pendingPumpState = null;
            _pendingStateTime = null;
          }
        }
        if (_currentPumpState == false) {
          debugPrint("Polling detected pump is OFF, cancelling timer.");
        }
      });
    } catch (e) {
      debugPrint("Error in _fetchPumpStatus: $e");
      if (mounted) {
        setState(() {
          _errorMessage = "Status unavailable";
        });
      }
    } finally {
      if (mounted && (showLoading || _isProcessing)) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> _setPumpState(bool newState) async {
    if (_isProcessing) return;
    setState(() {
      _isProcessing = true;
      _errorMessage = null;
      _pendingPumpState = newState;
      _pendingStateTime = DateTime.now();
    });
    try {
      final success = await _pumpService.updatePumpStatus(
        id: widget.pumpId,
        status: newState ? PumpStatus.on : PumpStatus.off,
      );
      if (success && mounted) {
        _pollingTimer?.cancel();
        setState(() {
          _currentPumpState = newState;
          _errorMessage = null;
          if (newState) {
            final now = DateTime.now();
            _lastActivatedTime = now;
            _saveLastActivatedTime(now);
          }
        });
        Future.delayed(const Duration(seconds: 5), () {
          if (mounted) _startPolling();
        });
      } else if (mounted) {
        _errorMessage = newState ? "Start failed" : "Stop failed";
        _fetchPumpStatus(showLoading: false);
        _startPolling();
      }
    } catch (e) {
      debugPrint("Error in _setPumpState: $e");
      if (mounted) {
        _errorMessage = newState ? "Start failed" : "Stop failed";
        _fetchPumpStatus(showLoading: false);
        _startPolling();
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  void _onManualTogglePressed() {
    if (_currentPumpState == null || _isProcessing) return;

    if (_currentPumpState == true) {
      _setPumpState(false);
    } else {
      _setPumpState(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final bool canInteractButton = _currentPumpState != null && !_isProcessing;
    final bool isCurrentlyOn = _currentPumpState == true;

    final Color activeColor = Colors.green.shade500;
    final Color inactiveColor = theme.disabledColor;
    const Color processingColor = Color.fromARGB(255, 163, 212, 203);
    final Color unknownColor = Colors.grey.shade400;

    Color currentBgColor;
    if (_isProcessing) {
      currentBgColor = processingColor;
    } else if (_currentPumpState == null) {
      currentBgColor = unknownColor;
    } else {
      currentBgColor = isCurrentlyOn ? activeColor : inactiveColor;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_pump?.name ?? 'Pump'),
        backgroundColor: currentBgColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              if (!_isProcessing) {
                _fetchPumpStatus();
                _loadLastActivatedTime();
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child:
            _pump == null
                ? const Center(child: CircularProgressIndicator())
                : Container(
                  child: Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 10.0,
                    ),
                    elevation: 4.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            theme.cardColor,
                            theme.colorScheme.brightness == Brightness.dark
                                ? Colors.white
                                : Colors.greenAccent.shade400,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          const double baseWidth = 350.0;
                          final double scaleFactor = (constraints.maxWidth /
                                  baseWidth)
                              .clamp(0.85, 1.3);

                          final double verticalPadding = 20.0 * scaleFactor;
                          final double horizontalPadding = max(
                            16.0,
                            24.0 * scaleFactor * 0.8,
                          );

                          final double titleTimerSpacing = 20.0 * scaleFactor;
                          final double timerButtonSpacing = 50.0 * scaleFactor;
                          final double buttonStatusSpacing = 16.0 * scaleFactor;
                          final double statusErrorSpacing = 8.0 * scaleFactor;
                          final double errorTopSpacing = 8.0 * scaleFactor;

                          final TextStyle titleStyle = theme
                              .textTheme
                              .headlineSmall!
                              .copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize:
                                    (theme.textTheme.headlineSmall!.fontSize ??
                                        24) *
                                    scaleFactor.clamp(0.9, 1.1),
                              );
                          final TextStyle statusStyle = theme
                              .textTheme
                              .titleMedium!
                              .copyWith(
                                fontSize:
                                    (theme.textTheme.titleMedium!.fontSize ??
                                        16) *
                                    scaleFactor.clamp(0.9, 1.1),
                              );
                          final TextStyle errorStyle = theme
                              .textTheme
                              .bodyMedium!
                              .copyWith(
                                color: theme.colorScheme.error,
                                fontSize: 13 * scaleFactor.clamp(0.9, 1.05),
                              );

                          return Padding(
                            padding: EdgeInsets.only(
                              top: verticalPadding,
                              bottom: verticalPadding,
                              left: horizontalPadding,
                              right: horizontalPadding,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('Pump Control', style: titleStyle),
                                SizedBox(height: titleTimerSpacing),
                                if (_lastActivatedTime != null)
                                  Text(
                                    'Last activated: '
                                    '${_lastActivatedTime != null ? _formatDateTime(_lastActivatedTime!) : 'N/A'}',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: Colors.blueGrey.shade700,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                SizedBox(height: timerButtonSpacing),
                                _buildCentralControlButton(
                                  context,
                                  constraints,
                                  scaleFactor,
                                  isCurrentlyOn,
                                  canInteractButton,
                                  currentBgColor,
                                ),
                                SizedBox(height: buttonStatusSpacing),
                                _buildStatusText(
                                  context,
                                  statusStyle,
                                  currentBgColor,
                                ),
                                SizedBox(height: statusErrorSpacing),
                                _buildWaterLevelPot(),
                                Container(
                                  constraints: const BoxConstraints(
                                    minHeight: 20,
                                  ),
                                  child:
                                      _errorMessage != null
                                          ? Padding(
                                            padding: EdgeInsets.only(
                                              top: errorTopSpacing,
                                            ),
                                            child: Text(
                                              _errorMessage!,
                                              style: errorStyle,
                                              textAlign: TextAlign.center,
                                            ),
                                          )
                                          : null,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}';
  }

  Widget _buildCentralControlButton(
    BuildContext context,
    BoxConstraints constraints,
    double scaleFactor,
    bool isOn,
    bool canInteract,
    Color bgColor,
  ) {
    final double buttonDiameter = (constraints.maxWidth * 0.38 * scaleFactor)
        .clamp(80.0, 140.0);
    final double iconSize = buttonDiameter * 0.4;
    final double progressSize = buttonDiameter * 0.35;

    return GestureDetector(
      onTap: canInteract ? _onManualTogglePressed : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: buttonDiameter,
        height: buttonDiameter,
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
          boxShadow: [
            if (!canInteract)
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                offset: const Offset(0, 2),
                blurRadius: 4,
              ),
            if (canInteract && !isOn)
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                offset: const Offset(1, 1),
                blurRadius: 3,
                spreadRadius: -2,
              ),
            if (canInteract && (isOn))
              BoxShadow(
                color: bgColor.withOpacity(0.6),
                blurRadius: 12,
                spreadRadius: 2,
              ),
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child:
              _isProcessing
                  ? SizedBox(
                    width: progressSize,
                    height: progressSize,
                    child: const CircularProgressIndicator(
                      strokeWidth: 3.0,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
                    ),
                  )
                  : AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    transitionBuilder: (child, animation) {
                      return ScaleTransition(scale: animation, child: child);
                    },
                    child: Icon(
                      isOn ? Icons.power_settings_new : Icons.power_off,
                      key: ValueKey<bool>(isOn),
                      size: iconSize,
                      color: Colors.white.withOpacity(canInteract ? 1.0 : 0.7),
                    ),
                  ),
        ),
      ),
    );
  }

  Widget _buildStatusText(
    BuildContext context,
    TextStyle statusStyle,
    Color statusColor,
  ) {
    final theme = Theme.of(context);
    String text;
    FontWeight weight = FontWeight.bold;
    Color textColor;

    if (_isProcessing) {
      text = "UPDATING...";
      textColor = const Color.fromARGB(255, 123, 122, 120);
      weight = FontWeight.normal;
    } else if (_currentPumpState == null) {
      text = "STATUS UNKNOWN";
      textColor = theme.textTheme.bodySmall?.color ?? Colors.grey;
      weight = FontWeight.normal;
    } else {
      text = _currentPumpState! ? "PUMP ACTIVE" : "PUMP INACTIVE";
      textColor =
          statusColor.computeLuminance() > 0.3
              ? statusColor
              : (theme.textTheme.bodyLarge?.color ?? Colors.black);
      if (!_currentPumpState!) {
        textColor = Colors.grey.shade700;
      }
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      transitionBuilder: (child, animation) {
        return FadeTransition(opacity: animation, child: child);
      },
      child: Text(
        text,
        key: ValueKey<String>(text),
        style: statusStyle.copyWith(
          fontWeight: weight,
          color: textColor,
          letterSpacing: 0.5,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildWaterLevelPot() {
    // Example: 60% water level, you can replace with real data
    double waterLevel = 0.6;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Center(
        child: SizedBox(
          width: 100,
          height: 120,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              // Rectangle pot outline
              Container(
                width: 100,
                height: 120,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.brown.shade400, width: 4),
                    left: BorderSide(width: 6, color: Colors.brown.shade400),
                    right: BorderSide(width: 6, color: Colors.brown.shade400),
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                  color: Colors.brown.shade50,
                ),
              ),
              // Water fill
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  width: 100,
                  height: (120 * waterLevel).clamp(0, 100),
                  decoration: BoxDecoration(
                    color: Colors.blueAccent.withOpacity(0.7),
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(8),
                      top: Radius.circular(8),
                    ),
                  ),
                ),
              ),
              // Water level text
              Positioned(
                bottom: 40,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    '${(waterLevel * 100).toInt()}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      shadows: [Shadow(blurRadius: 2, color: Colors.black26)],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
