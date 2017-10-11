//
//  AppDelegate+UMengPush.h
//  YDProject
//
//  Created by guest1 on 17/7/26.
//  Copyright © 2017年 DYL. All rights reserved.
//

#import "AppDelegate.h"
#import "UMessage.h"

@interface AppDelegate (UMengPush)<UNUserNotificationCenterDelegate>

- (void)umengPushApplication:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions;

@end
