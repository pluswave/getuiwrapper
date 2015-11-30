# getuiwrapper

getui.com 个推API在Cordova/Phonegap平台的plugin，支持Android/iOS. 功能：让程序可以接收到透明推送的内容。

# 如何使用

## 安装

```shell
cordova plugin add https://www.github.com/pluswave/getuiwrapper.git --variable APP_ID=<注册个推应用得到的APP_ID> --variable APP_KEY=<个推APP_KEY> --variable APP_SECRET=<个推APP_SECRET> --variable PACKAGE_ID=com.your.package.name` 
```
## API

注册透传回调：


```javascript
cordova.plugins.getuiwrapper.registerPushListener(cb)
cb = function(object){
  // 透明推送的内容为Json格式，objec为解析后的结果。
  // 否则，静默忽略，该回调不会被调用。
}
```

反注册透传回调

```javascript
cordova.plugins.getuiwrapper.unregisterPushListener(cb)
```

获得ClientID

```javascript
cordova.plugins.getuiwrapper.getClientID( success, error)
```
# 致谢

代码参考了 [phonegap-plugin-push](https://github.com/phonegap/phonegap-plugin-push/) 感谢相关作者！

#LICENSE

MIT
