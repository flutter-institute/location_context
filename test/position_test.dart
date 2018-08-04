// Copyright (c) 2018, Brian Armstrong. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:location/location.dart';

import 'package:location_context/location_context.dart';

void main() {
  final Position p1 = Position(
    latitude: 111.11,
    longitude: 22.22,
    accuracy: 100.3,
    altitude: 5432.1,
    speed: 133.7,
    speedAccuracy: 0.2,
  );

  final Position p2 = Position(
    latitude: 111.11,
    longitude: 22.22,
    accuracy: 100.3,
    altitude: 5432.1,
    speed: 133.7,
    speedAccuracy: 0.2,
  );

  final Position p3 = Position(
    latitude: 123.45,
    longitude: 23.45,
    accuracy: 101.3,
    altitude: 432.1,
    speed: 13.7,
    speedAccuracy: 0.0,
  );

  test('check hash correctly into a set', () {
    Set<Position> s = new Set<Position>();
    s.add(p1);
    expect(s, hasLength(1));
    s.add(p2);
    expect(s, hasLength(1));
    s.add(p3);
    expect(s, hasLength(2));
  });

  test('check equality comparison', () {
    expect(p1 == p2, isTrue);
    expect(p1 == p3, isFalse);
    expect(p2 != p3, isTrue);
  });
}
