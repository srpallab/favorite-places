import 'package:favorite_places/providers/place_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../screens/place_details.dart';

class PlacesList extends ConsumerStatefulWidget {
  const PlacesList({super.key});

  @override
  ConsumerState createState() => _PlacesListState();
}

class _PlacesListState extends ConsumerState<PlacesList> {
  late Future<void> _placesFuture;

  @override
  void initState() {
    super.initState();
    _placesFuture = ref.read(userPlacesProvider.notifier).loadPlaces();
  }

  @override
  Widget build(BuildContext context) {
    final placeList = ref.watch(userPlacesProvider);
    return FutureBuilder(
      future: _placesFuture,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else {
          if (placeList.isEmpty) {
            return const Center(
              child: Text(
                "No Data Found.",
                style: TextStyle(color: Colors.white, fontSize: 26),
              ),
            );
          } else {
            return ListView.builder(
              itemCount: placeList.length,
              itemBuilder: (ctx, index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListTile(
                    onTap: () {
                      Navigator.of(context)
                          .push(MaterialPageRoute(builder: (ctx) {
                        return PlaceDetailsScreen(place: placeList[index]);
                      }));
                    },
                    leading: CircleAvatar(
                      backgroundImage: FileImage(placeList[index].image),
                    ),
                    title: Text(
                      placeList[index].title,
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                            color: Theme.of(context).colorScheme.onBackground,
                          ),
                    ),
                    subtitle: Text(
                      placeList[index].location.address,
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            color: Theme.of(context).colorScheme.onBackground,
                          ),
                    ),
                  ),
                );
              },
            );
          }
        }
      },
    );
  }
}
