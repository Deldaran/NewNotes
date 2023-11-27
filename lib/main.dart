import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => PostItDataProvider(),
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

class PostItDataProvider extends ChangeNotifier {
  List<PostItData> _postItData = [];

  List<PostItData> get postItData => _postItData;

  void setPostItData(List<PostItData> data) {
    _postItData = data;
    notifyListeners();
  }
}

class MyAppState extends ChangeNotifier {}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<PostItData> postItData = [];
  PostItData? selectedPostIt;
  void _modifyPostIt(PostItData postIt) {
    showDialog(
      context: context,
      builder: (context) {
        return PostItDialog(
            onSave: (title, description) {},
            initialTitle: postIt.title,
            initialDescription: postIt.description,
            postItId: postIt.id,
            postItColor: postIt.color);
      },
    );
  }

  Future<void> updateData() async {
    try {
      List<PostItData> data = await DataFetcher.fetchData();
      Provider.of<PostItDataProvider>(context, listen: false)
          .setPostItData(data);
    } catch (e) {
      print('Error fetching data: $e');
      // Handle error
    }
  }

  void _deletePostIt() {
    if (selectedPostIt != null) {
      _sendDeleteRequest(selectedPostIt!.id);
    } else {
      print("Aucun Post-It sélectionné pour la suppression");
    }
  }

  void _sendDeleteRequest(int postId) async {
    try {
      await http.delete(Uri.parse('http://localhost:3001/elements/$postId'));
      print('Requête DELETE réussie');
      updateData();
    } catch (error) {
      print('Erreur lors de la requête DELETE : $error');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      List<PostItData> data = await DataFetcher.fetchData();
      Provider.of<PostItDataProvider>(context, listen: false)
          .setPostItData(data);
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    final Random random = Random();
    double startColumnWidth = MediaQuery.of(context).size.width * 0.5;

    List<PostItData> postItData =
        Provider.of<PostItDataProvider>(context).postItData;

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 186, 186, 186),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  BigCard(
                    selectedPostIt: selectedPostIt,
                    onModifyPressed: () => _modifyPostIt(selectedPostIt!),
                    onDeletePressed: _deletePostIt,
                  ),
                ],
              ),
              ...postItData.map((postIt) {
                double posTop = postIt.y.toDouble();
                double posLeft = postIt.x.toDouble();
                String title = postIt.title;
                String description = postIt.description;
                int id = postIt.id;
                int colorValue = postIt.color;

                double newPosTop = posTop *
                    constraints.maxHeight /
                    MediaQuery.of(context).size.height;
                double newPosLeft = posLeft *
                    constraints.maxWidth /
                    MediaQuery.of(context).size.width;

                return Positioned(
                  top: newPosTop,
                  left: newPosLeft,
                  child: PostIt(
                    x: newPosTop,
                    y: newPosLeft,
                    title: title,
                    description: description,
                    onSelect: () {
                      setState(() {
                        selectedPostIt = postIt;
                      });
                    },
                    colorValue: colorValue,
                    id: id,
                  ),
                );
              }).toList(),
              Positioned(
                top: 0,
                right: 500,
                child: Text(
                  'Number of Post-Its: ${postItData.length}',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class DataFetcher {
  static Future<List<PostItData>> fetchData() async {
    final response =
        await http.get(Uri.parse('http://localhost:3001/elements'));
    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((data) => PostItData.fromJson(data)).toList();
    } else {
      throw Exception('Failed to fetch data');
    }
  }
}

class PostItData {
  final String title;
  final String description;
  final int x;
  final int y;
  final int id;
  final int color;

  PostItData(
      {required this.title,
      required this.description,
      required this.x,
      required this.y,
      required this.id,
      required this.color});

  factory PostItData.fromJson(Map<String, dynamic> json) {
    return PostItData(
        title: json['title'] ?? '',
        description: json['description'] ?? '',
        x: json['x'] ?? 0,
        y: json['y'] ?? 0,
        id: json['id'] != null ? int.parse(json['id'].toString()) : 0,
        color: json['color']);
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

  void setColor(Color color) {
    _selectedColor = color;
  }
}

class PostIt extends StatefulWidget {
  final double x;
  final double y;
  final String title;
  final String description;
  final VoidCallback onSelect;
  final int colorValue;
  final int id;

  const PostIt(
      {Key? key,
      required this.x,
      required this.y,
      required this.title,
      required this.description,
      required this.onSelect,
      required this.colorValue,
      required this.id})
      : super(key: key);

  @override
  _PostItState createState() => _PostItState();
}

class _PostItState extends State<PostIt> {
  late double top;
  late double left;
  late Color color;
  late int id;
  @override
  void initState() {
    super.initState();
    color = Color(widget.colorValue);
    top = widget.x;
    left = widget.y;
    id = widget.id;
  }

  void _handleDoubleTap() {
    _showPostItDialog();
  }

  void _showPostItDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return PostItDialog(
          onSave: (title, description) {
            _sendUpdateRequest();
          },
          initialTitle: widget.title,
          initialDescription: widget.description,
          postItId: widget.id,
          postItColor: widget.colorValue,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      left: left,
      child: GestureDetector(
        onTap: widget.onSelect,
        onDoubleTap: _handleDoubleTap,
        child: Draggable(
          feedback: SizedBox(
            width: 300,
            height: 300,
            child: Card(
              color: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(0),
              ),
              elevation: 10,
              child: buildCardContent(),
            ),
          ),
          childWhenDragging: SizedBox.shrink(),
          onDragEnd: (details) {
            setState(() {
              top = details.offset.dy;
              left = details.offset.dx;
            });

            _sendUpdateRequest();
          },
          child: buildCardContent(),
        ),
      ),
    );
  }

  Future<void> updateData() async {
    try {
      List<PostItData> data = await DataFetcher.fetchData();
      Provider.of<PostItDataProvider>(context, listen: false)
          .setPostItData(data);
    } catch (e) {
      print('Error fetching data: $e');
      // Handle error
    }
  }

  void _sendUpdateRequest() async {
    try {
      final double normalizedX = left / MediaQuery.of(context).size.width;
      final double normalizedY = top / MediaQuery.of(context).size.height;

      final Map<String, dynamic> requestBody = {
        'x': ((normalizedX) * MediaQuery.of(context).size.width).toInt(),
        'y': ((normalizedY) * MediaQuery.of(context).size.height).toInt(),
      };

      await http.put(
        Uri.parse('http://localhost:3001/elements/${widget.id}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      print('Requête UPDATE réussie');
      updateData();
    } catch (error) {
      print('Erreur lors de la requête UPDATE : $error');
    }
  }

  Widget buildCardContent() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: SizedBox(
        width: 300,
        height: 300,
        child: Card(
          color: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0),
          ),
          elevation: 10,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: 90,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: SingleChildScrollView(
                    child: Text(
                      widget.title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
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
              Container(
                height: 145,
                padding: const EdgeInsets.all(20.0),
                child: SingleChildScrollView(
                  child: Text(
                    widget.description,
                    style: TextStyle(
                      fontSize: 16,
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

class PostItDialog extends StatefulWidget {
  final Function(String title, String description) onSave;
  final String? initialTitle;
  final String? initialDescription;
  final int postItId;
  final int postItColor;

  const PostItDialog(
      {Key? key,
      required this.onSave,
      this.initialTitle,
      this.initialDescription,
      required this.postItId,
      required this.postItColor})
      : super(key: key);

  @override
  _PostItDialogState createState() => _PostItDialogState();
}

class _PostItDialogState extends State<PostItDialog> {
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  final ColorManager colorManager = ColorManager();
  late PostItData postItData;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.initialTitle);
    descriptionController =
        TextEditingController(text: widget.initialDescription);
    postItData = PostItData(
        title: widget.initialTitle ?? '',
        description: widget.initialDescription ?? '',
        x: 0,
        y: 0,
        id: widget.postItId,
        color: widget.postItColor);
  }

  Future<void> putData() async {
    try {
      final String title = titleController.text;
      final String description = descriptionController.text;

      final Map<String, dynamic> requestBody = {
        'title': title,
        'description': description,
      };

      await http
          .put(
        Uri.parse('http://localhost:3001/elements/${postItData.id}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      )
          .then((_) {
        print('Requête PUT réussie');
        updateData();
      });
    } catch (error) {
      print('Erreur lors de la requête PUT : $error');
    }
  }

  Future<void> updateData() async {
    try {
      List<PostItData> data = await DataFetcher.fetchData();
      Provider.of<PostItDataProvider>(context, listen: false)
          .setPostItData(data);
    } catch (e) {
      print('Error fetching data: $e');
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width / 1.2,
        height: MediaQuery.of(context).size.height / 1.2,
        padding: EdgeInsets.all(100.0),
        decoration: BoxDecoration(
          color: Color(postItData.color).withOpacity(0.95),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Modifier le Post-It',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text('Titre:'),
            TextField(
              controller: titleController,
              maxLength: 120,
              maxLines: null,
              keyboardType: TextInputType.multiline,
            ),
            SizedBox(height: 20),
            Text('Contenu:'),
            TextField(
              controller: descriptionController,
              maxLines: null,
              keyboardType: TextInputType.multiline,
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: ElevatedButton(
                    onPressed: () {
                      putData();
                      Navigator.pop(context);
                    },
                    child: Text('Save'),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Cancel'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class PostItInputDialog extends StatefulWidget {
  final Function(String title, String description) onSave;
  final String? initialTitle;
  final String? initialDescription;
  const PostItInputDialog({
    Key? key,
    required this.onSave,
    this.initialTitle,
    this.initialDescription,
  }) : super(key: key);

  @override
  _PostItInputDialogState createState() => _PostItInputDialogState();
}

class _PostItInputDialogState extends State<PostItInputDialog> {
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  final ColorManager colorManager = ColorManager();
  final Random random = Random();
  int x = 0;
  int y = 0;
  int id = 0;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController();
    descriptionController = TextEditingController();
    colorManager.chooseRandomColor();
    x = random.nextInt(500);
    y = random.nextInt(500);
  }

  Future<void> postData() async {
    try {
      final String title = titleController.text;
      final String description = descriptionController.text;
      final Color? color = colorManager.selectedColor;
      final Map<String, dynamic> requestBody = {
        'title': title,
        'description': description,
        'x': x,
        'y': y,
        'color': color?.value,
      };

      await http
          .post(
        Uri.parse('http://localhost:3001/elements'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      )
          .then((_) {
        print('Requête POST réussie');
        updateData();
      });
    } catch (error) {
      print('Erreur lors de la requête POST : $error');
    }
  }

  Future<void> updateData() async {
    try {
      List<PostItData> data = await DataFetcher.fetchData();
      Provider.of<PostItDataProvider>(context, listen: false)
          .setPostItData(data);
    } catch (e) {
      print('Error fetching data: $e');
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: colorManager.selectedColor?.withOpacity(0.95),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Créer un Post-It',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text('Titre:'),
            TextField(
              controller: titleController,
              maxLength: 120,
              keyboardType: TextInputType.multiline,
            ),
            SizedBox(height: 20),
            Text('Contenue:'),
            TextField(
              controller: descriptionController,
              maxLines: null,
              keyboardType: TextInputType.multiline,
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: ElevatedButton(
                    onPressed: () {
                      postData();
                      Navigator.pop(context);
                    },
                    child: Text('Save'),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Cancel'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class BigCard extends StatelessWidget {
  final PostItData? selectedPostIt;
  final Function()? onModifyPressed;
  final Function()? onDeletePressed;
  const BigCard({
    Key? key,
    required this.selectedPostIt,
    required this.onModifyPressed,
    required this.onDeletePressed,
  }) : super(key: key);

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
              SizedBox(height: 50),
              Container(
                width: MediaQuery.of(context).size.width / 3,
                child: ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return PostItInputDialog(
                          onSave: (title, description) {},
                        );
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 246, 9, 167),
                    padding: EdgeInsets.all(20),
                  ),
                  child: Text(
                    'Créer un Post-it',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 100),
              Container(
                width: MediaQuery.of(context).size.width / 3,
                child: ElevatedButton(
                  onPressed: () {
                    if (selectedPostIt != null) {
                      onModifyPressed?.call();
                      ;
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 236, 19, 184),
                    padding: EdgeInsets.all(20),
                  ),
                  child: Text(
                    'Modifie ton Post-It',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 100),
              Container(
                width: MediaQuery.of(context).size.width / 3,
                child: ElevatedButton(
                  onPressed: () {
                    onDeletePressed?.call();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 227, 28, 202),
                    padding: EdgeInsets.all(20),
                  ),
                  child: Text(
                    'Supprime ton Post-It',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
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
