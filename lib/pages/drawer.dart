import 'package:cnode_flutter/services/index.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/model.dart';

class HomeDrawer extends StatefulWidget {
  final getListFn;

  HomeDrawer({this.getListFn});
  _HomeDrawerState createState() => new _HomeDrawerState();
}

class _HomeDrawerState extends State<HomeDrawer> {
  var userInfo = <String, dynamic>{
    'avatar_url': '',
    'loginname': '北京吴彦祖',
    'score': '0',
  };

  // 获取用户信息
  void getUserInfoFn() async {
    var res = await HttpActions.getUserInfo();
    setState(() {
      userInfo = res.data['data'];
    });
  }

  @override
  // 生命周期钩子
  void initState() {
    super.initState();
    print('drawer initState');
    // 获取用户信息
    getUserInfoFn();
  }

  @override
  // 生命周期钩子
  void dispose() {
    print('drawer dispose');
    super.dispose();
  }

  Widget build(BuildContext context) {
    // Drawer 抽屉部件 https://docs.flutter.cn/flutter/material/Drawer/Drawer.html
    return new Drawer(
      child: Column(children: generateListFn(context)),
    );
  }

  // 生成抽屉列表部件
  List<Widget> generateListFn(context) {
    var children = <Widget>[];
    // 添加用户信息部件
    children.add(generateUserBoxFn(userInfo, context));
    // 根据数组信息，生成可以点击的tab分类
    [
      {'label': '全部', 'id': '', 'icon': Icons.border_all},
      {'label': '精华', 'id': 'good', 'icon': Icons.thumb_up},
      {'label': '分享', 'id': 'share', 'icon': Icons.share},
      {'label': '问答', 'id': 'ask', 'icon': Icons.question_answer},
      {'label': '招聘', 'id': 'job', 'icon': Icons.work},
    ].forEach((item) {
      /// 依次将 按钮部件 推入[children]
      children.add(
        ListTile(
          title: new Text(item['label']),
          leading: Icon(item['icon']),
          trailing: Icon(Icons.keyboard_arrow_right),
          selected: item['id'] == Provider.of<Counter>(context).tab,
          onTap: () {
            /// 通过调用[rovider.of<Counter>]的change方法,来改变tab的值
            Provider.of<Counter>(context).change(item['id']);
            // 这里没有将 item['id'] 传递下去，是为了强行体现一下 provider 的作用:)
            widget.getListFn();
          },
        ),
      );
    });
    return children;
  }
}

// 生成用户信息盒子的方法
Widget generateUserBoxFn(userInfo, context) {
  return Container(
      // 内边距
      padding: EdgeInsets.only(top: 60, right: 20, bottom: 10, left: 20),
      // Container 部件颜色
      color: Colors.blue,
      child: Column(
        children: <Widget>[
          // 第一行：头像，夜间模式
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              // 头像
              userInfo['avatar_url'].length > 0
                  ? CircleAvatar(
                      backgroundImage: NetworkImage(userInfo['avatar_url']),
                      backgroundColor: Colors.blue,
                      radius: 20,
                    )
                  : new Icon(
                      Icons.person,
                      size: 40,
                      color: Colors.white,
                    ),
              // 夜间模式
              Listener(
                child: new Icon(Icons.brightness_2),
                onPointerDown: (PointerDownEvent event) {
                  print(event);
                  // 弹窗 配置如key名称所示，title：标题，titlePadding：标题的内边距，等等等
                  showDialog(
                    context: context,
                    builder: (BuildContext context) => SimpleDialog(
                      title: Text("提示"),
                      titlePadding: EdgeInsets.all(10),
                      backgroundColor: Colors.white,
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(6))),
                      children: <Widget>[
                        ListTile(
                          title: Center(
                            child: Text("女朋友召唤，来不及写了。"),
                          ),
                        ),
                      ],
                    ),
                  ).then<void>((value) {
                    // The value passed to Navigator.pop() or null.
                    print(value);
                  });
                },
              ),
            ],
          ),
          // 第二行：昵称、注销按钮
          Padding(
            padding: EdgeInsets.only(top: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // 昵称、积分
                    Container(
                      height: 20,
                      child: new Text(
                        userInfo['loginname'],
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Text.rich(new TextSpan(
                      text: '积分:',
                      children: <InlineSpan>[
                        new TextSpan(text: userInfo['score'].toString())
                      ],
                      style: TextStyle(
                        color: Colors.white60,
                      ),
                    ))
                  ],
                ),
                // 注销按钮，并监听点击事件
                Listener(
                    child: Text(
                      "注销",
                      style: TextStyle(
                        color: Colors.white60,
                      ),
                    ),
                    onPointerUp: (PointerUpEvent event) {
                      // 弹窗 配置如key名称所示，title：标题，titlePadding：标题的内边距，等等等
                      showDialog(
                        context: context,
                        builder: (BuildContext context) => SimpleDialog(
                          title: Text("提示"),
                          titlePadding: EdgeInsets.all(10),
                          backgroundColor: Colors.white,
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(6))),
                          children: <Widget>[
                            ListTile(
                              title: Center(
                                child: Text("女朋友召唤，来不及写了。"),
                              ),
                            ),
                          ],
                        ),
                      ).then<void>((value) {
                        // The value passed to Navigator.pop() or null.
                        print(value);
                      });
                    }),
              ],
            ),
          ),
        ],
      ));
}
