//
//  HomeWebViewController.h
//  YDProject
//
//  Created by guest1 on 16/10/5.
//  Copyright © 2016年 DYL. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomeWebViewController : UIViewController

@property (nonatomic,strong)NSString * urlStr;

@property (nonatomic,strong)NSString * isFrom;//1.从首页进入2.从点我请购进入3.从我的抽奖已中奖品进入

@property (nonatomic,strong)NSString * titleNav;

@property (nonatomic,strong)NSString * strJs;

@property (nonatomic,strong)NSString * zcID;//专场id

@property (nonatomic,strong)NSString * trackType;



@property (nonatomic, copy) void (^goBack)(void);


@end
