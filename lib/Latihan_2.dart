import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'University ASEAN',
      home: BlocProvider(
        create: (context) => UniversityBloc(),
        child: UniversitiesPage(),
      ),
    );
  }
}

class UniversityBloc extends Bloc<String, List<dynamic>> {
  UniversityBloc() : super([]) {
    on<String>((event, emit) async {
      currentCountry = event; // Menyimpan negara yang dipilih
      var universities = await fetchUniversities(event);
      emit(universities);
    });
  }

  String currentCountry =
      'Indonesia'; // State untuk menyimpan negara yang dipilih
  Future<List<dynamic>> fetchUniversities(String country) async {
    var url =
        Uri.parse('http://universities.hipolabs.com/search?country=$country');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load universities');
      }
    } catch (e) {
      print('Error fetching universities: $e');
      return [];
    }
  }
}

class UniversitiesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Universitas di ASEAN'),
      ),
      body: Column(
        children: [
          CountryDropdown(),
          Expanded(
            child: BlocBuilder<UniversityBloc, List<dynamic>>(
              builder: (context, universities) {
                return universities.isEmpty
                    ? Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        itemCount: universities.length,
                        itemBuilder: (context, index) {
                          var university = universities[index];
                          return Container(
                            decoration: BoxDecoration(
                              color: index % 2 == 0
                                  ? Colors.grey[200]
                                  : Colors.white,
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            margin: EdgeInsets.all(8.0),
                            child: ListTile(
                              title: Text(
                                university['name'],
                                textAlign: TextAlign.center,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                university['web_pages'][0],
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: const Color.fromARGB(
                                        255, 110, 101, 101)),
                              ),
                              onTap: () =>
                                  _launchURL(university['web_pages'][0]),
                            ),
                          );
                        },
                      );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _launchURL(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      print('Could not launch $url');
    }
  }
}

class CountryDropdown extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UniversityBloc, List<dynamic>>(
      builder: (context, universities) {
        final universityBloc = BlocProvider.of<UniversityBloc>(context);
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: DropdownButton<String>(
            value: universityBloc.currentCountry,
            isExpanded: true,
            onChanged: (value) {
              if (value != null) {
                // Memperbarui nilai currentCountry pada UniversityBloc
                universityBloc.currentCountry = value;
                // Memanggil event ChangeCountry dengan negara yang dipilih
                universityBloc.add(value);
              }
            },
            items: [
              'Indonesia',
              'Singapore',
              'Malaysia',
              'Thailand',
              'philippines',
              'Vietnam',
              'Cambodia',
              'Myanmar',
              'Brunei Darussalam'
            ]
                .map<DropdownMenuItem<String>>(
                  (String value) => DropdownMenuItem<String>(
                    value: value,
                    child:
                        Center(child: Text(value, textAlign: TextAlign.center)),
                  ),
                )
                .toList(),
          ),
        );
      },
    );
  }
}
