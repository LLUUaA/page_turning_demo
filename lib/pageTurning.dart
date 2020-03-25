import 'dart:ui';
import 'dart:math';

import 'package:flutter/material.dart';
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

  static Offset offset;
  static Offset a, b, c, d, e, f, g, h, i, j, k; // 各位置见原理图

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    print('MediaQuery size ${size}');
    return GestureDetector(
      onPanDown: (DragDownDetails _) {
        offset = Offset(0, 0);
      },
      onPanUpdate: (DragUpdateDetails _) {
        print('onPanDown delta= ${_.delta}');
        offset += _.delta;
        setState(() {
          offset = _.globalPosition;
        });
      },
      onPanEnd: (DragEndDetails _) {
        print('onPanEnd velocity= ${_.velocity}');

        setState(() {
          offset = Offset(0, 0);
        });
      },
      child: Container(
        width: size.width,
        height: size.height,
        decoration: BoxDecoration(
          color: Color(0x77cdb175),
        ),
        child: Stack(
          children: <Widget>[
            // CustomPaint(
            //   size: size,
            //   painter: MyPainter(),
            // ),
            CustomPaint(
              size: size,
              painter: MyPageTurn(offset: offset),
            ),
          ],
        ),
      ),
    );
  }
}

class MyPageTurn extends CustomPainter {
  final Offset offset;
  MyPageTurn({@required this.offset});

  static Offset a, f, g, e, h, c, j, b, k, d, i; // points

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = new Paint()
      ..color = Colors.greenAccent
      ..blendMode = BlendMode.dstATop
      ..isAntiAlias = true;

    a = offset ?? Offset.zero;
    f = Offset(size.width, size.height);
    g = Offset((f.dx + a.dx) / 2, (f.dy + a.dy) / 2);
    e = Offset(g.dx - (pow(f.dx, 2) / f.dx - g.dx), f.dy); // 证明过程见图示
    h = Offset(f.dx, g.dy - (pow(f.dy, 2) / f.dy - g.dy)); // 有e同理可证得到点
    c = Offset(e.dx - (f.dx - e.dx) / 2, f.dy); // 选择等分点
    j = Offset(f.dx, h.dy - (f.dy - h.dy) / 2);
    b = getIntersectionPoint(LineOffset(a, e), LineOffset(c, j));
    k = getIntersectionPoint(LineOffset(a, h), LineOffset(c, j));
    d = Offset((c.dx + 2 * e.dx + b.dx) / 4,
        (c.dy + 2 * e.dy + b.dy) / 4); // 设置贝塞尔曲线点d
    i = Offset((j.dx + 2 * h.dx + k.dx) / 4,
        (j.dy + 2 * h.dy + k.dy) / 4); // 设置贝塞尔曲线点i

    canvas.drawPath(drawPathA(size), paint); // draw path
    // paint..color = Colors.blueAccent;
    // canvas.drawPath(drawPathB(size), paint); // draw path
    paint..color = Colors.yellowAccent;
    canvas.drawPath(drawPathC(size), paint); // draw path
  }

  Path drawPathA(Size size) {
    Path path = new Path();
    // 移到移动点 准备划出轮廓
    path.reset();
    path.lineTo(0, size.height); //移动到左下角
    path.lineTo(c.dx, c.dy);
    path.quadraticBezierTo(e.dx, e.dy, b.dx, b.dy); // 第一条曲线
    path.lineTo(a.dx, a.dy);
    path.lineTo(k.dx, k.dy);
    path.quadraticBezierTo(h.dx, h.dy, j.dx, j.dy); // 第二条曲线
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  Path drawPathB(Size size) {
    Path path = new Path();

    return path;
  }

  Path drawPathC(Size size) {
    Path path = new Path();
    path.moveTo(d.dx, d.dy);
    path.lineTo(i.dx, i.dy);
    path.lineTo(k.dx, k.dy);
    path.lineTo(a.dx, a.dy);
    path.moveTo(b.dx, b.dy);
    path.close();
    return path;
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
