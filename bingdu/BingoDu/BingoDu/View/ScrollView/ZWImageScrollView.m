#import "ZWImageScrollView.h"
#import "UIImageView+WebCache.h"
#import "CustomURLCache.h"
#import "ZWImageCommentView.h"
#import "ZWLoginViewController.h"
#import "ZWNewsNetworkManager.h"
#import "ZWNewsImageCommentManager.h"
#import "MBProgressHUD.h"
@interface ZWImageScrollView()<UIScrollViewDelegate>
{
    //记录自己的位置
    CGRect scaleOriginRect;
    //图片的大小
    CGSize imgSize;
    //缩放前大小
    CGRect initRect;
}
@property (nonatomic,assign)BOOL imgMove;//标示当前图片集是否在移动
@property (nonatomic,strong)ZWImageCommentModel *imageCommentModel;  //发送图片评论Model
@property (nonatomic,strong)NSString *imageUrl;  //图片url
@property (nonatomic,strong)UIImageView *loadProgressView;  //加载进度view
/**图评管理器*/
@property (nonatomic,strong)ZWNewsImageCommentManager *newsImageCommentManager;
@end

@implementation ZWImageScrollView
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.imgMove=NO;
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        self.bouncesZoom = YES;
        self.delegate = self;
        self.bounces = NO;
        self.downLoadFinished=NO;
        self.minimumZoomScale = 1.0;
        self.maximumZoomScale = 2.0;
        [self addSubview:self.imgView];
        self.backgroundColor=[UIColor blackColor];
        [self addTapGesture];
        /**监听图评隐藏或显示的通知*/
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self selector:@selector(hideOrShowComment:) name:HideOrShowComentNotification object:nil];
     
    }
    return self;
}
-(void)dealloc
{
    ZWLog(@"ZWImageScrollView dealloc");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
#pragma mark - Getter & Setter
-(ZWNewsImageCommentManager*)newsImageCommentManager
{
    if (!_newsImageCommentManager)
    {
        __weak typeof(self) weakSelf=self;
        _newsImageCommentManager=[[ZWNewsImageCommentManager alloc] initWithImageCommentType:[self imgView] newsID:_newsId imageUrl:_imageUrl loadResultBlock:^(ZWImageCommentResultType imageCommentResultType,ZWImageCommentModel* model,BOOL isSuccess)
                                  {
                                      switch (imageCommentResultType)
                                      {
                                          case ZWImageCommentDelete:
                                          {
                                              if (isSuccess)
                                              {
                                                  /** 在响应的父视图加上*/
                                                  for (ZWImageCommentModel *tempModel in weakSelf.commmentModelArray)
                                                  {
                                                      if ([tempModel.commentImageComment isEqualToString:model.commentImageComment])
                                                      {
                                                        [weakSelf.commmentModelArray removeObject:tempModel];
                                                          
                                                          return ;
                                                      }
                                                  }
                                                  
                                              }
                                          }
                                              break;
                                          case ZWImageCommentAdd:
                                          {
                                              if (isSuccess)
                                              {
                                                    /** 图评过加进图评数组中，只加一次 在响应的父视图加上*/
                                                  if(![weakSelf.imageCommentDetailChange containsObject:weakSelf.imageUrl])
                                                      [weakSelf.imageCommentDetailChange safe_addObject:weakSelf.imageUrl];
                                                  model.isAlreadyShow=NO;
                                                  [weakSelf.commmentModelArray safe_addObject:model];
                                              }
                                          }
                                              break;
                                              
                                          default:
                                              break;
                                      }
                                      
                                  }];
    }
    return _newsImageCommentManager;
}
-(ZWImageCommentModel *)imageCommentModel
{
    if (!_imageCommentModel)
    {
        _imageCommentModel=[[ZWImageCommentModel alloc]init];
    }
    return _imageCommentModel;
}
#pragma mark set or get UI
//加载图片视图
-(UIImageView *)loadProgressView
{
    if (!_loadProgressView)
    {
        _loadProgressView=[[UIImageView alloc]initWithFrame:CGRectMake((SCREEN_WIDTH-56)/2, (SCREEN_HEIGH-56)/2-15, 56, 56)];
        _loadProgressView.clipsToBounds = YES;
        _loadProgressView.contentMode = UIViewContentModeScaleAspectFill;
        [_loadProgressView setImage:[UIImage imageNamed:@"image_load_flag"]];

    }
    return _loadProgressView;
}
-(UIImageView *)imgView
{
    if (!_imgView)
    {
        _imgView=[[UIImageView alloc]initWithFrame:self.bounds];
        _imgView.clipsToBounds = YES;
        _imgView.contentMode = UIViewContentModeScaleAspectFill;
        [_imgView setImage:[UIImage imageNamed:@"icon_banner_ad"]];
        _imgView.userInteractionEnabled=YES;
        _imgView.autoresizesSubviews=YES;
    }
    return _imgView;
}
- (void) setContentWithFrame:(CGRect) rect
{
    self.imgView.frame = rect;
    initRect = rect;
}
/**
  设置图片为指定缩放大小
 */
- (void) setAnimationRect
{
    if (self.imgView) {
        self.imgView.frame = scaleOriginRect;
    }
}
- (void) rechangeInitRdct
{
    self.zoomScale = 1.0;
    self.imgView.frame = initRect;
}
- (void) setImageUrl:(NSString *) imageUrl
{
    __weak typeof(self) weakSelf=self;
    _imageUrl=imageUrl;
    if (_isNeedImagaComment)
    {
          [self newsImageCommentManager];
    }
  
    UIImage *image = [self loadCacheImage:imageUrl];
    if(image)
    {
        self.downLoadFinished=YES;
        [self.imgView setImage:image];
        [self setImgSize:image];
        [self setAnimationRect];
        if (!_isLiveNews)
        {
            [self addImageComment];
        }
 
    }
    else
    {
        [self addSubview:[self loadProgressView]];
        [self startLoadAnimation];
        //调用SDWebImage 下载该图片
        [self.imgView sd_setImageWithURL:[NSURL URLWithString:imageUrl]
                        placeholderImage:nil
                                 options:SDWebImageHighPriority
                                progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                    
                                }
                               completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                   ZWLog(@"%@", error);
                                   //删除加载动画
                                   [[weakSelf loadProgressView].layer removeAllAnimations];
                                   [[weakSelf loadProgressView] removeFromSuperview];
                                   if(image)
                                   {
                                       weakSelf.downLoadFinished=YES;
                                       [weakSelf setImgSize:image];
                                       [weakSelf setAnimationRect];
                                       if (!weakSelf.isLiveNews)
                                       {
                                           [weakSelf addImageComment];
                                       }
                                   }
                               }];
    }
}
-(void)setImgSize:(UIImage *)image
{
    imgSize = image.size;
    //判断首先缩放的值
    float scaleX = self.frame.size.width/imgSize.width;
    float scaleY = self.frame.size.height/imgSize.height;
    //倍数小的，先到边缘
    if (scaleX > scaleY)
    {
        //Y方向先到边缘
        float imgViewWidth = imgSize.width*scaleY;
        //self.maximumZoomScale = self.frame.size.width/imgViewWidth;
        scaleOriginRect = (CGRect){self.frame.size.width/2-imgViewWidth/2,0,imgViewWidth,self.frame.size.height};
    }
    else
    {
        //X先到边缘
        float imgViewHeight = imgSize.height*scaleX;
        //self.maximumZoomScale = self.frame.size.height/imgViewHeight;
        scaleOriginRect = (CGRect){0,self.frame.size.height/2-imgViewHeight/2,self.frame.size.width,imgViewHeight};
    }
}
/** 
 添加所有图评到图片
 */
-(void)addImageComment
{
    UIView *imageCommentView=[[UIView alloc] initWithFrame:self.imgView.bounds];
    imageCommentView.backgroundColor=[UIColor clearColor];
    imageCommentView.tag=1805;
    imageCommentView.hidden=YES;
    imageCommentView.userInteractionEnabled=YES;
    [self.imgView addSubview:imageCommentView];
    for (ZWImageCommentModel *model in _commmentModelArray)
    {
        [[self newsImageCommentManager] addOneImageCommentView:model];
    }
}
/**
 查询在html网页内是否已经下载完成该图片 有则直接调用
 */
-(UIImage *)loadCacheImage:(NSString *)url
{
    NSData *response = [[[CustomURLCache sharedURLCache] cachedResponseForRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]] data];
    if(response)
    {
        UIImage *image = [[UIImage alloc] initWithData:response];
        if(image != nil){
            return image;
        }
    }
    return nil;
}
#pragma mark - scroll delegate
//缩放委托
- (UIView *) viewForZoomingInScrollView:(UIScrollView *)scrollView
{
   return self.imgView;
}
// 当缩放结束后，并且缩放大小回到minimumZoomScale与maximumZoomScale之间后（我们也许会超出缩放范围），调用该方法。
-(void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    ZWLog(@"scrollViewDidEndZooming");
    (int)scale==1?(self.imgMove=NO):(self.imgMove=YES);
}
//当scrollView缩放时，调用该方法。在缩放过程中，回多次调用
- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    /**有图评编辑框隐藏键盘*/
    ZWImageCommentView* subView=(ZWImageCommentView*)[self.imgView viewWithTag:8759];
    if (subView && [subView viewWithTag:9801] )
    {
        UITextField *field=(UITextField*)[subView viewWithTag:9801];
        if ([field isFirstResponder])
        {
            [field resignFirstResponder];
        }
        [self.imgView bringSubviewToFront:subView];
        self.zoomScale=1.0f;
        return;
    }
    ZWLog(@"scrollViewDidZoom");
    CGSize boundsSize = scrollView.bounds.size;
    CGRect imgFrame = self.imgView.frame;
    CGSize contentSize = scrollView.contentSize;
    CGPoint centerPoint = CGPointMake(contentSize.width/2, contentSize.height/2);
    
    if (imgFrame.size.width <= boundsSize.width)
    {
        centerPoint.x = boundsSize.width/2;
    }
    if (imgFrame.size.height <= boundsSize.height)
    {
        centerPoint.y = boundsSize.height/2;
    }
    self.imgView.center = centerPoint;
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.imgMove)
    {
             ZWLog(@"scrollViewDidScroll");
        if (scrollView.contentOffset.x==0||
            scrollView.contentOffset.x==scrollView.contentSize.width-SCREEN_WIDTH)
        {
            /**
              滑动到最后一张图或者开始的时候
             */
            [self changeBgScrollViewEnabled:self.imgMove];
        }
        else
        {
            [self changeBgScrollViewEnabled:!self.imgMove];
        }
    }
    else
    {
        [self changeBgScrollViewEnabled:!self.imgMove];
    }
}
/**
 改变父视图的滚动状态
 */
-(void)changeBgScrollViewEnabled:(BOOL)move
{
    if ([[self nextResponder] isMemberOfClass:[UIScrollView class]])
    {
        UIScrollView *bgScroll = (UIScrollView *)([self nextResponder]);
        [bgScroll setScrollEnabled:move];
    }
}
#pragma mark - touch
//保持最大最小的范围
- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    ZWLog(@"touchesEnded");
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    UITouch *touch = [touches anyObject];
    
    if(touch.tapCount == 2)
    {
        if(self.zoomScale == self.minimumZoomScale)
            [self setZoomScale:self.maximumZoomScale animated:YES];
        else
            [self setZoomScale:self.minimumZoomScale animated:YES];
    }
}
#pragma mark - private methods

-(void)addTapGesture
{
    UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTabGesture:)];
    [self addGestureRecognizer:tapGesture];
}
-(void)startLoadAnimation
{
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 ];
    rotationAnimation.duration = 0.6f;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = 10000000;
    [[self loadProgressView].layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
 }
#pragma mark - event handle
-(void)handleTabGesture:(UIGestureRecognizer*)ges
{
    [[NSNotificationCenter defaultCenter] postNotificationName:HideOrShowComentNotification object:nil];
}
-(void)hideOrShowComment:(NSNotification*)notify
{
    /** 影藏或者显示图评蒙版 */
    UIView *imageCommentView=[self.imgView viewWithTag:1805];
    if (imageCommentView)
    {
        imageCommentView.hidden=!imageCommentView.hidden;
    }
}

@end
