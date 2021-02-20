#import "ZWShareActivityView.h"
#import <ShareSDK/ShareSDK.h>
#import "AppDelegate.h"
#import <ShareSDK/SSDKTypeDefine.h>
#import <TencentOpenAPI/QQApiInterface.h>
#import "WXApi.h"
#import "ZWMoneyNetworkManager.h"
#import <ShareSDKUI/ShareSDK+SSUI.h>
#import "DAKeyboardControl.h"
#import "ZWIntegralRuleModel.h"
#import "ZWIntegralStatisticsModel.h"

#define WINDOW_COLOR                            [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4]
#define ACTIONSHEET_BACKGROUNDCOLOR             COLOR_F8F8F8
#define ANIMATE_DURATION                        0.25f

#define SHAREBUTTONTITLE_FONT                   [UIFont fontWithName:@"Helvetica-Bold" size:12]

#define SHAREBUTTON_WIDTH                       50
#define SHAREBUTTON_HEIGHT                      50
#define SHAREBUTTON_INTERVAL_WIDTH              24
#define SHAREBUTTON_INTERVAL_HEIGHT             40

#define SHARETITLE_WIDTH                        65
#define SHARETITLE_HEIGHT                       15
#define SHARETITLE_INTERVAL_WIDTH               24
#define SHARETITLE_INTERVAL_HEIGHT              SHAREBUTTON_WIDTH+SHAREBUTTON_INTERVAL_HEIGHT
#define SHARETITLE_FONT                         [UIFont fontWithName:@"Helvetica-Bold" size:16]

#define BUTTON_INTERVAL_HEIGHT                  0
#define BUTTON_HEIGHT                           45
#define BUTTON_INTERVAL_WIDTH                   40
#define BUTTON_WIDTH                            240
#define BUTTONTITLE_FONT                        [UIFont fontWithName:@"HelveticaNeue-Bold" size:18]
#define BUTTON_BORDER_WIDTH                     0.5f
#define BUTTON_BORDER_COLOR                     COLOR_E7E7E7.CGColor

#define TITLE_FONT    [UIFont fontWithName:@"Helvetica-Bold" size:15]

@interface ZWShareActivityView ()

/**背景视图*/
@property (nonatomic, strong) UIView *backGroundView;

/**分享内容*/
@property (nonatomic, strong) NSString *shareMessage;

/**短信分享信息内容*/
@property (nonatomic, strong) NSString *SMSMessage;

/**分享标题*/
@property (nonatomic, strong) NSString *title;

/**分享图片*/
@property (nonatomic, strong) UIImage *shareImage;

/**分享url*/
@property (nonatomic, strong) NSString *shareUrl;

/**用于判断是否拼接sf参数*/
@property (nonatomic, assign) BOOL isMarkSF;

/**分享完成状态block*/
@property (nonatomic, strong) ZWShareFinishBlock finish;

/**分享通知后台结果回调*/
@property (nonatomic, strong) ZWShareRequestResultBlock requestResultBlock;

/**分享参数model*/
@property (nonatomic, strong) ZWShareParametersModel *requestModel;

/**友盟统计事件名称*/
@property (nonatomic, copy) NSString *mobClickString;

/**是否属于普通分享（加入收藏则为特殊分享）*/
@property (nonatomic, assign) BOOL isNormalShare;

@end

@implementation ZWShareParametersModel

#pragma mark -init
+(id)shareParametersModelWithChannelId:(NSString *)channelID
                               shareID:(NSString *)shareID
                             shareType:(ShareType)shareType
                               orderID:(NSString *)orderID
{
    ZWShareParametersModel *model = [[ZWShareParametersModel alloc] init];
    [model setChannelID:channelID];
    [model setShareID:shareID];
    [model setShareType:shareType];
    [model setOrderID:orderID];
    return model;
}

@end

@implementation ZWShareActivityView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

#pragma mark - Public method

- (void)initQrcodeShareViewWithTitle:(NSString *)title
                             content:(NSString *)content
                                 SMS:(NSString *)message
                               image:(UIImage *)image
                                 url:(NSString *)url
                            mobClick:(NSString *)mobClick
                              markSF:(BOOL)isMarkSF
                         shareResult:(ZWShareFinishBlock)shareResult
{
    [self initWithTitle:title content:content SMS:message image:image url:url mobClick:mobClick markSF:isMarkSF isShowQrcode:YES isNormalShare:YES requestParametersModel:nil shareResult:shareResult requestResult:nil];
}


- (void)initCollectShareViewWithTitle:(NSString *)title
                              content:(NSString *)content
                                image:(UIImage *)image
                                  url:(NSString *)url
                             mobClick:(NSString *)mobClick
                               markSF:(BOOL)isMarkSF
                          shareResult:(ZWShareFinishBlock)shareResult
{
    [self initWithTitle:title content:content SMS:nil image:image url:url mobClick:mobClick markSF:isMarkSF isShowQrcode:NO isNormalShare:NO requestParametersModel:nil shareResult:shareResult requestResult:nil];
}

- (void)initCollectShareViewWithTitle:(NSString *)title
                              content:(NSString *)content
                                image:(UIImage *)image
                                  url:(NSString *)url
                             mobClick:(NSString *)mobClick
                               markSF:(BOOL)isMarkSF
               requestParametersModel:(ZWShareParametersModel *)model
                          shareResult:(ZWShareFinishBlock)shareResult
                        requestResult:(ZWShareRequestResultBlock)requestResult
{
    [self initWithTitle:title content:content SMS:nil image:image url:url mobClick:mobClick markSF:isMarkSF isShowQrcode:NO isNormalShare:NO requestParametersModel:model shareResult:shareResult requestResult:requestResult];
}


- (void)initNormalShareViewWithTitle:(NSString *)title
                             content:(NSString *)content
                                 SMS:(NSString *)message
                               image:(UIImage *)image
                                 url:(NSString *)url
                            mobClick:(NSString *)mobClick
                              markSF:(BOOL)isMarkSF
              requestParametersModel:(ZWShareParametersModel *)model
                         shareResult:(ZWShareFinishBlock)shareResult
                       requestResult:(ZWShareRequestResultBlock)requestResult
{
    [self initWithTitle:title content:content SMS:message image:image url:url mobClick:mobClick markSF:isMarkSF isShowQrcode:NO isNormalShare:YES requestParametersModel:model shareResult:shareResult requestResult:requestResult];
}


- (void)initNormalShareViewWithTitle:(NSString *)title
                             content:(NSString *)content
                                 SMS:(NSString *)message
                               image:(UIImage *)image
                                 url:(NSString *)url
                            mobClick:(NSString *)mobClick
                              markSF:(BOOL)isMarkSF
                         shareResult:(ZWShareFinishBlock)shareResult
{
    [self initWithTitle:title content:content SMS:message image:image url:url mobClick:mobClick markSF:isMarkSF isShowQrcode:NO isNormalShare:YES requestParametersModel:nil shareResult:shareResult requestResult:nil];
}

+ (BOOL)hasAuthorizedWeibo
{
    return [ShareSDK hasAuthorized:SSDKPlatformTypeSinaWeibo];
}

+ (void)cancelAuthorizedWeibo
{
    [ShareSDK cancelAuthorize:SSDKPlatformTypeSinaWeibo];
}

+ (void)authorizedWeiBo:(ZWWeiboAuthorizedResultBlock)result
{
    [ShareSDK authorize:SSDKPlatformTypeSinaWeibo settings:@{SSDKAuthSettingKeyScopes : @[@"all", @"mail"]} onStateChanged:^(SSDKResponseState state, SSDKUser *user, NSError *error) {
        if(state == SSDKResponseStateSuccess)
            result(YES);
        else if(state == SSDKResponseStateFail)
        {
            result(NO);
        }
        else if(state == SSDKResponseStateCancel)
        {
            result(NO);
        }
    }];
}

-  (void)initWithTitle:(NSString *)title
               content:(NSString *)content
                   SMS:(NSString *)message
                 image:(UIImage *)image
                   url:(NSString *)url
              mobClick:(NSString *)mobClick
                markSF:(BOOL)isMarkSF
          isShowQrcode:(BOOL)isShowQrcode
         isNormalShare:(BOOL)isNormalShare
requestParametersModel:(ZWShareParametersModel *)model
           shareResult:(ZWShareFinishBlock)shareResult
         requestResult:(ZWShareRequestResultBlock)requestResult

{
    ZWShareActivityView *shareAvti = [super init];
    if (shareAvti) {
        //初始化背景视图，添加手势
        shareAvti.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
        shareAvti.backgroundColor = WINDOW_COLOR;
        shareAvti.userInteractionEnabled = YES;
        shareAvti.tag = 500;
        
        shareAvti.shareImage = image;
        shareAvti.shareMessage = content;
        shareAvti.shareUrl = url;
        shareAvti.title = title;
        shareAvti.SMSMessage = message;
        shareAvti.finish = shareResult;
        shareAvti.requestModel = model;
        shareAvti.requestResultBlock = requestResult;
        
        shareAvti.isNormalShare = isNormalShare;
        
        shareAvti.mobClickString = mobClick;
        
        shareAvti.isMarkSF = isMarkSF;
        
        NSArray*  shareButtonTitleArray;
        NSArray* shareButtonImageNameArray;
        
        if(!isNormalShare)
        {
            shareButtonTitleArray = @[@"微信朋友圈",@"微信好友",@"新浪微博",@"QQ空间",@"QQ好友",@"微信收藏",@"加入收藏",@"复制链接"];
            shareButtonImageNameArray = @[@"wechatFrends_icon",@"wechat_icon",@"weibo_icon",@"qqzone_icon",@"QQ_icon",@"icon_wechatFavorites",@"icon_share_collection", @"copy_icon"];
        }
        else
        {
            shareButtonTitleArray = @[@"微信朋友圈",@"微信好友",@"微信收藏",@"QQ好友",@"QQ空间",@"新浪微博",@"复制链接",@"短信"];
            shareButtonImageNameArray = @[@"wechatFrends_icon",@"wechat_icon",@"icon_wechatFavorites",@"QQ_icon",@"qqzone_icon",@"weibo_icon",@"copy_icon", @"message_icon"];
        }
        
        [shareAvti creatButtonsWithTitle:nil
                       cancelButtonTitle:@"取消分享"
                       shareButtonTitles:shareButtonTitleArray
               withShareButtonImagesName:shareButtonImageNameArray
                            isShowQrcode:isShowQrcode];
    }
    [shareAvti show];
}

- (void)show
{
    self.tag = 666;
    [[UIApplication sharedApplication].delegate.window.rootViewController.view addSubview:self];
}

#pragma mark - Praviate method
- (void)creatButtonsWithTitle:(NSString *)title
            cancelButtonTitle:(NSString *)cancelButtonTitle
            shareButtonTitles:(NSArray *)shareButtonTitlesArray
    withShareButtonImagesName:(NSArray *)shareButtonImagesNameArray
                 isShowQrcode:(BOOL)isShowQrcode
{
    //生成LXActionSheetView
    self.backGroundView = [[UIView alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width, 0)];
    self.backGroundView.backgroundColor = ACTIONSHEET_BACKGROUNDCOLOR;
    [self addSubview:self.backGroundView];
    
    NSInteger hight = 0;
    if(isShowQrcode)
    {
        hight = 450;
    }
    else
    {
        hight = 300;
    }
    
    if(!isShowQrcode)
    {
        UILabel *titleLabel = [self creatTitleLabelWith:@"分享到"];
        [self.backGroundView addSubview:titleLabel];
    }
    else
    {
        [self.backGroundView addSubview:[self creatQrcodeView]];
    }
    
    for (int i = 1; i < shareButtonImagesNameArray.count+1; i++) {
        //计算出行数，与列数
        int column = (int)ceil((float)(i)/4); //行
        int line = (i)%4; //列
        if (line == 0) {
            line = 4;
        }
        UIButton *shareButton = [self creatShareButtonWithColumn:column andLine:line];
        [shareButton addTarget:self action:@selector(didClickOnImageIndex:) forControlEvents:UIControlEventTouchUpInside];
        
        [shareButton setBackgroundImage:[UIImage imageNamed:[shareButtonImagesNameArray objectAtIndex:i-1]] forState:UIControlStateNormal];
        shareButton.tag = i;
        
        int interval = [UIScreen mainScreen].bounds.size.width/4;
        
        [shareButton setFrame:CGRectMake(0, hight - 235 +((column-1)*(SHAREBUTTON_INTERVAL_HEIGHT+SHAREBUTTON_HEIGHT)), SHAREBUTTON_WIDTH, SHAREBUTTON_HEIGHT)];
        [shareButton setCenter:CGPointMake(interval/2 + (line-1)*interval, shareButton.center.y)];
        [self.backGroundView addSubview:shareButton];
        
        UILabel *shareLabel = [self creatShareLabelWithColumn:column andLine:line];
        shareLabel.text = [shareButtonTitlesArray objectAtIndex:i-1];
        [shareLabel setCenter:CGPointMake(interval/2 + (line-1)*interval, shareButton.center.y + 40)];
        [self.backGroundView addSubview:shareLabel];
    }
    
    UIButton *cancelButton = [self creatCancelButtonWith:cancelButtonTitle];
    [cancelButton addTarget:self action:@selector(didClickOnImageIndex:) forControlEvents:UIControlEventTouchUpInside];
    [cancelButton setFrame:CGRectMake(cancelButton.frame.origin.x, hight-cancelButton.frame.size.height, cancelButton.frame.size.width, cancelButton.frame.size.height)];
    [self.backGroundView addSubview:cancelButton];
    __block  BOOL isPersonWifiOpen=[AppDelegate sharedInstance].isPersonWifeOpen;
    [UIView animateWithDuration:ANIMATE_DURATION animations:^{
        [self.backGroundView setFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height-(isPersonWifiOpen?hight+20:hight), [UIScreen mainScreen].bounds.size.width, hight)];
    } completion:^(BOOL finished) {
    }];
}

- (UILabel *)creatTitleLabelWith:(NSString *)title
{
    UILabel *titlelabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 44)];
    titlelabel.backgroundColor = [UIColor clearColor];
    titlelabel.textAlignment = NSTextAlignmentCenter;
    titlelabel.layer.borderWidth = 0.5f;
    titlelabel.layer.borderColor = [COLOR_E7E7E7 CGColor];
    titlelabel.layer.masksToBounds = YES;
    titlelabel.font = [UIFont systemFontOfSize:16];
    titlelabel.text = title;
    titlelabel.textColor = COLOR_333333;
    return titlelabel;
}

- (UIButton *)creatCancelButtonWith:(NSString *)cancelButtonTitle
{
    UIButton *cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(0, BUTTON_INTERVAL_HEIGHT, self.frame.size.width, BUTTON_HEIGHT)];
    
    cancelButton.layer.borderWidth = BUTTON_BORDER_WIDTH;
    cancelButton.layer.borderColor = BUTTON_BORDER_COLOR;
    
    [cancelButton setBackgroundColor:[UIColor colorWithHexString:@"#f0f0f0"]];
    
    [cancelButton setTitle:@"取 消" forState:UIControlStateNormal];
    cancelButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [cancelButton setTitleColor:COLOR_333333 forState:UIControlStateNormal];
    cancelButton.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2, cancelButton.center.y);
    
    return cancelButton;
}
/**
 *  创建二维码界面
 */
- (UIView *)creatQrcodeView
{
    UIView *codeView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 200)];
    codeView.backgroundColor = [UIColor colorWithHexString:@"#fcfcfc"];
    codeView.layer.borderColor = [[UIColor colorWithHexString:@"#dedede"] CGColor];
    codeView.layer.borderWidth = 0.5f;
    
    UIImage *codeImage = [UIImage imageNamed:@"icon_qrcode"];
    UIImageView *qrcodeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 20, codeImage.size.width, codeImage.size.height)];
    qrcodeImageView.image = codeImage;
    qrcodeImageView.center = CGPointMake(SCREEN_WIDTH/2, qrcodeImageView.center.y);
    [codeView addSubview:qrcodeImageView];
    
    ZWIntegralRuleModel *itemRule=(ZWIntegralRuleModel *)[ZWIntegralStatisticsModel saveIntergralItemData:IntegralRegistration];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 20+codeImage.size.height + 15, SCREEN_WIDTH, 15)];
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = [NSString stringWithFormat:@"扫一扫下载并读，填邀请码即可为你增加%.f积分", [itemRule.pointValue floatValue]];
    label.textColor = COLOR_333333;
    
    if(SCREEN_WIDTH > 320)
        label.font = [UIFont systemFontOfSize:13.];
    else
        label.font = [UIFont systemFontOfSize:12.];
    [codeView addSubview:label];
    
    NSMutableAttributedString *notice =
    [[NSMutableAttributedString alloc] initWithString:@"邀请码:"
                                           attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:18],NSForegroundColorAttributeName:COLOR_333333}];
    [notice appendAttributedString:
     [[NSAttributedString alloc] initWithString:[ZWUserInfoModel sharedInstance].myCode
                                     attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:18],NSForegroundColorAttributeName:COLOR_MAIN}]];
    
    UILabel *codeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 20+codeImage.size.height + 15*3, SCREEN_WIDTH, 25)];
    codeLabel.backgroundColor = [UIColor clearColor];
    codeLabel.textAlignment = NSTextAlignmentCenter;
    codeLabel.textColor = COLOR_333333;
    codeLabel.font = [UIFont systemFontOfSize:18.];
    codeLabel.attributedText = notice;
    [codeView addSubview:codeLabel];
    
    return codeView;
}
/**
 *  创建分享按钮
 */
- (UIButton *)creatShareButtonWithColumn:(int)column andLine:(int)line
{
    UIButton *shareButton = [[UIButton alloc] initWithFrame:CGRectMake(SHAREBUTTON_INTERVAL_WIDTH+((line-1)*(SHAREBUTTON_INTERVAL_WIDTH+SHAREBUTTON_WIDTH)), SHAREBUTTON_INTERVAL_HEIGHT+((column-1)*(SHAREBUTTON_INTERVAL_HEIGHT+SHAREBUTTON_HEIGHT)), SHAREBUTTON_WIDTH, SHAREBUTTON_HEIGHT)];
    return shareButton;
}
/**
 *  创建每个分享的标题
 */
- (UILabel *)creatShareLabelWithColumn:(int)column andLine:(int)line
{
    UILabel *shareLabel = [[UILabel alloc] initWithFrame:CGRectMake(SHARETITLE_INTERVAL_WIDTH+((line-1)*(SHARETITLE_INTERVAL_WIDTH+SHARETITLE_WIDTH)), SHARETITLE_INTERVAL_HEIGHT+((column-1)*(SHARETITLE_INTERVAL_HEIGHT))+ 30, SHARETITLE_WIDTH, SHARETITLE_HEIGHT)];
    
    shareLabel.backgroundColor = [UIColor clearColor];
    shareLabel.textAlignment = NSTextAlignmentCenter;
    shareLabel.font = [UIFont systemFontOfSize:13];
    shareLabel.textColor = COLOR_333333;
    return shareLabel;
}

/**
 *  判断是否图片需要压缩，如果要压缩图片
 */
-(void)compressImage:(SSDKPlatformType)type
{
    NSData *sendImageData = UIImageJPEGRepresentation(self.shareImage, 1.0);
    NSUInteger sizeOrigin = [sendImageData length];
    NSUInteger sizeOriginKB = sizeOrigin / 1024;
    NSInteger size = 200;
    if(type == SSDKPlatformSubTypeWechatTimeline || type == SSDKPlatformSubTypeWechatFav || type == SSDKPlatformSubTypeWechatSession)
    {
        size = 50;
    }
    if (sizeOriginKB>size)
    {
        self.shareImage=[self imageCompressForWidth:self.shareImage targetWidth:size];
    }
}

-(UIImage *) imageCompressForWidth:(UIImage *)sourceImage targetWidth:(CGFloat)defineWidth
{
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = defineWidth;
    CGFloat targetHeight = (targetWidth / width) * height;
    UIGraphicsBeginImageContext(CGSizeMake(targetWidth, targetHeight));
    [sourceImage drawInRect:CGRectMake(0,0,targetWidth,  targetHeight)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (void)mobclickCount:(SSDKPlatformType)type
{
    if(!self.mobClickString || self.mobClickString.length == 0)
    {
        return;
    }
    
    switch (type) {
        case SSDKPlatformTypeSinaWeibo:
            [MobClick event:[NSString stringWithFormat:@"share_weibo%@", self.mobClickString]];
            break;
        case SSDKPlatformSubTypeQZone:
            [MobClick event:[NSString stringWithFormat:@"share_qzone%@", self.mobClickString]];
            break;
        case SSDKPlatformTypeCopy:
            [MobClick event:[NSString stringWithFormat:@"share_copy%@", self.mobClickString]];
            break;
        case SSDKPlatformSubTypeWechatSession:
            [MobClick event:[NSString stringWithFormat:@"share_wechat%@", self.mobClickString]];
            break;
        case SSDKPlatformSubTypeWechatTimeline:
            [MobClick event:[NSString stringWithFormat:@"share_wechat_friends%@", self.mobClickString]];
            break;
        case SSDKPlatformSubTypeQQFriend:
            [MobClick event:[NSString stringWithFormat:@"share_qq%@", self.mobClickString]];
            break;
        case SSDKPlatformSubTypeWechatFav:
            [MobClick event:[NSString stringWithFormat:@"share_wechat_collect%@", self.mobClickString]];
            break;
            
        case SSDKPlatformTypeUnknown:
            [MobClick event:[NSString stringWithFormat:@"share_collect%@", self.mobClickString]];
            break;
            
        default:
            break;
    }
    
}

#pragma mark - Event handler
/**
 *  分享按钮触发方法
 *  @param  button 分享按钮
 */
- (void)didClickOnImageIndex:(UIButton *)button
{
    if (button.tag != 0) {
        [self shareWithButton:button];
    }
    else
    {
        [self finish](SSDKResponseStateBegin, SSDKPlatformTypeUnknown, nil, nil, nil);
    }
    [self tappedCancel];
}

- (void)tappedCancel
{
    [UIView animateWithDuration:ANIMATE_DURATION animations:^{
        [self.backGroundView setFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width, 0)];
        self.alpha = 0;
    } completion:^(BOOL finished) {
        if (finished) {
                [self removeFromSuperview];
        }
    }];
}

+ (void)disMissShareView
{
    ZWShareActivityView *view =  (ZWShareActivityView *)[[UIApplication sharedApplication].delegate.window.rootViewController.view viewWithTag:666];
    [UIView animateWithDuration:ANIMATE_DURATION animations:^{
        [view.backGroundView setFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width, 0)];
        view.alpha = 0;
    } completion:^(BOOL finished) {
        if (finished) {
            [view removeFromSuperview];
        }
    }];
}

- (void)shareWithButton:(UIButton *)sender
{
    //分享的ShareType类型
    NSArray *typeArray = self.isNormalShare == YES ? @[@"23", @"22",@"37", @"24", @"6", @"1", @"21", @"19"] : @[@"23", @"22",@"1", @"6", @"24", @"37", @"0", @"21"];
    
    SSDKPlatformType type = (SSDKPlatformType)[[typeArray objectAtIndex:sender.tag - 1] integerValue];
    
    //分享QQ空间时，检测用户手机未安装QQ客户端则弹出提示
    if(type == SSDKPlatformSubTypeQZone || type == SSDKPlatformSubTypeQQFriend)
    {
        if(![QQApiInterface isQQInstalled])
        {
            hint(@"尚未安装手机QQ");
            return;
        }
    }
    
    if(type == SSDKPlatformSubTypeWechatTimeline || type == SSDKPlatformSubTypeWechatFav || type == SSDKPlatformSubTypeWechatSession)
    {
        if(![WXApi isWXAppInstalled])
        {
            hint(@"尚未安装微信");
            return;
        }
    }
    
    NSArray *shareChannels = self.isNormalShare == YES ? @[@"1", @"2", @"3", @"7", @"8", @"4", @"6", @"5"] : @[@"1", @"2", @"4", @"8", @"7", @"3", @"5", @"6"];
    
    //新闻详情分享URL添加fs参数
    BOOL isShareNewsDetail = NO;
    if([self.shareUrl rangeOfString:@"&sf="].location != NSNotFound)
    {
        self.shareUrl = [self.shareUrl stringByReplacingOccurrencesOfString:@"&sf=" withString:@""];
        isShareNewsDetail = YES;
    }
    NSString *beforeReplaceString = [NSString stringWithFormat:@"%@", [self shareUrl]];
    if(self.isMarkSF)
    {
        self.shareUrl = [NSString stringWithFormat:@"%@&sf=%@", self.shareUrl, [shareChannels objectAtIndex:sender.tag-1]];
    }
    
    if(type == SSDKPlatformTypeSinaWeibo)
    {
        NSString *sinaMessage = [self.shareMessage rangeOfString:@"邀请码【"].location == NSNotFound ? [NSString stringWithFormat:@"【%@】%@", self.title,self.shareMessage] : [NSString stringWithFormat:@"分享@并读 ：%@", self.shareMessage];
        
        if(sinaMessage && [sinaMessage rangeOfString:@"http"].location == NSNotFound)
        {
            sinaMessage = [NSString stringWithFormat:@"%@...%@", sinaMessage, self.shareUrl];
        }
        else if(sinaMessage && [sinaMessage rangeOfString:@"http"].location != NSNotFound)
        {
            sinaMessage = [sinaMessage stringByReplacingOccurrencesOfString:beforeReplaceString withString:self.shareUrl];
        }
        if(isShareNewsDetail == YES)
        {
            sinaMessage = [NSString stringWithFormat:@"分享@并读 ：%@", sinaMessage];
        }
        self.shareMessage = [sinaMessage copy];
    }
    if((type == SSDKPlatformSubTypeWechatTimeline || type == SSDKPlatformSubTypeQQFriend || type == SSDKPlatformSubTypeWechatFav || type == SSDKPlatformSubTypeWechatSession || type == SSDKPlatformSubTypeQZone) && [self.shareMessage rangeOfString:@"邀请码【"].location != NSNotFound)
    {
        self.shareMessage = @"并读，在亿万种生活方式中，精选最贴合你的生活资讯。";
    }
    
    if(type == SSDKPlatformTypeSMS)
    {
        self.shareMessage = self.SMSMessage;
    }

    [self compressImage:type];
    
    [self mobclickCount:type];
    
    if(type == SSDKPlatformTypeCopy)//复制类型
    {
        [self finish](SSDKResponseStateBegin, SSDKPlatformTypeCopy, nil, nil, nil);
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = self.shareUrl;
        [self requestShareInfo:6];
        occasionalHint(@"复制成功");
    }
    else if(type == SSDKPlatformTypeUnknown)//加入收藏
    {
        [self finish](SSDKResponseStateSuccess, SSDKPlatformTypeUnknown, nil, nil, nil);
    }
    else
    {
        //创建分享参数
        NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
        
        UIImage * image = [UIImage imageNamed:@"icon_logo"];
        
        if(self.shareImage != nil || self.shareImage != NULL)
        {
            image = self.shareImage;
        }
        
        NSArray* imageArray = @[image];
        //短信分享不需要图标
        if(type == SSDKPlatformTypeSMS)
        {
            imageArray = @[];
        }
        
        [shareParams SSDKSetupShareParamsByText:self.shareMessage
                                         images:imageArray
                                            url:[NSURL URLWithString:self.shareUrl]
                                          title:self.title
                                           type:SSDKContentTypeAuto];
        
        if(type == SSDKPlatformTypeSinaWeibo)
        {
            [self finish](SSDKResponseStateBegin, SSDKPlatformTypeSinaWeibo, nil, nil, nil);
            
            [ShareSDK showShareEditor:SSDKPlatformTypeSinaWeibo
                   otherPlatformTypes:@[]
                          shareParams:shareParams
                  onShareStateChanged:^(SSDKResponseState state, SSDKPlatformType platformType, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error, BOOL end)
             {
                 [self finish](state, SSDKPlatformTypeSinaWeibo, userData, contentEntity, error);
                 if (state == SSDKResponseStateSuccess)
                 {
                     [self requestShareInfo:[[shareChannels objectAtIndex:sender.tag-1] integerValue]];
                 }
             }];
        }
        else
        {
            //进行分享
            [ShareSDK share:type
                 parameters:shareParams
             onStateChanged:^(SSDKResponseState state, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error) {
                 
                 [self finish](state, type, userData, contentEntity, error);
                 if (state == SSDKResponseStateSuccess)
                 {
                     [self requestShareInfo:[[shareChannels objectAtIndex:sender.tag-1] integerValue]];
                 }
             }];
        }
    }
}


+ (void)shareSinaWithTitle:(NSString *)title
                   content:(NSString *)content
                     image:(UIImage *)image
                       url:(NSString *)url
    requestParametersModel:(ZWShareParametersModel *)model
               shareResult:(ZWShareFinishBlock)shareResult
             requestResult:(ZWShareRequestResultBlock)requestResult
{
    //创建分享参数
    NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
    
    UIImage * shareImage = image ? image : [UIImage imageNamed:@"logo"];
    
    NSArray* imageArray = @[shareImage];
    
    NSString *sinaMessage = [NSString stringWithFormat:@"【%@】%@", title,content];
    if([sinaMessage rangeOfString:@"http"].location == NSNotFound)
    {
        sinaMessage = [NSString stringWithFormat:@"%@...%@", sinaMessage, url];
    }
    sinaMessage = [NSString stringWithFormat:@"分享@并读 ：%@", sinaMessage];
    
    [shareParams SSDKSetupShareParamsByText:sinaMessage
                                     images:imageArray
                                        url:[NSURL URLWithString:url]
                                      title:title
                                       type:SSDKContentTypeAuto];

    if (shareResult)
    {
         shareResult(SSDKResponseStateBegin, SSDKPlatformTypeSinaWeibo, nil, nil, nil);
    }
   

    //进行分享
    [ShareSDK share:SSDKPlatformTypeSinaWeibo
         parameters:shareParams
     onStateChanged:^(SSDKResponseState state, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error)
    {
        if (shareResult)
        {
            shareResult(state, SSDKPlatformTypeSinaWeibo, userData, contentEntity, error);
        }
        
         
         if (state == SSDKResponseStateSuccess)
         {
             if(model && requestResult)
             {
                 [[ZWMoneyNetworkManager sharedInstance]
                  updateShareWithChannelID:model.channelID
                  shareType:model.shareType
                  ShareID:[model.shareID integerValue]
                  orderID:model.orderID
                  shareChannel:1
                  succed:^(id result) {
                      if(result && [result isKindOfClass:[NSString class]] && [result length] > 0)
                      {
                          requestResult(YES, [result boolValue], nil);
                      }
                      else
                      {
                          requestResult(YES, NO, nil);
                      }
                  } failed:^(NSString *errorString) {
                      
                      requestResult(NO, NO, errorString);
                  }];
             }
         }
     }];
}

#pragma mark - network
/**分享通知后台接口*/
- (void)requestShareInfo:(NSInteger)shareChannel
{
    if(self.requestModel && self.requestResultBlock )
    {
        [[ZWMoneyNetworkManager sharedInstance]
         updateShareWithChannelID:self.requestModel.channelID
                        shareType:self.requestModel.shareType
                          ShareID:[self.requestModel.shareID integerValue]
                          orderID:self.requestModel.orderID
                     shareChannel:shareChannel
                           succed:^(id result) {
                               if(result && [result isKindOfClass:[NSString class]] && [result length] > 0)
                               {
                                   self.requestResultBlock(YES, [result boolValue], nil);
                               }
                               else
                               {
                                   self.requestResultBlock(YES, NO, nil);
                               }
            
            
        } failed:^(NSString *errorString) {
            
            self.requestResultBlock(NO, NO, errorString);
            
        }];
    }
}

@end
