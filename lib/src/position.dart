// Copyright (c) 2018, Brian Armstrong. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

part of location_context;

/// The Position information returned by the system
class Position {
  /// The latitutde in degrees
  final double? latitude;

  /// The longitude in degrees
  final double? longitude;

  /// Estimated horizontal accuracy of this location, radial, in meters
  final double? accuracy;

  /// Estimated vertical accuracy of this location, in meters
  final double? verticalAccuracy;

  /// The altitude of the device, in meters
  /// Always 0 on web
  final double? altitude;

  /// In meters/second
  /// Always 0 on web
  final double? speed;

  /// How accurate the speed is, in meters/second
  /// Always 0 on web
  final double? speedAccuracy; // Always 0 on ios

  /// The heading on the horizontal direction of travel, in degrees
  /// Always 0 on web
  final double? heading;

  /// Timestamp of the LocationData
  final double? time;

  final int _hashCode;

  Position({
    this.latitude,
    this.longitude,
    this.accuracy,
    this.verticalAccuracy,
    this.altitude,
    this.speed,
    this.speedAccuracy,
    this.heading,
    this.time,
  }) : _hashCode = hashObjects([
          latitude,
          longitude,
          accuracy,
          verticalAccuracy,
          altitude,
          speed,
          speedAccuracy,
          heading,
          time
        ]);

  Position._fromLocationData(LocationData data)
      : this(
          latitude: data.latitude,
          longitude: data.longitude,
          accuracy: data.accuracy,
          verticalAccuracy: data.verticalAccuracy,
          altitude: data.altitude,
          speed: data.speed,
          speedAccuracy: data.speedAccuracy,
          heading: data.heading,
          time: data.time,
        );

  // ignore: unused_element
  Position._fromMap(Map<String, double> data)
      : this(
          latitude: data['latitude'],
          longitude: data['longitude'],
          accuracy: data['accuracy'],
          verticalAccuracy: data['verticalAccuracy'],
          altitude: data['altitude'],
          speed: data['speed'],
          speedAccuracy: data['speed_accuracy'],
          heading: data['heading'],
          time: data['time'],
        );

  @override
  bool operator ==(dynamic other) {
    if (other is! Position) return false;
    return hashCode == other.hashCode;
  }

  @override
  int get hashCode => _hashCode;

  @override
  String toString() {
    return 'Position($latitude, $longitude, $accuracy, $verticalAccuracy, $altitude, $speed, $speedAccuracy, $heading, $time)';
  }
}
