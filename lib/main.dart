import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

Future<List<Country>> getData(http.Client client) async {
  final response =
  await client.get(Uri.parse('https://restcountries.eu/rest/v2/all'));

  var jsonResponse = jsonDecode(response.body);

  List<Country> list =
  List<Country>.from(jsonResponse.map((json) => Country.fromJson(json)));
  return list;
}

class _MyHomePageState extends State<MyHomePage> {
  List<Country>? mainList;

  var selected;
  late Future<List<Country>> list;

  @override
  void initState() {
    super.initState();
  }

  PreferredSizeWidget selectAppBar(dynamic selection) {
    if (selection == null) {
      return AppBar(
        title: Text('Countries'),
      );
    } else {
      return AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            setState(() {
              selected = null;
            });
          },
        ),
        title: Text('${mainList![selection].name}'),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: selectAppBar(selected),
        body: (selected == null)
            ? FutureBuilder<List<Country>>(
          builder: (BuildContext context,
              AsyncSnapshot<List<Country>> snapshot) {
            if (snapshot.hasData) {
              mainList = snapshot.data;
              return ListView.builder(
                itemBuilder: (context, index) {
                  return ListTile(
                    title: ElevatedButton(
                      child: Text('${mainList![index].name}'),
                      onPressed: () {
                        setState(() {
                          selected = index;
                        });
                      },
                    ),
                  );
                },
                itemCount: mainList!.length,
              );
            } else if (snapshot.hasError) {
              print(snapshot.error.toString());
              return Text('${snapshot.error}');
            }
            return Center(
              child: Text('Loading'),
            );
          },
          future: getData(http.Client()),
        )
            : Align(
            alignment: Alignment.topCenter,
            child: Column(
              children: [
                Text('Alpha3Code: ${mainList![selected].alpha3code}'),
                Text('Capital: ${mainList![selected].capital}'),
                Text('Region: ${mainList![selected].region}'),
                Text('Subregion: ${mainList![selected].subregion}'),
                Text('Demonym: ${mainList![selected].demonym}'),
                Text('NativeName: ${mainList![selected].nativeName}'),
                Text('NumericCode: ${mainList![selected].numericCode}'),
                Text('Population: ${mainList![selected].population}'),
                Text('Area: ${mainList![selected].area}'),
              ],
            )));
  }
}

class Country {
  final String name,
      alpha3code,
      capital,
      region,
      subregion,
      demonym,
      nativeName,
      flag,
      numericCode;

  final int population;
  final double area;

  Country({
    required this.name,
    required this.alpha3code,
    required this.area,
    required this.population,
    required this.capital,
    required this.flag,
    required this.nativeName,
    required this.demonym,
    required this.numericCode,
    required this.region,
    required this.subregion,
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      name: json['name'],
      alpha3code: json['alpha3Code'] ?? '',
      area: json['area'] ?? 0.toDouble(),
      population: json['population'] ?? 0.toInt(),
      capital: json['capital'] ?? '',
      flag: json['flag'] ?? '',
      nativeName: json['nativeName'] ?? '',
      demonym: json['demonym'] ?? '',
      numericCode: json['numericCode'] ?? '',
      region: json['region'] ?? '',
      subregion: json['subregion'] ?? '',
    );
  }
}
