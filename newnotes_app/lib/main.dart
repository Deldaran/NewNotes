import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'NewNotes',
        theme: ThemeData(
          useMaterial3: true,
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Random random = Random();
    double startColumnWidth = MediaQuery.of(context).size.width * 0.5;
    double posTop = MediaQuery.of(context).size.height * random.nextDouble();
    double posleft = startColumnWidth +
        MediaQuery.of(context).size.width * 0.5 * random.nextDouble();
    while (posTop + 300 > MediaQuery.of(context).size.height) {
      posTop = MediaQuery.of(context).size.height * random.nextDouble();
    }
    while (posleft - 300 >
        MediaQuery.of(context).size.width * 0.5 * random.nextDouble()) {
      posleft = startColumnWidth +
          MediaQuery.of(context).size.width * 0.5 * random.nextDouble();
    }
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 186, 186, 186),
      body: Stack(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              BigCard(),
            ],
          ),
          Positioned(
            top: posTop,
            left: posleft,
            child: PostIt(),
          ),
        ],
      ),
    );
  }
}

class ColorManager {
  Color? _selectedColor;

  Color? get selectedColor => _selectedColor;

  void chooseRandomColor() {
    final Random random = Random();
    final List<Color> primaryColors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.yellow,
      Colors.orange,
      Colors.purple,
      Colors.pink,
      Colors.teal,
      Colors.cyan,
      Colors.indigo,
    ];
    _selectedColor = primaryColors[random.nextInt(primaryColors.length)];
  }
}

class PostIt extends StatefulWidget {
  const PostIt();

  @override
  _PostItState createState() => _PostItState();
}

class _PostItState extends State<PostIt> {
  final ColorManager colorManager = ColorManager();

  @override
  void initState() {
    super.initState();
    colorManager.chooseRandomColor();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: SizedBox(
        width: 300,
        height: 300,
        child: Card(
          color: colorManager.selectedColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0),
          ),
          elevation: 10,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                margin: EdgeInsets.only(bottom: 20),
                child: Padding(
                  padding: const EdgeInsets.only(top: 50),
                  child: Text(
                    'Mon Titre',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Divider(
                thickness: 1,
                color: Colors.black,
                indent: 20,
                endIndent: 20,
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  'Contenu de mon texte ici...',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: SizedBox(
        width: MediaQuery.of(context).size.width / 3 + 100,
        height: MediaQuery.of(context).size.height / 1.02,
        child: Card(
          color: Color.fromARGB(255, 255, 255, 255),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 0),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: AspectRatio(
                    aspectRatio: 10 / 6,
                    child: Image.asset(
                      "lib/assets/logo.png",
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
