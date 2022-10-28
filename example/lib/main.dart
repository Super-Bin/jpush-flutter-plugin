import 'dart:convert';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:jpush_example/jpush_android_model.dart';
import 'package:jpush_flutter/jpush_flutter.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? debugLable = 'Unknown';
  String? rid = '';
  final JPush jpush = new JPush();
  // late JPush jpush;

  @override
  void initState() {
    super.initState();
    initPlatformState();
    // jpush.setBadge(0);
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String? platformVersion;

    try {
      jpush.createNotificationChannel("orderChannelId", "OrderInfo", true);
      jpush.addEventHandler(
          onReceiveNotification: (Map<String, dynamic> message) async {
        print("flutter onReceiveNotification: $message");
        /// android通知栏回调
        /// 测试处理数据
        handleMsg(message);
        setState(() {
          debugLable = "flutter onReceiveNotification: $message";
        });
      }, onOpenNotification: (Map<String, dynamic> message) async {
        print("flutter onOpenNotification: $message");
        setState(() {
          debugLable = "flutter onOpenNotification: $message";
          rid = "flutter onOpenNotification: $message";
        });
      }, onReceiveMessage: (Map<String, dynamic> message) async {
        print("flutter onReceiveMessage: $message");
        setState(() {
          debugLable = "flutter onReceiveMessage: $message";
        });
      }, onReceiveNotificationAuthorization:
              (Map<String, dynamic> message) async {
        print("flutter onReceiveNotificationAuthorization: $message");
        // setState(() {
        //   debugLable = "flutter onReceiveNotificationAuthorization: $message";
        // });
      },onNotifyMessageUnShow:
          (Map<String, dynamic> message) async {
        print("flutter onNotifyMessageUnShow: $message");
        // setState(() {
        //   debugLable = "flutter onNotifyMessageUnShow: $message";
        // });
      });
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    jpush.setAuth(enable: true);
    jpush.setup(
      appKey: "xxxxx", //你自己应用的 AppKey，android不需要
      // appKey: "com.jiguang.jpushexample", //你自己应用的 AppKey
      channel: "developer-default",
      production: false, //android无效
      debug: true, //android有效
    );
    /// 设置美国地区，验证fcm
    jpush.testCountryCode("us");
    jpush.applyPushAuthority(
        new NotificationSettingsIOS(sound: true, alert: true, badge: true));

    // Platform messages may fail, so we use a try/catch PlatformException.
    jpush.getRegistrationID().then((rid) {
      print("flutter get registration id : $rid");
      setState(() {
        // debugLable = "flutter getRegistrationID: $rid";
        this.rid = rid;
      });
    });

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      debugLable = platformVersion;
    });
  }

  /// 处理消息
  /// {alert: 过来数据了吧, extras: {cn.jpush.android.ALERT_TYPE: 7, cn.jpush.android.NOTIFICATION_ID: 512426856, cn.jpush.android.MSG_ID: 18100352286206560, cn.jpush.android.ALERT: 过来数据了吧, cn.jpush.android.EXTRA: {"name":"傻逼"}}, title: flutter推送}
  void handleMsg(Map<String, dynamic> message){
    print("——————————开始处理消息——————————");

    try{
      JpushAndroidModel jpushAndroidModel = JpushAndroidModel.fromJson(message);
      print("转换后的数据 ${jpushAndroidModel.toJson()}");

      Map<String, dynamic>? extraExtra = jsonDecode(message['extras']['cn.jpush.android.EXTRA']);
      print("extraExtra转换后的数据 ${extraExtra.toString()}");
      print("extraExtra转换后的数据 name = ${extraExtra?["name"]}");
      print("extraExtra转换后的数据 order = ${extraExtra?["order"]}");
    }catch (e){
      print("解析数据出问题 $e");
    }

    print("——————————结束处理消息——————————");
  }

// 编写视图
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: const Text('Plugin example app'),
        ),
        body: new Center(
            child: new Column(children: [
              Container(
                margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
                // color: Colors.brown,
                child: Text(this.rid ?? ""),
                width: 350,
                height: 50,
              ),
          Container(
            // margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
            color: Colors.brown,
            child: Text(debugLable ?? "Unknown"),
            width: 350,
            height: 150,
          ),
          new Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new Text(" "),
                new CustomButton(
                    title: "发本地推送",
                    onPressed: () {
                      // 三秒后出发本地推送
                      var fireDate = DateTime.fromMillisecondsSinceEpoch(
                          DateTime.now().millisecondsSinceEpoch + 3000);
                      var localNotification = LocalNotification(
                          id: 234,
                          title: 'fadsfa',
                          buildId: 1,
                          content: 'fdas',
                          fireTime: fireDate,
                          subtitle: 'fasf',
                          badge: 5,
                          extra: {"fa": "0"});
                      jpush
                          .sendLocalNotification(localNotification)
                          .then((res) {
                        setState(() {
                          debugLable = res;
                        });
                      });
                    }),
                new Text(" "),
                new CustomButton(
                    title: "getLaunchAppNotification",
                    onPressed: () {
                      jpush.getLaunchAppNotification().then((map) {
                        print("flutter getLaunchAppNotification:$map");
                        setState(() {
                          debugLable = "getLaunchAppNotification success: $map";
                        });
                      }).catchError((error) {
                        setState(() {
                          debugLable = "getLaunchAppNotification error: $error";
                        });
                      });
                    }),
              ]),
          new Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new Text(" "),
                new CustomButton(
                    title: "setTags",
                    onPressed: () {
                      jpush.setTags(["lala", "haha"]).then((map) {
                        var tags = map['tags'];
                        setState(() {
                          debugLable = "set tags success: $map $tags";
                        });
                      }).catchError((error) {
                        setState(() {
                          debugLable = "set tags error: $error";
                        });
                      });
                    }),
                new Text(" "),
                new CustomButton(
                    title: "addTags",
                    onPressed: () {
                      jpush.addTags(["lala", "haha"]).then((map) {
                        var tags = map['tags'];
                        setState(() {
                          debugLable = "addTags success: $map $tags";
                        });
                      }).catchError((error) {
                        setState(() {
                          debugLable = "addTags error: $error";
                        });
                      });
                    }),
                new Text(" "),
                new CustomButton(
                    title: "deleteTags",
                    onPressed: () {
                      jpush.deleteTags(["lala", "haha"]).then((map) {
                        var tags = map['tags'];
                        setState(() {
                          debugLable = "deleteTags success: $map $tags";
                        });
                      }).catchError((error) {
                        setState(() {
                          debugLable = "deleteTags error: $error";
                        });
                      });
                    }),
              ]),
          new Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new Text(" "),
                new CustomButton(
                    title: "getAllTags",
                    onPressed: () {
                      jpush.getAllTags().then((map) {
                        setState(() {
                          debugLable = "getAllTags success: $map";
                        });
                      }).catchError((error) {
                        setState(() {
                          debugLable = "getAllTags error: $error";
                        });
                      });
                    }),
                new Text(" "),
                new CustomButton(
                    title: "cleanTags",
                    onPressed: () {
                      jpush.cleanTags().then((map) {
                        var tags = map['tags'];
                        setState(() {
                          debugLable = "cleanTags success: $map $tags";
                        });
                      }).catchError((error) {
                        setState(() {
                          debugLable = "cleanTags error: $error";
                        });
                      });
                    }),
              ]),
          new Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new Text(" "),
                new CustomButton(
                    title: "setAlias",
                    onPressed: () {
                      jpush.setAlias("thealias11").then((map) {
                        setState(() {
                          debugLable = "setAlias success: $map";
                        });
                      }).catchError((error) {
                        setState(() {
                          debugLable = "setAlias error: $error";
                        });
                      });
                    }),
                new Text(" "),
                new CustomButton(
                    title: "deleteAlias",
                    onPressed: () {
                      jpush.deleteAlias().then((map) {
                        setState(() {
                          debugLable = "deleteAlias success: $map";
                        });
                      }).catchError((error) {
                        setState(() {
                          debugLable = "deleteAlias error: $error";
                        });
                      });
                    }),
                new Text(" "),
                new CustomButton(
                    title: "getAlias",
                    onPressed: () {
                      jpush.getAlias().then((map) {
                        setState(() {
                          debugLable = "getAlias success: $map";
                        });
                      }).catchError((error) {
                        setState(() {
                          debugLable = "getAlias error: $error";
                        });
                      });
                    }),
              ]),
          new Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Text(" "),
              new CustomButton(
                  title: "stopPush",
                  onPressed: () {
                    jpush.stopPush();
                  }),
              new Text(" "),
              new CustomButton(
                  title: "resumePush",
                  onPressed: () {
                    jpush.resumePush();
                  }),
            ],
          ),
          new Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Text(" "),
              new CustomButton(
                  title: "clearAllNotifications",
                  onPressed: () {
                    jpush.clearAllNotifications();
                  }),
              new Text(" "),
              new CustomButton(
                  title: "setBadge",
                  onPressed: () {
                    jpush.setBadge(66).then((map) {
                      setState(() {
                        debugLable = "setBadge success: $map";
                      });
                    }).catchError((error) {
                      setState(() {
                        debugLable = "setBadge error: $error";
                      });
                    });
                  }),
            ],
          ),
          new Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Text(" "),
              new CustomButton(
                  title: "通知授权是否打开",
                  onPressed: () {
                    jpush.isNotificationEnabled().then((bool value) {
                      setState(() {
                        debugLable = "通知授权是否打开: $value";
                      });
                    }).catchError((onError) {
                      setState(() {
                        debugLable = "通知授权是否打开: ${onError.toString()}";
                      });
                    });
                  }),
              new Text(" "),
              new CustomButton(
                  title: "打开系统设置",
                  onPressed: () {
                    jpush.openSettingsForNotification();
                  }),
            ],
          ),
        ])),
      ),
    );
  }
}

/// 封装控件
class CustomButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String? title;

  const CustomButton({@required this.onPressed, @required this.title});

  @override
  Widget build(BuildContext context) {
    return new TextButton(
      onPressed: onPressed,
      child: new Text("$title"),
      style: new ButtonStyle(foregroundColor: MaterialStateProperty.all(Colors.white),
        overlayColor: MaterialStateProperty.all(Color(0xff888888)),
        backgroundColor: MaterialStateProperty.all(Color(0xff585858)),
        padding: MaterialStateProperty.all(EdgeInsets.fromLTRB(10, 5, 10, 5)), ),
    );
  }
}
