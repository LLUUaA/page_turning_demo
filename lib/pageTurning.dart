import 'dart:ui' as ui;
import 'dart:math' show min, max, atan2, sqrt, pow;

import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as v;
import 'package:flutter/services.dart';

class PageTurningDemo1 extends StatefulWidget {
  @override
  _PageTurningDemo1 createState() => _PageTurningDemo1();
}

class _PageTurningDemo1 extends State<PageTurningDemo1> {
  _PageTurningDemo1() {
    SystemChrome.setEnabledSystemUIOverlays([]);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.black,
      systemNavigationBarColor: Colors.black,
      systemNavigationBarDividerColor: Colors.black,
    ));
  }

  static Offset offset = Offset.zero; // move offset

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return GestureDetector(
      onPanDown: (DragDownDetails _) {
        this.handlePanDown(_, size);
      },
      onPanUpdate: (DragUpdateDetails _) {
        setState(() {
          offset = _.globalPosition;
        });
      },
      onPanEnd: (DragEndDetails _) {
        setState(() {
          offset = Offset.zero;
        });
      },
      child: CustomPaint(
        size: size,
        painter: MyPageTurn(offset: offset),
      ),
    );
  }

  void handlePanDown(DragDownDetails _, Size size) {
    double boxW = size.width / 3;
    double boxH = size.height / 3;
    double dx = _.globalPosition.dx;
    double dy = _.globalPosition.dy;
    if (dy > 2 * boxH && dx > boxW) {
      MyPageTurn.initPosition = POSITION_STYLE.BOTTOM_RIGHT;
    } else if (dy < boxH && dx > boxW) {
      MyPageTurn.initPosition = POSITION_STYLE.TOP_RIGHT;
    } else if (dy > boxH && dy < 2 * boxH && dx > boxW && dx < 2 * boxW) {
      MyPageTurn.initPosition = POSITION_STYLE.MID;
    } else if (dy > boxH && dy < 2 * boxH && dx > 2 * boxW) {
      MyPageTurn.initPosition = POSITION_STYLE.RIGHT;
    } else {
      MyPageTurn.initPosition = POSITION_STYLE.LEFT;
    }
    print('click POSITION_STYLE =${MyPageTurn.initPosition}');
  }
}

enum POSITION_STYLE { TOP_RIGHT, BOTTOM_RIGHT, LEFT, RIGHT, MID }

class MyPageTurn extends CustomPainter {
  MyPageTurn({
    @required this.offset,
  }) {
    assert(this.offset != null);
    // Path
    pathA = new Path();
    pathB = new Path();
    pathC = new Path();
    // paint
    paintA = new Paint()
      ..isAntiAlias = true
      ..color = Color(0x77cdb175);
    paintB = new Paint()
      ..blendMode = BlendMode.dstATop
      ..isAntiAlias = true
      ..color = Color(0x77cdb175);
    paintC = new Paint()
      ..color = Color(0x77cdb175)
      ..isAntiAlias = true
      ..blendMode = BlendMode.dstATop;
    paintBg = new Paint()..color = Colors.orangeAccent;
    // canvasBitMap
    this.newPicRecorder();
  }

  final Offset offset;

  static Offset a, f, g, e, h, c, j, b, k, d, i; // points
  // static Canvas canvas;
  static Size size;
  static POSITION_STYLE initPosition;

  // canvas
  static Canvas canvasBitMap;
  static ui.PictureRecorder picRecorder;

  /// path
  static Path pathA;
  static Path pathB;
  static Path pathC;

  /// paint
  static Paint paintA;
  static Paint paintB;
  static Paint paintC;
  static Paint paintBg;

  /// dis
  ///A区域左阴影矩形短边长度参考值
  double lPathAShadowDis = 0;

  /// A区域右阴影矩形短边长度参考值
  double rPathAShadowDis = 0;

  // repaint
  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    /// 点击中间区域不绘画
    return POSITION_STYLE.MID != initPosition;
  }

  /// 计算c点有没有超出区域
  bool calcPointC() {
    // reset
    if (offset == Offset.zero || (-1 == offset.dx && -1 == offset.dy)) {
      a = Offset(-1, -1);
      initPosition = POSITION_STYLE.TOP_RIGHT;
      f = Offset(size.width, 0);
      return true;
    }

    a = offset;
    if (initPosition == POSITION_STYLE.BOTTOM_RIGHT) {
      f = Offset(size.width, size.height);
    } else if (initPosition == POSITION_STYLE.TOP_RIGHT) {
      f = Offset(size.width, 0);
    } else {
      a = Offset(offset.dx, size.height - 1);
      f = Offset(size.width, size.height);
    }

    g = Offset((f.dx + a.dx) / 2, (f.dy + a.dy) / 2);
    e = Offset(g.dx - pow(f.dy - g.dy, 2) / (f.dx - g.dx), f.dy);
    c = Offset(e.dx - (f.dx - e.dx) / 2, f.dy);

    if (c.dx < 1) {
      double w0 = size.width - c.dx;
      double w1 = (f.dx - a.dx).abs();
      double w2 = size.width * w1 / w0;
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
    MyPageTurn.size = size;

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
    pb.pushStyle(ui.TextStyle(color: color ?? Colors.black87, fontSize: 16.0));
    pb.addText(text);
    ui.ParagraphConstraints pc = ui.ParagraphConstraints(width: width);

    ///这里需要先layout, 后面才能获取到文字高度
    ui.Paragraph paragraph = pb.build()..layout(pc);
    canvas.drawParagraph(paragraph, offset);
  }

  void newPicRecorder() {
    picRecorder = ui.PictureRecorder();
    canvasBitMap = Canvas(picRecorder);
  }

  void drawPathA(Canvas canvas) {
    canvas.save();
    this.newPicRecorder();
    canvasBitMap.drawPath(getPathA(), paintA);
    _drawText(canvasBitMap, "这是阅读页内容AAA", Colors.black, size.width,
        Offset(size.width / 2, size.height - 100),
        fontSize: 16.0);

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
    canvasBitMap.drawPath(getPathB(), paintB);
    _drawText(canvasBitMap, "这是下一页内容BBB", Colors.black, size.width,
        Offset(size.width / 2, size.height - 100),
        fontSize: 16.0);
    ui.Picture pic = picRecorder.endRecording();
    canvas.clipPath(getPathB());
    canvas.drawPicture(pic);
    this.drawPathBShadow(canvas);
    canvas.restore();
  }

  void drawPathC(Canvas canvas) {
    Path pathC = getPathC();

    /// 生成背面文字
    canvas.drawPath(pathC, paintC);
    canvas.save();
    this.newPicRecorder();
    paintC..color = Color(0x66cdb175);
    canvasBitMap.drawPath(_getDefaultPath(), paintC);
    _drawText(
      canvasBitMap,
      "这是阅读页内容AAA",
      Colors.black26,
      size.width,
      Offset(size.width / 2, size.height - 100),
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
      Colors.black38,
    ];

    double left;
    double right;
    double top = e.dy;
    double bottom = (e.dy + size.height);
    ui.Gradient gradient;
    if (initPosition == POSITION_STYLE.TOP_RIGHT) {
      left = (e.dx - lPathAShadowDis);
      right = (e.dx);
      gradient = ui.Gradient.linear(
          Offset(left, top), Offset(right, top), gradientColors);
    } else {
      left = (e.dx);
      right = (e.dx + lPathAShadowDis);

      gradient = ui.Gradient.linear(
          Offset(right, top), Offset(left, top), gradientColors);
    }
    Paint paint = new Paint()..shader = gradient;

    //裁剪出我们需要的区域
    Path mPath = new Path();
    mPath.moveTo(a.dx - max(rPathAShadowDis, lPathAShadowDis), a.dy);
    mPath.lineTo(d.dx, d.dy);
    mPath.lineTo(e.dx, e.dy);
    mPath.lineTo(a.dx, a.dy);
    mPath.close();
    var pn = Path.combine(PathOperation.intersect, pathA, mPath);
    canvas.clipPath(pn);

    canvas.translate(e.dx, e.dy);
    canvas.rotate(atan2(e.dx - a.dx, a.dy - e.dy));
    canvas.translate(-e.dx, -e.dy);
    var rect = Rect.fromLTRB(left, top, right, bottom);
    canvas.drawRect(rect, paint);
  }

  void drawPathARightShadow(Canvas canvas, Path pathA) {
    canvas.restore();
    canvas.save();
    var gradientColors = [Colors.black38, Colors.transparent];

    double viewDiagonalLength =
        _getDistance(Offset.zero, Offset(size.width, size.height)); //view对角线长度
    double left = h.dx;
    double right = (h.dx + viewDiagonalLength * 100);
    double top;
    double bottom;

    ui.Gradient gradient;
    if (initPosition == POSITION_STYLE.TOP_RIGHT) {
      top = (h.dy - rPathAShadowDis);
      bottom = h.dy;
      gradient = ui.Gradient.linear(
          Offset(left, bottom), Offset(left, top), gradientColors);
    } else {
      top = h.dy;
      bottom = (h.dy + rPathAShadowDis);

      gradient = ui.Gradient.linear(
          Offset(left, top), Offset(left, bottom), gradientColors);
    }
    Paint paint = new Paint()..shader = gradient;

    Path mPath = new Path();
    mPath.moveTo(a.dx - max(rPathAShadowDis, lPathAShadowDis), a.dy);
    mPath.lineTo(h.dx, h.dy);
    mPath.lineTo(a.dx, a.dy);
    mPath.close();
    var pn = Path.combine(PathOperation.intersect, pathA, mPath);
    canvas.clipPath(pn);

    canvas.translate(h.dx, h.dy);
    canvas.rotate(atan2(a.dy - h.dy, a.dx - h.dx));
    canvas.translate(-h.dx, -h.dy);
    var rect = Rect.fromLTRB(left, top, right, bottom);
    canvas.drawRect(rect, paint);
  }

  void drawPathBShadow(Canvas canvas) {
    List<Color> gradientColors = [
      Color(0xff111111),
      Color(0x00333333),
    ]; //渐变颜色数组
    int elevation = 5;
    int deepOffset = -15; //深色端的偏移值
    int lightOffset = 5; //浅色端的偏移值
    double aTof = _getDistance(a, f); //a到f的距离
    double viewDiagonalLength =
        _getDistance(Offset.zero, Offset(size.width, size.height)); //view对角线长度

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

      gradient = ui.Gradient.linear(
          Offset(left, top), Offset(right, top), gradientColors);
    } else {
      left = (c.dx - aTof / elevation - lightOffset); //c点位于左下角
      right = (c.dx + deepOffset);
      gradient = ui.Gradient.linear(
          Offset(right, top), Offset(left, top), gradientColors);
    }

    Paint paint = new Paint()..shader = gradient;

    canvas.translate(c.dx, c.dy);
    canvas.rotate(atan2(e.dx - f.dx, h.dy - f.dy));
    canvas.translate(-c.dx, -c.dy);
    var rect = Rect.fromLTRB(left, top, right, bottom);
    canvas.drawRect(rect, paint);
  }

// 阴影B区域
  void drawPathCShadow(Canvas canvas, Path path) {
    canvas.restore();
    canvas.save();
    List<Color> gradientColors = [
      Color(0x00333333),
      Color(0xff111111)
    ]; //渐变颜色数组

    int deepOffset = 26; //深色端的偏移值
    int lightOffset = -10; //浅色端的偏移值
    num viewDiagonalLength =
        _getDistance(Offset.zero, Offset(size.width, size.height)); //view对角线长度
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

      gradient = ui.Gradient.linear(
          Offset(left, top), Offset(right, top), gradientColors);
    } else {
      left = (c.dx - minDisToControlPoint - deepOffset);
      right = (c.dx + lightOffset);
      gradient = ui.Gradient.linear(
          Offset(right, top), Offset(left, top), gradientColors);
    }
    Paint paint = new Paint()
      ..isAntiAlias = true
      ..shader = gradient;
    canvas.clipPath(path);
    canvas.translate(c.dx, c.dy);
    canvas.rotate(atan2(e.dx - f.dx, h.dy - f.dy));
    canvas.translate(-c.dx, -c.dy);
    Rect rect = Rect.fromLTRB(left, top, right, bottom);
    canvas.drawRect(rect, paint);
  }

// 阴影right
  Path drawShadowRight() {
    pathB
      ..reset()
      ..moveTo(e.dx, e.dy)
      ..lineTo(h.dx, h.dy)
      ..close();
    return pathB;
  }

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
    pathB.lineTo(0, size.height); //移动到左下角
    pathB.lineTo(size.width, size.height); //移动到右下角
    pathB.lineTo(size.width, 0); //移动到右上角
    pathB.close(); //闭合区域
    return pathB;
  }

  // 右下角翻页
  Path getPathAByBottomRight() {
    pathA
      ..reset()
      ..lineTo(0, size.height) //移动到左下角
      ..lineTo(c.dx, c.dy)
      ..quadraticBezierTo(e.dx, e.dy, b.dx, b.dy) // 第一条曲线
      ..lineTo(a.dx, a.dy)
      ..lineTo(k.dx, k.dy)
      ..quadraticBezierTo(h.dx, h.dy, j.dx, j.dy) // 第二条曲线
      ..lineTo(size.width, 0)
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
      ..lineTo(size.width, size.height) //移动到右下角
      ..lineTo(0, size.height) //移动到左下角
      ..close();
    return pathA;
  }

  Path getPathB() {
    pathB
      ..reset()
      ..lineTo(0, size.height) //移动到左下角
      ..lineTo(size.width, size.height) //移动到右下角
      ..lineTo(size.width, 0) //移动到右上角
      ..close(); //闭合区域
    Path pAB = Path.combine(PathOperation.union, getPathA(), getPathC());
    Path pn = Path.combine(PathOperation.reverseDifference, pAB, pathB);
    return pn;
  }

  Path getPathC() {
    pathC
      ..reset()
      ..moveTo(i.dx, i.dy)
      ..lineTo(d.dx, d.dy)
      ..lineTo(b.dx, b.dy)
      ..lineTo(a.dx, a.dy)
      ..lineTo(k.dx, k.dy);
    pathC.close();
    return Path.combine(PathOperation.difference, pathC, getPathA());
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

    // A shawow
    // double lA = a.dy - e.dy;
    // double lB = e.dx - a.dx;
    // double lC = a.dx * e.dy - e.dx * a.dy;
    // lPathAShadowDis =
    //     ((lA * d.dx + lB * d.dy + lC) / (_getDistance(a, e)).abs());
    lPathAShadowDis = 12.0;

    // double rA = a.dy - h.dy;
    // double rB = h.dx - a.dx;
    // double rC = a.dx * h.dy - h.dx * a.dy;
    // rPathAShadowDis = ((rA * i.dx + rB * i.dy + rC) / _getDistance(a, h)).abs();
    rPathAShadowDis = 12.0;
  }
}

class LineOffset {
  LineOffset(this.pointOne, this.pointTwo);
  final Offset pointOne;
  final Offset pointTwo;
}

class MyPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    TextPainter textPainter = TextPainter(
        text: TextSpan(
          text:
              "三日前，他帮宗门下山取灵药，却被敌对宗门的高手偷袭，他拼死守护灵药，九死一生回到宗门，丹田却被打碎，成为一个不折不扣的废物。",
          style: TextStyle(color: Colors.black, fontSize: 18.0),
        ),
        textDirection: TextDirection.ltr)
      ..layout(maxWidth: size.width, minWidth: 1)
      ..paint(canvas, Offset(0.0, size.height - 72));

    /// textPainter.size 绘制此文本所需的空间量。
    ///仅在调用[layout]后有效。
    print('textPainter.size ${textPainter.size}');
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class MyChessPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    double eWidth = size.width / 15;
    double eHeight = size.height / 15;

    //画棋盘背景
    var paint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.fill //填充
      ..color = Color(0x77cdb175); //背景为纸黄色
    canvas.drawRect(Offset.zero & size, paint);

    //画棋盘网格
    paint
      ..style = PaintingStyle.stroke //线
      ..color = Colors.black87
      ..strokeWidth = 1.0;

    for (int i = 0; i <= 15; ++i) {
      double dy = eHeight * i;
      canvas.drawLine(Offset(0, dy), Offset(size.width, dy), paint);
    }

    for (int i = 0; i <= 15; ++i) {
      double dx = eWidth * i;
      canvas.drawLine(Offset(dx, 0), Offset(dx, size.height), paint);
    }

    //画一个黑子
    paint
      ..style = PaintingStyle.fill
      ..color = Colors.black;
    canvas.drawCircle(
      Offset(size.width / 2 - eWidth / 2, size.height / 2 - eHeight / 2),
      min(eWidth / 2, eHeight / 2) - 2,
      paint,
    );

    //画一个白子
    paint.color = Colors.white;
    canvas.drawCircle(
      Offset(size.width / 2 + eWidth / 2, size.height / 2 - eHeight / 2),
      min(eWidth / 2, eHeight / 2) - 2,
      paint,
    );
  }

  //在实际场景中正确利用此回调可以避免重绘开销，本示例我们简单的返回true
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
