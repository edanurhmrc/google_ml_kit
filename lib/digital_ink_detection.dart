// ignore_for_file: use_build_context_synchronously

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_digital_ink_recognition/google_mlkit_digital_ink_recognition.dart'
    as ink_recog;
import 'package:google_mlkit_digital_ink_recognition/google_mlkit_digital_ink_recognition.dart';

class DigitalInkRecognition extends StatefulWidget {
  const DigitalInkRecognition({Key? key}) : super(key: key);

  @override
  State<DigitalInkRecognition> createState() => _DigitalInkRecognitionState();
}

class _DigitalInkRecognitionState extends State<DigitalInkRecognition> {
  final DigitalInkRecognizerModelManager _modelManager =
      DigitalInkRecognizerModelManager();

  //final String _language = 'tr-TR'; // 'en-US', 'tr-TR', 'fr-FR', 'es-ES'
  final DigitalInkRecognizer _recognizer =
      DigitalInkRecognizer(languageCode: 'tr-TR');

  // Ink nesnesi
  final ink = ink_recog.Ink();
  List<StrokePoint> _points = [];
  String _recognizedText = '';

  @override
  void initState() {
    super.initState();
    initializeModel();
  }

  // Modeli yükle
  Future<void> initializeModel() async {
    try {
      await _modelManager.downloadModel('tr-TR');
      bool isDowloaded = await _modelManager.isModelDownloaded('tr-TR');
      if (kDebugMode) {
        print("DOWLOAD: $isDowloaded");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Modeli indirirken hata oluştu: $e");
      }
    }
  }

  Future<bool> isModelDowloaded() async {
    final isDownloaded = await _modelManager.isModelDownloaded('tr-TR');
    if (!isDownloaded) {
      await _modelManager.downloadModel('tr-TR');
    }
    return isDownloaded;
  }

  @override
  void dispose() {
    _recognizer.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          elevation: 1,
          backgroundColor:
              Theme.of(context).colorScheme.primary.withOpacity(0.9),
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text(
            'Digital Ink Recognition',
            style: TextStyle(color: Colors.white),
          )),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(10),
                child: strokes(context),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        await _recognize();
                        Navigator.pop(context);
                        _showModalBottomsheet();
                      },
                      child: const Text('Recognize'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        ink.strokes.clear();
                        _points.clear();
                        _recognizedText = '';
                        setState(() {});
                      },
                      child: const Text('Clear'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Ekrana çizilen noktaları güncelle
  void _updatePoints(DragUpdateDetails details, BuildContext context) {
    final RenderObject? object =
        context.findRenderObject(); // RenderObject'ı al
    final localPosition = (object as RenderBox?)
        ?.globalToLocal(details.localPosition); // localPosition'ı al
    if (localPosition != null) {
      // Eğer localPosition null değilse _points listesine noktaları ekle
      _points = List.from(_points)
        ..add(StrokePoint(
          x: localPosition.dx,
          y: localPosition.dy,
          t: DateTime.now().millisecondsSinceEpoch,
        ));
    }
    // Eğer ink.strokes listesi boş değilse ink.strokes listesinin son elemanına _points listesini ekle
    if (ink.strokes.isNotEmpty) {
      ink.strokes.last.points = _points.toList();
    }
    setState(() {});
  }

  // Ekrana çizilen noktaları temizle
  void _clearPoints() {
    _points.clear();
    setState(() {});
  }

  void _showModalBottomsheet() {
    showModalBottomSheet(
      context: context,
      isDismissible: true,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(10),
          margin: const EdgeInsets.all(7),
          width: MediaQuery.of(context).size.width,
          child: SelectableText(
            'Candidate: $_recognizedText',
            style: const TextStyle(fontSize: 23),
          ),
        );
      },
    );
  }

  Future<void> _recognize() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        title: Text("Recognizing..."),
      ),
    );

    try {
      // Model indirilmiş ise tanıma işlemini yap ve ekrana yazdır
      bool isDownloaded = await isModelDowloaded();
      if (isDownloaded) {
        final candidates = await _recognizer.recognize(ink); 
        _recognizedText = '';
        for (final candidate in candidates) {
          _recognizedText += '\n${candidate.text}';
        }
        setState(() {});
        _showModalBottomsheet();
      } else {
        if (kDebugMode) {
          print("Model henüz indirilmedi.");
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.toString()),
      ));
    }

    Navigator.pop(context);
  }

  // Ekrana çizilen noktaları göster
  Widget strokes(BuildContext context) {
    return GestureDetector(
      onPanStart: (details) { //Ekrana dokunulduğunda yeni Stroke oluştur
        ink.strokes.add(Stroke()); // ink.strokes listesine yeni Stroke ekle
      },
      onPanUpdate: (details) => _updatePoints(details,
          context), // Kullanıcının ekranda parmağını hareket ettirdiği sürece tetiklenir
      onPanEnd: (details) => _clearPoints(),

      // CustomPaint widget'ı kullanarak çizim yapıyoruz
      child: CustomPaint(
        painter: _MyPainter(ink),
        size: Size.infinite,
      ),
    );
  }

  void clearPad() {
    ink.strokes.clear();
    _points.clear();
    _recognizedText = '';
    setState(() {});
  }
}

class _MyPainter extends CustomPainter {
  ink_recog.Ink ink;
  _MyPainter(this.ink);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.black
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5.0;

    for (final stroke in ink.strokes) {
      for (int i = 0; i < stroke.points.length - 1; i++) {
        final p1 = stroke.points[i];
        final p2 = stroke.points[i + 1];
        canvas.drawLine(
          Offset(p1.x.toDouble(), p1.y.toDouble()),
          Offset(p2.x.toDouble(), p2.y.toDouble()),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_MyPainter oldDelegate) => true;
}
