
#import "ZWNewsImageCommentManager.h"
#import "UIWebView+Additions.h"
#import "ZWLoginViewController.h"
#import "ZWNewsNetworkManager.h"
#import "ZWNewsWebview.h"
@interface ZWNewsImageCommentManager()<UIGestureRecognizerDelegate>
{
    
}
/**添加图评的view*/
@property(nonatomic,strong)UIView *commentParentView;
/**新闻id*/
@property(nonatomic,strong)NSString *newsId;
/**图片详情某张图片的url*/
@property(nonatomic,strong)NSString *imageUrl;
/**结果回调*/
@property(nonatomic,copy)imageCommentResultCallBack imageCommentLoadResultCallBack;
/**发送图片评论Model*/
@property (nonatomic,strong)ZWImageCommentModel *imageCommentModel;
/**图片评论数据*/
@property (nonatomic,strong)NSMutableDictionary *imageCommentList;
@end
@implementation ZWNewsImageCommentManager

#pragma mark - life cycle -
-(id)initWithImageCommentType:(UIView*) commentView newsID:(NSString*)newsId imageUrl:(NSString*) imageComentUrl loadResultBlock:(imageCommentResultCallBack) imageCommentLoadResultCallBack
{
    self=[super init];
    if (self)
    {
        _commentParentView=commentView;
        _newsId=newsId;
        _imageUrl=imageComentUrl;
        _imageCommentLoadResultCallBack=imageCommentLoadResultCallBack;
        [self addLongPressGesture];
        if ([commentView isKindOfClass:[UIWebView class]])
        {
            [self loadNewsImageCommentData];
        }
        
    }
    return self;
}
-(void)dealloc
{
    ZWLog(@"ZWNewsImageCommentManager dealloc");
}

#pragma mark - Event handle -
//图评长按手势响应
-(void)longtap:(UILongPressGestureRecognizer * )longtapGes
{
    if (longtapGes.state == UIGestureRecognizerStateBegan)
    {
        CGPoint pt = [longtapGes locationInView:_commentParentView];
        // convert point from view to HTML coordinate system
        /**新闻详情的图评*/
        if ([_commentParentView isKindOfClass:[UIWebView class]])
        {
            /**如果以前有图评编辑框，先删除以前的*/
            UIWebView *imageWebView=(UIWebView*)_commentParentView;
            UIView *subView=[imageWebView.scrollView viewWithTag:8759];
            if (subView && [subView isKindOfClass:[ZWImageCommentView class]] && [subView viewWithTag:9801])
            {
                [subView removeFromSuperview];
                subView=nil;
            }
            if ([self isPressOnImage:longtapGes])
            {
                //判断用户受否登陆 登陆则执行发送 无登陆则跳转登陆
                if(![ZWUserInfoModel login])
                {
                    ZWLoginViewController *loginView = [[ZWLoginViewController alloc] init];
                    UIViewController* controller=(UIViewController*)[imageWebView.superview.superview nextResponder];
                    [controller.navigationController pushViewController:loginView animated:YES];
                    return;
                }
                
                [self constructImageCommentModel:pt];
                [self startImageComment:pt];
            }
            
            
        }
        /**图片详情的图评*/
        else if ([_commentParentView isKindOfClass:[UIImageView class]])
        {
            /**如果以前有图评编辑框，先删除以前的*/
            UIView *subView=[_commentParentView viewWithTag:8759];
            if (subView)
            {
                [subView removeFromSuperview];
                subView=nil;
            }
            UIImageView *imageCommentImageView=(UIImageView*)_commentParentView;
            UIScrollView *imageCommentSrollview=(UIScrollView*)_commentParentView.superview;
            if(![ZWUserInfoModel login])
            {
                ZWLoginViewController *loginView = [[ZWLoginViewController alloc] init];
                UIViewController *controller=(UIViewController*)imageCommentSrollview.superview.superview.nextResponder;
                UINavigationController *nav=controller.navigationController;
                [nav  pushViewController:loginView animated:YES];
                return;
            }
            
            CGPoint imagePt = [longtapGes locationInView:imageCommentImageView];
            [self constructImageCommentModel:imagePt];
            if(imageCommentSrollview.zoomScale>1.0f)
                [imageCommentSrollview setZoomScale:1.0f animated:NO];
            
            CGPoint pt = [longtapGes locationInView:imageCommentSrollview];
            [self startImageComment:pt];
            
        }
        
    }
    else if (longtapGes.state == UIGestureRecognizerStateEnded)
    {
        /**图片详情的图评，必须加上以下代码*/
        if ([_commentParentView isKindOfClass:[UIImageView class]])
        {
            UIScrollView *imageCommentSrollview=(UIScrollView*)_commentParentView.superview;
            CGPoint oldContentOffset=imageCommentSrollview.contentOffset;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [imageCommentSrollview setContentOffset:oldContentOffset animated:YES];
            });
            ZWLog(@"the oldContentoffset is %f,%f",oldContentOffset.x,oldContentOffset.y);
        }
    }
}

/**文字增加复制功能，当长按图片时，两个事件不能同时发生，只响应一个事件*/
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if ([self isPressOnImage:gestureRecognizer])
    {
        return NO;
    }
    return YES;
    
}
#pragma mark - private mothods -

/**判断发表评论是否超过30秒*/
-(BOOL)judgeIsCanCommit
{
    NSDate *lastSendDate=[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@",self.newsId]];
    if (lastSendDate)
    {
        NSTimeInterval lastTimeFloat=[lastSendDate timeIntervalSince1970];
        NSTimeInterval nowTimeFloat=[[NSDate date] timeIntervalSince1970];
        NSTimeInterval disTime=nowTimeFloat-lastTimeFloat;
        if (disTime<30)
        {
            return NO;
        }
    }
    
    return YES;
}
/**增加长按手势到webview*/
-(void)addLongPressGesture
{
    UILongPressGestureRecognizer *longtapGesture = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longtap:)];
    longtapGesture.minimumPressDuration=0.45f;
    longtapGesture.delegate=self;
    [_commentParentView addGestureRecognizer:longtapGesture];
    
    
}
//构建发送图评的model数据
-(void)constructImageCommentModel:(CGPoint)pt
{
    
    if ([_commentParentView isKindOfClass:[UIWebView class]])
    {
        UIWebView *imageWebView=(UIWebView*)_commentParentView;
        
        NSString *imageInfoStr = [imageWebView stringByEvaluatingJavaScriptFromString:
                                  [NSString stringWithFormat:@"getElementsInfoAtPoint(%li,%li);",(NSInteger)pt.x,(NSInteger)pt.y-24]];
        ZWLog(@"the imageInfoStr is %@",imageInfoStr);
        if ([imageInfoStr containsString:@"finishimageurl:"] && [imageInfoStr containsString:@"frame:"])
        {
            
            NSArray *strArray=[imageInfoStr componentsSeparatedByString:@"&frame:"];
            NSString *imageUrlStr=[[[strArray objectAtIndex:0]
                                    componentsSeparatedByString:@"finishimageurl:"] objectAtIndex:1];
            if (!imageUrlStr || imageUrlStr.length<=1)
            {
                return;
            }
            ZWLog(@"the imageUrlStr is %@",imageUrlStr);
            NSString *frameStr=[strArray objectAtIndex:1];
            if (!frameStr || frameStr.length<=1) {
                return;
            }
            NSArray *framArray=[frameStr componentsSeparatedByString:@","];
            //图片的frame
            if(framArray.count<4)
                return;
            CGFloat y=[framArray[0] floatValue];
            CGFloat x=[framArray[1] floatValue];
            CGFloat width=[framArray[2] floatValue];
            CGFloat height=[framArray[3] floatValue];
            //计算相对于图片的坐标百分比
            CGFloat xPercent=(pt.x-x)/width;
            CGFloat yPercent=(pt.y+imageWebView.scrollView.contentOffset.y-y)/height;
            
            ZWImageCommentModel *model=[[ZWImageCommentModel alloc] init];
            
            model.newsId=self.newsId;
            model.userId=[ZWUserInfoModel userID];
            model.commentImageUrl=imageUrlStr;
            model.xPercent=xPercent;
            model.yPercent=yPercent;
            model.x=pt.x;
            model.y=pt.y;
            model.webViewOffsetY=imageWebView.scrollView.contentOffset.y;
            
            /**判断上下是否超越边界*/
            if (yPercent*height<newsCommentImageHeight || !imageUrlStr || yPercent>1.0f || yPercent*height+newsCommentImageHeight>height)
            {
                model.isExceedBoundary=YES;
            }
            _imageCommentModel=model;
            
        }
    }
    /**图片详情的图评*/
    else if ([_commentParentView isKindOfClass:[UIImageView class]])
    {
        UIImageView *imageCommentImageView=(UIImageView*)_commentParentView;
        ZWImageCommentModel *model=[[ZWImageCommentModel alloc] init];
        model.newsId=self.newsId;
        model.userId=[ZWUserInfoModel userID];
        model.commentImageUrl=_imageUrl;
        model.xPercent=(pt.x)/imageCommentImageView.bounds.size.width;
        model.yPercent=(pt.y)/imageCommentImageView.bounds.size.height;
        model.x=pt.x;
        model.y=pt.y;
        /**判断上下是否超越边界*/
        if (pt.y<9.5f || (pt.y+9.5f)>=imageCommentImageView.bounds.size.height)
        {
            model.isExceedBoundary=YES;
        }
        _imageCommentModel=model;
    }
    
}
/**判断是否按在图片上*/
-(BOOL)isPressOnImage:(UIGestureRecognizer*)gestureRecognizer
{
    CGPoint pt = [gestureRecognizer locationInView:_commentParentView];
    
    // convert point from view to HTML coordinate system
    /**新闻详情的图评*/
    if ([_commentParentView isKindOfClass:[UIWebView class]])
    {
        UIWebView *imageWebView=(UIWebView*)_commentParentView;
        
        CGSize viewSize = [imageWebView frame].size;
        CGSize windowSize = [imageWebView windowSize];
        CGFloat f = windowSize.width / viewSize.width;
        
        if ([[[UIDevice currentDevice] systemVersion] doubleValue] >= 5.0)
        {
            pt.x = pt.x * f;
            pt.y = pt.y * f;
        }
        else
        {
            // On iOS 4 and previous, document.elementFromPoint is not taking
            // offset into account, we have to handle it
            CGPoint offset = [imageWebView scrollOffset];
            pt.x = pt.x * f + offset.x;
            pt.y = pt.y * f + offset.y;
        }
        NSString *tags = [imageWebView stringByEvaluatingJavaScriptFromString:
                          [NSString stringWithFormat:@"getElementAtPoint(%i,%i);",(NSInteger)pt.x,(NSInteger)pt.y-10]];
        /**判断是否长按在图片上*/
        if ([tags containsString:@"IMG"])
        {
            
            return YES;
        }
        else
        {
            
            return NO;
        }
        
    }
    return NO;
}
#pragma mark - Getter & Setter -
-(NSMutableDictionary *)imageCommentList
{
    if (!_imageCommentList)
    {
        _imageCommentList=[[NSMutableDictionary alloc]init];
    }
    return _imageCommentList;
}
-(ZWImageCommentModel *)imageCommentModel
{
    if (!_imageCommentModel)
    {
        _imageCommentModel=[[ZWImageCommentModel alloc]init];
    }
    return _imageCommentModel;
}
#pragma mark - UI -
/**开始图评*/
-(void)startImageComment:(CGPoint)pt
{
    /** 超越界限，不让评论 */
    if ([self imageCommentModel].isExceedBoundary)
    {
        return;
    }
    __weak typeof(self) weakSelf=self;
    
    if ([_commentParentView isKindOfClass:[UIImageView class]])
    {
        UIImageView *imageCommentImageView=(UIImageView*)_commentParentView;
        UIScrollView *imageCommentSrollview=(UIScrollView*)_commentParentView.superview;
        /** 开始评论，恢复以前的位置 */
        [imageCommentSrollview setContentOffset:CGPointMake(imageCommentSrollview.contentOffset.x, 0) animated:NO];
        /**构建发表图评视图*/
        ZWImageCommentView *imageCommentView=[[ZWImageCommentView alloc] initWithImageCommentType:ZWImageCommentWrite imageUrl:self.imageUrl  content:@"" point:pt commentId:nil imageCommentId:nil imageCommentSource:ZWImageCommentSourceImageDetail callBack:^(NSString *content, NSString *imageUrl,NSString *commentId,BOOL isDelete)
                                              {
                                                  /**用户选择发表图评*/
                                                  if (content && content.length>0 && !isDelete)
                                                  {
                                                      /**图评发送到服务器*/
                                                      [weakSelf upLoadNewsImageCommentData:content];
                                                  }
                                                  imageCommentSrollview.scrollEnabled=YES;
                                                  
                                              }];
        
        imageCommentView.tag=8759;
        /**重新设置图评视图的正确位置*/
        CGRect rect=imageCommentView.frame;
        CGFloat x;
        CGFloat currentX=[self imageCommentModel].xPercent*imageCommentImageView.bounds.size.width;
        /**箭头朝左跟ZWImageCommentView方法判断一致*/
        if(pt.x>SCREEN_WIDTH/2+10)
        {
            x=currentX-imageCommentView.bounds.size.width+7;
            if(x>SCREEN_WIDTH-12)
            {
                x=SCREEN_WIDTH-12;
            }
            else if (x<12)
            {
                x=12;
            }
        }
        else
        {
            x=currentX-7;
            if(x<12)
            {
                x=12;
            }
            else if ((x+imageCommentView.bounds.size.width)>SCREEN_WIDTH-10)
            {
                x=SCREEN_WIDTH-17-imageCommentView.bounds.size.width;
            }
        }
        rect.origin.x=x;
        if (rect.origin.x+rect.size.width>imageCommentImageView.bounds.size.width-5)
        {
            rect.origin.x=imageCommentImageView.bounds.size.width-rect.size.width-5;
        }
        rect.origin.y=[self imageCommentModel].yPercent*imageCommentImageView.bounds.size.height-rect.size.height+9.5f;
        imageCommentView.frame=rect;
        [imageCommentImageView addSubview:imageCommentView];
    }
    else if ([_commentParentView isKindOfClass:[ZWNewsWebview class]])
    {
        
        ZWImageCommentView *tempImageCommentView=[[ZWImageCommentView alloc] initWithImageCommentType:ZWImageCommentWrite imageUrl:[self imageCommentModel].commentImageUrl  content:@"" point:pt commentId:nil imageCommentId:nil imageCommentSource:ZWImageCommentSourceNewsDetail callBack:^(NSString *content, NSString *imageUrl, NSString *commentId, BOOL isDelete){
            /**用户选择发表图评*/
            if (content && content.length>0 && !isDelete)
            {
                /**图评发送到服务器*/
                [weakSelf upLoadNewsImageCommentData:content];
            }
        }];
        
        __weak ZWNewsWebview *tempImageWebView=(ZWNewsWebview*)_commentParentView;
        
        CGRect rect=tempImageCommentView.frame;
        rect.origin.y+=tempImageWebView.scrollView.contentOffset.y;
        tempImageCommentView.frame=rect;
        tempImageCommentView.tag=8759;
        /**先让键盘收起，在添加*/
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [tempImageWebView.scrollView addSubview:tempImageCommentView];
        });
        
        
    }
}
-(void)addOneImageCommentView:(ZWImageCommentModel*)model
{
    /**判断图评开关打开，只显示自己的图评*/
    if([NSUserDefaults loadValueForKey:kEnableForImageComment] && [[NSUserDefaults loadValueForKey:kEnableForImageComment] boolValue] == NO)
    {
        if (![model.userId isEqualToString:[ZWUserInfoModel sharedInstance].userId])
        {
            return;
        }
        
    }
    __weak typeof(self) weakSelf=self;
    if ([_commentParentView isKindOfClass:[UIImageView class]])
    {
        ZWImageCommentView *commentView=[[ZWImageCommentView alloc] initWithImageCommentType:ZWImageCommentShow imageUrl:self.imageUrl content:model.commentImageComment  point:CGPointMake(_commentParentView.bounds.size.width*model.xPercent, model.yPercent*_commentParentView.bounds.size.height) commentId:model.userId imageCommentId:model.commmentImageId imageCommentSource:ZWImageCommentSourceImageDetail callBack:^(NSString *content, NSString *imageUrl, NSString *commentId,BOOL isDelete)
                                         {
                                             /** 自己的评论被删除 同时也从评论数组中删除 */
                                             if (isDelete)
                                             {
                                                 ZWImageCommentModel *model=[[ZWImageCommentModel alloc] init];
                                                 model.commentImageUrl=imageUrl;
                                                 model.commentImageComment=content;
                                                 weakSelf.imageCommentLoadResultCallBack(ZWImageCommentDelete,model,YES);
                                             }
                                         }];
        [[_commentParentView viewWithTag:1805] addSubview:commentView];
    }
    else
    {
        /**获取这张图片的frame*/
        CGRect imageRect=[[self.imageCommentList objectForKey:[NSString stringWithFormat:@"frame_%@",model.commentImageUrl]] CGRectValue];
        __weak typeof(self) weakSelf=self;
        ZWImageCommentView *commentView=[[ZWImageCommentView alloc] initWithImageCommentType:ZWImageCommentShow imageUrl:model.commentImageUrl content:model.commentImageComment point:CGPointMake(imageRect.size.width*model.xPercent+imageRect.origin.x, imageRect.origin.y+model.yPercent*imageRect.size.height) commentId:model.userId imageCommentId:model.commmentImageId imageCommentSource:ZWImageCommentSourceNewsDetail callBack:^(NSString *content, NSString *imageUrl,NSString *commentId, BOOL isDelete)
                                         {
                                             /** 获取这种图片的图评数组 */
                                             NSMutableArray *oneImageCommentArray=(NSMutableArray*)[[weakSelf imageCommentList] objectForKey:imageUrl];
                                             /** 自己的评论被删除 同时也从评论数组中删除 */
                                             if (isDelete)
                                             {
                                                 for (ZWImageCommentModel *model in oneImageCommentArray)
                                                 {
                                                     if ([model.commentImageComment isEqualToString:content])
                                                     {
                                                         [oneImageCommentArray removeObject:model];
                                                         return ;
                                                     }
                                                 }
                                             }
                                             
                                             
                                             
                                         }];
        if ([_commentParentView isKindOfClass:[UIWebView class]])
        {
            UIWebView *imageWebView=(UIWebView*)_commentParentView;
            [imageWebView.scrollView addSubview:commentView];
            
        }
        
        model.isAlreadyShow=YES;
    }
    
}


-(void)afterUploadImageCommentSuccess:(NSString*)content imageCommentId:(NSString*)imageCommentId
{
    __weak typeof(self) weakSelf=self;
    if ([_commentParentView isKindOfClass:[UIImageView class]])
    {
        UIImageView *imageCommentImageView=(UIImageView*)_commentParentView;
        UIScrollView *imageCommentSrollview=(UIScrollView*)_commentParentView.superview;
        /** 给newsDetail发送通知，把图评加入到评论列表中 */
        [[NSNotificationCenter defaultCenter] postNotificationName:ImageCommentSendSuccess object:content userInfo:nil];
        
        /** 评论成功后 加入到图片数组当中，让新闻详情也把评论加上 */
        [self imageCommentModel].commentImageComment=content;
        
        /** 评论成功后 显示在图片上 */
        ZWImageCommentView *commentView=[[ZWImageCommentView alloc] initWithImageCommentType:ZWImageCommentShow imageUrl:self.imageUrl content:content point:CGPointMake([self imageCommentModel].x, [self imageCommentModel].y) commentId:[ZWUserInfoModel userID] imageCommentId:imageCommentId  imageCommentSource:ZWImageCommentSourceImageDetail callBack:^(NSString *content, NSString *imageUrl,NSString *commentId,BOOL isDelete)
                                         {
                                             /** 自己的评论被删除 同时也从评论数组中删除 */
                                             if (isDelete)
                                             {
                                                 ZWImageCommentModel *model=[[ZWImageCommentModel alloc] init];
                                                 model.commentImageUrl=imageUrl;
                                                 model.commentImageComment=content;
                                                 weakSelf.imageCommentLoadResultCallBack(ZWImageCommentDelete,model,YES);
                                             }
                                         }];
        
        /** 获取评论包含评论的父视图，并且把评论视图加进父视图显示出来 */
        UIView *imageCommentView=[imageCommentImageView viewWithTag:1805];
        if (imageCommentView)
        {
            if (imageCommentView.hidden)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:HideOrShowComentNotification object:nil];
            }
            
            [imageCommentView addSubview:commentView];
        }
        /** 评论完了，恢复以前的位置 */
        [imageCommentSrollview setContentOffset:CGPointMake(imageCommentSrollview.contentOffset.x, 0) animated:YES];
        _imageCommentLoadResultCallBack(ZWImageCommentAdd,[self imageCommentModel],YES);
    }
    else if ([_commentParentView isKindOfClass:[UIWebView class]])
    {
        UIWebView *imageWebView=(UIWebView*)_commentParentView;
        ZWImageCommentView *commentView=[[ZWImageCommentView alloc] initWithImageCommentType:ZWImageCommentShow imageUrl:[self imageCommentModel].commentImageUrl content:content point:CGPointMake([self imageCommentModel].x, [self imageCommentModel].y) commentId:[ZWUserInfoModel userID] imageCommentId:imageCommentId  imageCommentSource:ZWImageCommentSourceNewsDetail callBack:^(NSString *content, NSString *imageUrl,NSString *commentId, BOOL isDelete)
                                         {
                                             
                                             if (isDelete)
                                             {
                                                 
                                                 NSMutableArray *oneImageCommentArray=(NSMutableArray*)[[weakSelf imageCommentList] objectForKey:imageUrl];
                                                 /** 自己的评论被删除 同时也从评论数组中删除 */
                                                 for (ZWImageCommentModel *model in oneImageCommentArray)
                                                 {
                                                     if ([model.commentImageComment isEqualToString:content])
                                                     {
                                                         [oneImageCommentArray removeObject:model];
                                                         return ;
                                                     }
                                                 }
                                             }
                                             
                                             
                                             
                                         }];
        CGRect rect=commentView.frame;
        rect.origin.y+=[self imageCommentModel].webViewOffsetY;
        commentView.frame=rect;
        [imageWebView.scrollView addSubview:commentView];
        
        [self imageCommentModel].commentImageComment=content;
        [self imageCommentModel].isAlreadyShow=YES;
        
        
        NSMutableArray *oneImageCommentArray=[[weakSelf imageCommentList] objectForKey:[self imageCommentModel].commentImageUrl];
        if (oneImageCommentArray)
        {
            [oneImageCommentArray safe_addObject:[self imageCommentModel]];
        }
        else
        {
            NSMutableArray *array=[[NSMutableArray alloc] init];
            [array safe_addObject:[self imageCommentModel]];
            [[weakSelf imageCommentList] safe_setObject:array forKey:[self imageCommentModel].commentImageUrl];
        }
        _imageCommentLoadResultCallBack(ZWImageCommentAdd,[self imageCommentModel],YES);
    }
    
}
#pragma mark - newwork -
/**
 *  获取新闻图评数据
 */
-(void)loadNewsImageCommentData
{
    typeof(self) __weak weakSelf = self;
    [[ZWNewsNetworkManager sharedInstance] loadNewsImageCommentWithNewId:_newsId uId:[ZWUserInfoModel userID] succed:^(id result)
     
     {
         if(!weakSelf)
             return ;
         if([result isKindOfClass:[NSArray class]])
         {
             NSArray *commentList=(NSArray*)result;
             if (commentList)
             {
                 for (NSDictionary *dic in commentList)
                 {
                     if (dic)
                     {
                         ZWImageCommentModel *model=[ZWImageCommentModel imageCommentModelFromDictionary:dic];
                         model.newsId=weakSelf.newsId;
                         NSMutableArray *arrayObj=[[weakSelf imageCommentList] objectForKey:model.commentImageUrl];
                         if (arrayObj)
                         {
                             [arrayObj addObject:model];
                         }
                         else
                         {
                             NSMutableArray *array=[[NSMutableArray alloc] init];
                             [array addObject:model];
                             [[weakSelf imageCommentList] safe_setObject:array forKey:model.commentImageUrl];
                         }
                         
                     }
                 }
                 [weakSelf imageCommentModel].imageCommentList=[weakSelf imageCommentList];
                 weakSelf.imageCommentLoadResultCallBack(ZWImageCommentLoad,[weakSelf imageCommentModel],YES);
             }
         }
         else
         {
             weakSelf.imageCommentLoadResultCallBack(ZWImageCommentLoad,[weakSelf imageCommentModel],NO);
         }
         
         
     }
                                                                  failed:^(NSString *errorString)
     {
         NSString *str=[NSString stringWithFormat:@"获取图评数据失败：%@",errorString];
         occasionalHint(str);
         if (weakSelf)
         {
             if (weakSelf.imageCommentLoadResultCallBack)
                 weakSelf.imageCommentLoadResultCallBack(ZWImageCommentLoad,[weakSelf imageCommentModel],NO);
         }

     }];
}
-(void)upLoadNewsImageCommentData:(NSString*)content
{
    [MobClick event:@"send_picture_comment"];//友盟统计
    //评论间隔需要30秒
    if (![self judgeIsCanCommit])
    {
        if ([self.commentParentView isKindOfClass:[UIImageView class]])
        {
            UIScrollView *imageCommentSrollview=(UIScrollView*)self.commentParentView.superview;
            [imageCommentSrollview setContentOffset:CGPointMake(imageCommentSrollview.contentOffset.x, 0) animated:YES];
        }
        occasionalHint(@"客官妙语连珠，休息一会再发吧~");
        return;
    }
    typeof(self) __weak weakSelf = self;
    [[ZWNewsNetworkManager sharedInstance] uploadNewsImageCommentWithNewId:_newsId uid:[ZWUserInfoModel userID]  x:[NSString stringWithFormat:@"%f",[self imageCommentModel].xPercent ]  y:[NSString stringWithFormat:@"%f",[self imageCommentModel].yPercent] url:[self imageCommentModel].commentImageUrl content:content
                                                                    succed:^(id result)
     {
         NSString *imageCommentId;
         /** 获取后台返回新加的图评的id,删除时会用到 */
         if([result isKindOfClass:[NSDictionary class]])
             imageCommentId=[NSString stringWithFormat:@"%ld",[[result objectForKey:@"picCommentId"] integerValue]];
         else if([result isKindOfClass:[NSString class]])
         {
             imageCommentId=result;
         }
         [weakSelf imageCommentModel].commmentImageId=imageCommentId;
         [weakSelf afterUploadImageCommentSuccess:content imageCommentId:imageCommentId];
         
     }
                                                                    failed:^(NSString *errorString)
     {
         NSString *str=[NSString stringWithFormat:@"发表图评失败：%@",errorString];
         occasionalHint(str);
         if ([weakSelf.commentParentView isKindOfClass:[UIImageView class]])
         {
             UIScrollView *imageCommentSrollview=(UIScrollView*)weakSelf.commentParentView.superview;
             [imageCommentSrollview setContentOffset:CGPointMake(imageCommentSrollview.contentOffset.x, 0) animated:YES];
         }
     }];
}
@end
