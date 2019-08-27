const String _domain = 'https://cnodejs.org/api/v1/';

class Apis {
  // get /topics 主题首页
  static const String topicList = '$_domain/topics';
  // get /topic/:id 主题详情
  static const String topicDetail = '$_domain/topic';

  // post /topic_collect/collect 收藏主题
  static const String addTopicCollect = '$_domain/topic_collect/collect';
  // post /topic_collect/de_collect 取消主题
  static const String deleteTopicCollect = '$_domain/topic_collect/de_collect';
  // get /topic_collect/:loginname 用户所收藏的主题
  static const String topicCollectList = '$_domain/topic_collect';

  // get /user/:loginname 用户详情
  static const String userInfo = '$_domain/user';
  // post /accesstoken 验证 accessToken 的正确性
  static const String accesstoken = '$_domain/accesstoken';

  // get /message/count 获取未读消息数
  static const String messageCount = '$_domain/message/count';
  // get /messages 获取已读和未读消息
  static const String messagesList = '$_domain/messages';
  // post /message/mark_all 标记全部已读
  static const String msgMarkAll = '$_domain/message/mark_all';
  // post /message/mark_one/:msg_id 标记单个消息为已读
  static const String msgMarkOne = '$_domain/message/mark_one';
}
