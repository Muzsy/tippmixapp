import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

class ImageResizer {
  /// Downscales an image file to stay under [maxBytes] by reducing dimensions.
  /// PNG encoding is used to avoid external dependencies.
  static Future<File> downscalePng(
    File file, {
    int maxBytes = 2 * 1024 * 1024,
    int initialMaxDimension = 1024,
    int minDimension = 128,
  }) async {
    try {
      final original = await file.readAsBytes();
      if (original.lengthInBytes <= maxBytes) return file;

      final codec0 = await ui.instantiateImageCodec(original);
      final frame0 = await codec0.getNextFrame();
      final img0 = frame0.image;

      int target = math.min(initialMaxDimension, math.max(img0.width, img0.height));
      // Iteratively downscale until size constraint met or minDimension reached
      File current = file;
      while (target >= minDimension) {
        final scale = target / math.max(img0.width, img0.height);
        final w = (img0.width * scale).round().clamp(1, img0.width);
        final h = (img0.height * scale).round().clamp(1, img0.height);
      final recorder = ui.PictureRecorder();
      final canvas = ui.Canvas(recorder);
      final src = ui.Rect.fromLTWH(0, 0, img0.width.toDouble(), img0.height.toDouble());
      final dst = ui.Rect.fromLTWH(0, 0, w.toDouble(), h.toDouble());
      final paint = ui.Paint();
      canvas.drawImageRect(img0, src, dst, paint);
        final scaled = await recorder.endRecording().toImage(w, h);
        final data = await scaled.toByteData(format: ui.ImageByteFormat.png);
        final bytesOut = data!.buffer.asUint8List();
        if (bytesOut.lengthInBytes <= maxBytes) {
          return await current.writeAsBytes(bytesOut, flush: true);
        }
        // write anyway to keep progress and try smaller
        current = await current.writeAsBytes(bytesOut, flush: true);
        target = (target / 1.5).round();
      }
      return current;
    } catch (_) {
      // On any error, return original file to avoid blocking uploads
      return file;
    }
  }
}
