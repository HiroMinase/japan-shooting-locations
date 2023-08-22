import 'dart:convert';

import 'package:auto_route/auto_route.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../router/router.dart';

// google place api にて取得したサジェスト
class AutocompletePlace {
  AutocompletePlace({
    required this.placeName,
    required this.placeId,
  });

  final String placeName;
  final String placeId;

  AutocompletePlace.fromJson(Map<String, dynamic> json)
      : placeName = json['description'],
        placeId = json['place_id'];
}

@RoutePage()
class SearchPlace extends StatefulWidget {
  const SearchPlace({super.key});

  /// [AutoRoute] で指定するパス文字列。
  static const path = '/searchPlace';

  /// [SearchPlace] に遷移する際に `context.router.pushNamed` で指定する文字列。
  static const location = path;

  @override
  SearchPlaceState createState() => SearchPlaceState();
}

class SearchPlaceState extends State<SearchPlace> {
  List<AutocompletePlace> predictions = [];
  final _nameEditingController = TextEditingController();

  @override
  void dispose() {
    _nameEditingController.dispose();
    super.dispose();
  }

  // 入力された文字列からなるサジェストを PlaceAPI を使って取得
  void getAutocompletePlace(String input) async {
    setState(() {
      predictions = [];
    });

    const baseurl = "https://maps.googleapis.com/maps/api/place/autocomplete/json?";
    const language = "ja";
    final apiKey = dotenv.env['GOOGLE_MAP_API_KEY'];

    final generatedUrl = "${baseurl}input=$input&language=$language&key=${apiKey!}";

    final dio = Dio();
    final response = await dio.get(generatedUrl);

    List<dynamic> autocompletePlaces = json.decode(response.toString())["predictions"];
    List<AutocompletePlace> generatedAutocompletePlace = [];

    if (autocompletePlaces.isEmpty) return;

    // 20を超える結果は取り除く
    if (autocompletePlaces.length > 20) {
      autocompletePlaces.removeRange(20, autocompletePlaces.length);
    }

    // AutocompletePlace オブジェクトへ変換
    for (var element in autocompletePlaces) {
      generatedAutocompletePlace.add(
        AutocompletePlace(placeName: element["description"], placeId: element["place_id"]),
      );
    }

    setState(() {
      predictions.addAll(generatedAutocompletePlace);
    });
  }

  // 選択された AutocompletePlace の緯度経度を PlaceDetailAPI を使って取得
  // 参考にスクランブルスクエアの place_id: ChIJ7WUBoDGLGGARaK3ikXtAfDg
  Future<LatLng> getPlaceDetail(String placeId) async {
    const baseurl = "https://maps.googleapis.com/maps/api/place/details/json?";
    const fields = "geometry";
    final apiKey = dotenv.env['GOOGLE_MAP_API_KEY'];

    final generatedUrl = "${baseurl}fields=$fields&place_id=$placeId&key=${apiKey!}";

    final dio = Dio();
    final response = await dio.get(generatedUrl);

    Map<String, dynamic> placeDetailGeometry = json.decode(response.toString())["result"]["geometry"];

    return LatLng(
      placeDetailGeometry["location"]["lat"],
      placeDetailGeometry["location"]["lng"],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            spreadRadius: 0.5,
                            blurRadius: 5.0,
                            offset: Offset(5, 5),
                          ),
                        ],
                      ),
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.9,
                        alignment: Alignment.centerLeft,
                        child: TextFormField(
                          autofocus: true,
                          controller: _nameEditingController,
                          onChanged: (String value) {
                            getAutocompletePlace(value);
                          },
                          decoration: InputDecoration(
                            prefixIcon: IconButton(
                              color: Colors.grey[500],
                              icon: const Icon(Icons.arrow_back_ios_new),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                            hintText: '場所を検索',
                            hintStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: predictions.length,
                  itemBuilder: (context, index) {
                    return Card(
                      child: ListTile(
                        title: Text(predictions[index].placeName),
                        onTap: () async {
                          getPlaceDetail(predictions[index].placeId).then((value) {
                            context.router.push(MapViewRoute(placeLatLng: value));
                          });
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
