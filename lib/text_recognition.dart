// ignore_for_file: avoid_print, use_build_context_synchronously

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

class TextRecognition extends StatefulWidget {
  const TextRecognition({super.key});

  @override
  State<TextRecognition> createState() => _TextRecognitionState();
}

class _TextRecognitionState extends State<TextRecognition> {
  File? _image;
  bool isImageLoaded = false;
  var result = '';

  double? _imageWidth;
  double? _imageHeight;

  bool isVisible = false;

  Future<void> pickImage(ImageSource source) async {
    try {
      final pickedImage =
          await ImagePicker().pickImage(source: source); // Resim seç
      if (pickedImage == null) return;
      final imageTemporary =
          File(pickedImage.path); // Resmi geçici olarak saklar

      // Resmi boyutlandır
      final decodedImage = img.decodeImage(
          File(pickedImage.path).readAsBytesSync()); // Resmi çözümler
      final screenWidth = MediaQuery.of(context).size.width;
      final screenHeight = MediaQuery.of(context).size.height;
      final double maxWidth = screenWidth - 16;
      final double maxHeight = screenHeight - 200;
      final double aspectRatio = decodedImage!.width / decodedImage.height;
      _imageWidth = (decodedImage.width > maxWidth)
          ? maxWidth
          : decodedImage.width.toDouble();
      _imageHeight = _imageWidth! / aspectRatio;

      // Resmi boyutlandır
      if (_imageHeight! > maxHeight) {
        _imageHeight = maxHeight;
        _imageWidth = _imageHeight! * aspectRatio;
      }
      setState(() {
        _image = imageTemporary;
        isImageLoaded = true;
      });
    } on PlatformException catch (e) {
      print("Failed to pick image: $e");
    }
  }

  // Resmi çözümler
  Future<img.Image> decodeImage(List<int> imageBytes) async {
    final Uint8List imageBytesUint8 = Uint8List.fromList(imageBytes);
    final img.Image? decodedImage = img.decodeImage(imageBytesUint8);
    if (decodedImage == null) {
      throw Exception('Failed to decode image.');
    }
    return decodedImage;
  }

  // Resimden metin okur
  Future<void> readTextFromAnImage() async {
    setState(() {
      result = 'Recognizing text...';
      isVisible = true;
    });

    if (_image == null) return;

    // Resmi işler
    final readText = await GoogleMlKit.vision
        .textRecognizer()
        .processImage(InputImage.fromFile(_image!));

    String scannedText = '';

    // Metni blok, satır ve kelime olarak okur
    for (TextBlock block in readText.blocks) {
      for (TextLine line in block.lines) {
        for (TextElement word in line.elements) {
          scannedText += '${word.text} ';
        }
        scannedText += '\n';
      }
      scannedText += '\n';
    }

    setState(() {
      result = scannedText.trim();
    });
  }

  // Resmi ve metni temizler
  void clearImageAndText() {
    setState(() {
      _image = null;
      isImageLoaded = false;
      result = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.9),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Text Recognition",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: Container(
                      width: _imageWidth == null
                          ? MediaQuery.of(context).size.width
                          : _imageWidth!,
                      height: _imageHeight == null
                          ? MediaQuery.of(context).size.height * 0.6
                          : _imageHeight!,
                      decoration: const BoxDecoration(),
                      child: _image != null &&
                              _imageWidth != null &&
                              _imageHeight != null
                          ? Image.file(
                              _image!,
                              width: _imageWidth,
                              height: _imageHeight,
                              fit: BoxFit.contain,
                            )
                          : Icon(
                              Icons.no_photography_outlined,
                              size: 80,
                              color: Colors.grey[400],
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        // Galeriden resim seç
                        pickImage(ImageSource.gallery);
                      },
                      child: const Icon(Icons.image_outlined),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // Kameradan resim seç
                        pickImage(ImageSource.camera);
                      },
                      child: const Icon(Icons.camera_alt_outlined),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        readTextFromAnImage();
                      },
                      label: const Text("Scan"),
                      icon: const Icon(Icons.document_scanner_outlined),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        clearImageAndText();
                        isVisible = false;
                      },
                      child: const Text("Clear"),
                    ),
                  ],
                ),
                Visibility(
                  visible: isVisible,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.9,
                        height: MediaQuery.of(context).size.height * 0.8,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                        ),
                        child: SelectableText(
                          result,
                          style: const TextStyle(
                              fontSize: 16, color: Colors.black),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
