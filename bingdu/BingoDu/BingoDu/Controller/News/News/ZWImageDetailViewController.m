#import "ZWImageDetailViewController.h"
#import "CustomURLCache.h"
#import "ZWNewsNetworkManager.h"
#import "UIButton+EnlargeTouchArea.h"
#import "ZWImageScrollView.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "ZWGuideManager.h"
#import "UIViewController+BackGesture.h"
#import "ZWNewsModel.h"

@interface ZWImageDetailViewController ()<UIScrollViewDelegate,UITextViewDelegate>
/**存放图片*/
@property (nonatomic,strong)UIScrollView *myScrollView;
/**标题lable*/
@property (nonatomic,strong)UILabel *titleLbl;
/**显示当前是第几张图片的lable*/
@property (nonatomic,strong)UILabel *numLbl;
/**图片的url*/
@property (nonatomic,strong)NSMutableArray *imgArray;
/**显示图片view的scrollview*/
@property (nonatomic,strong)NSMutableArray *imgScrollArray;
/*图片标题*/
@property (nonatomic,strong)NSString *imgTitle;
/**图片概要*/
@property (nonatomic,strong)NSString *summary;
/**显示概要的textView*/
@property (nonatomic,strong)UITextView *contentTextView;
/**当前图片的索引*/
@property (nonatomic,assign)NSInteger curIndex;
/**上一张图片的位置索引*/
@property (nonatomic,assign)NSInteger oldCurIndex;
@end

@implementation ZWImageDetailViewController
#pragma mark - life cycle -
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor blackColor];
    UIView *statusBarView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 20)];
    statusBarView.backgroundColor=[UIColor blackColor];
    [self.view addSubview:statusBarView];
    self.imgArray=self.imgData[@"imgUrls"];
    self.imgScrollArray=[[NSMutableArray alloc]init];
    [self showImageCommentGuide];
    [self addImgScroView];
//    [self addSummaryInfoView];
    [self addBackButton];
    [self addDownLoadButton];
    ZWNewsModel *newsModel =self.imgData[@"newsModel"];
    __weak typeof(self) weakSelf=self;
    [[ZWNewsNetworkManager sharedInstance] loadNewsImgTitles:newsModel.newsId
                                                     isCache:NO
                                                      succed:^(id result) {
                                                          [[weakSelf imgData] safe_setObject:result[@"newsTitle"] forKey:@"imgTitle"];
                                                          [[weakSelf imgData] safe_setObject: result[@"summary"] forKey:@"summary"];
                                                          weakSelf.imgTitle=weakSelf.imgData[@"imgTitle"];
                                                          weakSelf.summary=weakSelf.imgData[@"summary"];
                                                          [[weakSelf titleLbl] setText:weakSelf.imgTitle];
                                                          [[weakSelf contentTextView] setText:weakSelf.summary];
                                                        [weakSelf addSummaryInfoView];
                                                      } failed:^(NSString *errorString) {
                                                         [weakSelf addSummaryInfoView];
                                                      }];
    [self.view bringSubviewToFront:[self contentTextView]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
-(void)dealloc
{
    ZWLog(@"zwImagdetail dealloc");
}

#pragma mark - Getter & Setter -
//显示图评引导图
-(void)showImageCommentGuide
{
    ZWNewsModel *newsModel =self.imgData[@"newsModel"];
    /**直播模式不用图评，也不用图评引导图*/
    if(newsModel.displayType == kNewsDisplayTypeLive)
    {
        return;
    }
    else if (newsModel.newsType==kNewsTypeLifeStyle)
    {
        return;
    }
    /**直播模式不用图评，也不用图评引导图*/
    if (![[self.imgData objectForKey:@"isLiveNews"] boolValue])
    {
        [ZWGuideManager showGuidePage:kGuidePageImageDetail];
    }
    
}
-(UITextView *)contentTextView
{
    if (!_contentTextView) {
        _contentTextView=[[UITextView alloc]initWithFrame:CGRectMake(10, [self titleLbl].frame.origin.y+[self titleLbl].frame.size.height, SCREEN_WIDTH-10-10, 85)];
        _contentTextView.userInteractionEnabled=YES;
        _contentTextView.backgroundColor=[UIColor clearColor];
        _contentTextView.showsVerticalScrollIndicator=NO;
        [_contentTextView setEditable:YES];
        [_contentTextView setDelegate:self];
        [_contentTextView setFont:[UIFont systemFontOfSize:13]];
        _contentTextView.layer.borderWidth=0;
        [_contentTextView setTextColor:[UIColor whiteColor]];
    }
    return _contentTextView;
}

-(UIImageView *)showdowImagView
{
    UIImageView *shadowImageView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bottomMongolian"]];
    [self.view addSubview:shadowImageView];
    return shadowImageView;
}
-(UILabel *)titleLbl
{
    if (!_titleLbl) {
        _titleLbl=[[UILabel alloc]initWithFrame:CGRectMake(15, 0, SCREEN_WIDTH-15-10-50, 20)];
        [_titleLbl setFont:[UIFont systemFontOfSize:16]];
        [_titleLbl setTextColor:[UIColor whiteColor]];
        _titleLbl.userInteractionEnabled=NO;
    }
    return _titleLbl;
}
-(UILabel *)numLbl
{
    if (!_numLbl) {
        _numLbl=[[UILabel alloc]initWithFrame:CGRectMake(SCREEN_WIDTH-10-60, 0, 60, 20)];
        [_numLbl setFont:[UIFont systemFontOfSize:16]];
        [_numLbl setTextAlignment:NSTextAlignmentRight];
        [_numLbl setTextColor:[UIColor whiteColor]];
    }
    return _numLbl;
}

-(UIScrollView *)myScrollView
{
    if(!_myScrollView)
    {
        _myScrollView=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 20, SCREEN_WIDTH, SCREEN_HEIGH-20)];
        _myScrollView.tag=107;
        _myScrollView.pagingEnabled=YES;
        _myScrollView.showsHorizontalScrollIndicator = NO;
        _myScrollView.delegate=self;
        _myScrollView.backgroundColor=[UIColor colorWithHexString:@"#000000"];
    }
    return _myScrollView;
}
#pragma mark - UI -
/** 添加滚动视图ui*/
-(void)addImgScroView
{
    [self.view addSubview:[self myScrollView]];
    CGFloat contentW = self.imgArray.count *_myScrollView.frame.size.width;
    [[self myScrollView] setContentSize:CGSizeMake(contentW, 0)];
    self.curIndex=[self getSelectIndexInImagearray];
    self.oldCurIndex=self.curIndex;
    [self addSubImgView];
    
}
- (void) addSubImgView
{
    for (UIView *tmpView in [self myScrollView].subviews)
    {
        [tmpView removeFromSuperview];
    }
    for (int i = 0; i < self.imgArray.count; i ++)
    {
        ZWImageScrollView *tmpImgScrollView = [[ZWImageScrollView alloc] initWithFrame:(CGRect){i*self.myScrollView.bounds.size.width,0,self.myScrollView.bounds.size.width, self.myScrollView.bounds.size.height}];
        tmpImgScrollView.tag=2457+i;
        tmpImgScrollView.imageCommentDetailChange=[self.imgData objectForKey:@"imageChangeArray"];
        tmpImgScrollView.isLiveNews=[[self.imgData objectForKey:@"isLiveNews"] boolValue];
        
        ZWNewsModel *newsModel =self.imgData[@"newsModel"];
        /**直播模式不用图评，也不用图评引导图*/
        if(newsModel.displayType == kNewsDisplayTypeLive || newsModel.newsType==kNewsTypeLifeStyle)
        {
            tmpImgScrollView.isNeedImagaComment=NO;
        }
        else
        {
            tmpImgScrollView.isNeedImagaComment=YES;
        }

        NSString *newsId=newsModel.newsId;
        if (newsId)
        {
            tmpImgScrollView.newsId=newsId;
        }
        //获取这张图片的图评数据
        NSMutableDictionary *dic=[_imgData objectForKey:@"ImageCommentList"];
        if (dic)
        {
            NSMutableArray *commmonModel=[dic objectForKey:self.imgArray[i]];
            if (commmonModel)
            {
                [tmpImgScrollView setCommmentModelArray:commmonModel];
            }
            else
            {
                NSMutableArray *array=[[NSMutableArray alloc] init];
                [dic safe_setObject:array forKey:self.imgArray[i]];
                [tmpImgScrollView setCommmentModelArray:array];
            }
            
        }
        [tmpImgScrollView setImageUrl:self.imgArray[i]];
        [[self myScrollView] addSubview:tmpImgScrollView];
        [self.imgScrollArray safe_addObject:tmpImgScrollView];
    }
    [[self myScrollView] setContentOffset:CGPointMake(self.curIndex*self.myScrollView.bounds.size.width , 0) animated:NO];
    [[self numLbl] setText:[NSString stringWithFormat:@"%d/%d",(int)self.curIndex+1,(int)self.imgArray.count]];
}

/**
 添加图片详细信息ui
 */
-(void)addSummaryInfoView
{
    [self showdowImagView].frame=CGRectMake(0, SCREEN_HEIGH-300, SCREEN_WIDTH,300);
    UIView *bottomView=[[UIView alloc]initWithFrame:CGRectMake(0, SCREEN_HEIGH-85-20, SCREEN_WIDTH, SCREEN_HEIGH- (SCREEN_HEIGH-20-85))];
    bottomView.backgroundColor=[UIColor clearColor];
    [self.view addSubview:bottomView];
    CGSize textSize=[NSString heightForString:self.summary fontSize:13 andSize:CGSizeMake(SCREEN_WIDTH-10-10, MAXFLOAT)].size;
    if (textSize.height>85)
    {
        bottomView.userInteractionEnabled=YES;
    }
    else
        bottomView.userInteractionEnabled=NO;

    [bottomView addSubview:[self titleLbl]];
    [bottomView addSubview:[self numLbl]];
    [bottomView addSubview:[self contentTextView]];


}
/**
 添加返回按钮
 */
-(void)addBackButton
{
    UIImage *img = [UIImage imageNamed:@"btn_back_nav"];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:img forState:UIControlStateNormal];
    [button setImage:img forState:UIControlStateHighlighted];
    button.frame = CGRectMake(10, 40, img.size.width, img.size.height);
    [button setEnlargeEdgeWithTop:10 right:10 bottom:10
                             left:10];
    [button addTarget:self action:@selector(backNav) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}
/**
 添加图片下载按钮
 */
-(void)addDownLoadButton
{
    UIButton * downLoadButton=[UIButton buttonWithType:UIButtonTypeCustom];
    [downLoadButton setFrame:CGRectMake(SCREEN_WIDTH-50,30, 50, 50)];
    [downLoadButton setImage:[UIImage imageNamed:@"saveImg"] forState:UIControlStateNormal];
    [downLoadButton setEnlargeEdgeWithTop:10 right:10 bottom:10
                                     left:10];
    [downLoadButton addTarget:self action:@selector(downLoadImg) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:downLoadButton];
}

#pragma mark - 在手机相册中创建相册 -
- (void)createAlbumInPhoneAlbum:(UIImageView *)curImgView
{
    ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
    NSMutableArray *groups=[[NSMutableArray alloc]init];
    ALAssetsLibraryGroupsEnumerationResultsBlock listGroupBlock = ^(ALAssetsGroup *group, BOOL *stop)
    {
        if (group) {
            [groups safe_addObject:group];
        } else
        {
            BOOL haveHDRGroup = NO;
            for (ALAssetsGroup *gp in groups)
            {
                NSString *name =[gp valueForProperty:ALAssetsGroupPropertyName];
                if ([name isEqualToString:@"并读新闻"])
                {
                    haveHDRGroup = YES;
                }
            }
            if (!haveHDRGroup) {
                [assetsLibrary addAssetsGroupAlbumWithName:@"并读新闻"
                                               resultBlock:^(ALAssetsGroup *group)
                 {
                     if (group) {
                         [groups safe_addObject:group];
                     }
                 }
                                              failureBlock:nil];
            }
        }
        
    };
    __weak typeof(self) weakSelf=self;
    //创建相簿
    [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAlbum usingBlock:listGroupBlock failureBlock:nil];
    [self saveToAlbumWithMetadata:nil imageData:UIImagePNGRepresentation(curImgView.image) customAlbumName:@"并读新闻" completionBlock:^
     {
         [weakSelf performSelectorOnMainThread:@selector(hintSaveImgFinished) withObject:nil waitUntilDone:NO];
     }
                     failureBlock:^(NSError *error)
     {
         //处理添加失败的方法显示alert让它回到主线程执行，不然那个框框死活不肯弹出来
         dispatch_async(dispatch_get_main_queue(), ^{
             //添加失败一般是由用户不允许应用访问相册造成的，这边可以取出这种情况加以判断一下
             if([error.localizedDescription rangeOfString:@"User denied access"].location != NSNotFound ||[error.localizedDescription rangeOfString:@"用户拒绝访问"].location!=NSNotFound){
                 UIAlertView *alert=[[UIAlertView alloc]initWithTitle:error.localizedDescription message:error.localizedFailureReason delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", nil) otherButtonTitles: nil];
                 [alert show];
             }
         });
     }];
}
- (void)saveToAlbumWithMetadata:(NSDictionary *)metadata
                      imageData:(NSData *)imageData
                customAlbumName:(NSString *)customAlbumName
                completionBlock:(void (^)(void))completionBlock
                   failureBlock:(void (^)(NSError *error))failureBlock
{
    ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
    void (^AddAsset)(ALAssetsLibrary *, NSURL *) = ^(ALAssetsLibrary *assetsLibrary, NSURL *assetURL) {
        [assetsLibrary assetForURL:assetURL resultBlock:^(ALAsset *asset) {
            [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                
                if ([[group valueForProperty:ALAssetsGroupPropertyName] isEqualToString:customAlbumName]) {
                    [group addAsset:asset];
                    if (completionBlock) {
                        completionBlock();
                    }
                }
            } failureBlock:^(NSError *error) {
                if (failureBlock) {
                    failureBlock(error);
                }
            }];
        } failureBlock:^(NSError *error) {
            if (failureBlock) {
                failureBlock(error);
            }
        }];
    };
    [assetsLibrary writeImageDataToSavedPhotosAlbum:imageData metadata:metadata completionBlock:^(NSURL *assetURL, NSError *error) {
        __block ALAssetsLibrary * _assetsLibrary = assetsLibrary;
        if (customAlbumName) {
            [assetsLibrary addAssetsGroupAlbumWithName:customAlbumName resultBlock:^(ALAssetsGroup *group) {
                if (group) {
                    [_assetsLibrary assetForURL:assetURL resultBlock:^(ALAsset *asset) {
                        [group addAsset:asset];
                        if (completionBlock) {
                            completionBlock();
                        }
                    } failureBlock:^(NSError *error) {
                        if (failureBlock) {
                            failureBlock(error);
                        }
                    }];
                } else {
                    AddAsset(_assetsLibrary, assetURL);
                }
            } failureBlock:^(NSError *error) {
                AddAsset(_assetsLibrary, assetURL);
            }];
        } else {
            if (completionBlock) {
                completionBlock();
            }
        }
    }];
}
-(void)downLoadImg
{
    /**TODO:
     暂时保留（因第一次提示允许打开相册授权信息时拒绝的话 再点击下载图片按钮 不会提示，目前是采用不创建相册直接下载到手机的方式）
     */
    
    /*
     if (((ZWImgScrollView*)self.imgScrollArray[self.curIndex]).downLoadFinished) {
     dispatch_async(dispatch_get_global_queue(0, 0), ^{
     [self createAlbumInPhoneAlbum:((ZWImgScrollView*)self.imgScrollArray[self.curIndex]).imgView];
     });
     }else
     occasionalHint(@"图片未加载完，操作无效。");
     */
    
    if (((ZWImageScrollView*)self.imgScrollArray[self.curIndex]).downLoadFinished) {
        UIImageView *img=((ZWImageScrollView*)self.imgScrollArray[self.curIndex]).imgView;
        UIImageWriteToSavedPhotosAlbum(img.image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
    }else
        occasionalHint(@"图片未加载完，操作无效。");
}
/**
 图片下载到手机的回调
 */
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (error == nil)
    {
        occasionalHint(@"已下载到相册");
    }
    else
    {
        [self hint:@"保存图片被阻止了" message:@"请到系统“设置 > 隐私 > 照片”中开启并读的访问权限"
         trueTitle:@"确定"
         trueBlock:^{
             
         }
       cancelTitle:nil
       cancelBlock:^{
           
       }];
    }
    
}
-(void)hintSaveImgFinished
{
    occasionalHint(@"已下载到相册");
}
#pragma mark - event handle -
/**
 获取当前选中图片的索引
 */
-(int)getSelectIndexInImagearray
{
    NSArray *imageArray=[_imgData objectForKey:@"imgUrls"];
    NSString *selectImageUrl=[_imgData objectForKey:@"selectImageUrl"];
    if ([imageArray containsObject:selectImageUrl]) {
        return (int)[imageArray indexOfObject:selectImageUrl];
    }
    return 0;
}
-(UIImage *)loadCacheImage:(int)index
{
    NSData *response = [[[CustomURLCache sharedURLCache] cachedResponseForRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.imgArray[index]]]] data];
    if(response)
    {
        UIImage *image = [[UIImage alloc] initWithData:response];
        if(image != nil){
            return image;
        }
    }
    return nil;
}
-(void)initswip
{
    ZWLog(@"主要是用来覆盖父类方法");
}
-(void)backNav
{
    [self.navigationController  popViewControllerAnimated:YES];
}

#pragma mark  - UITextView代理 -
-(BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    return NO;
}
#pragma mark  - UIScrollView代理 -
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    int index = scrollView.contentOffset.x/scrollView.frame.size.width+1;
    self.curIndex=index-1;
    if (index != 0) {
        [self.numLbl setText:[[NSString stringWithFormat:@"%d",index] stringByAppendingFormat:@"%@%d",@"/",(int)self.imgArray.count]];
    }
    if(self.contentTextView.text.length<=0)
        [self.contentTextView setText:self.summary];
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (_oldCurIndex==_curIndex)
    {
        return;
    }
    /**移动时删除图评框*/
    if (_curIndex >= 0)
    {
        UIScrollView *subView=(UIScrollView*)[[self myScrollView] viewWithTag:2457+_oldCurIndex];
        if (subView)
        {
            [subView setContentOffset:CGPointMake(subView.contentOffset.x, 0)];
            UIView *tmeSubView=[subView viewWithTag:(8759)];
            if (tmeSubView)
            {
                [tmeSubView removeFromSuperview];
                tmeSubView=nil;
            }
        }
    }
    _oldCurIndex=_curIndex;
}

#pragma mark - 根据用户选择的图片  更新显示数据 -
-(void)updateView
{
    self.curIndex=[self getSelectIndexInImagearray];
    [[self myScrollView] setContentOffset:CGPointMake(self.curIndex*self.myScrollView.bounds.size.width , 0) animated:NO];
    [[self numLbl] setText:[NSString stringWithFormat:@"%d/%d",(int)self.curIndex+1,(int)self.imgArray.count]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}

#pragma mark - FDFullscreenPopGesture -
- (BOOL)fd_prefersNavigationBarHidden {
    return YES;
}

@end
