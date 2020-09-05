import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:dio/dio.dart';

void main() async {
  await DotEnv().load('.env');
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Restaurant searcher by Karthik",
      home: searchingpage(),
    ),
  );
}

class searchingpage extends StatefulWidget {
  final dio = Dio(BaseOptions(
      baseUrl: 'https://developers.zomato.com/api/v2.1/search',
      headers: {'user-key': DotEnv().env['ZOMATO_API_KEY']}));
  @override
  _searchingpageState createState() => _searchingpageState();
}

class _searchingpageState extends State<searchingpage> {
  List _restaurants;
  void searchrestaurents(String query) async {
    final response = await widget.dio.get("", queryParameters: {'q': query});
    setState(() {
      _restaurants = response.data['restaurants'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        title: Text("Restaurant Searching app"),
      ),
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          searchform(
            onsearch: searchrestaurents,
          ),
          _restaurants == null
              ? Column(
                  children: [
                    Icon(
                      Icons.search,
                      color: Colors.grey,
                      size: 50,
                    ),
                    Text(
                      "No results to display",
                      style: TextStyle(color: Colors.grey),
                    )
                  ],
                )
              : Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListView(
                      children: _restaurants.map((restaurant) {
                        return ListTile(
                            title: Text(restaurant['restaurant']['name']),
                            subtitle: Text(restaurant['restaurant']['location']
                                ['address']),
                            trailing: Text(
                                '${restaurant['restaurant']['user_rating']['aggregate_rating']} stars'));
                      }).toList(),
                    ),
                  ),
                ),
        ],
      )),
    );
  }
}

class searchform extends StatefulWidget {
  searchform({this.onsearch});
  final void Function(String search) onsearch;
  @override
  _searchformState createState() => _searchformState();
}

class _searchformState extends State<searchform> {
  final _formkey = GlobalKey<FormState>();
  var _autovalidate = false;
  var _search;
  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formkey,
        autovalidate: _autovalidate,
        child: Column(
          children: [
            TextFormField(
              decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: "Enter Search term Eg. hotel_name"
                  // border: OutlineInputBorder(),
                  ,
                  filled: true,
                  errorStyle: TextStyle(fontSize: 15)),
              onChanged: (value) {
                _search = value;
              },
              validator: (value) {
                if (value.isEmpty) {
                  return "Please enter a search term";
                }
                return null;
              },
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: FlatButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5)),
                onPressed: () {
                  final isvalid = _formkey.currentState.validate();
                  if (isvalid) {
                    widget.onsearch(_search);
                  } else {
                    setState(() {
                      _autovalidate = true;
                    });
                  }
                },
                child: Text(
                  "Search",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15),
                ),
                color: Colors.blueGrey,
              ),
            )
          ],
        ));
  }
}
