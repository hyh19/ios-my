//
//  XXWebViewController.m
//  LiveShow
//
//  Created by lgh on 16/2/18.
//  Copyright © 2016年 XX. All rights reserved.
//
#import "FBWebViewController.h"
#import "FBFailureView.h"
#import "FBTAViewController.h"
#import "FBLivePlayViewController.h"
#import "FBLiveInfoModel.h"


@interface FBWebViewController ()<UIWebViewDelegate>

@property (nonatomic, strong) FBFailureView *failureView;

@end

@implementation FBWebViewController

#pragma mark - Init -
- (instancetype)initWithTitle:(NSString *)title url:(NSString *)url formattedURL:(BOOL)isFormatted {
    self.hidesBottomBarWhenPushed = YES;
    self.navigationItem.title = title;
    NSString *formattedURL = [FBHTTPSessionManager formatedURLString:url];
    NSURL *URL = isFormatted ? [NSURL URLWithString:formattedURL] : [NSURL URLWithString:url];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    [self.webView loadRequest:request];
    return self;
}


- (instancetype)initWithTitle:(NSString *)title
                          url:(NSString *)url
                 formattedURL:(BOOL)isFormatted
                 navRightItem:(UIBarButtonItem *)item {
    self.hidesBottomBarWhenPushed = YES;
    self.navigationItem.title = title;
    self.navigationItem.rightBarButtonItem = item;
    NSString *formattedURL = [FBHTTPSessionManager formatedURLString:url];
    NSURL *URL = isFormatted ? [NSURL URLWithString:formattedURL] : [NSURL URLWithString:url];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    [self.webView loadRequest:request];
    return self;
}


#pragma mark - Life Cycle -
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.webView];
}

#pragma mark - UI Management -
- (FBFailureView *)failureView {
    if (!_failureView) {
        _failureView = [[FBFailureView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGH) image:kLogoFailureView message:kLocalizationNetworkError];
    }
    return _failureView;
}

- (UIWebView *)webView {
    if (!_webView) {
        _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGH)];
        _webView.scrollView.contentInset = UIEdgeInsetsMake(0, 0, 60, 0);
        _webView.delegate = self;
    }
    return _webView;
}
#pragma mark - UIWebViewDelegate -
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    NSString *url= [[request URL] absoluteString];
    
    if ([url hasPrefix:@"itsme://live_room"]) {
        //直播间
        [self pushLiveRoomControllerWithURL:url];
        
    } else if ([url hasPrefix:@"itsme://personal"]) {
        //个人主页
        [self pushTaViewControllerWithURL:url];
        
    } else {
        
        NSLog(@"url = %@",url);
    }
    
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [self.failureView removeFromSuperview];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.webView animated:YES];
    hud.yOffset = -60;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [MBProgressHUD hideAllHUDsForView:self.webView animated:YES];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [MBProgressHUD hideAllHUDsForView:self.webView animated:YES];
}


#pragma mark - Data Management -
- (NSMutableDictionary *)dictionryParameterFromURL:(NSString *)URLString {
    //itsme://personal?nick=%E0%B9%80&uid=2085594&portrait=5594.jpg
    
    //nick=%E0%B9%80&uid=2085594&portrait=5594.jpg
    NSString *parametersString = [[URLString componentsSeparatedByString:@"?"] lastObject];
    //转码
    NSString *encodingString = [parametersString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    // nick=%E0%B9%80 uid=2085594 portrait=5594.jpg
    NSArray *parameterArray = [encodingString componentsSeparatedByString:@"&"];
    
    NSMutableDictionary *parameterDict = [NSMutableDictionary dictionary];
    for (NSString *parameter in parameterArray) {
        
        NSMutableArray *parameters = [[parameter componentsSeparatedByString:@"="] copy];
        if (parameters.count < 2) {
            [parameters addObject:@"null"];
        }
        
        [parameterDict setValue:parameters[1] forKey:parameters[0]];
    }
    return parameterDict;
}

- (FBUserInfoModel *)userInfoFromParameterDict:(NSMutableDictionary *)dict {
    FBUserInfoModel *userInfo = [[FBUserInfoModel alloc] init];
    userInfo.userID = dict[@"uid"];
    userInfo.portrait = dict[@"portrait"];
    userInfo.nick = dict[@"nick"];
    return userInfo;
}

- (FBLiveInfoModel *)liveInfoFromParameterDict:(NSMutableDictionary *)dict userInfo:(FBUserInfoModel *)userInfo{
    FBLiveInfoModel *liveInfo = [[FBLiveInfoModel alloc] init];
    liveInfo.city = dict[@"city"];
    liveInfo.broadcaster = userInfo;
    liveInfo.group = @([dict[@"group"] intValue]);
    liveInfo.live_id = dict[@"id"];
    liveInfo.roomID = dict[@"room_id"];
    return liveInfo;
}

#pragma mark - Event Handler -

#pragma mark - Navigation -
- (void)pushLiveRoomControllerWithURL:(NSString *)url {
    //itsme://live_room?city=&group=20004&id=713265502&creator=2085594&image=&online_users=201&pub_stat=1&room_id=95255&share_addr=null&status=1&stream_addr=null&version=0&uid=2085594&portrait=0c76d1abcaec_2085594.jpg
    
    NSMutableDictionary *parameterDict = [self dictionryParameterFromURL:url];
    
    FBUserInfoModel *userInfo = [self userInfoFromParameterDict:parameterDict];
    
    FBLiveInfoModel *liveInfo = [self liveInfoFromParameterDict:parameterDict userInfo:userInfo];

    FBLivePlayViewController *liveController = [[FBLivePlayViewController alloc] initWithModel:liveInfo];
    [liveController startPlay];
    [self.navigationController pushViewController:liveController animated:YES];
}

- (void)pushTaViewControllerWithURL:(NSString *)url {
    //    itsme://personal?nick=%E0%B9%80&uid=2085594&portrait=5594.jpg
    
    NSMutableDictionary *parameterDict = [self dictionryParameterFromURL:url];
    
    FBUserInfoModel *userInfo = [[FBUserInfoModel alloc] init];
    userInfo.userID = parameterDict[@"uid"];
    userInfo.portrait = parameterDict[@"portrait"];
    userInfo.nick = parameterDict[@"nick"];
    
    FBTAViewController *taController = [FBTAViewController taViewController:userInfo];
    [self.navigationController pushViewController:taController animated:YES];
}


#pragma mark -overRide-
//后退/返回上一个控制器
- (void)goBack {
    if ([_webView canGoBack] && !self.immediateBack) {
        [_webView goBack];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (BOOL)fd_interactivePopDisabled {
    return YES;
}
@end
