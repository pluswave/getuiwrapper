//
//  AppDelegate+notification.m
//  pushtest
//
//  Created by Robert Easterday on 10/26/12.
//
//

#import "AppDelegate+notification.h"
#import "PushPlugin.h"
#import "GeTuiSdk.h"
#import <objc/runtime.h>

#define NotifyActionKey "NotifyAction"
NSString *const NotificationCategoryIdent = @"ACTIONABLE";
NSString *const NotificationActionOneIdent = @"ACTION_ONE";
NSString *const NotificationActionTwoIdent = @"ACTION_TWO";


typedef enum{
  CONFIG_APPID,
  CONFIG_APPKEY,
  CONFIG_APPSECRET
} GETUI_CONFIG_KEY;


static char launchNotificationKey;

@implementation AppDelegate (notification)

- (id) getCommandInstance:(NSString*)className
{
    return [self.viewController getCommandInstance:className];
}

// its dangerous to override a method from within a category.
// Instead we will use method swizzling. we set this up in the load call.
+ (void)load
{
    Method original, swizzled;

    original = class_getInstanceMethod(self, @selector(init));
    swizzled = class_getInstanceMethod(self, @selector(swizzled_init));
    method_exchangeImplementations(original, swizzled);
}

- (AppDelegate *)swizzled_init
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(createNotificationChecker:)
               name:@"UIApplicationDidFinishLaunchingNotification" object:nil];

    // This actually calls the original init method over in AppDelegate. Equivilent to calling super
    // on an overrided method, this is not recursive, although it appears that way. neat huh?
    return [self swizzled_init];
}

// This code will be called immediately after application:didFinishLaunchingWithOptions:. We need
// to process notifications in cold-start situations
- (void)createNotificationChecker:(NSNotification *)notification
{
  if (notification)
    {
      NSDictionary *launchOptions = [notification userInfo];
      if (launchOptions){
        self.launchNotification = [launchOptions objectForKey: @"UIApplicationLaunchOptionsRemoteNotificationKey"];
        
       }
      // [1]:使用APPID/APPKEY/APPSECRENT创建个推实例
    
     [self startSdkWith:[AppDelegate getGetuiConfig:CONFIG_APPID] appKey:[AppDelegate getGetuiConfig:CONFIG_APPKEY] appSecret:[AppDelegate getGetuiConfig:CONFIG_APPSECRET]];

      // [2]:注册APNS
     [self registerRemoteNotification];
      
    }
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
  //PushPlugin *pushHandler = [self getCommandInstance:@"PushNotification"];
  //[pushHandler didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
     NSString *token = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
     token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
     // [3]:向个推服务器注册deviceToken
    [GeTuiSdk registerDeviceToken:token]; 
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
  // PushPlugin *pushHandler = [self getCommandInstance:@"PushNotification"];
  // [pushHandler didFailToRegisterForRemoteNotificationsWithError:error];

  [GeTuiSdk registerDeviceToken:@""];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
  NSLog(@"didReceiveNotification with fetchCompletionHandler");
  
  completionHandler(UIBackgroundFetchResultNewData);
}

- (void)applicationDidBecomeActive:(UIApplication *)application {

  application.applicationIconBadgeNumber = 0;        
}



// The accessors use an Associative Reference since you can't define a iVar in a category
// http://developer.apple.com/library/ios/#documentation/cocoa/conceptual/objectivec/Chapters/ocAssociativeReferences.html
- (NSMutableArray *)launchNotification
{
   return objc_getAssociatedObject(self, &launchNotificationKey);
}

- (void)setLaunchNotification:(NSDictionary *)aDictionary
{
    objc_setAssociatedObject(self, &launchNotificationKey, aDictionary, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)dealloc
{
    self.launchNotification = nil; // clear the association and release the object
}

+ (NSString *)getGetuiConfig:(GETUI_CONFIG_KEY)key
{
    NSString *retValue = @"unkonw";
    NSString *sKey = @"unknowKey" ;
    switch(key){
    case CONFIG_APPID:
      sKey = @"com.getui.kGTAppId";
      break;
    case CONFIG_APPKEY:
      sKey = @"com.getui.kGTAppKey";
      break;
    case CONFIG_APPSECRET:
      sKey = @"com.getui.kGTAppSecret";
      break;
    }
    
    NSString *configPath = [[NSBundle mainBundle] pathForResource:@"gtsdk" ofType:@"plist"];
    NSDictionary *configs = [NSDictionary dictionaryWithContentsOfFile:configPath];
    if (configs) {
        NSString *dictValue = configs[sKey];
        if (dictValue && [dictValue isKindOfClass:[NSString class]] && dictValue.length) {
            retValue = dictValue;
        }
    }
    
    return retValue;

}


- (void)startSdkWith:(NSString *)appID appKey:(NSString *)appKey appSecret:(NSString *)appSecret
{

  PushPlugin *pushHandler = [self getCommandInstance:@"getuiwrapper"];

  //[1-1]:通过 AppId、 appKey 、appSecret 启动SDK
  //该方法需要在主线程中调用
  [GeTuiSdk startSdkWithAppId:appID appKey:appKey appSecret:appSecret delegate:pushHandler];

  //[1-2]:设置是否后台运行开关
  [GeTuiSdk runBackgroundEnable:YES];
  //[1-3]:设置电子围栏功能，开启LBS定位服务 和 是否允许SDK 弹出用户定位请求
  [GeTuiSdk lbsLocationEnable:NO andUserVerify:NO];
}


/** 注册远程通知 */
- (void)registerRemoteNotification {

#ifdef __IPHONE_8_0
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        //IOS8 新的通知机制category注册
        UIMutableUserNotificationAction *action1;
        action1 = [[UIMutableUserNotificationAction alloc] init];
        [action1 setActivationMode:UIUserNotificationActivationModeBackground];
        [action1 setTitle:@"取消"];
        [action1 setIdentifier:NotificationActionOneIdent];
        [action1 setDestructive:NO];
        [action1 setAuthenticationRequired:NO];

        UIMutableUserNotificationAction *action2;
        action2 = [[UIMutableUserNotificationAction alloc] init];
        [action2 setActivationMode:UIUserNotificationActivationModeBackground];
        [action2 setTitle:@"回复"];
        [action2 setIdentifier:NotificationActionTwoIdent];
        [action2 setDestructive:NO];
        [action2 setAuthenticationRequired:NO];

        UIMutableUserNotificationCategory *actionCategory;
        actionCategory = [[UIMutableUserNotificationCategory alloc] init];
        [actionCategory setIdentifier:NotificationCategoryIdent];
        [actionCategory setActions:@[ action1, action2 ]
                        forContext:UIUserNotificationActionContextDefault];

        NSSet *categories = [NSSet setWithObject:actionCategory];
        UIUserNotificationType types = (UIUserNotificationTypeAlert |
                                        UIUserNotificationTypeSound |
                                        UIUserNotificationTypeBadge);

        UIUserNotificationSettings *settings;
        settings = [UIUserNotificationSettings settingsForTypes:types categories:categories];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];

    } else {
        UIRemoteNotificationType apn_type = (UIRemoteNotificationType)(UIRemoteNotificationTypeAlert |
                                                                       UIRemoteNotificationTypeSound |
                                                                       UIRemoteNotificationTypeBadge);
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:apn_type];
    }
#else
    UIRemoteNotificationType apn_type = (UIRemoteNotificationType)(UIRemoteNotificationTypeAlert |
                                                                   UIRemoteNotificationTypeSound |
                                                                   UIRemoteNotificationTypeBadge);
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:apn_type];
#endif
}


@end
