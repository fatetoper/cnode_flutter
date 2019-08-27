import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:cnode_flutter/services/index.dart';
import 'package:cnode_flutter/pages/article.dart';
import 'package:cnode_flutter/pages/drawer.dart';
import 'package:provider/provider.dart';
import '../model/model.dart';

// 首页（列表） 继承 StatefulWidget（有状态模型？）
class Home extends StatefulWidget {
  // Home({Key: key}) :super(Key key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // Scaffold 部件的key
  static GlobalKey<ScaffoldState> _globalKey = new GlobalKey();
  // List 不免的key
  static GlobalKey<ListState> _listKey = new GlobalKey();

  @override
  Widget build(BuildContext context) {
    // 页面脚手架 https://docs.flutter.cn/flutter/material/Scaffold-class.html
    return Scaffold(
      // 部件的key主要用来提升diff算法性能，跟前端概念中的key是类似的
      // https://my.oschina.net/u/4082889/blog/3031508
      key: _globalKey,
      appBar: new AppBar(
        title: const Text('list'),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            // Scaffold.of(context).openDrawer();
            _globalKey.currentState.openDrawer();
          },
          tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
        ),
      ),
      // new抽屉实例，并将更新列表的方法传递给drawer页面调用（也可以用eventbus）
      drawer: new HomeDrawer(getListFn: () {
        _listKey.currentState.curPage = 1;
        _listKey.currentState.getListFn(
            loadMoreBool: false,
            tab: Provider.of<Counter>(context).tab,
            page: 1);
      }),
      body: new List(key: _listKey),
    );
  }
}

// 产生列表widge
class List extends StatefulWidget {
  List({Key key}) : super(key: key);
  @override
  ListState createState() => new ListState();
}

class ListState extends State<List> {
  var list = <dynamic>['loading']; // 数据数组
  var curPage = 1; // 当前页数
  var loadingBool = false; // 是否正在加载中，避免多次请求阻塞
  ScrollController _controller = ScrollController(); // list scroll controller

  /// 通过http请求获取列表数据
  /// [loadMoreBool]:是否是加载更多 示例：true
  /// [tab]:话题类型 示例：good
  /// [page]:第几页 示例：1

  // ListState() {}
  @override
  void initState() {
    super.initState();
    curPage = 1;
    getListFn(loadMoreBool: false, tab: '', page: curPage);
  }

  @override
  void dispose() {
    //内存泄露，可以调用_controller.dispose，释放
    // _controller.dispose();
    super.dispose();
  }

  // _ListState({Key:key}):super(Key:key)
  Widget build(BuildContext context) {
    // list scroll controller
    _controller.addListener(() async {
      // 获取页面长度 和 当前滚动条所在位置
      var maxScroll = _controller.position.maxScrollExtent;
      var pixels = _controller.position.pixels;

      // 滑动到底部加载更多
      if (!loadingBool && maxScroll == pixels) {
        /// [loadingBool] 正在加载中状态，避免重复请求
        loadingBool = true;
        await getListFn(
            loadMoreBool: true,
            tab: Provider.of<Counter>(context).tab,
            page: curPage);
        loadingBool = false;
      }
    });

    // 列表
    // ListView部件说明：https://book.flutterchina.club/chapter6/listview.html
    return ListView.builder(
      /// 总长度，例如为50，第一屏显示五项，那么[itemBuilder]会创建第一屏需要的部件，而不是将列表中的50个部件都创建出来
      itemCount: list.length,
      padding: const EdgeInsets.only(top: 0, left: 0, right: 0, bottom: 20),
      // 按需创建部件
      itemBuilder: (BuildContext _context, int i) {
        // 如果这一项为 String，带着这一项是特殊的部件，比如 loading（加载中）、noMore（没有更多）、none（暂无数据）
        if (list[i] is String) {
          if (list[i] == 'loading') {
            // 部件：加载中
            return Container(
              padding: const EdgeInsets.all(16.0),
              alignment: Alignment.center,
              child: SizedBox(
                  width: 24.0,
                  height: 24.0,
                  child: CircularProgressIndicator(strokeWidth: 2.0)),
            );
          } else if (list[i] == 'noMore') {
            // 部件：没有更多
            return Container(
                alignment: Alignment.topCenter,
                padding: EdgeInsets.all(16.0),
                child: Text(
                  "没有更多了",
                  style: TextStyle(color: Colors.grey),
                ));
          } else if (list[i] == 'none') {
            // 部件：暂无数据
            return Container(
                alignment: Alignment.topCenter,
                padding: EdgeInsets.all(16.0),
                child: Text(
                  "暂无数据",
                  style: TextStyle(color: Colors.grey),
                ));
          }
        }
        // 创建item部件，并返回给列表
        return buildItem(list[i]);
      },
      controller: _controller,
    );
  }

  /// 调用http请求获取列表数据
  /// [loadMoreBool] Bool 加载更多标志
  /// [tab] String 主题分类。目前有 ask share job good
  /// [page] Number 页数
  Future getListFn({bool loadMoreBool, String tab, int page}) {
    // print('$loadMoreBool,$tab,$page');
    return HttpActions.getTopicList(page: page, tab: tab).then((res) {
      var data = res.data['data'];
      var l = data.length;
      setState(() {
        if (loadMoreBool) {
          // 加载更多逻辑
          if (l > 0) {
            // 有数据，向list中添加新数据
            curPage++;
            list.insertAll(list.length - 1, data);
          } else {
            // 无数据，向list中添加'noMore'标识
            list[list.length - 1] = 'noMore';
          }
        } else {
          // 第一次获取数据逻辑
          // 清楚list原有数据
          list = <dynamic>['loading'];
          // 滚动列表页到顶部
          _controller.animateTo(.0,
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInOutExpo);
          if (l > 0) {
            // 有数据，向list中添加新数据
            list.insertAll(list.length - 1, data);
            curPage++;
          } else {
            // 无数据，向list中添加'noMore'标识
            list[list.length - 1] = 'none';
          }
        }
      });
    });
  }

  // 创建itemwidget
  Widget buildItem(_item) {
    var item = _item;

    /// 图片url不带议名时，[NetworkImage]组件会报错
    item['author']['avatar_url'] = item['author']['avatar_url']
        .replaceAllMapped(new RegExp(r'(?<!https:|http:)//'), (hasil) {
      return 'https://';
    });
    return Card(
      elevation: 4.0,
      child: InkWell(
        child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // 标题
                new Text(
                  item['title'],
                  // 指定文本显示的最大行数
                  maxLines: 2,
                  // 指定超出文本的截断方式
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 16.0),
                ),
                // 正文概要，只显示两行，其余显示...
                Container(
                  padding:
                      // Creates insets from offsets from the left, top, right, and bottom.
                      EdgeInsets.only(top: 10, right: 0, bottom: 5, left: 0),
                  child: Text(
                    item['content']
                        .toString()
                        .replaceAll(new RegExp('[\r\n]'), ''),
                    // 指定文本显示的最大行数
                    maxLines: 2,
                    // 指定超出文本的截断方式
                    overflow: TextOverflow.ellipsis,
                    // 文字样式，接收一个TextStyle
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                // 分割线
                Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        // 圆形头像
                        CircleAvatar(
                          radius: 16,
                          backgroundImage:
                              NetworkImage(item['author']['avatar_url']),
                          backgroundColor: Colors.blue,
                        ),
                        Text(
                          '  ${item['author']['loginname']}',
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                    // Text.rich 可以显示多重样式的文本部件
                    Text.rich(
                      TextSpan(text: '创建于：', children: [
                        TextSpan(
                            // todo DateTime.parse 时间解析不了这种格式 2019-04-24T03:36:12.582Z
                            text: DateFormat('yyyy-MM-dd hh:mm:ss')
                                .format(DateTime.parse(item['create_at'])))
                      ]),
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                )
              ],
            )),
        onTap: () {
          // 跳转详情页面
          Navigator.of(context).push(MaterialPageRoute(
              builder: (BuildContext context) => new ArticleDetail(item)));
        },
      ),
    );
  }
}
