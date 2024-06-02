// import 'package:flutter/services.dart';
// import 'package:google_ml_kit/google_ml_kit.dart';

// class SelfieSegmenter {
//   static const MethodChannel _channel =
//       MethodChannel('new_selfie_segmentation');

//   final SegmenterMode mode;
//   final bool enableRawSizeMask;
//   final id = DateTime.now().microsecondsSinceEpoch.toString();

//   SelfieSegmenter({
//     this.mode = SegmenterMode.stream,
//     this.enableRawSizeMask = true,
//   });

//   Future<SegmentationMask?> processImage(InputImage image) async {
//     final result = await _channel.invokeMethod('processImage', {
//       'id': id,
//       'image': image.toJson(),
//       'isStream': mode == SegmenterMode.stream,
//       'enableRawSizeMask': enableRawSizeMask,
//     });

//     return result == null ? null : SegmentationMask.fromJson(result);
//   }

//   Future<void> close() async {
//     _channel.invokeMethod('close', {'id': id});
//   }
// }

// enum SegmenterMode {
//   single,
//   stream,
// }

// class SegmentationMask {
//   late final int width;
//   late final int height;

//   final List<double> confidences;

//   SegmentationMask({
//     required this.width,
//     required this.height,
//     required this.confidences,
//   });
  
//   factory SegmentationMask.fromJson(Map<dynamic, dynamic> json) {
//      final values = json['confidences'];
//     final List<double> confidences = [];
//     for (final item in values) {
//       confidences.add(double.parse(item.toString()));
//     }
//     return SegmentationMask(
//       width: json['width'],
//       height: json['height'],
//       confidences: List<double>.from(json['confidences']),
//     );
//   }
// }
