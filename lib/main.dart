import 'package:euclidscribble/poemdeatil.dart';
import 'package:euclidscribble/poemlist.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Euclid Scribble',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.blue,
      ),
      home: PoemList(),
    );
  }
}

class AllPoems extends StatelessWidget {
  final String searchTerm;

  AllPoems({required this.searchTerm});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('poems').snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text('No image data available.'),
          );
        }

        List<ImageData> images = snapshot.data!.docs.map((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          return ImageData(
            name: data['name'] ?? '',
            title: data['title'] ?? '',
            description: data['description'] ?? '',
            imageUrl: data['image_url'] ?? '',
          );
        }).toList();

        if (searchTerm.isNotEmpty) {
          images = images
              .where((image) =>
                  image.title.toLowerCase().contains(searchTerm.toLowerCase()))
              .toList();
        }

        return ListView.builder(
          itemCount: images.length,
          itemBuilder: (context, index) {
            return InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        PoemDetailScreen(imageData: images[index]),
                  ),
                );
              },
              child: PoemCard(imageData: images[index]),
            );
          },
        );
      },
    );
  }
}

class PoemCard extends StatelessWidget {
  final ImageData imageData;

  PoemCard({required this.imageData});

  @override
  Widget build(BuildContext context) {
    return Card(
      borderOnForeground: false,
      color: const Color.fromARGB(255, 0, 0, 0),
      shadowColor: Colors.grey,
      surfaceTintColor: Colors.grey,
      elevation: 8,
      margin: EdgeInsets.all(10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12.0),
              topRight: Radius.circular(12.0),
            ),
            child: CachedNetworkImage(
              imageUrl: imageData.imageUrl,
              fit: BoxFit.cover,
              height: 200,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 8),
                Text(
                  imageData.title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: const Color.fromARGB(255, 187, 187, 187),
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.book_rounded,
                      color: Colors.grey,
                      size: 18,
                    ),
                    SizedBox(width: 4),
                    Text(
                      imageData.name,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
