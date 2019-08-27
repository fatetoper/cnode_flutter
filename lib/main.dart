// material 组件库
import 'package:flutter/material.dart';
// 列表页部件
import 'package:cnode_flutter/pages/home.dart';
// provider组件
import 'package:provider/provider.dart';
// model
import './model/model.dart';

// 应用入口
void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      // 状态共享 https://book.flutterchina.club/chapter7/provider.html
      providers: [
        ChangeNotifierProvider(builder: (_) => Counter()),
      ],
      // Consumer 消费者 https://book.flutterchina.club/chapter7/provider.html
      // 这里强行用了一下~ 作为示例而
      child: Consumer<Counter>(
        builder: (context, counter, _) {
          /// [Consumer]可以通过[counter]访问到[Counter]这个model下的状态
          print(counter);
          // MaterialApp 是Material库中提供的Flutter APP框架
          // https://docs.flutter.cn/flutter/material/MaterialApp-class.html
          return MaterialApp(
            // 应用名称
            title: 'CNode',
            // 主题
            theme: ThemeData(
              // 定义主题色 Colors 是MaterialApp中的颜色部件，里面定义了很多颜色
              primaryColor: Colors.blue,
            ),
            // 首页
            home: Home(),
          );
        },
      ),
    );
  }
}
