// Copyright (c) 2018, Brian Armstrong. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:location/location.dart';

import 'package:location_context/location_context.dart';
import 'package:location_platform_interface/location_platform_interface.dart';

class TestWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final loc = LocationContext.of(context);

    return MaterialApp(
      home: Scaffold(
        body: Column(
          children: <Widget>[
            Text('current location: ${loc?.currentLocation}'),
            Text('last location: ${loc?.lastLocation}'),
            Text('error: ${loc?.error}'),
          ],
        ),
      ),
    );
  }
}

final List<LocationData> locations = [
  {
    'latitude': 1.2345,
    'longitude': 5.4321,
    'accuracy': 123.0,
    'verticalAccuracy': 321.0,
    'altitude': 5678.9,
    'speed': 12.0,
    'speed_accuracy': 0.0,
    'heading': 0.0,
    'time': 0.0,
  },
  {
    'latitude': 5.4321,
    'longitude': 1.2345,
    'accuracy': 0.0,
    'verticalAccuracy': 0.0,
    'altitude': 432.1,
    'speed': 5.0,
    'speed_accuracy': 0.0,
    'heading': 0.0,
    'time': 0.0,
  },
  {
    'latitude': 40.5,
    'longitude': -111.9,
    'accuracy': 0.0,
    'verticalAccuracy': 0.0,
    'altitude': 432.1,
    'speed': 5.0,
    'speed_accuracy': 0.5,
    'heading': 0.0,
    'time': 0.0,
  },
].map((m) => LocationData.fromMap(m)).toList();

class MockLocation implements Location {
  final LocationData _default;
  final Stream<LocationData> _stream;
  final PermissionStatus _permissionStatus;

  MockLocation(this._default, this._stream,
      [this._permissionStatus = PermissionStatus.granted]);

  @override
  Future<bool> changeSettings({
    LocationAccuracy? accuracy = LocationAccuracy.high,
    int? interval = 1000,
    double? distanceFilter = 0,
  }) async =>
      true;

  @override
  Future<LocationData> getLocation() async => _default;

  @override
  Future<PermissionStatus> hasPermission() async => _permissionStatus;

  @override
  Stream<LocationData> get onLocationChanged => _stream;

  @override
  Future<PermissionStatus> requestPermission() async => _permissionStatus;

  @override
  Future<bool> requestService() async => true;

  @override
  Future<bool> serviceEnabled() async => true;

  @override
  Future<AndroidNotificationData?> changeNotificationOptions({
    String? channelName,
    String? title,
    String? iconName,
    String? subtitle,
    String? description,
    Color? color,
    bool? onTapBringToFront,
  }) async {
    return AndroidNotificationData.fromMap({
      'channelId': channelName,
      'notificationId': 12345,
    });
  }

  var _backgroundMode = false;
  @override
  Future<bool> enableBackgroundMode({bool? enable = true}) async =>
      _backgroundMode = enable ?? false;

  @override
  Future<bool> isBackgroundModeEnabled() async => _backgroundMode;
}

class MockLocationError implements Location {
  final String errorCode;

  MockLocationError(this.errorCode);
  @override
  Future<bool> changeSettings({
    LocationAccuracy? accuracy = LocationAccuracy.high,
    int? interval = 1000,
    double? distanceFilter = 0,
  }) async =>
      true;

  @override
  Future<LocationData> getLocation() async =>
      throw PlatformException(code: errorCode);

  @override
  Future<PermissionStatus> hasPermission() async => PermissionStatus.denied;

  @override
  Stream<LocationData> get onLocationChanged => Stream.empty();

  @override
  Future<PermissionStatus> requestPermission() async => PermissionStatus.denied;

  @override
  Future<bool> requestService() async => false;

  @override
  Future<bool> serviceEnabled() async => false;

  @override
  Future<AndroidNotificationData?> changeNotificationOptions({
    String? channelName,
    String? title,
    String? iconName,
    String? subtitle,
    String? description,
    Color? color,
    bool? onTapBringToFront,
  }) async {
    return AndroidNotificationData.fromMap({
      'channelId': channelName,
      'notificationId': 12345,
    });
  }

  var _backgroundMode = false;
  @override
  Future<bool> enableBackgroundMode({bool? enable = true}) async =>
      _backgroundMode = enable ?? false;

  @override
  Future<bool> isBackgroundModeEnabled() async => _backgroundMode;
}

void main() {
  late StreamController<LocationData> locationStream;

  setUp(() {
    locationStream = StreamController<LocationData>();
    mockLocation(() => MockLocation(locations[0], locationStream.stream));
  });

  tearDown(() {
    locationStream.close();
  });

  testWidgets('check default location values', (WidgetTester tester) async {
    await tester.pumpWidget(LocationContext.around(TestWidget()));

    expect(find.text('current location: null'), findsOneWidget);
    expect(find.text('last location: null'), findsOneWidget);
    expect(find.text('error: null'), findsOneWidget);

    await tester.pump();

    const defaultPosition =
        'Position(1.2345, 5.4321, 123.0, 321.0, 5678.9, 12.0, 0.0, 0.0, 0.0)';
    expect(find.text('current location: $defaultPosition'), findsOneWidget);
    expect(find.text('last location: $defaultPosition'), findsOneWidget);
    expect(find.text('error: null'), findsOneWidget);
  });

  testWidgets('check stream location values', (WidgetTester tester) async {
    await tester.pumpWidget(LocationContext.around(TestWidget()));
    locationStream.add(locations[1]);
    await tester.pumpAndSettle(); // Wait for render after stream

    expect(
        find.text(
            'current location: Position(5.4321, 1.2345, 0.0, 0.0, 432.1, 5.0, 0.0, 0.0, 0.0)'),
        findsOneWidget);
    expect(
        find.text(
            'last location: Position(1.2345, 5.4321, 123.0, 321.0, 5678.9, 12.0, 0.0, 0.0, 0.0)'),
        findsOneWidget);
    expect(find.text('error: null'), findsOneWidget);

    locationStream.add(locations[2]);
    await tester.pumpAndSettle();

    expect(
        find.text(
            'current location: Position(40.5, -111.9, 0.0, 0.0, 432.1, 5.0, 0.5, 0.0, 0.0)'),
        findsOneWidget);
    expect(
        find.text(
            'last location: Position(5.4321, 1.2345, 0.0, 0.0, 432.1, 5.0, 0.0, 0.0, 0.0)'),
        findsOneWidget);
    expect(find.text('error: null'), findsOneWidget);
  });

  testWidgets('check permission denied', (WidgetTester tester) async {
    mockLocation(() => MockLocationError('PERMISSION_DENIED'));

    await tester.pumpWidget(LocationContext.around(TestWidget()));
    await tester.pump(); // Get the error

    expect(find.text('current location: null'), findsOneWidget);
    expect(find.text('last location: null'), findsOneWidget);
    expect(find.text('error: Location Permission Denied'), findsOneWidget);
  });

  testWidgets('check permission denied never asked',
      (WidgetTester tester) async {
    mockLocation(() => MockLocationError('PERMISSION_DENIED_NEVER_ASK'));

    await tester.pumpWidget(LocationContext.around(TestWidget()));
    await tester.pump(); // Get the error

    expect(find.text('current location: null'), findsOneWidget);
    expect(find.text('last location: null'), findsOneWidget);
    expect(
        find.text(
            'error: Location Permission Denied. Please open App Settings and enabled Location Permissions'),
        findsOneWidget);
  });
}
