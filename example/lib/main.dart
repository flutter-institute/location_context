import 'package:flutter/material.dart';
import 'package:location_context/location_context.dart';

const MAPS_API_KEY = 'AIzaSyB0vykgvACInKwdBKsrgvJwOVIvC2AHEdU';

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
    final LocationContext loc = LocationContext.of(context);
    final Size size = MediaQuery.of(context).size;

    final List<Widget> children = List();

    if (loc.error != null) {
      children.add(Center(
        child: Text('Error ${loc.error}', style: TextStyle(color: Colors.red)),
      ));
    } else {
      final Position pos = loc.currentLocation;
      if (pos != null) {
        Uri uri = Uri.https('maps.googleapis.com', 'maps/api/staticmap', {
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
              Expanded(child: Center(child: Text('Longitude: ${pos.longitude}'))),
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
