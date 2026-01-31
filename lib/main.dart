import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _songNameCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _typeCtrl = TextEditingController();

  InputDecoration textStyle = InputDecoration();

  void addSong() async {
    String _songName = _songNameCtrl.text,
        _name = _nameCtrl.text,
        _type = _typeCtrl.text;

    try {
      await FirebaseFirestore.instance.collection("song").add({
        "songName": _songName,
        "artis": _name,
        "type": _type,
      });

      _songNameCtrl.clear();
      _nameCtrl.clear();
      _typeCtrl.clear();
    } catch (e) {
      print("Error najarrrr!!! : $e");
    }

    print("ค่า $_songName");
    print("ค่า $_name");
    print("ค่า $_type");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.blue, title: Text("data")),
      body: Center(
        child: Column(
          children: [
            TextField(
              controller: _songNameCtrl,
              decoration: textStyle.copyWith(
                labelText: "ชื่อเพลง",
                hintText: "",
              ),
            ),
            TextField(
              controller: _nameCtrl,
              decoration: textStyle.copyWith(
                labelText: "ชื่อศิลปิน",
                hintText: "",
              ),
            ),
            TextField(
              controller: _typeCtrl,
              decoration: textStyle.copyWith(
                labelText: "แนวเพลง",
                hintText: "",
              ),
            ),
            ElevatedButton(onPressed: addSong, child: Text("Submit")),
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("song")
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text(snapshot.error.toString()));
                  }

                  final docs = snapshot.data!.docs;

                  return GridView.builder(
                    itemCount: docs.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemBuilder: (context, index) {
                      final songs = docs[index];
                      final s = songs.data();

                      return InkWell(
                        onTap: (){
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_)=> SongDetail(song: s)
                              )
                          );
                        },
                          child: Card(
                            child: Text(s["songName"]),
                          ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SongDetail extends StatelessWidget {
  final song;

  const SongDetail({super.key, required this.song});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Song")),
      body: Column(
        children: [
          Text(song["artis"]),
          Text(song["songName"]),
          Text(song["type"]),
        ],
      ),
    );
  }
