# flutter_chat
聊天室，使用Dart开发后端，使用Flutter开发前端页面

## 介绍

作为一个Android开发，基本没怎么接触后台开发的东西，对这方面也有点兴趣，一直都想写套接口实现下简单的后端服务玩一玩。
Flutter也学习了快一年了，加上之前看了下闲鱼的一篇文章[Flutter & Dart三端一体化开发](https://blog.csdn.net/weixin_38912070/article/details/93857162)，兴趣就来了，有兴趣就有学习热情。于是将Dart的[HttpServer](https://dart.dev/tutorials/server/httpserver)学习了一下，实现了一个简单的聊天室应用。

做这个应用还有其他的目的：

* 学习WebSocket，顺便复习下计算机网络的一些知识。
* 开发过程中需要两个客户端进行聊天的聊天，使用两个android studio模拟器的话，电脑简直卡飞天了。所以就使用Flutter开发的Desktop客户端来进行调试。反正基本上就是一套代码，然后自己做下desktop端和app端的屏幕适配就行了。
* 学习Dart的HttpServer和第三方服务端框架[aqueduct](https://aqueduct.io/docs/)。看了下网上的几个dart服务器框架，就这个比较好，上手容易，功能和文档也比较完善。
* 继续练手Flutter，这段时间没做项目，感觉有点生疏了
* 体验一波全栈开发的过程

## 演示
![](https://tva1.sinaimg.cn/large/006tNbRwgy1ga73vgkhu3j319c0u0b29.jpg)
![](https://tva1.sinaimg.cn/large/006tNbRwgy1ga73wsgtgpj319v0u0b29.jpg)
![](https://tva1.sinaimg.cn/large/006tNbRwgy1ga73y6l3q7j319v0u0hdt.jpg)

[Github源码](https://github.com/LXD312569496/flutter_chat),包括了客户端和服务端的代码。

clone项目后，可以在本地运行我的客户端代码。基本上是一套代码，目前只适配了app和desktop平台。（web遇到点问题，所以还没弄好）


## 基本功能

由于时间关系，也只是做了下一些最基本的功能，后面有空再继续完善。

### 客户端
* 用户登录注册
* 查看所有会话
* 用户发送消息和接收消息

### 服务端
* 提供登录注册接口
* 查询所有会话记录
* 查询历史聊天记录
* 提供socket连接实现并和客户端进行交互 
这是生成的[接口文档地址](http://120.77.215.190:8888/files/client.html):
![](https://tva1.sinaimg.cn/large/006tNbRwgy1ga74zcr4ocj31ox0u0jvc.jpg)



## 项目实现

* 开发工具，Flutter客户端使用的是Android Studio开发，服务端是使用IntelliJ IDEA。

### 服务端

* 服务端实现，这里不是用最基本的HttpServer来实现，而是用了一个第三方库的服务端框架[aqueduct](https://aqueduct.io/docs/)，一个构建支持RESTful APIs/ORM对象数据库映射/OAuth2.0的http server 框架。我们可以利用这个框架，快速实现接口的开发，使用Router来进行路由处理，使用Controller来处理每个请求，使用Postgres数据库框架来进行数据库操作，使用集成OAuth2.0授权框架来提供授权服务。（具体关于aqueduct框架的使用，后面会再翻译下文档，写篇更加具体的使用文章。这里简单介绍下。）

#### 总览
![](https://tva1.sinaimg.cn/large/006tNbRwgy1g9m51ny6j5j31260octd6.jpg)
![](https://tva1.sinaimg.cn/large/006tNbRwgy1g9m5ehjqpxj31220ecq6j.jpg)

* ApplicationChannel（应用通道），每个aqueduct应用程序会根据isolate数目去启动相应数量的ApplicationChannel（一个isolate会创建一个ApplicationChannel）。

* 不同的HTTP请求，会根据Router配置的路径，由不同的Controller进行处理。每个里面都有相应的逻辑去处理HTTP请求。

* 可以链接多个controller处理，形成子通道。比如实现一个获取好友列表的接口，很明显，前提是我们需要在请求接口的时候带上用户信息（比如token）。这样的话，就可以考虑一个Authorizer controller，用来验证请求的授权凭据是否正确。再加一个FriendController来获取好友列表数据作为response。

#### 定义路由

比如下面的代码，定义了注册接口和登录接口的路由。
```
    router
        .route("/register")
        .link(() => RegisterController(authServer, context));

    router.route("/login").link(() => LoginController(context));

```

#### 实现Controller

针对不同的接口，定义Controller进行相应的处理。下面的登录接口的相关代码。
1. 首先查询数据库是否存在这个用户库。用户不存在，接口返回失败提示。
2. 用户存在，通过auth/token获取token。token获取失败，接口返回失败。
3. token获取成功，接口将token和用户信息返回给客户端

```
class LoginController extends ResourceController {
  final ManagedContext context;

  LoginController(this.context);

  @Operation.post()
  Future<Response> login(@Bind.body() User user) async {
    String msg = "登录异常";
    //查询数据库是否存在这个用户
    var query = Query<User>(context)
      ..where((u) => u.username).equalTo(user.username);
    User result = await query.fetchOne();

    if (result == null) {
      msg = "用户不存在";
    } else {
      //通过auth/token获取token。登录成功的话，返回token
      var clientId = "com.donggua.chat";
      var clientSecret = "dongguasecret";
      var body =
          "username=${user.username}&password=${user.password}&grant_type=password";
      var clientCredentials =
          Base64Encoder().convert("$clientId:$clientSecret".codeUnits);

      res.Response response =
          await http.post("http://127.0.0.1:8888/auth/token",
              headers: {
                "Content-Type": "application/x-www-form-urlencoded",
                "Authorization": "Basic $clientCredentials"
              },
              body: body);

      if (response.statusCode == 200) {
        var map = json.decode(response.body);

        return Response.ok(
          BaseResult(
            code: 1,
            msg: "登录成功",
            data: {
              'userId': result.id,
              'access_token': map['access_token'],
              'userName': result.username
            },
          ),
        );
      }
    }

    return Response.ok(
      BaseResult(
        code: 1,
        msg: msg,
      ),
    );
  }
}
```

#### 创建WebSocket
* 利用WebSocketTransformer.upgrade，将HTTP请求升级为一个WebSocket连接。
* 使用socket.listen()方法，监听客户端发送过来的消息
* 本地使用一个类型为Map<int, WebSocket>的connections变量，来保存当前isolate中的所有的socket连接
* 利用messageHub将消息发送到其他isolate中

```
    //跟服务器建立连接
    router
        .route("/connect")
        .link(() => Authorizer.bearer(authServer))
        .linkFunction((request) async {
      //连接的用户id
      int userId = request.authorization.ownerID;
      var socket = await WebSocketTransformer.upgrade(request.raw);

      print("userId：$userId的用户跟服务器建立连接");
      socket.listen((event) {
        print("server listen:${event}");
        handleEvent(event, fromUserId: userId);

        messageHub.add(
          {
            "event": "websocket_broadcast",
            "message": event,
            'fromUserId': userId,
          },
        );
      }, onDone: () {
        //socket连接断了的话，移除连接
        connections.remove(userId);
      });
      //保存连接
      connections[userId] = socket;

      print("当前连接用户有${connections.length}个");
      connections.keys.forEach((userId) {
        print("userId:$userId");
      });
      return null;
    });
```

#### 配置数据库

项目目录下有一个config.yaml文件，用来实现一些信息的配置,比如数据库方面的配置。
```
database:
  host: localhost
  port: 5432
  username: donggua
  password: password
  databaseName: database_chat
```

在项目中初始化数据库。在prepare()方法中，进行数据库的连接，并获取到数据库的上下文ManagedContext对象。将ManagedContext保存到一个context的成员变量中，然后可以传给需要数据库操作的controller的构造函数，这样的话，我们就可以在controller里面进行一些数据库方面的操作。

```
 @override
  Future prepare() async {
    final config = CustomConfig(options.configurationFilePath);
    final dateModel = ManagedDataModel.fromCurrentMirrorSystem();
    final persistentStore = PostgreSQLPersistentStore.fromConnectionInfo(
        config.database.username,
        config.database.password,
        config.database.host,
        config.database.port,
        config.database.databaseName);
    context = ManagedContext(dateModel, persistentStore);
```


#### 运行服务器
1. 在服务器上面安装Dart sdk,这里的服务器建议是ubuntu,可以直接安装官网的Dart SDK。如果是centOS的话，需要自己下载dart sdk源码并进行编译构建，好麻烦，而且可能还会遇到其他问题。（所以我最后重装系统，搞成ubuntu系统了）

2. 将本地的服务器代码，放置到服务器上面。用到两个工具，SecureCRT和FileZilla，SecureCRT用来搞远程登录，FileZilla用来搞文件传输。具体使用百度一下。
![](https://tva1.sinaimg.cn/large/006tNbRwgy1ga10o9bs7ij30vc0qawjq.jpg)
![](https://tva1.sinaimg.cn/large/006tNbRwgy1ga10p9c6swj30u00u97uf.jpg)

3. 在服务器上面安装dart sdk和aqueduct框架
* 从[Dart官网](https://dart.dev/get-dart)下载Dart SDK，然后利用FileZilla上传到服务器上，解压，安装，搞定。
* 运行命令激活aqueduct
```
pub global activate aqueduct
```

4. 安装Postgresql，创建用户，创建数据库

这块具体也可以百度一下，这里就不细说了。创建配置的信息，要和我们的服务端项目中的配置信息保持一致就行。

5. 在项目目录下，运行下面的命令，开启服务。成功的话，就可以使用Postman去测试接口调用了。/
```
aqueduct serve
```
![](https://tva1.sinaimg.cn/large/006tNbRwgy1ga10xi1qb5j30sm08wmyt.jpg)

6. 使用Screen管理远程会话，让程序在后台运行

一般情况下，当我们关闭远程窗口的话，项目就跟着退出运行了。所以可以使用Screen来让我们在关闭ssh连接的情况下，让程序继续在后台运行。screen命令可以实现当前窗口与任务分离，我们即使离线了，服务器仍在后台运行任务。当我们重新登录服务器，可以读取窗口线程，重新连接任务窗口。

推荐一篇文章，了解下什么是Screen。[linux 技巧：使用 screen 管理你的远程会话](https://www.ibm.com/developerworks/cn/linux/l-cn-screen/)。


### 客户端
客户端实现，Flutter。客户端这边的实现比较简单，为了快点体验出三端一体化的快感，用了一些第三方库加快节奏。UI的话就是一个登录注册页面，再加上一个聊天列表和聊天窗口页面。
#### 总览

![](https://tva1.sinaimg.cn/large/006tNbRwgy1ga7103cd8nj30j417cafj.jpg)

只是做简单Demo,所以整体的代码架构比较简单，后期再优化下。

* config目录：保存App配置的一些信息。比如当前平台是否是大屏幕、配置根据当前环境去拿去host（本地环境拿本地host,线上环境拿生产host）
* model目录：定义接口返回的实体类。
* page目录：定义多个页面,登录注册页面、聊天列表页面、聊天详情页面。
* util目录：定义工具类,主要是简单封装了一个创建socket连接并添加事件监听的Manager类。
* widget目录：现在只有一个，就是显示聊天消息item的widget
* main.dart和main_local.dart：这两个的代码是一样的，区别就是接口的host不一样。main_local.dart在开发阶段测试接口用的是本地的localhost，main.dart用的是生产环境的host。

#### 登录注册页面
UI的代码就不展示了，无非就是两个文本框加个登录按钮。
看一下之前在前面的项目中，LoginController定义好的登录接口返回的结构:

```
//登录成功
{
  "code": 1,
  "msg": “登录成功”,
  "data":{
    "userId":"12345",
    “access_token”:"abcdefg",
    "userName":"donggua"
  }
}
//登录失败
{
  "code":1,
  "msg":"登录异常:具体原因"
}

```

点击按钮，使用Dio调用之前定义好的后端接口。

```
  void login() async {
    Dio dio = Dio(BaseOptions(baseUrl: GetIt.instance<AppConfig>().apiHost));

    Response<Map<String, dynamic>> response =
        await dio.post<Map<String, dynamic>>(
      "/login",
      data: {
        'username': username_controller.text.toString(),
        'password': password_controller.text.toString(),
      },
    );

    print("登录结果:$response");
    if (response != null &&
        response.data != null &&
        response.data['code'] == 1 &&
        response.data['data']['access_token'] != null) {
      //登录成功
      String token = response.data['data']['access_token'];
      int fromUserId = response.data['data']['userId'];
      String userName = response.data['data']['userName'];

      Navigator.of(context).push(MaterialPageRoute(builder: (context) {
        return ChatListPage(
          token: token,
          fromUserId: fromUserId,
          userName: userName,
        );
      }));
    }
  }
```

#### 聊天列表页面
登录成功，进入到聊天列表页面。

1.请求聊天列表接口/chat_list，获取聊天列表并展示。(后台定义接口类ChatListController，注意客户端接口请求是要带上token的，因为服务端会做token验证。若token无效，则返回401错误码)。
```
  getChatList() async {
    Dio dio = Dio(BaseOptions(
        baseUrl: GetIt.instance<AppConfig>().apiHost,
        headers: {'Authorization': 'Bearer ${widget.token}'}));

    Response<Map<String, dynamic>> response =
        await dio.get<Map<String, dynamic>>(
      "/chat_list",
    );

    if (response != null &&
        response.data != null &&
        response.data['code'] == 1) {
      List list = response.data['data'];
      list?.forEach((json) {
        userList.add(User.fromJson(json));
      });

      setState(() {});
    }
  }
```

2.使用SocketManager创建WebSocket连接，使客户端和服务器之间可以进行通信。 
```
  void initState(){
      socketManager.connectWithServer(widget.token).then((bool) {
      if (bool) {
        showToast("连接服务器成功");
      } else {
        showToast("连接服务器失败");
      }
    });
  }
```

#### 聊天详情页面
1.打开聊天详情页面，获取历史聊天记录（App这边暂时没做数据保存，所以数据全是在后端的数据库中）。这里就不展示代码了，跟前面的一样，请求接口，获取数据后进行展示。有一点就是要根据是否是当前用户，消息item的展示会有所区别。

2.在文本框中输入内容，使用socket进行发送消息。
```
  sendMessage() async {
    //发送消息
    Map<String, dynamic> data = {
      'toUserId': widget.toUser.id,
      'msg_content': inputController.text.toString(),
      'msg_type': 1,
    };

    GetIt.instance<SocketManager>().sendMessage(data);

    //清空editText
    inputController.clear();

    debugPrint("向服务器发送消息:$data");
  }
```

3.监听服务器的消息。当接收到服务端的消息后，往ListView的数据源中添加一条消息。

```
void initState(){
     listener = (Map<String, dynamic> json) {
      if (mounted) {
        setState(() {
          print("messageList增加一条消息");
          Message newMessage = Message.fromJson(json);
          //消息是自己发的，或者是别人要发给自己的，才进行展示
          if (newMessage.fromUserId == widget.fromUserId ||
              newMessage.toUserId == widget.fromUserId) {
            messageList.add(newMessage);
          }
        });
        Future.delayed(Duration(milliseconds: 50), () {
          scrollController.jumpTo(scrollController.position.maxScrollExtent);
        });
      }
    };
    //添加监听
    GetIt.instance<SocketManager>().addListener(listener);
}
```

#### 根据屏幕进行适配
这里介绍下之前写过的一篇文章[Flutter之支持不同的屏幕尺寸和方向](https://juejin.im/post/5c45abc0f265da617265c656)。

![](https://tva1.sinaimg.cn/large/006tNbRwgy1ga7469tx8fj30jh0d4q48.jpg)
![](https://tva1.sinaimg.cn/large/006tNbRwgy1ga7489m6nvj312y0swjzw.jpg)
这里的场景是，在App里面就显示一个聊天列表页面，这个页面是充满整个屏幕的，点击item才会进入一个新的聊天详情页面。但是在桌面端或者平板，这种大尺寸的屏幕上，可以在左侧显示聊天列表，右侧显示聊天详情，合理地使用屏幕空间。

整体的思路是类似Android的Fragment。我们需要做的就是定义两个Widget，一个用于显示主列表，一个用于显示详细视图。实际上，这些就是类似的fragments。

我们只需要检查设备是否具有足够的宽度来处理列表视图和详细视图。如果是，我们在同一屏幕上显示两个widget。如果设备没有足够的宽度来包含两个界面，那我们只需要在屏幕中展示主列表，点击列表项后导航到独立的屏幕来显示详细视图。



## 总结

1. 做这个项目主要还是为了体验下用Dart进行全栈开发的感觉，总体效率确实提高很多。
2. 没有在真正的项目中进行实战。先把基础的知识学习积累起来，期待在后面能够应用到真正的项目中。
3. 现在的Demo比较简单，有空再把这个项目进行完善
4. 近段时间还是在看原生的东西，有些技术还是类似的，对原生了解得比较深入，可以更好地使用和理解Flutter。
