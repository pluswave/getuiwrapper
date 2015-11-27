
#import "PushPlugin.h"

@implementation PushPlugin

@synthesize clientID;


- (void)getClientID:(CDVInvokedUrlCommand*)command;
{
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:self.clientID];
    [pluginResult setKeepCallbackAsBool:NO];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}



#pragma mark - GeTuiSdkDelegate

/** SDK启动成功返回cid */
- (void)GeTuiSdkDidRegisterClient:(NSString *)clientId {
    // [4-EXT-1]: 个推SDK已注册，返回clientId
    NSLog(@">>>[GeTuiSdk RegisterClient]:%@", clientId);
    self.clientID = clientId;
}

/** SDK收到透传消息回调 */
- (void)GeTuiSdkDidReceivePayload:(NSString *)payloadId andTaskId:(NSString *)taskId andMessageId:(NSString *)aMsgId andOffLine:(BOOL)offLine fromApplication:(NSString *)appId {
    // [4]: 收到个推消息
    NSData *payload = [GeTuiSdk retrivePayloadById:payloadId];
    NSString *payloadMsg = nil;
    if (payload) {
        payloadMsg = [[NSString alloc] initWithBytes:payload.bytes
                                              length:payload.length
                                            encoding:NSUTF8StringEncoding];
    }

    
    
    /*
    NSString *record = [NSString stringWithFormat:@"%d, %@, %@%@", ++_lastPayloadIndex, [self formateTime:[NSDate date]], payloadMsg, offLine ? @"<离线消息>" : @""];
    [_viewController logMsg:record];

    NSString *msg = [NSString stringWithFormat:@"%@ : %@%@", [self formateTime:[NSDate date]], payloadMsg, offLine ? @"<离线消息>" : @""];
    NSLog(@"GexinSdkReceivePayload : %@, taskId: %@, msgId :%@", msg, taskId, aMsgId);
    */
}

/** SDK收到sendMessage消息回调 */
- (void)GeTuiSdkDidSendMessage:(NSString *)messageId result:(int)result {
    // [4-EXT]:发送上行消息结果反馈
    // NSString *record = [NSString stringWithFormat:@"Received sendmessage:%@ result:%d", messageId, result];
    // [_viewController logMsg:record];
}

/** SDK遇到错误回调 */
- (void)GeTuiSdkDidOccurError:(NSError *)error {
    // [EXT]:个推错误报告，集成步骤发生的任何错误都在这里通知，如果集成后，无法正常收到消息，查看这里的通知。
    // [_viewController logMsg:[NSString stringWithFormat:@">>>[GexinSdk error]:%@", [error localizedDescription]]];
}

/** SDK运行状态通知 */
- (void)GeTuiSDkDidNotifySdkState:(SdkStatus)aStatus {
    // [EXT]:通知SDK运行状态
    // [_viewController updateStatusView:self];
}

//SDK设置推送模式回调
- (void)GeTuiSdkDidSetPushMode:(BOOL)isModeOff error:(NSError *)error {
  /*
    if (error) {
        [_viewController logMsg:[NSString stringWithFormat:@">>>[SetModeOff error]: %@", [error localizedDescription]]];
        return;
    }

    [_viewController logMsg:[NSString stringWithFormat:@">>>[GexinSdkSetModeOff]: %@", isModeOff ? @"开启" : @"关闭"]];

    UIViewController *vc = _naviController.topViewController;
    if ([vc isKindOfClass:[ViewController class]]) {
        ViewController *nextController = (ViewController *) vc;
        [nextController updateModeOffButton:isModeOff];
    }
  */
}

/*
- (NSString *)formateTime:(NSDate *)date {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm:ss"];
    NSString *dateTime = [formatter stringFromDate:date];
    return dateTime;
}
*/

@end
