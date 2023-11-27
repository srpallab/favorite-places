import 'package:flutter/material.dart';

import '../widgets/places_list_widget.dart';
import 'add_place.dart';

class PlacesListScreen extends StatelessWidget {
  const PlacesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Places"),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (BuildContext context) => const AddPlaceScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.add)),
        ],
      ),
      body: const PlacesList(),
    );
  }
}
