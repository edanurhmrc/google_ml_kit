import 'package:flutter/material.dart';
import 'package:google_ml_kit_project/digital_ink_detection.dart';
import 'package:google_ml_kit_project/selfie_segmentation.dart';
import 'package:google_ml_kit_project/text_recognition.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          elevation: 1,
          backgroundColor:
              Theme.of(context).colorScheme.primary.withOpacity(0.9),
          title: const Text(
            'Google ML Kit',
            style: TextStyle(color: Colors.white),
          )),
      body: Container(
        color: Colors.grey[200],
        child: ListView(
          padding: const EdgeInsets.all(10),
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.image_search),
              title: const Text('Text Recognition'),
              textColor: Colors.blueAccent,
              iconColor: Colors.blueAccent,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const TextRecognition(),
                  ),
                );
              },
            ),
            Divider(
              color: Colors.grey[300],
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Digital Ink Recognition'),
              textColor: Colors.blueAccent,
              iconColor: Colors.blueAccent,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const DigitalInkRecognition(),
                  ),
                );
              },
            ),
            Divider(
              color: Colors.grey[300],
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_back_outlined),
              title: const Text('Selfie Segmentation'),
              textColor: Colors.blueAccent,
              iconColor: Colors.blueAccent,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const SelfieSeg(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
