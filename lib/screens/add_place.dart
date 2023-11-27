import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:favorite_places/models/place.dart';
import 'package:favorite_places/providers/place_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';

class AddPlaceScreen extends ConsumerStatefulWidget {
  const AddPlaceScreen({super.key});

  @override
  ConsumerState createState() => _AddPlaceScreenState();
}

class _AddPlaceScreenState extends ConsumerState<AddPlaceScreen> {
  final TextEditingController titleCtl = TextEditingController();
  Location location = Location();
  String imagePath = "";
  String mapImageUrl = "";
  bool _isGettingLocation = false;
  PlaceLocation? _pickedLocation;

  String get locationImage {
    if (_pickedLocation == null) return '';

    final lat = _pickedLocation!.latitude;
    final lon = _pickedLocation!.longitude;
    return 'https://maps.googleapis.com/maps/api/staticmap?center=$lat,$lon'
        '&zoom=16&size=600x300&maptype=roadmap'
        '&markers=color:red%7Clabel:A%7C$lat,$lon'
        '&key=AIzaSyDIFJJr_XlU-aHVVR6VdBW-R1vo1z8K50M';
  }

  Future<void> _takePhoto() async {
    final XFile? image =
        await ImagePicker().pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        imagePath = image.path;
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isGettingLocation = true;
    });
    bool serviceEnabled;
    PermissionStatus permissionGranted;
    LocationData locationData;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    locationData = await location.getLocation();
    log(locationData.latitude.toString());
    log(locationData.longitude.toString());

    final url = Uri.parse(
      "https://maps.googleapis.com/maps/api/geocode/json?latlng="
      "${locationData.latitude},${locationData.longitude}&"
      "key=AIzaSyDIFJJr_XlU-aHVVR6VdBW-R1vo1z8K50M",
    );
    log(url.toString());
    final response = await http.get(url);
    final resData = json.decode(response.body);
    final address = resData["results"][0]['formatted_address'];

    if (locationData.latitude == null ||
        locationData.longitude == null ||
        address.isEmpty) {
      return;
    }

    setState(() {
      _pickedLocation = PlaceLocation(
        latitude: locationData.latitude!,
        longitude: locationData.longitude!,
        address: address,
      );
      _isGettingLocation = false;
    });
  }

  void _addLocation() {
    if (titleCtl.text.isEmpty || imagePath.isEmpty || _pickedLocation == null) {
      return;
    }
    ref.read(userPlacesProvider.notifier).addPlace(
          Place(
            title: titleCtl.text,
            image: File(imagePath),
            location: _pickedLocation!,
          ),
        );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ADD NEW PLACE"),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextField(
                  controller: titleCtl,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    label: Text("Place Title"),
                    hintText: "Dhaka",
                    hintStyle: TextStyle(color: Colors.white24),
                  ),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: _takePhoto,
                  child: Container(
                    width: double.infinity,
                    alignment: Alignment.center,
                    height: 250,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white60, width: 2.0),
                    ),
                    child: imagePath.isEmpty
                        ? const Text(
                            "Click To Add Image",
                            style: TextStyle(fontSize: 20, color: Colors.white),
                          )
                        : Image.file(
                            File(imagePath),
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  height: 190,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white60),
                  ),
                  child: _pickedLocation != null
                      ? Image.network(locationImage, fit: BoxFit.cover)
                      : const Text(
                          "Map Location",
                          style: TextStyle(fontSize: 20, color: Colors.white),
                        ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _isGettingLocation
                        ? const CircularProgressIndicator.adaptive()
                        : TextButton.icon(
                            onPressed: _getCurrentLocation,
                            icon: const Icon(Icons.location_on),
                            label: const Text("Get Current Location"),
                          ),
                    TextButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.map),
                      label: const Text("Select on Map"),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                addBtn()
              ],
            ),
          ),
        ),
      ),
    );
  }

  ElevatedButton addBtn() {
    return ElevatedButton(
      onPressed: _addLocation,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 90),
      ),
      child: const Text(
        "ADD LOCATION",
        style: TextStyle(fontSize: 20, color: Colors.white),
      ),
    );
  }
}
