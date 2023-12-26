import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:euclidscribble/main.dart';
import 'package:euclidscribble/poemdeatil.dart';
import 'package:flutter/material.dart';

class PoemList extends StatefulWidget {
  @override
  _PoemListState createState() => _PoemListState();
}

class _PoemListState extends State<PoemList> {
  final TextEditingController _searchController = TextEditingController();
  late String _searchTerm;

  @override
  void initState() {
    super.initState();
    _searchTerm = '';
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.black54,
        appBar: AppBar(
          backgroundColor: Colors.black,
          foregroundColor: Colors.cyanAccent,
          title: Text('Euclid Scribble ?'),
          bottom: TabBar(
            labelColor: Colors.cyanAccent,
            dividerColor: const Color.fromARGB(255, 0, 0, 0),
            indicatorColor: Colors.cyanAccent,
            overlayColor:
                MaterialStateProperty.all(Color.fromARGB(255, 0, 0, 0)),
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: 'Latest Poems'),
              Tab(text: 'All Poems'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            LatestPoems(searchTerm: _searchTerm),
            AllPoems(searchTerm: _searchTerm),
          ],
        ),
      ),
    );
  }
}

class LatestPoems extends StatelessWidget {
  final String searchTerm;

  LatestPoems({required this.searchTerm});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('poems')
          .orderBy('timestamp', descending: true)
          .snapshots(),
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
            return PoemCard1(imageData: images[index]);
          },
        );
      },
    );
  }
}

class PoemCard1 extends StatelessWidget {
  final ImageData imageData;

  PoemCard1({required this.imageData});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            imageData.title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: const Color.fromARGB(255, 212, 211, 211),
            ),
          ),
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(12.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: CachedNetworkImage(
              imageUrl: imageData.imageUrl,
              fit: BoxFit.cover,
              height: 200,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 8),
              Text(
                imageData.description,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: 16),
              Text(
                '${imageData.name}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
        Divider(
          color: Colors.grey,
          height: 1,
          thickness: 1,
        ),
      ],
    );
  }
}
