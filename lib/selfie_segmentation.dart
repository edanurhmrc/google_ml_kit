// ignore_for_file: avoid_print, library_private_types_in_public_api

import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';

class SelfieSeg extends StatefulWidget {
  const SelfieSeg({super.key});

  @override
  _SelfieSegState createState() => _SelfieSegState();
}

class _SelfieSegState extends State<SelfieSeg> {
  File? _imageFile;
  bool _isImageLoaded = false;
  SelfieSegmenter? _selfieSegmenter; // SelfieSegmenter nesnesi
  bool? _isSegmenting; // Segmentasyon işlemi başlatıldı mı
  Uint8List? _segmentationResult; // Segmentasyon sonucu

  @override
  void initState() {
    super.initState();
    // SelfieSegmenter nesnesi oluşturuluyor.Segmentasyon işlemi başlatılmamış durumda
    _selfieSegmenter =
        SelfieSegmenter(mode: SegmenterMode.stream, enableRawSizeMask: true);
    _isSegmenting = false;
  }

  @override
  void dispose() {
    _selfieSegmenter?.close();
    super.dispose();
  }

  // Fotoğraf seçme 
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        _isImageLoaded = true;
        _segmentationResult = null;
      });
    }
  }

  // Segmentasyon işlemi
  Future<void> _segmentImage() async { 
    if (_imageFile == null || _selfieSegmenter == null) {
      return;
    }
    setState(() {
      _isSegmenting = true; // Segmentasyon işlemi başlatılıyor 
    });

    final inputImage = InputImage.fromFile(_imageFile!);

    try {
      final segmentationMask = await _selfieSegmenter?.processImage(inputImage); // Segmentasyon işlemi yapılıyor
      if (segmentationMask == null) {
        print("Segmentation mask is null");
        return;
      }

      final resultImage =
          await _createSegmentationResultImage(segmentationMask);

      setState(() {
        _segmentationResult = resultImage; // Segmentasyon sonucu atanıyor
      });
    } catch (e) {
      print("Error during segmentation: $e");
    } finally {
      setState(() {
        _isSegmenting = false; // Segmentasyon işlemi tamamlandı
      });
    }
  }

  // Segmentasyon sonucu
  Future<Uint8List> _createSegmentationResultImage(
      SegmentationMask segmentationMask) async {
    try {
      final inputBytes = await _imageFile!.readAsBytes();
      final inputImage = img.decodeImage(inputBytes)!;
      final resizedImage = img.copyResize(inputImage,
          width: segmentationMask.width, height: segmentationMask.height);

      for (var y = 0; y < segmentationMask.height; y++) {
        for (var x = 0; x < segmentationMask.width; x++) {
          // Pikselin ön plan mı arka plan mı olduğu kontrol ediliyor
          final isForeground =
              segmentationMask.confidences[y * segmentationMask.width + x] >
                  0.5;
          if (!isForeground) {
            resizedImage.setPixelRgba(x, y, 255, 255, 255, 0);
          }
        }
      }

      final outputBytes = img.encodePng(resizedImage);
      return outputBytes;
    } catch (e) {
      print("Error during image processing: $e");
      throw Exception(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Selfie Segmentasyon'),
      ),
      body: Center(
        child: SizedBox(
          // width: 500,
          // height: 500,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (!_isImageLoaded)
                ElevatedButton(
                  onPressed: _pickImage,
                  child: const Text('Fotoğrafı Seç'),
                ),
              if (_isImageLoaded && _segmentationResult == null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.file(
                    _imageFile!,
                    width: MediaQuery.of(context).size.width * 0.8,
                    height: 500,
                  ),
                ),
              if (_segmentationResult != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.memory(_segmentationResult!),
                ),
              if (_isSegmenting == true) const CircularProgressIndicator(),
              if (_isImageLoaded && _isSegmenting == false)
                ElevatedButton(
                  onPressed:
                      _segmentationResult != null ? _pickImage : _segmentImage,
                  child: Text(_segmentationResult != null
                      ? 'Fotoğrafı Değiştir'
                      : 'Selfie Segmentasyonu Başlat'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
