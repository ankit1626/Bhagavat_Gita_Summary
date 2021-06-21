import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_spinkit/flutter_spinkit.dart';

enum language {
  English,
  Hindi,
}
String apikey = '';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<void> getchapters() async {
    dynamic res = '';
    http.Response response = await http
        .get(Uri.parse('https://bhagavadgitaapi.in/chapters?api_key=$apikey'));
    if (response.statusCode == 200) {
      res = jsonDecode(response.body);
      Navigator.pop(context);
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => Chapters(res: res)));
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getchapters();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
            image: AssetImage('Images/Krishna.jpg'), fit: BoxFit.cover),
      ),
      child: Center(
        child: SpinKitRotatingCircle(
          color: Colors.white,
          size: 50.0,
        ),
      ),
    );
  }
}

class Chapters extends StatefulWidget {
  Chapters({@required this.res});
  dynamic res;

  @override
  _ChaptersState createState() => _ChaptersState();
}

class _ChaptersState extends State<Chapters> {
  void fun(int i) async {
    http.Response res = await http.get(Uri.parse(
        'https://bhagavadgitaapi.in/chapter/${i + 1}?api_key=$apikey'));
    if (res.statusCode == 200) {
      if (res.body != '') {
        dynamic chsummary = jsonDecode(res.body);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => SummaryScreen1(
                      chaptersummary: chsummary,
                    )));
      }
    }
  }

  dynamic res;

  List<Widget> buildchapterlist() {
    List<Widget> l1 = [];

    for (int i = 0; i < 18; i++) {
      l1.add(GestureDetector(
        onTap: () {
          fun(i);
        },
        child: Container(
          margin: EdgeInsets.all(3.0),
          padding: EdgeInsets.all(20.0),
          decoration: BoxDecoration(
              color: Colors.orange, borderRadius: BorderRadius.circular(6.0)),
          child: Center(
            child: Text(
              res[i]['name'] + "/" + res[i]['translation'],
              style: TextStyle(color: Colors.white, fontSize: 15.0),
            ),
          ),
        ),
      ));
    }
    return l1;
  }

  @override
  Widget build(BuildContext context) {
    res = widget.res;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              child: Text(
                'CHAPTERS',
                style: TextStyle(
                    color: Colors.black, fontSize: 40.0, letterSpacing: 1.0),
              ),
            ),
            Expanded(
              child: ListView(
                children: buildchapterlist(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SummaryScreen1 extends StatefulWidget {
  SummaryScreen1({@required this.chaptersummary});
  dynamic chaptersummary;
  @override
  _SummaryScreen1State createState() => _SummaryScreen1State();
}

class _SummaryScreen1State extends State<SummaryScreen1> {
  dynamic chaptersummary;
  Color deactivecolor = Colors.white;
  Color activecolor = Colors.blueAccent;
  language l1 = language.English;
  @override
  Widget build(BuildContext context) {
    chaptersummary = widget.chaptersummary;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Card(
              elevation: 3.0,
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          l1 = language.English;
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.all(15.0),
                        child: Center(
                            child: Text(
                          'English',
                          style: TextStyle(
                              color: (l1 == language.English)
                                  ? Colors.white
                                  : Colors.black,
                              fontSize: 16.0),
                        )),
                        color: (l1 == language.English)
                            ? activecolor
                            : deactivecolor,
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          l1 = language.Hindi;
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.all(16.0),
                        child: Center(
                            child: Text('Hindi',
                                style: TextStyle(
                                    color: (l1 == language.Hindi)
                                        ? Colors.white
                                        : Colors.black,
                                    fontSize: 16.0))),
                        color: (l1 == language.Hindi)
                            ? activecolor
                            : deactivecolor,
                      ),
                    ),
                  )
                ],
              ),
            ),
            Text(
              (l1 == language.English)
                  ? chaptersummary['translation']
                  : chaptersummary['name'],
              style: TextStyle(fontSize: 24.0, fontFamily: 'Roboto-Heading'),
            ),
            Container(
              child: Text(
                (l1 == language.English)
                    ? chaptersummary['summary']['en']
                    : chaptersummary['summary']['hi'],
                style: TextStyle(fontSize: 18.0, fontFamily: 'Roboto'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
