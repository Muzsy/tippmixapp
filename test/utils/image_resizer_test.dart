import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';
import 'package:tippmixapp/utils/image_resizer.dart';

void main() {
  test('cropSquareResize256 produces 256x256 under 150KB', () async {
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);
    final paint = ui.Paint()..color = const ui.Color(0xFF123456);
    canvas.drawRect(const ui.Rect.fromLTWH(0, 0, 400, 300), paint);
    final image = await recorder.endRecording().toImage(400, 300);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    final bytes = data!.buffer.asUint8List();
    final out = await ImageResizer.cropSquareResize256(bytes);
    expect(out.lengthInBytes < 150 * 1024, true);
    final codec = await ui.instantiateImageCodec(out);
    final frame = await codec.getNextFrame();
    expect(frame.image.width, 256);
    expect(frame.image.height, 256);
  });
}
