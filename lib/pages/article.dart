import 'package:flutter/material.dart';
import 'package:cnode_flutter/services/index.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class ArticleDetail extends StatefulWidget {
  // 接受列表页传过来的参数
  final data;
  ArticleDetail(this.data);
  _ArticleDetailState createState() => new _ArticleDetailState(data);
}

class _ArticleDetailState extends State<ArticleDetail> {
  var data;
  // 存放整个页面的widgets
  var listViewChildren = <Widget>[];
  // 获取文章的内容信息
  _ArticleDetailState(this.data);

  @override
  initState() {
    super.initState();
    // avatar_url值为 '//www.baidu.com', //开头flutter的image部件会报错，需要处理一下数据
    // 这里没有处理的原因是，数据在列表页面已经处理过
    // data['author']['avatar_url'] = data['author']['avatar_url']
    //     .replaceAllMapped(new RegExp(r'(?<!https:|http:)//'), (hasil) {
    //   return 'https://';
    // });

    // 初始化话题详情内容信息
    initPageWidgetsFn();

    // 调取详情接口获取文章的详细信息（比如回复）
    HttpActions.getTopicDetail(id: data['id']).then((res) {
      print(res);
      // 添加评论
      addReplyWidgetsFn(res.data['data']['replies']);
    });
  }

  Widget build(BuildContext context) {
    // 页面脚手架 https://docs.flutter.cn/flutter/material/Scaffold-class.html
    return Scaffold(
        appBar: new AppBar(title: Text('话题')),
        body: Padding(
          padding: EdgeInsets.all(12),
          child: ListView.builder(
              itemCount: listViewChildren.length,
              itemBuilder: (context, index) {
                return listViewChildren[index];
              }),
        ));
  }

  // 初始化页面内容，话题的标题、内容、作者信息
  void initPageWidgetsFn() {
    setState(() {
      listViewChildren.addAll([
        // 标题
        Padding(
          padding: EdgeInsets.only(bottom: 10),
          child: Text(
            data['title'],
            style: TextStyle(
                color: Colors.black, fontSize: 17, fontWeight: FontWeight.w500),
          ),
        ),
        // 作者信息
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              children: <Widget>[
                // 头像
                CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(data['author']['avatar_url']),
                ),
                // 昵称、浏览量
                Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(data['author']['loginname']),
                      Text.rich(
                        TextSpan(
                            text: data['visit_count'].toString(),
                            children: [TextSpan(text: '次浏览')]),
                      )
                    ],
                  ),
                )
              ],
            ),
            // 是否已经收藏
            data['is_collect'] == true
                ? new Icon(
                    Icons.favorite,
                    color: Colors.green,
                  )
                : new Icon(
                    Icons.favorite_border,
                    color: Colors.grey,
                  )
          ],
        ),
        // 正文
        Padding(
          padding: EdgeInsets.only(top: 15),
          child: new MarkdownBody(
              // 请注意在下面的示例中使用_raw string_（前缀为`r`的字符串）。 使用原始字符串将字符串中的每个字符视为文字字符。
              data: data['content'].replaceAllMapped(
                  new RegExp(r'(?<!http:|https:)//'), (hasil) {
            return 'https://';
          })),
        ),
        new Divider(
          height: 40,
        )
      ]);
    });
  }

  // 添加评论部件
  void addReplyWidgetsFn(repliesList) {
    // 评论部件 生成后一次添加进话题内容，其实刚好的做法是跟话题列表一样，添加上拉加载
    var widgets = <Widget>[];
    if (repliesList.length < 1) {
      // 没有评论的情况
      widgets.add(Text('no replies'));
    } else {
      // 有评论的情况
      /// 很好奇数组的forEach方法为什么不提供索引[index]
      repliesList.asMap().forEach((index, item) => widgets.add(Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    // 头像
                    children: <Widget>[
                      CircleAvatar(
                        radius: 16,
                        backgroundImage:
                            NetworkImage(item['author']['avatar_url']),
                      ),
                      // 昵称、楼层信息
                      Padding(
                        padding: EdgeInsets.only(left: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(item['author']['loginname']),
                            Text.rich(
                              TextSpan(
                                  text: index.toString(),
                                  children: [TextSpan(text: '楼')]),
                              style: TextStyle(color: Colors.green),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                  // 是否已经收藏
                  item['is_collect'] == true
                      ? new Icon(
                          Icons.favorite,
                          color: Colors.green,
                        )
                      : new Icon(
                          Icons.favorite_border,
                          color: Colors.grey,
                        )
                ],
              ),
              // 评论
              Padding(
                padding: EdgeInsets.symmetric(
                  vertical: 10,
                ),
                child: Text(
                  item['content'],
                ),
              ),
            ],
          )));
      setState(() {
        listViewChildren.addAll(widgets);
      });
    }
  }
}
