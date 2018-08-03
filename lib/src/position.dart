// Copyright (c) 2018, Brian Armstrong. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

part of location_context;

class Position {
  final double latitude;
  final double longitude;
  final double accuracy;
  final double altitude;
  final double speed;
  final double speedAccuracy; // Always 0 on ios

  Position({
    this.latitude,
    this.longitude,
    this.accuracy,
    this.altitude,
    this.speed,
    this.speedAccuracy,
  });

  Position._fromMap(Map<String, double> data)
      : this(
          latitude: data['latitude'],
          longitude: data['longitude'],
          accuracy: data['accuracy'],
          altitude: data['altitude'],
          speed: data['speed'],
          speedAccuracy: data['speed_accuracy'],
        );

  @override
  bool operator ==(dynamic other) {
    if (other is! Position) return false;
    final Position typedOther = other;
    return latitude == typedOther.latitude &&
        longitude == typedOther.longitude &&
        accuracy == typedOther.accuracy &&
        altitude == typedOther.altitude &&
        speed == typedOther.speed &&
        speedAccuracy == typedOther.speedAccuracy;
  }

  @override
  int get hashCode => hashObjects(
      [latitude, longitude, accuracy, altitude, speed, speedAccuracy]);

  @override
  String toString() {
    return 'Position($latitude, $longitude, $accuracy, $altitude, $speed, $speedAccuracy)';
  }
}
