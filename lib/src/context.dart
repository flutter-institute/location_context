// Copyright (c) 2018, Brian Armstrong. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

part of location_context;

/// Type of function that will create a location. Visible for testing so that we can
/// mock the Location information being returned
@visibleForTesting
typedef Location LocationFactory();

/// Test help that allows us to mock the location that is being used
@visibleForTesting
void mockLocation(LocationFactory mock) {
  _createLocation = mock;
}

/// Internal handler to get the location
LocationFactory _createLocation = () => Location();

/// The actual inherited widget for the context
/// Use this widget at the root of the tree so that all children will be able
/// to retrieve the current location
class LocationContext extends InheritedWidget {
  /// The current location of the device
  final Position? currentLocation;

  /// The previous location of the device
  final Position? lastLocation;

  /// The most recent error that was encountered
  final String? error;

  LocationContext._({
    required this.currentLocation,
    required Widget child,
    this.lastLocation,
    this.error,
    Key? key,
  }) : super(key: key, child: child);

  /// Helper function to wrap the given child widget in the Location Context
  static Widget around(Widget child, {Key? key}) {
    return _LocationContextWrapper(child: child, key: key);
  }

  /// Retrieve the location provider for the current context
  static LocationContext? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<LocationContext>();
  }

  /// Notify only when the location has changed
  @override
  bool updateShouldNotify(LocationContext oldWidget) {
    return currentLocation != oldWidget.currentLocation ||
        lastLocation != oldWidget.lastLocation ||
        error != oldWidget.error;
  }
}

/// Use this widget to automagically wrap the context
class _LocationContextWrapper extends StatefulWidget {
  final Widget child;

  _LocationContextWrapper({Key? key, required this.child}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _LocationContextWrapperState();
}

class _LocationContextWrapperState extends State<_LocationContextWrapper> {
  final Location _location = _createLocation();

  String? _error;

  Position? _currentLocation;
  Position? _lastLocation;

  StreamSubscription<LocationData>? _locationChangedSubscription;

  @override
  void initState() {
    super.initState();

    // Subscribe to location updates from the phone and save them to the state
    _locationChangedSubscription =
        _location.onLocationChanged.listen((LocationData result) {
      final Position nextLocation = Position._fromLocationData(result);
      setState(() {
        _error = null;
        _lastLocation = _currentLocation;
        _currentLocation = nextLocation;
      });
    });

    initLocation();
  }

  @override
  void dispose() {
    _locationChangedSubscription?.cancel();

    super.dispose();
  }

  /// Initialize our location handling (and first result) and get everything moving
  void initLocation() async {
    try {
      final result = await _location.getLocation();

      setState(() {
        _error = null;
        _lastLocation = Position._fromLocationData(result);
        _currentLocation = _lastLocation;
      });
    } on PlatformException catch (e) {
      setState(() {
        if (e.code == 'PERMISSION_DENIED') {
          _error = 'Location Permission Denied';
        } else if (e.code == 'PERMISSION_DENIED_NEVER_ASK') {
          _error =
              'Location Permission Denied. Please open App Settings and enabled Location Permissions';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LocationContext._(
      lastLocation: _lastLocation,
      currentLocation: _currentLocation,
      error: _error,
      child: widget.child,
    );
  }
}
