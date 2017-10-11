//
//  AppDelegate+UMengPush.m
//  YDProject
//
//  Created by guest1 on 17/7/26.
//  Copyright © 2017年 DYL. All rights reserved.
//
#define DEF_SCREEN_WIDTH [[UIScreen mainScreen] bounds].size.width
#define DEF_SCREEN_HEIGHT [[UIScreen mainScreen] bounds].size.height
#define UMengPushDic @"umengPushDic" //友盟推送数据

#import "AppDelegate+UMengPush.h"
#import "UMessage.h"
#import "HomeWebViewController.h"
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 10000
#import <UserNotifications/UserNotifications.h>
#endif


@implementation AppDelegate (UMengPush)

- (void)umengPushApplication:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [UMessage startWithAppkey:@"59dc9313734be452920001ce" launchOptions:launchOptions];
#if DEBUG
    [UMessage openDebugMode:YES];
#endif
    [UMessage setLogEnabled:YES];//是否开启开发模式 YES为开发模式 NO为生产模式 默认为生产模式
    //IOS10必须添加这段代码
    
    //对交互方式进行判断
    if ([[[UIDevice currentDevice] systemVersion] intValue] >= 8 && [[[UIDevice currentDevice] systemVersion] intValue] < 10.0) {
        UIMutableUserNotificationAction *action1 = [[UIMutableUserNotificationAction alloc]init];
        action1.identifier = @"action1_identifier";
        action1.title = @"打开应用";
        action1.activationMode = UIUserNotificationActivationModeForeground;
        
        UIMutableUserNotificationAction *action2 = [[UIMutableUserNotificationAction alloc]init];
        action2.identifier = @"action2_identifiier";
        action2.title = @"忽略";
        action2.activationMode = UIUserNotificationActivationModeBackground;
        action2.authenticationRequired = YES;//需要解锁才能处理，如果action.activationMode = UIUserNotificationActivationModeForeground;则这个属性被忽略；
        action2.destructive = YES;//破坏性的
        UIMutableUserNotificationCategory *actionCategory1 = [[UIMutableUserNotificationCategory alloc]init];
        actionCategory1.identifier = @"category1";//这组动作的唯一标识
        [actionCategory1 setActions:@[action1,action2] forContext:(UIUserNotificationActionContextDefault)];
        NSSet *categories = [NSSet setWithObjects:actionCategory1, nil];
        [UMessage registerForRemoteNotifications:categories];
    }
    
    if (@available(iOS 10.0, *)) {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = self;
        UNAuthorizationOptions types10 = UNAuthorizationOptionAlert | UNAuthorizationOptionSound | UNAuthorizationOptionBadge;
        [center requestAuthorizationWithOptions:types10 completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if (granted) {
                //点击允许
            } else {
                //点击不允许
            }
        }];
        
        UNNotificationAction *action1_ios10 = [UNNotificationAction actionWithIdentifier:@"action1_ios10" title:@"打开应用" options:UNNotificationActionOptionForeground];
        UNNotificationAction *action2_ios10 = [UNNotificationAction actionWithIdentifier:@"action2_ios10" title:@"忽略" options:UNNotificationActionOptionForeground];
        
        UNNotificationCategory *category1_ios10 = [UNNotificationCategory categoryWithIdentifier:@"category1_ios10" actions:@[action1_ios10,action2_ios10] intentIdentifiers:@[] options:UNNotificationCategoryOptionCustomDismissAction];
        NSSet *categorys = [NSSet setWithObjects:category1_ios10, nil];
        [center setNotificationCategories:categorys];
        //注册通知
        [UMessage registerForRemoteNotifications:categorys];
        
    } else {
        // Fallback on earlier versions
    }
    
    //打开调试日志
    [UMessage setLogEnabled:YES];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSLog(@"%@",[[[[deviceToken description] stringByReplacingOccurrencesOfString: @"<" withString: @""]
                  stringByReplacingOccurrencesOfString: @">" withString: @""]
                 stringByReplacingOccurrencesOfString: @" " withString: @""]);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(nonnull void (^)(UIBackgroundFetchResult))completionHandler {
    [UMessage setAutoAlert:NO];
    [UMessage didReceiveRemoteNotification:userInfo];
    [self managerReceiveMessage:userInfo application:application];
    completionHandler(UIBackgroundFetchResultNewData);
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [UMessage setAutoAlert:NO];
    [UMessage didReceiveRemoteNotification:userInfo];
    [self managerReceiveMessage:userInfo application:application];
}
- (void)applicationWillResignActive:(UIApplication *)application {
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    
}

- (void)applicationWillTerminate:(UIApplication *)application {
    
}

-(void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
    NSDictionary * userInfo = notification.request.content.userInfo;
    if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [UMessage setAutoAlert:NO];
        [self popAlertWithUserInfo:userInfo];
        [UMessage sendClickReportForRemoteNotification:userInfo];
        //应用处于前台时的远程推送接受
        //必须加这句代码
        [UMessage didReceiveRemoteNotification:userInfo];
        
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        [ud setObject:[NSString stringWithFormat:@"%@",userInfo] forKey:@"UMPuserInfoNotification"];
        
    }else {
        //应用处于前台时的本地推送接受
    }
    completionHandler(UNNotificationPresentationOptionSound);
}

//iOS10新增：处理后台点击通知的代理方法
-(void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler{
    NSDictionary * userInfo = response.notification.request.content.userInfo;
    if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [self presentToViewController:userInfo];
        [UMessage sendClickReportForRemoteNotification:userInfo];
        //应用处于后台时的远程推送接受
        //必须加这句代码
        [UMessage didReceiveRemoteNotification:userInfo];
        
        
        
    }else {
        //应用处于后台时的本地推送接受
    }
    completionHandler();
}


//iOS10新增：处理前台收到通知的代理方法

#pragma mark - 自定义事件

- (void)managerReceiveMessage:(NSDictionary *)userInfo application:(UIApplication *)application {
    if (application.applicationState == UIApplicationStateActive) {
        [self popAlertWithUserInfo:userInfo];
    }else {
        [self presentToViewController:userInfo];
    }
}

#pragma mark - ios弹出框
- (void)popAlertWithUserInfo:(NSDictionary *)userInfo {

    NSDictionary *apsDic = [userInfo objectForKey:@"aps"];
    NSString *url = apsDic[@"url"];
    NSDictionary *alertDic = apsDic[@"alert"];
    NSString *body = alertDic[@"body"];
    NSString *title = alertDic[@"title"];
    
    if (title && title.length > 0) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                                 message:body
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"去查看" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self presentToViewController:userInfo];
        }];
        if (url && url.length > 0) {
            [alertController addAction:alertAction];
            [alertController addAction:okAction];
        }else{
            [alertController addAction:alertAction];
        }
        [self.window.rootViewController presentViewController:alertController animated:YES completion:nil];
    }else {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil
                                                                                 message:body
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"去查看" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self presentToViewController:userInfo];
        }];
        
        if (url && url.length > 0) {
            [alertController addAction:alertAction];
            [alertController addAction:okAction];
        }else{
            [alertController addAction:alertAction];
        }
        [self.window.rootViewController presentViewController:alertController animated:YES completion:nil];
    }
}

- (void)presentToViewController:(NSDictionary *)userInfo {
    
    NSDictionary *apsDic = [userInfo objectForKey:@"aps"];
    NSString *url = apsDic[@"url"];
    if (!url || url.length == 0) {
        return;
    }
    __block UIWindow *screenWindow;
    
    screenWindow = [[UIWindow alloc]initWithFrame:CGRectMake(0, 0, DEF_SCREEN_WIDTH, DEF_SCREEN_HEIGHT)];
    screenWindow.backgroundColor = [UIColor whiteColor];
    screenWindow.hidden = NO;
    
    HomeWebViewController *pushVC = [[HomeWebViewController alloc] init];
    pushVC.urlStr = url;
    
    pushVC.goBack = ^{
        screenWindow.hidden = YES;
        screenWindow.rootViewController = nil;
        [screenWindow removeFromSuperview];
        screenWindow = nil;
    };
    UINavigationController *debugSettingViewControllerNav = [[UINavigationController alloc] initWithRootViewController:pushVC];
    screenWindow.rootViewController = debugSettingViewControllerNav;
}
@end
