import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lomi/data/places_api.dart';

class MySearchDelegate extends SearchDelegate<LatLng> {
  final String placeId = '';
  final api = PlaceApiProvider(DateTime.now().toIso8601String());
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      GestureDetector(
        onTap: () {
          query = '';
        },
        child: const Padding(
          padding: EdgeInsets.all(8.0),
          child: Icon(Icons.clear),
        ),
      )
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {}

  @override
  Widget buildResults(BuildContext context) {
    return FutureBuilder<List<Suggestion>>(
      future: api.fetchSuggestions(query),
      builder: (_, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (query != '') {
            final suggestions = snapshot.data!;
            return ListView.builder(
              itemCount: suggestions.length,
              itemBuilder: (_, i) {
                return ListTile(
                  title: Text(suggestions[i].description),
                  onTap: () async {
                    final result =
                        await api.getPlaceDetailFromId(suggestions[i].placeId);
                    close(context, result);
                  },
                );
              },
            );
          } else {
            return const SizedBox();
          }
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return FutureBuilder<List<Suggestion>>(
      future: api.fetchSuggestions(query),
      builder: (_, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (query != '') {
            final suggestions = snapshot.data!;
            return ListView.builder(
              itemCount: suggestions.length,
              itemBuilder: (_, i) {
                return ListTile(
                  title: Text(suggestions[i].description),
                  onTap: () async {
                    query = suggestions[i].description;
                    showResults(context);
                  },
                );
              },
            );
          } else {
            return const SizedBox();
          }
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
