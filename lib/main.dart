import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '雨檬学字',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: MyStatefulWidget(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyStatefulWidget extends StatefulWidget {
  // 可比较的数字格式,默认4个
  final mCount = 4;

  // 比较数字是什么,现在只比较0至10即可,后续再进行扩展
  final mNumberMax = 10;

  MyStatefulWidget({Key key}) : super(key: key);

  @override
  _MyStatefulWidgetState createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  // 记录在哪个位置
  int mTargetPosition = -1;

  // 当前数字
  int mCurrentNumber = 0;

  // 当前的数字对象
  TargetObject mCurrentTargetObject;

  // 目标数组
  List<TargetObject> mTargetObjects;

  // 是否移动到target
  bool mTargetSuccess = false;

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIOverlays([]);
    changeValues(0);
    super.initState();
  }

  void changeValues(int value) {
    mTargetSuccess = false;
    mCurrentNumber = value;
    mTargetObjects = new List();
    var random = Random();
    mTargetPosition = random.nextInt(widget.mCount);
    mCurrentTargetObject = TargetObject(
      name: "$mCurrentNumber",
      backgroundColor: Colors.red,
    );
    // 生成 mCount-1 个不同数字,因为当前数字已经知道了,所以只需要知道其他随便几个数字即可
    // 循环产生数字,直到数组长度达到mCount-1
    // 为什么要减一呢?因为目标数字已经存在了
    while (mTargetObjects.length != widget.mCount - 1) {
      int position = random.nextInt(widget.mNumberMax);
      if (position == mCurrentNumber ||
          mTargetObjects.any((obj) {
            return int.parse(obj.name) == position;
          })) {
        // 如果产生的数字和target数字相同,则继续
        continue;
      }
      mTargetObjects.add(TargetObject(
        name: "$position",
      ));
    }
    // 把目标结果进行设置
    mTargetObjects.insert(
        mTargetPosition,
        TargetObject(
          name: "$mCurrentNumber",
          onAccept: () {
            setState(() {
              mTargetSuccess = true;
            });
          },
        ));
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.symmetric(
          vertical: 10,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            mTargetSuccess
                ? Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        GestureDetector(
                          child: Text(
                            "👍",
                            style: TextStyle(
                              fontSize: MediaQuery.of(context).size.width / 6,
                            ),
                          ),
                          onTap: () {
                            _reset = true;
                            changeValues(mCurrentNumber == widget.mNumberMax
                                ? 0
                                : ++mCurrentNumber);
                            setState(() {});
                          },
                        ),
                        Text(
                          "点击小手进行下一关",
                          style: TextStyle(
                            fontSize: 28,
                            color: Colors.blueGrey,
                          ),
                        ),
                      ],
                    ),
                    flex: 1,
                  )
                : Draggable(
                    child: mCurrentTargetObject,
                    feedback: mCurrentTargetObject,
                    childWhenDragging: Container(),
                    data: mCurrentNumber.toString(),
                  ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                FloatingActionButton(
                  onPressed: _showSelect,
                  child: Icon(
                    Icons.local_airport,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: mTargetObjects.map((targetObject) {
                return targetObject;
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Future _showSelect() async {
    var result = await showModalBottomSheet(
        context: context,
        builder: (ctx) {
          return Center(
            child: Wrap(
              children:
                  List<Widget>.generate(widget.mNumberMax + 1, (position) {
                return RaisedButton(
                  onPressed: () {
                    Navigator.of(ctx).pop(position);
                  },
                  child: Text(
                    "$position",
                    style: TextStyle(
                      fontSize: 28,
                    ),
                  ),
                  color: position == mCurrentNumber ? Colors.green : Theme.of(context).buttonColor,
                  textColor: position == mCurrentNumber ? Colors.white : Colors.black,
                );
              }),
              spacing: 20,
              runSpacing: 10,
            ),
          );
        });
    if (result != null && result != mCurrentNumber) {
      mCurrentNumber = result;
      changeValues(mCurrentNumber);
      setState(() {});
    }
  }
}

var _reset = false;

class TargetObject extends StatefulWidget {
  final String name;
  final Color backgroundColor;
  final VoidCallback onAccept;
  final Color acceptColor;

  const TargetObject(
      {Key key,
      @required this.name,
      this.backgroundColor = Colors.green,
      this.acceptColor = Colors.red,
      this.onAccept})
      : super(key: key);

  @override
  _TargetObjectState createState() => _TargetObjectState();

  @override
  String toStringShort() {
    return name.toString();
  }
}

class _TargetObjectState extends State<TargetObject> {
  bool accept = false;

  _TargetObjectState() {
    debugPrint("------------ 创建了-------");
  }

  @override
  Widget build(BuildContext context) {
    if (_reset) {
      accept = false;
    }
    var size = MediaQuery.of(context).size;
    var widthAndHeight = size.width / 8.0;
    return DragTarget(
      builder: (BuildContext context, List<String> candidateData,
          List<dynamic> rejectedData) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(
              Radius.circular(8),
            ),
            color: accept ? widget.acceptColor : widget.backgroundColor,
          ),
          alignment: Alignment.center,
          width: widthAndHeight,
          height: widthAndHeight,
          child: SizedBox.expand(
            child: FittedBox(
              child: Text(
                widget.name,
                style: TextStyle(
                  color: Colors.white,
                  decoration: TextDecoration.none,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
          ),
        );
      },
      onAccept: (data) {
        if (data == widget.name && widget.onAccept != null) {
          setState(() {
            accept = true;
            _reset = false;
          });
          widget.onAccept();
        }
      },
    );
  }
}
