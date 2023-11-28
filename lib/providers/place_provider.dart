import 'dart:developer';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as sys_paths;
import 'package:sqflite/sqflite.dart' as sql;
import 'package:sqflite/sqlite_api.dart';

import '../models/place.dart';

class UserPlacesNotifier extends StateNotifier<List<Place>> {
  UserPlacesNotifier() : super([]);

  Future<Database> _getDatabase() async {
    final String dbPath = await sql.getDatabasesPath();
    final Database db = await sql.openDatabase(
      path.join(dbPath, 'places.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE user_places(id TEXT PRIMARY KEY, title TEXT,'
          'image TEXT, lat REAL, lng REAL, address TEXT)',
        );
      },
      version: 1,
    );
    return db;
  }

  Future<void> loadPlaces() async {
    final db = await _getDatabase();
    final data = await db.query("user_places");
    final places = data
        .map(
          (row) => Place(
            id: row['id'] as String,
            title: row['title'] as String,
            image: File(row['image'] as String),
            location: PlaceLocation(
              latitude: row['lat'] as double,
              longitude: row['lng'] as double,
              address: row['address'] as String,
            ),
          ),
        )
        .toList();
    state = places;
  }

  Future<void> addPlace(Place place) async {
    final appDir = await sys_paths.getApplicationDocumentsDirectory();
    final fileName = path.basename(place.image.path);
    final copiedImage = await place.image.copy(
      '${appDir.path}/$fileName',
    );

    log(appDir.toString());

    final newPlace = Place(
      title: place.title,
      image: copiedImage,
      location: place.location,
    );

    final db = await _getDatabase();
    db.insert("user_places", {
      'id': newPlace.id,
      'title': newPlace.title,
      'image': newPlace.image.path,
      'lat': newPlace.location.latitude,
      'lng': newPlace.location.longitude,
      'address': newPlace.location.address,
    });

    state = [newPlace, ...state];
  }
}

final userPlacesProvider =
    StateNotifierProvider<UserPlacesNotifier, List<Place>>(
        (ref) => UserPlacesNotifier());
