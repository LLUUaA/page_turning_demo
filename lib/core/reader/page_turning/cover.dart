/// cover
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class Cover extends CustomPainter {
  Cover({@required this.offset, this.bgColor}) {
    paintCurr = new Paint()
      ..color = this.bgColor ?? Colors.blue
      ..blendMode = BlendMode.dstATop;
    paintNext = new Paint()
      ..color = this.bgColor ?? Colors.green
      ..blendMode = BlendMode.dstATop;
    paintBg = new Paint();

    /// _path
    _path = new Path();
  }

  final Color bgColor;
  final Offset offset;

  /// paint
  Paint paintCurr;
  Paint paintNext;
  Paint paintBg;

  /// path
  Path _path;

  /// Canvas
  Canvas _canvas;
  Size _size;

  /// Canvas bitmap
  Canvas canvasBitMap;
  ui.PictureRecorder picRecorder;

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.saveLayer(Rect.fromLTRB(0, 0, size.width, size.height), paintBg);
    this._canvas = canvas;
    this._size = size;
    this._getViewPath();
    // canvas.drawRect(
    //     Rect.fromLTRB(0, 0, size.width / 2, size.height), paintCurr);
    // canvas.drawRect(
    //     Rect.fromLTWH(size.width / 2, 0, size.width / 2, size.height),
    //     paintNext);

    this._drawPageNext();
    this._drawPageCurrent();
    canvas.restore();
  }

  void _newPicRecorder() {
    picRecorder = ui.PictureRecorder();
    canvasBitMap = Canvas(picRecorder);
  }

  void _drawPageCurrent() {
    _canvas.save();
    this._newPicRecorder();
    canvasBitMap.drawPath(_path, paintCurr);
    this._drawText(canvasBitMap, "这是current page");
    _canvas.drawPicture(picRecorder.endRecording());
    _canvas.clipPath(_path);
    _canvas.restore();
  }

  void _drawPageNext() {
    _canvas.save();
    this._newPicRecorder();
    canvasBitMap.drawPath(_path, paintNext);
    this._drawText(canvasBitMap, "这是next page");
    _canvas.drawPicture(picRecorder.endRecording());
    _canvas.clipPath(_path);
    _canvas.restore();
  }

  void _drawText(Canvas canvas, String content) {
    TextPainter textPainter = TextPainter(
        text: TextSpan(
          text: content,
          style: TextStyle(color: Colors.black, fontSize: 18.0),
        ),
        textDirection: TextDirection.ltr)
      ..layout(maxWidth: _size.width, minWidth: 1)
      ..paint(_canvas, Offset.zero);

    /// textPainter.size 绘制此文本所需的空间量。
    ///仅在调用[layout]后有效。
    print('textPainter.size ${textPainter.size}');
  }

  ///利用 Paragraph 实现 _drawText
  // void _drawText(
  //   Canvas canvas,
  //   String text, {
  //   TextAlign textAlign = TextAlign.start,
  //   Color color,
  // }) {
  //   ui.ParagraphBuilder pb = ui.ParagraphBuilder(ui.ParagraphStyle(
  //     textAlign: textAlign,
  //     fontStyle: FontStyle.normal,
  //   ));
  //   pb.pushStyle(ui.TextStyle(
  //     color: color ?? Colors.black87,
  //     fontSize: 16.0,
  //   ));
  //   pb.addText(text);

  //   ///这里需要先layout, 后面才能获取到文字高度
  //   ui.Paragraph paragraph = pb.build()
  //     ..layout(ui.ParagraphConstraints(width: _size.width));
  //   canvas.drawParagraph(paragraph, Offset.zero);
  // }

  Path _getViewPath() {
    _path
      ..reset()
      ..lineTo(0, _size.height)
      ..lineTo(_size.width, _size.height)
      ..lineTo(_size.width, 0)
      ..close();
    return _path;
  }
}
