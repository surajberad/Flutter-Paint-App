import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class DrawingArea {
  Offset point;
  Paint areaPaint;

  DrawingArea({this.point, this.areaPaint});
}

class ListofList {
  List<Offset> list;
  Paint areaPaint;

  ListofList({this.list, this.areaPaint});
}

List<ListofList> list = [];
List<ListofList> drawingArea(List<Offset> offset, Paint areaPaint) {
  List<Offset> newList2 = [];

  for (int i = 0; i < offset.length; i++) {
    Offset of = offset[i];
    newList2.add(of);
  }

  list.add(ListofList(list: newList2, areaPaint: areaPaint));
  return list;
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Offset> offset = [];
  List<ListofList> newList = [];
  List<ListofList> undoHistory = [];
  List<DrawingArea> points = [];
  Color selectedColor;
  double strokeWidth;
  int i = 2, repainter = 0, undo = 0;
  BlendMode blend = BlendMode.srcOver;
  Icon iconChange = Icon(Icons.brush);

  @override
  void initState() {
    super.initState();
    selectedColor = Colors.black;
    strokeWidth = 2.0;
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;

    void selectColor() {
      showDialog(
        context: context,
        child: AlertDialog(
          title: const Text('Color Chooser'),
          content: SingleChildScrollView(
            child: BlockPicker(
              pickerColor: selectedColor,
              onColorChanged: (color) {
                this.setState(() {
                  selectedColor = color;
                });
              },
            ),
          ),
          actions: <Widget>[
            FlatButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("Close"))
          ],
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                  Color.fromRGBO(138, 35, 135, 1.0),
                  Color.fromRGBO(233, 64, 87, 1.0),
                  Color.fromRGBO(242, 113, 33, 1.0),
                ])),
          ),
          Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    width: width * 0.95,
                    height: height * 0.80,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(20.0)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.4),
                            blurRadius: 5.0,
                            spreadRadius: 1.0,
                          )
                        ]),
                    child: GestureDetector(
                      onPanDown: (details) {
                        this.setState(() {
                          offset.add(details.localPosition);
                          repainter++;

                          points.add(DrawingArea(
                              point: details.localPosition,
                              areaPaint: Paint()
                                ..strokeCap = StrokeCap.round
                                ..isAntiAlias = true
                                ..color = selectedColor
                                ..blendMode = blend
                                ..strokeWidth = strokeWidth));
                        });
                      },
                      onPanUpdate: (details) {
                        this.setState(() {
                          offset.add(details.localPosition);
                          repainter++;

                          points.add(DrawingArea(
                              point: details.localPosition,
                              areaPaint: Paint()
                                ..strokeCap = StrokeCap.round
                                ..isAntiAlias = true
                                ..color = selectedColor
                                ..blendMode = blend
                                ..strokeWidth = strokeWidth));
                        });
                      },
                      onPanEnd: (details) {
                        this.setState(() {
                          repainter--;
                          Paint paint = Paint()
                            ..strokeCap = StrokeCap.round
                            ..isAntiAlias = true
                            ..color = selectedColor
                            ..strokeWidth = strokeWidth
                            ..blendMode = blend;

                          offset.add(null);

                          newList = drawingArea(offset, paint);
                          offset.clear();
                          points.clear();
                        });
                      },
                      child: Stack(children: <Widget>[
                        SizedBox.expand(
                          child: ClipRRect(
                            borderRadius:
                                BorderRadius.all(Radius.circular(20.0)),
                            child: CustomPaint(
                              painter: MyCustomPainter(
                                  newList: newList, repainter: repainter),
                            ),
                          ),
                        ),
                        SizedBox.expand(
                            child: ClipRRect(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20.0)),
                                child: CustomPaint(
                                  painter: MyCustomPainter2(points: points),
                                )))
                      ]),
                    ),
                  ),
                ),
                Container(
                  width: width * 0.95,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(20.0))),
                  child: Column(
                    children: [
                      Row(
                        children: <Widget>[
                          IconButton(
                              icon: Icon(
                                Icons.color_lens,
                                color: selectedColor,
                              ),
                              onPressed: () {
                                selectColor();
                              }),
                          IconButton(
                              icon: iconChange,
                              onPressed: () {
                                this.setState(() {
                                  if (i % 2 == 0) {
                                    blend = BlendMode.clear;
                                    iconChange = Icon(Icons.album);

                                    print(i);
                                  } else {
                                    blend = BlendMode.srcOver;
                                    iconChange = Icon(Icons.brush);
                                  }
                                  i++;
                                });
                              }),
                          Ink(
                            decoration: const ShapeDecoration(
                              color: Colors.lightBlue,
                              shape: CircleBorder(),
                            ),
                            child: IconButton(
                                icon: Icon(Icons.layers_clear),
                                color: Colors.red,
                                enableFeedback: true,
                                focusColor: Colors.amber,
                                onPressed: () {
                                  this.setState(() {
                                    newList.clear();
                                    undoHistory.clear();
                                  });
                                }),
                          ),
                          IconButton(
                              icon: Icon(Icons.undo),
                              onPressed: () {
                                this.setState(() {
                                  if (newList.isNotEmpty) {
                                    undoHistory.add(newList.last);
                                    newList.removeLast();
                                    undo++;
                                  }
                                });
                              }),
                          IconButton(
                              icon: Icon(Icons.redo),
                              onPressed: () {
                                this.setState(() {
                                  if (undo > 0) {
                                    if (undoHistory.isNotEmpty) {
                                      newList.add(undoHistory.last);
                                      undoHistory.removeLast();
                                      undo--;
                                      if (undo == 0) {
                                        undoHistory.clear();
                                      }
                                    }
                                  }
                                });
                              })
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Slider(
                              min: 1.0,
                              max: 50.0,
                              label: "Stroke $strokeWidth",
                              activeColor: selectedColor,
                              value: strokeWidth,
                              onChanged: (double value) {
                                this.setState(() {
                                  strokeWidth = value;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MyCustomPainter extends CustomPainter {
  List<ListofList> newList;
  int repainter;

  MyCustomPainter({@required this.newList, this.repainter});

  @override
  void paint(Canvas canvas, Size size) {
    Paint background = Paint()..color = Colors.white;
    Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);

    canvas.drawRect(rect, background);
    canvas.clipRect(rect);

    canvas.saveLayer(Offset.zero & size, Paint());
    for (int l = 0; l < newList.length; l++) {
      for (int x = 0; x < newList[l].list.length; x++) {
        if (newList[l].list[x] != null && newList[l].list[x + 1] != null) {
          canvas.drawLine(
              newList[l].list[x], newList[l].list[x + 1], newList[l].areaPaint);
        } else if (newList[l].list[x] != null &&
            newList[l].list[x + 1] == null) {
          canvas.drawPoints(
              PointMode.points, [newList[l].list[x]], newList[l].areaPaint);
        }
      }
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(MyCustomPainter oldDelegate) {
    return false;
  }
}

class MyCustomPainter2 extends CustomPainter {
  List<DrawingArea> points;

  MyCustomPainter2({@required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);

    canvas.clipRect(rect);
    canvas.saveLayer(Offset.zero & size, Paint());
    for (int x = 0; x < points.length - 1; x++) {
      if (points[x] != null && points[x + 1] != null) {
        canvas.drawLine(
            points[x].point, points[x + 1].point, points[x].areaPaint);
      } else if (points[x] != null && points[x + 1] == null) {
        canvas.drawPoints(
            PointMode.points, [points[x].point], points[x].areaPaint);
      }
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(MyCustomPainter2 oldDelegate) {
    return false;
  }
}
