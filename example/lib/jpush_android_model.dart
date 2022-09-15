import 'dart:convert';

class JPushInterface {
  static const extraAlertType = "cn.jpush.android.ALERT_TYPE";
  static const extraNotificationId = "cn.jpush.android.NOTIFICATION_ID";
  static const extraMsgId = "cn.jpush.android.MSG_ID";
  static const extraAlert = "cn.jpush.android.ALERT";
  /// 扩展信息
  static const extraExtra = "cn.jpush.android.EXTRA";
}

class JpushAndroidModel {
  /// 标题
  String? title;
  /// 内容
  String? alert;
  /// 极光自己使用的扩展信息，携带消息id等
  JpushAndroidExtras? extras;

  JpushAndroidModel({
    this.title,
    this.alert,
    this.extras,
  });

  JpushAndroidModel.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    alert = json['alert'];
    extras =
    json['extras'] != null ? JpushAndroidExtras.fromJson(json['extras']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['title'] = this.title;
    data['alert'] = this.alert;
    if (this.extras != null) {
      data['extras'] = this.extras!.toJson();
    }

    return data;
  }
}

class JpushAndroidExtras {
  String? extraAlertType;
  String? extraNotificationId;
  String? extraMsgId;
  String? extraAlert;
  Map<String, dynamic>? extraExtra;

  JpushAndroidExtras.fromJson(Map<dynamic, dynamic> json) {
    print("JpushAndroidExtras接收到的数据 $json");
    extraAlertType = json[JPushInterface.extraAlertType].toString();
    extraNotificationId = json[JPushInterface.extraNotificationId].toString();
    extraMsgId = json[JPushInterface.extraMsgId].toString();
    extraAlert = json[JPushInterface.extraAlert].toString();
    print("JpushAndroidExtras打印拓展字段 ${json[JPushInterface.extraExtra]}");
    // extraExtra = json[JPushInterface.extraExtra];
    extraExtra = jsonDecode(json[JPushInterface.extraExtra]);
    // extraExtra =
    // json['extraExtra'] != null ? OrderDataModel.fromJson(json['data']) : null;

  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['extraAlertType'] = this.extraAlertType;
    data['extraNotificationId'] = this.extraNotificationId;
    data['extraMsgId'] = this.extraMsgId;
    data['extraAlert'] = this.extraAlert;
    print("this.extraExtra 是否为空 ${this.extraExtra == null}");
    if (this.extraExtra != null) {
      data['extraExtra'] = this.extraExtra;
    }

    return data;
  }
}