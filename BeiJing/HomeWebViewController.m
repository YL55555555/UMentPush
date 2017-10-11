//
//  HomeWebViewController.m
//  YDProject
//
//  Created by guest1 on 16/10/5.
//  Copyright © 2016年 DYL. All rights reserved.
//
#define DEF_SCREEN_WIDTH [[UIScreen mainScreen] bounds].size.width
#define DEF_SCREEN_HEIGHT [[UIScreen mainScreen] bounds].size.height

#import "HomeWebViewController.h"
#import <WebKit/WebKit.h>

@interface HomeWebViewController ()<WKNavigationDelegate>

@property (nonatomic,strong)WKWebView * wkWebView;
@property (nonatomic,strong)UIProgressView * progressview;//进度条
@property (nonatomic,assign)NSUInteger loadCount;

@property (nonatomic, strong)WKWebViewConfiguration * config;

@property (nonatomic,strong)NSString * jsStr;

@end

@implementation HomeWebViewController



-(WKWebView *)wkWebView
{
    if (!_wkWebView) {

        _wkWebView = [[WKWebView alloc]initWithFrame:CGRectMake(0, 0, DEF_SCREEN_WIDTH, DEF_SCREEN_HEIGHT)];
        [self.view addSubview:_wkWebView];
        
        _progressview = [[UIProgressView alloc]initWithFrame:CGRectMake(0, 0, DEF_SCREEN_WIDTH, 5)];
        _progressview.progressTintColor = [UIColor blueColor];
        _progressview.trackTintColor = [UIColor whiteColor];
        [_progressview setProgress:0.1f animated:YES];
        [self.view addSubview:_progressview];
        
        _wkWebView.navigationDelegate = self;

        [_wkWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.urlStr]]];
        _wkWebView.scrollView.showsVerticalScrollIndicator = NO;
        [self.view insertSubview:_wkWebView belowSubview:self.progressview];
        
    }
    return _wkWebView;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];


    [self.wkWebView removeObserver:self forKeyPath:@"estimatedProgress"];

    [self.wkWebView removeObserver:self forKeyPath:@"title"];

    [self.wkWebView removeObserver:self forKeyPath:@"loading"];


}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self.wkWebView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    [self.wkWebView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:nil];
    [self.wkWebView addObserver:self forKeyPath:@"loading" options:NSKeyValueObservingOptionNew context:nil];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    NSLog(@"urlStr:%@",self.urlStr);
    self.title = self.titleNav;

    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(0, 0, 22, 22);
    //    backBtn.titleEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 0);
    [backBtn setImage:[UIImage imageNamed:@"back_bt_7"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(doBack) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    self.navigationItem.leftBarButtonItem = backItem;


    [self wkWebView];

}

#pragma mark - wkwebview代理

-(void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    decisionHandler(WKNavigationActionPolicyAllow);


}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {

    if (object == self.wkWebView && [keyPath isEqualToString:@"estimatedProgress"]) {

        [self.progressview setAlpha:1.f];
        [self.progressview setProgress:self.wkWebView.estimatedProgress animated:YES];
        if (self.wkWebView.estimatedProgress >= 1.f) {
            [UIView animateWithDuration:0.3 delay:0.3 options:UIViewAnimationOptionCurveEaseOut animations:^{
                [self.progressview setAlpha:0.0f];
            } completion:^(BOOL finished) {
                [self.progressview setProgress:0.0f animated:NO];
            }];
        }

    }

    if (self.titleNav.length == 0) {
        if ([keyPath isEqualToString:@"title"]) {
            self.title = self.wkWebView.title;
        }
    }


}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
