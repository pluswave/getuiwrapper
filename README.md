# getuiwrapper

getui.com 个推API在Cordova/Phonegap平台的plugin，目前仅仅支持Android。

# 如何使用

## 安装

`cordova plugin add https://www.github.com/pluswave/getuiwrapper.git --variable APP_ID=<注册个推应用得到的APP_ID> --variable APP_KEY=<个推APP_KEY> --variable APP_SECRET=<个推APP_SECRET> --variable PACKAGE_ID=com.your.package.name` 

## API

注册透传回调：

`cordova.plugins.getuiwrapper.registerPushListener(cb)`

反注册透传回调

`cordova.plugins.getuiwrapper.unregisterPushListener(cb)`

获得ClientID

`cordova.plugins.getuiwrapper.getClientID( success, error)`

