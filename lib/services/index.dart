import 'package:dio/dio.dart';
import 'package:cnode_flutter/services/apis.dart';

class HttpActions {
  // 获取话题列表
  static Future getTopicList(
      {int limit = 20, int page, bool mdrender = false, String tab}) {
    return Dio().get(
        '${Apis.topicList}?mdrender=$mdrender&limit=$limit&page=$page&tab=$tab');
  }

  // 获取话题详情
  static Future getTopicDetail({String id, bool mdrender = false}) {
    return Dio().get('${Apis.topicDetail}/$id?mdrender=$mdrender');
  }

  // 获取用户信息
  static Future getUserInfo() {
    return Dio().get('${Apis.userInfo}/alsotang');
  }
}
