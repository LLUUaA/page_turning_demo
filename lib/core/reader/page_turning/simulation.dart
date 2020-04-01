import 'dart:ui' as ui;
import 'dart:math' show min, max, atan2, sqrt, pow;
import 'package:vector_math/vector_math_64.dart' as v;

import 'package:flutter/material.dart'
    show
        CustomPainter,
        Color,
        required,
        Path,
        Paint,
        Offset,
        Size,
        Canvas,
        DragDownDetails,
        TextAlign,
        Rect,
        // fontSize,
        PathOperation,
        FontStyle,
        Colors,
        Matrix4;

enum POSITION_STYLE { TOP_RIGHT, BOTTOM_RIGHT, LEFT, RIGHT, MID }

class Simulation extends CustomPainter {
  Simulation({@required this.offset}) {
    assert(this.offset != null);
    // bg Color
    bgColorSave = Color(0x77cdb175);

    // Path
    pathA = new Path();
    pathB = new Path();
    pathC = new Path();
    // paint
    paintA = new Paint()
      ..isAntiAlias = true
      ..color = bgColorSave;
    paintBg = new Paint();
    paintShadow = new Paint();
    // canvasBitMap
    this.newPicRecorder();
  }

  /// final
  final Offset offset;

  /// offset(pos)
  Offset a, f, g, e, h, c, j, b, k, d, i; // points
  // Canvas canvas;
  static Size viewSize;
  // defalutBgColor
  Color bgColorSave;

  /// POSITION STYLE
  static POSITION_STYLE initPosition;

  /// viewDiagonalLength
  num viewDiagonalLength;
  // canvas
  Canvas canvasBitMap;
  ui.PictureRecorder picRecorder;

  /// path
  Path pathA;
  Path pathB;
  Path pathC;

  /// paint
  Paint paintA;
  Paint paintBg;
  Paint paintShadow;

  /// dis
  ///A区域左阴影矩形短边长度参考值
  double lPathAShadowDis = 12.0;

  /// A区域右阴影矩形短边长度参考值
  double rPathAShadowDis = 12.0;

  // repaint
  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    /// 点击中间区域不绘画
    return POSITION_STYLE.MID != initPosition;
  }

  static void handlePanDown(DragDownDetails _) {
    double boxW = viewSize.width / 3;
    double boxH = viewSize.height / 3;
    double dx = _.globalPosition.dx;
    double dy = _.globalPosition.dy;
    if (dy > 2 * boxH && dx > boxW) {
      initPosition = POSITION_STYLE.BOTTOM_RIGHT;
    } else if (dy < boxH && dx > boxW) {
      initPosition = POSITION_STYLE.TOP_RIGHT;
    } else if (dy > boxH && dy < 2 * boxH && dx > boxW && dx < 2 * boxW) {
      initPosition = POSITION_STYLE.MID;
    } else if (dy > boxH && dy < 2 * boxH && dx > 2 * boxW) {
      initPosition = POSITION_STYLE.RIGHT;
    } else {
      initPosition = POSITION_STYLE.LEFT;
    }
    print('click POSITION_STYLE =$initPosition');
  }

  /// 计算c点有没有超出区域
  bool calcPointC() {
    // reset
    if (offset == Offset.zero || (-1 == offset.dx && -1 == offset.dy)) {
      a = Offset(-1, -1);
      initPosition = POSITION_STYLE.TOP_RIGHT;
      f = Offset(viewSize.width, 0);
      return true;
    }

    a = offset;
    if (initPosition == POSITION_STYLE.BOTTOM_RIGHT) {
      f = Offset(viewSize.width, viewSize.height);
    } else if (initPosition == POSITION_STYLE.TOP_RIGHT) {
      f = Offset(viewSize.width, 0);
    } else {
      a = Offset(offset.dx, viewSize.height - 1);
      f = Offset(viewSize.width, viewSize.height);
    }

    g = Offset((f.dx + a.dx) / 2, (f.dy + a.dy) / 2);
    e = Offset(g.dx - pow(f.dy - g.dy, 2) / (f.dx - g.dx), f.dy);
    c = Offset(e.dx - (f.dx - e.dx) / 2, f.dy);

    if (c.dx < 1) {
      double w0 = viewSize.width - c.dx;
      double w1 = (f.dx - a.dx).abs();
      double w2 = viewSize.width * w1 / w0;
      double h1 = (f.dy - a.dy).abs();
      double h2 = w2 * h1 / w1;
      a = Offset((f.dx - w2).abs(), (f.dy - h2).abs());
    }
    return true;
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.saveLayer(Rect.fromLTRB(0, 0, size.width, size.height), paintBg);
    // MyPageTurn.canvas = canvas;
    viewDiagonalLength = _getDistance(
      Offset.zero,
      Offset(size.width, size.height),
    ); //view对角线长度
    /// [viewSize]
    viewSize = size;

    calcPointC();
    calcAllPioints();

    drawPathA(canvas);
    drawPathC(canvas);
    drawPathB(canvas);
    canvas.restore();
  }

  ///利用 Paragraph 实现 _drawText
  void _drawText(
      Canvas canvas, String text, Color color, double width, Offset offset,
      {TextAlign textAlign = TextAlign.start, double fontSize}) {
    ui.ParagraphBuilder pb = ui.ParagraphBuilder(ui.ParagraphStyle(
      textAlign: textAlign,
      fontSize: fontSize,
      fontStyle: FontStyle.normal,
    ));
    pb.pushStyle(ui.TextStyle(
      color: color ?? Colors.black87,
      fontSize: 16.0,
    ));
    pb.addText(text);

    ///这里需要先layout, 后面才能获取到文字高度
    ui.Paragraph paragraph = pb.build()
      ..layout(ui.ParagraphConstraints(width: width));
    canvas.drawParagraph(paragraph, offset);
  }

  void newPicRecorder() {
    picRecorder = ui.PictureRecorder();
    canvasBitMap = Canvas(picRecorder);
  }

  void drawPathA(Canvas canvas) {
    canvas.save();
    this.newPicRecorder();
    paintA..color = bgColorSave;
    canvasBitMap.drawPath(getPathA(), paintA);
    _drawText(
      canvasBitMap,
      "这是阅读页内容AAA",
      Colors.black,
      viewSize.width,
      Offset(viewSize.width / 2, viewSize.height - 100),
      fontSize: 16.0,
    );

    ui.Picture pic = picRecorder.endRecording();
    canvas.clipPath(pathA);

    canvas.drawPicture(pic);
    drawPathALeftShadow(canvas, pathA);
    drawPathARightShadow(canvas, pathA);
    canvas.restore();
  }

  void drawPathB(Canvas canvas) {
    canvas.save();
    this.newPicRecorder();
    paintA..color = bgColorSave;
    canvasBitMap.drawPath(getPathB(), paintA);
    _drawText(
      canvasBitMap,
      "这是下一页内容BBB",
      Colors.black,
      viewSize.width,
      Offset(viewSize.width / 2, viewSize.height - 100),
      fontSize: 16.0,
    );
    canvas.clipPath(pathB);
    canvas.drawPicture(picRecorder.endRecording());
    this.drawPathBShadow(canvas);
    canvas.restore();
  }

  void drawPathC(Canvas canvas) {
    /// 生成背面文字
    paintA..color = Color.alphaBlend(bgColorSave, Colors.white);
    canvas.drawPath(getPathC(), paintA);
    canvas.save();
    this.newPicRecorder();
    canvasBitMap.drawPath(_getDefaultPath(), paintA);
    _drawText(
      canvasBitMap,
      "这是阅读页内容AAA",
      Colors.black26,
      viewSize.width,
      Offset(viewSize.width / 2, viewSize.height - 100),
      fontSize: 16.0,
    );
    ui.Picture pic = picRecorder.endRecording();
    canvas.clipPath(pathC);

    double eh = _getDistance(e, h);
    double sin0 = (f.dx - e.dx) / eh;
    double cos0 = (h.dy - f.dy) / eh;

    //设置翻转和旋转矩阵
    Matrix4 mMatrix = Matrix4.columns(
      v.Vector4(-(1 - 2 * sin0 * sin0), 2 * sin0 * cos0, 0, 0),
      v.Vector4(2 * sin0 * cos0, (1 - 2 * sin0 * sin0), 0, 0),
      v.Vector4(0, 0, 1, 0),
      v.Vector4(0, 0, 0, 1),
    );

    canvas.translate(e.dx, e.dy);
    mMatrix.translate(-e.dx, -e.dy);
    canvas.transform(mMatrix.storage);
    canvas.drawPicture(pic); // draw
    this.drawPathCShadow(canvas, pathC);
    canvas.restore();
  }

  /// A 区域左边阴影
  void drawPathALeftShadow(Canvas canvas, Path pathA) {
    canvas.restore();
    canvas.save();

    var gradientColors = [
      Colors.transparent,
      Colors.black26,
    ];

    double left;
    double right;
    double top = e.dy;
    double bottom = (e.dy + viewSize.height);
    ui.Gradient gradient;
    if (initPosition == POSITION_STYLE.TOP_RIGHT) {
      left = (e.dx - lPathAShadowDis);
      right = (e.dx);
    } else {
      right = (e.dx);
      left = (e.dx + lPathAShadowDis);
    }

    gradient = ui.Gradient.linear(
      Offset(left, top),
      Offset(right, top),
      gradientColors,
    );
    paintShadow..shader = gradient;

    //裁剪出我们需要的区域
    Path mPath = new Path();
    mPath
      ..reset()
      ..moveTo(a.dx - max(rPathAShadowDis, lPathAShadowDis), a.dy)
      ..lineTo(d.dx, d.dy)
      ..lineTo(e.dx, e.dy)
      ..lineTo(a.dx, a.dy)
      ..close();
    this.newPicRecorder();
    canvasBitMap
      ..clipPath(Path.combine(PathOperation.intersect, pathA, mPath))
      ..translate(e.dx, e.dy)
      ..rotate(atan2(e.dx - a.dx, a.dy - e.dy))
      ..translate(-e.dx, -e.dy)
      ..drawRect(Rect.fromLTRB(left, top, right, bottom), paintShadow);

    canvas.drawPicture(picRecorder.endRecording());
  }

  void drawPathARightShadow(Canvas canvas, Path pathA) {
    canvas.restore();
    canvas.save();
    var gradientColors = [Colors.black26, Colors.transparent];

    double left = h.dx;
    double right = (h.dx + viewDiagonalLength * 100);
    double top;
    double bottom;

    ui.Gradient gradient;
    if (initPosition == POSITION_STYLE.TOP_RIGHT) {
      top = (h.dy - rPathAShadowDis);
      bottom = h.dy;
    } else {
      bottom = h.dy;
      top = (h.dy + rPathAShadowDis);
    }
    gradient = ui.Gradient.linear(
      Offset(left, top),
      Offset(left, bottom),
      gradientColors,
    );
    paintShadow..shader = gradient;
    Path mPath = new Path();
    mPath
      ..moveTo(a.dx - max(rPathAShadowDis, lPathAShadowDis), a.dy)
      ..lineTo(h.dx, h.dy)
      ..lineTo(a.dx, a.dy)
      ..close();
    this.newPicRecorder();
    canvasBitMap
      ..clipPath(Path.combine(PathOperation.intersect, pathA, mPath))
      ..translate(h.dx, h.dy)
      ..rotate(atan2(a.dy - h.dy, a.dx - h.dx))
      ..translate(-h.dx, -h.dy)
      ..drawRect(Rect.fromLTRB(left, top, right, bottom), paintShadow);
    canvas.drawPicture(picRecorder.endRecording());
  }

  void drawPathBShadow(Canvas canvas) {
    List<Color> gradientColors = [
      Color(0xff111111),
      Color(0x00333333),
    ]; //渐变颜色数组
    int elevation = 5;
    int deepOffset = -5; //深色端的偏移值
    int lightOffset = 10; //浅色端的偏移值
    double aTof = _getDistance(a, f); //a到f的距离
    double left;
    double right;
    double top = c.dy;
    double bottom = (viewDiagonalLength + c.dy);
    ui.Gradient gradient;
    if (initPosition == POSITION_STYLE.TOP_RIGHT) {
      //f点在右上角
      //从左向右线性渐变
      left = (c.dx - deepOffset); //c点位于左上角
      right = (c.dx + aTof / elevation + lightOffset);
    } else {
      right = (c.dx - aTof / elevation - lightOffset); //c点位于左下角
      left = (c.dx + deepOffset);
    }

    gradient = ui.Gradient.linear(
      Offset(left, top),
      Offset(right, top),
      gradientColors,
    );
    paintShadow..shader = gradient;
    this.newPicRecorder();
    canvasBitMap
      ..translate(c.dx, c.dy)
      ..rotate(atan2(e.dx - f.dx, h.dy - f.dy))
      ..translate(-c.dx, -c.dy)
      ..drawRect(Rect.fromLTRB(left, top, right, bottom), paintShadow);
    canvas.drawPicture(picRecorder.endRecording());
  }

// 阴影B区域
  void drawPathCShadow(Canvas canvas, Path path) {
    canvas.restore();
    canvas.save();
    List<Color> gradientColors = [
      Color(0x00333333),
      Color(0xff333333)
    ]; //渐变颜色数组

    int deepOffset = 25; //深色端的偏移值s
    int lightOffset = 0; //浅色端的偏移值

    double midpointCe = (c.dx + e.dx) / 2; //ce中点
    double midpointJh = (j.dy + h.dy) / 2; //jh中点
    double minDisToControlPoint =
        min((midpointCe - e.dx).abs(), (midpointJh - h.dy).abs()); //中点到控制点的最小值

    double left;
    double right;
    double top = c.dy;
    double bottom = (viewDiagonalLength + c.dy);
    ui.Gradient gradient;
    if (initPosition == POSITION_STYLE.TOP_RIGHT) {
      left = (c.dx - lightOffset);
      right = (c.dx + minDisToControlPoint + deepOffset);
    } else {
      right = (c.dx - minDisToControlPoint - deepOffset);
      left = (c.dx + lightOffset);
    }

    gradient = ui.Gradient.linear(
      Offset(left, top),
      Offset(right, top),
      gradientColors,
    );
    paintShadow..shader = gradient;
    this.newPicRecorder();
    canvasBitMap
      ..clipPath(path)
      ..translate(c.dx, c.dy)
      ..rotate(atan2(e.dx - f.dx, h.dy - f.dy))
      ..translate(-c.dx, -c.dy)
      ..drawRect(Rect.fromLTRB(left, top, right, bottom), paintShadow);
    canvas.drawPicture(picRecorder.endRecording());
  }

  /// Path A
  Path getPathA() {
    switch (initPosition) {
      case POSITION_STYLE.TOP_RIGHT:
        return getPathAByTopRight();
        break;
      default:
    }
    return getPathAByBottomRight();
  }

  Path _getDefaultPath() {
    pathB.reset();
    pathB.lineTo(0, viewSize.height); //移动到左下角
    pathB.lineTo(viewSize.width, viewSize.height); //移动到右下角
    pathB.lineTo(viewSize.width, 0); //移动到右上角
    pathB.close(); //闭合区域
    return pathB;
  }

  // 右下角翻页
  Path getPathAByBottomRight() {
    pathA
      ..reset()
      ..lineTo(0, viewSize.height) //移动到左下角
      ..lineTo(c.dx, c.dy)
      ..quadraticBezierTo(e.dx, e.dy, b.dx, b.dy) // 第一条曲线
      ..lineTo(a.dx, a.dy)
      ..lineTo(k.dx, k.dy)
      ..quadraticBezierTo(h.dx, h.dy, j.dx, j.dy) // 第二条曲线
      ..lineTo(viewSize.width, 0)
      ..close();
    return pathA;
  }

  // 右上角翻页
  Path getPathAByTopRight() {
    pathA
      ..reset()
      ..lineTo(c.dx, c.dy) //移动到c点
      ..quadraticBezierTo(e.dx, e.dy, b.dx, b.dy) //从c到b画贝塞尔曲线，控制点为e
      ..lineTo(a.dx, a.dy) //移动到a点
      ..lineTo(k.dx, k.dy) //移动到k点
      ..quadraticBezierTo(h.dx, h.dy, j.dx, j.dy) //从k到j画贝塞尔曲线，控制点为h
      ..lineTo(viewSize.width, viewSize.height) //移动到右下角
      ..lineTo(0, viewSize.height) //移动到左下角
      ..close();
    return pathA;
  }

  Path getPathB() {
    pathB
      ..reset()
      ..lineTo(0, viewSize.height) //移动到左下角
      ..lineTo(viewSize.width, viewSize.height) //移动到右下角
      ..lineTo(viewSize.width, 0) //移动到右上角
      ..close(); //闭合区域
    Path pAB = Path.combine(PathOperation.union, getPathA(), getPathC());
    pathB = Path.combine(PathOperation.reverseDifference, pAB, pathB);
    return pathB;
  }

  Path getPathC() {
    pathC
      ..reset()
      ..moveTo(i.dx, i.dy)
      ..lineTo(d.dx, d.dy)
      ..lineTo(b.dx, b.dy)
      ..lineTo(a.dx, a.dy)
      ..lineTo(k.dx, k.dy)
      ..close();
    pathC = Path.combine(PathOperation.difference, pathC, getPathA());
    return pathC;
  }

  num _getDistance(Offset pointA, Offset pointB) {
    num x = pointA.dx - pointB.dx;
    num y = pointA.dy - pointB.dy;

    var first = x.abs();
    var second = y.abs();

    if (y > x) {
      first = y.abs();
      second = x.abs();
    }

    if (first == 0.0) {
      return second;
    }

    final t = second / first;
    return first * sqrt(1 + t * t);
  }

  /// 计算两线段相交点坐标
  /// @param lineOne
  /// @param lineTwo
  /// @return 返回该点 [Offset]
  ///
  Offset getIntersectionPoint(LineOffset lineOne, LineOffset lineTwo) {
    double x1, y1, x2, y2, x3, y3, x4, y4;
    // line one
    x1 = lineOne.pointOne.dx;
    y1 = lineOne.pointOne.dy;
    x2 = lineOne.pointTwo.dx;
    y2 = lineOne.pointTwo.dy;
    // line two
    x3 = lineTwo.pointOne.dx;
    y3 = lineTwo.pointOne.dy;
    x4 = lineTwo.pointTwo.dx;
    y4 = lineTwo.pointTwo.dy;

    double dx =
        ((x1 - x2) * (x3 * y4 - x4 * y3) - (x3 - x4) * (x1 * y2 - x2 * y1)) /
            ((x3 - x4) * (y1 - y2) - (x1 - x2) * (y3 - y4));
    double dy =
        ((y1 - y2) * (x3 * y4 - x4 * y3) - (x1 * y2 - x2 * y1) * (y3 - y4)) /
            ((y1 - y2) * (x3 - x4) - (x1 - x2) * (y3 - y4));

    return Offset(dx, dy);
  }

  /// 计算所有位置
  void calcAllPioints() {
    g = Offset((f.dx + a.dx) / 2, (f.dy + a.dy) / 2);
    e = Offset(g.dx - pow(f.dy - g.dy, 2) / (f.dx - g.dx), f.dy); // 证明过程见图示
    h = Offset(f.dx, g.dy - pow(f.dx - g.dx, 2) / (f.dy - g.dy)); // 有e同理可证得到点
    c = Offset(e.dx - (f.dx - e.dx) / 2, f.dy); // 选择等分点
    j = Offset(f.dx, h.dy - (f.dy - h.dy) / 2);
    b = getIntersectionPoint(LineOffset(a, e), LineOffset(c, j));
    k = getIntersectionPoint(LineOffset(a, h), LineOffset(c, j));
    d = Offset((c.dx + 2 * e.dx + b.dx) / 4,
        (c.dy + 2 * e.dy + b.dy) / 4); // 设置贝塞尔曲线点d
    i = Offset((j.dx + 2 * h.dx + k.dx) / 4,
        (j.dy + 2 * h.dy + k.dy) / 4); // 设置贝塞尔曲线点i
  }
}

class LineOffset {
  LineOffset(this.pointOne, this.pointTwo);
  final Offset pointOne;
  final Offset pointTwo;
}
