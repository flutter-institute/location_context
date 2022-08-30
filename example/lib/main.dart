import 'package:flutter/material.dart';
import 'package:location_context/location_context.dart';

// TODO create your own google maps API key and set it up in .env.dart
import '.env.dart' show MAPS_API_KEY;

void main() => runApp(LocationContextExampleApp());

class LocationContextExampleApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LocationContext.around(
      MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: MapViewPage(),
      ),
    );
  }
}

class MapViewPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final loc = LocationContext.of(context);
    final size = MediaQuery.of(context).size;

    final children = <Widget>[];

    if (loc == null) {
      children.add(Center(child: Text('Location Context Not Found')));
    } else if (loc.error != null) {
      children.add(Center(
        child: Text('Error ${loc.error}', style: TextStyle(color: Colors.red)),
      ));
    } else {
      final pos = loc.currentLocation;
      if (pos != null) {
        final uri = Uri.https('maps.googleapis.com', 'maps/api/staticmap', {
          'center': '${pos.latitude},${pos.longitude}',
          'zoom': '18',
          'size': '${size.width.floor()}x${size.height.floor()}',
          'key': MAPS_API_KEY,
          'markers': 'color:blue|size:small|${pos.latitude},${pos.longitude}',
        });

        children.addAll(<Widget>[
          Expanded(
            child: Image.network(uri.toString()),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(child: Center(child: Text('Latitude: ${pos.latitude}'))),
              Expanded(
                  child: Center(child: Text('Longitude: ${pos.longitude}'))),
            ],
          ),
        ]);
      } else {
        children.add(Center(child: Text('Location Not Found')));
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Location Context Example'),
      ),
      body: Column(
        children: children,
      ),
    );
  }
}
