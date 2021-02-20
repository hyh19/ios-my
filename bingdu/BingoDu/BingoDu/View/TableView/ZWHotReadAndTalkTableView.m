#import "ZWHotReadAndTalkTableView.h"
#import "ZWHotReadCell.h"
#import "ZWReviewCell.h"
#import "ZWSofaCell.h"
#import "ZWNewsTalkModel.h"
#import "ZWNewsHotReadModel.h"
#import "ZWIntegralStatisticsModel.h"
#import "TalkInfoList.h"
#import "ZWReviewLikeHistoryList.h"
#import "NSDate+NHZW.h"
#import "UIImageView+WebCache.h"
#import "ZWArticleAdvertiseModel.h"
#import "ZWArticleAdvertisementCell.h"
#import "ZWNetworkUnioAdvertiseManager.h"
#import "ZWArticleDetailViewController.h"
#import "ZWNewsNetworkManager.h"
#import "ZWNewsCommentManager.h"
#import "ZWLiftStyleIntroduceNewsModel.h"
typedef enum {
    Approval_TalkInfo = 0,
    Report_TalkInfo = 1
}News_TalkInfo;

@interface ZWHotReadAndTalkTableView() <UIScrollViewDelegate,UITableViewDataSource,UITableViewDelegate>
@property (nonatomic,strong) ZWArticleAdvertisementCell *advertiseMentCell;
/**是否请求过热读浏览接口*/
@property (nonatomic, assign) BOOL isRequestHotReadInterface;
/**是否请求过热读浏览接口*/
@property (nonatomic, assign) BOOL isRequestHotTalkInterface;

/**记录上次点击的cell*/
@property (nonatomic, strong) ZWReviewCell *oldClickCell;

/**判断是否是生活方式新闻*/
@property (nonatomic, assign) BOOL isLifeStyleNews;

/**热议section index*/
@property (nonatomic, assign) int hotTalkIndex;

/**保存热读SectionView*/
@property (nonatomic, strong) NSMutableDictionary *hotSectionViewDic;
@end

@implementation ZWHotReadAndTalkTableView
@synthesize pullTableIsLoadingMore;
/**热读cell的复用标记*/
static NSString *CellIdentifier = @"Cell";
/**热议cell的复用标记*/
static NSString *TalkCellIdentifier = @"TalkCell";

#pragma mark - Life cycle -
- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    self = [super initWithFrame:frame style:style];
    if (self)
    {
        self.delegate=self;
        self.dataSource=self;
        self.stopLoad=NO;
        self.sectionFooterHeight = 0;
        _advertiseImageRate=95.0/304.0;
        self.separatorStyle=UITableViewCellSeparatorStyleNone;
        self.backgroundColor=[UIColor clearColor];
        self.layer.borderColor=[UIColor clearColor].CGColor;
        [self addSubview:[self loadMoreView]];
        _myDelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
        [self registerClass:[ZWHotReadCell class] forCellReuseIdentifier:CellIdentifier];
        [self registerNib:[UINib nibWithNibName:@"ZWReviewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:TalkCellIdentifier];
        _hotTalkIndex=-10;
        _hotSectionViewDic=[[NSMutableDictionary alloc] init];
    }
    
    return self;
}
- (void)dealloc
{
    _loadMoreView.delegate = nil;
    _loadMoreDelegate = nil;
    ZWLog(@" ZWHotReadAndTalkTableView  delloc");
}
#pragma mark - Private method -
-(void)setAllDictionary:(NSMutableDictionary *)allDictionary
{
    ZWLog(@"the allDictionary is %@" ,allDictionary);
    if (_allDictionary!=allDictionary)
    {
        _allDictionary=allDictionary;
        [self judgeIsLifeStyeNews];
        if(self.allDictionary[@"hotReview"])
        {
            [self judgeIsNewUnionAdvetise];
            self.loadMoreView.hidden=YES;
        }
    }
    [self reloadData];
    
}
/**判断是否生活方式新闻*/
-(void) judgeIsLifeStyeNews
{
    if (_allDictionary )
    {
        NSArray *array=self.allDictionary[HOTREADKEY];
        if(array)
        {
            if (array.count>0)
            {
                id obj=[array objectAtIndex:0];
                if ([obj isKindOfClass:[ZWLiftStyleIntroduceNewsModel class]])
                {
                    _isLifeStyleNews=YES;
                    _hotTalkIndex=(int)(self.allDictionary.count+array.count-5);
                }
                else
                {
                    _isLifeStyleNews=NO;
                    _hotTalkIndex=3;
                }
            }
            else
            {
                _isLifeStyleNews=NO;
                _hotTalkIndex=3;
            }
        }
        
    }
}
/**UI布局*/
- (void)layoutSubviews
{
    @try
    {
        CGFloat visibleTableDiffBoundsHeight = (self.bounds.size.height - MIN(self.bounds.size.height, self.contentSize.height));
        CGRect loadMoreFrame = [self loadMoreView].frame;
        loadMoreFrame.origin.y = self.contentSize.height + visibleTableDiffBoundsHeight;
        [self loadMoreView].frame = loadMoreFrame;
        [super layoutSubviews];
    }
    @catch (NSException *exception)
    {
        ZWLog(@"ZWHotandReadTableView layoutSubviews error");
    }
    @finally
    {
        
    }
}
/**评论加载更多*/
-(void)loadNewsDetailData
{
    if ([self.loadMoreDelegate respondsToSelector:@selector(pullTableViewDidTriggerLoadMore:)]) {
        [self.loadMoreDelegate pullTableViewDidTriggerLoadMore:self];
    }
}
/**判断是否网盟广告 如果是请求网盟数据，更新界面*/
-(void)judgeIsNewUnionAdvetise
{
    __weak typeof(self) weakSelf=self;
    __weak  ZWArticleAdvertiseModel* articleMode=self.allDictionary[ARTICLE_MODE_KEY];
    if (articleMode.unionAdvertiseUrl && articleMode.isAdAllianceAd)
    {
        //网盟广告
        ZWNetworkUnioAdvertiseManager *unionManager=[[ZWNetworkUnioAdvertiseManager alloc] initUionWithUlr:articleMode.unionAdvertiseUrl callBack:^(NSString* url, NSString *clickUrl ,NSString *title, NSArray *impressionUrl,NSArray*clickMonitorUrl)
                                                     {
                                                         articleMode.adversizeImgUrl=url;
                                                         articleMode.adversizeDetailUrl=clickUrl;
                                                         articleMode.adversizeTitle=title;
                                                         articleMode.impressionUrl=impressionUrl;
                                                         articleMode.clickMonitorUrl=clickMonitorUrl;
                                                         ZWArticleAdvertisementCell *cell=(ZWArticleAdvertisementCell*)[weakSelf cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
                                                         [cell setAdvertiseImageView:url];
                                                     }];
    }
    
    
}
#pragma mark - LoadMoreTableViewDelegate -
- (void)loadMoreTableFooterDidTriggerLoadMore:(LoadMoreTableFooterView *)view
{
    pullTableIsLoadingMore = YES;
    [self loadNewsDetailData];
}

#pragma mark - UIScrollViewDelegate -
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
    if(self.allDictionary[@"newsReview"])
        return;
    if(_loadMoreDelegate )
    {
        if ([_loadMoreDelegate respondsToSelector:@selector(commentScrollviewDidScroll:)])
        {
            [_loadMoreDelegate commentScrollviewDidScroll:scrollView];
        }
        
    }
    if (!self.stopLoad)
    {
        if (_loadMoreView && _loadMoreView.hidden)
        {
            return;
        }
        [[self loadMoreView] egoRefreshScrollViewDidScroll:scrollView];
    }
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if(self.allDictionary[@"hotReview"])
        return;
    if (!self.stopLoad)
    {
        if (_loadMoreView && _loadMoreView.hidden)
        {
            return;
        }
        [[self loadMoreView] egoRefreshScrollViewDidEndDragging:scrollView];
    }
    
}

#pragma mark - UITableViewDatasource -
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.allDictionary)
    {
        if(!_isLifeStyleNews)
            return [self.allDictionary count]-3;
        else
        {
            NSArray *hotArray=self.allDictionary[HOTREADKEY];
            return [self.allDictionary count]-4+hotArray.count;
        }
    }
    return 0;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.allDictionary)
    {
        /**订阅视图*/
        if (section==0)
        {
            return 0;
            //TODO:
            /**暂时屏蔽，1.6待打开*/
            //            id obj=self.allDictionary[SUBSCRIPTIONKEY];
            //            if ([obj isKindOfClass:[UIView class]])
            //            {
            //                return 1;
            //            }
            //            else
            //            {
            //                return 0;
            //            }
        }
        /**广告*/
        else if  (section==1)
        {
            ZWArticleAdvertiseModel* articleMode=self.allDictionary[ARTICLE_MODE_KEY];
            if (articleMode && articleMode.adversizeID)
            {
                return 1;
            }
            else
            {
                return 0;
            }
        }
        /**并读热议*/
        else if(section==_hotTalkIndex)
        {
            
            if ([self.allDictionary[@"commentClose"] boolValue]  || [self.allDictionary[@"talkSofa"] boolValue])
            {
                if (self.allDictionary[@"hotReview"])
                    return 1;
                else
                    return 0;
            }
            if (self.allDictionary[@"hotReview"])
            {
                return [self.allDictionary[@"hotReview"] count];
            }
            else if (self.allDictionary[@"newsReview"])
            {
                return [self.allDictionary[@"newsReview"] count];
            }
        }
        else
        {
            if (_isLifeStyleNews)
            {
                NSArray *hotReadArray=self.allDictionary[HOTREADKEY];
                if (hotReadArray)
                {
                    ZWLiftStyleIntroduceNewsModel *lifeModel=[hotReadArray objectAtIndex:section-2];
                    return lifeModel.subModelArray.count;
                }
            }
            /**热读*/
            if (self.allDictionary[HOTREADKEY])
            {
                return [self.allDictionary[HOTREADKEY] count];
            }
            return 0;
        }
        
    }
    return 0;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.allDictionary)
    {
        if (indexPath.section==0)
        {
            return 0;
            //TODO:下个版本开放           id obj =self.allDictionary[SUBSCRIPTIONKEY];
            //            if ([obj isKindOfClass:[UIView class]])
            //            {
            //                UIView *subscriptionView=obj;
            //                return subscriptionView.bounds.size.height;
            //            }
            
        }
        else  if(indexPath.section==1)
        {
            ZWArticleAdvertiseModel* articleMode=self.allDictionary[ARTICLE_MODE_KEY];
            if (articleMode && articleMode.adversizeID)
            {
                return 60+(SCREEN_WIDTH-16)*_advertiseImageRate;
            }
            else
            {
                return 0;
            }
            
        }
        else if (indexPath.section==_hotTalkIndex)
        {
            if ([self.allDictionary[@"commentClose"] boolValue]  || [self.allDictionary[@"talkSofa"] boolValue])
            {
                if (self.allDictionary[@"hotReview"])
                {
                    return 50;
                }
                else
                    return 0;
            }
            //根据字体长度自适应cell高度
            if (self.allDictionary[@"hotReview"])
            {
                //评论广告
                if (indexPath.row==5 && _detailViewType==ZWDetailDefaultNews)
                {
                    return 58;
                }
                ZWNewsTalkModel *cellModel = self.allDictionary[@"hotReview"][indexPath.row];
                return cellModel.cellHeight;
            }
            else if (self.allDictionary[@"newsReview"])
            {
                ZWNewsTalkModel *cellModel = self.allDictionary[@"newsReview"][indexPath.row];
                return cellModel.cellHeight;
            }
            
        }
        else
        {
            if (!_isLifeStyleNews && indexPath.section==2)
            {
                return 70;
            }
            else if(_isLifeStyleNews)
            {
                if (self.allDictionary[HOTREADKEY])
                    return 60;
                else
                    return 0;
            }
           
        }
        
    }
    return 0;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.allDictionary)
    {
        //订阅模块
        if (indexPath.section==0)
        {
            static NSString *subscriptionCell=@"subscriptionTiseCell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:subscriptionCell];
            if (!cell)
            {
                cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:subscriptionCell];
                cell.selectionStyle=UITableViewCellSelectionStyleNone;
            }
            id obj=self.allDictionary[SUBSCRIPTIONKEY];
            if ([obj isKindOfClass:[UIView class]])
            {
                [cell addSubview:(UIView*)obj];
            }
            return cell;
        }
        //广告模块
        else  if (indexPath.section==1)
        {
            static NSString *advertiseCell=@"adverTiseCell";
            ZWArticleAdvertiseModel* articleMode=self.allDictionary[ARTICLE_MODE_KEY];
            if (articleMode.adversizeImageLoadFinish)
            {
                return self.advertiseMentCell;
            }
            ZWArticleAdvertisementCell *cell = [tableView dequeueReusableCellWithIdentifier:advertiseCell];
            if (!cell)
            {
                cell= (ZWArticleAdvertisementCell *)[[[NSBundle  mainBundle]  loadNibNamed:@"ZWArticleAdvertisementCell" owner:self options:nil]  lastObject];
                cell.selectionStyle=UITableViewCellSelectionStyleNone;
                cell.articeAdvertizeModel=articleMode;
                [cell updateAdvetiseViewFrame:articleMode];
                
            }
            if (articleMode.adversizeID)
            {
                [cell setAccessoryType:UITableViewCellAccessoryNone];
                [cell setArticeAdvertizeModel:self.allDictionary[ARTICLE_MODE_KEY]];
                
            }
            self.advertiseMentCell=cell;
            return cell;
            
        }
        // 并友最热热议模块
        else if (indexPath.section==_hotTalkIndex)
        {
            if (!_isRequestHotTalkInterface && !_isClickCommentBtn)
            {
                [self sendHotTalkIsGetRequest];
            }
            if ([self.allDictionary[@"commentClose"] boolValue])
            {
                //调用沙发cell
                static NSString *TalkEmptyCell = @"TalkEmptyCell";
                ZWSofaCell *cell = [tableView dequeueReusableCellWithIdentifier:TalkEmptyCell];
                if (cell == nil) {
                    cell= (ZWSofaCell *)[[[NSBundle  mainBundle]  loadNibNamed:@"ZWSofaCell" owner:self options:nil]  lastObject];
                    
                    if (_detailViewType==ZWDetailVideo)
                    {
                        /**修改imageview的frame*/
                        CGRect rect=cell.frame;
                        rect.size.height=SCREEN_HEIGH-198-44-20;
                        cell.frame=rect;
                    }
                }
                cell.selectionStyle=UITableViewCellSelectionStyleNone;
                [cell setAccessoryType:UITableViewCellAccessoryNone];
                [cell.promptLabel setText:@"该文章暂时无法评论!"];
                return cell;
            }
            if ([self.allDictionary[@"talkSofa"] boolValue])
            {
                //调用沙发cell
                static NSString *TalkEmptyCell = @"TalkEmptyCell";
                ZWSofaCell *cell = [tableView dequeueReusableCellWithIdentifier:TalkEmptyCell];
                if (cell == nil) {
                    cell= (ZWSofaCell *)[[[NSBundle  mainBundle]  loadNibNamed:@"ZWSofaCell" owner:self options:nil]  lastObject];
                    if (_detailViewType==ZWDetailVideo)
                    {
                        /**修改imageview的frame*/
                        CGRect rect=cell.frame;
                        rect.size.height=SCREEN_HEIGH-198-20-44-100;
                        cell.frame=rect;
                        
                        cell.promptLabel.frame=cell.bounds;
                    }

                }
                cell.selectionStyle=UITableViewCellSelectionStyleNone;
                [cell setAccessoryType:UITableViewCellAccessoryNone];
                return cell;
            }
            else
            {
                //添加广告cell
                if(indexPath.row==5 && _detailViewType==ZWDetailDefaultNews)
                {
                    static NSString *advertiseCell=@"advertiseCell";
                    UITableViewCell* cell=[tableView dequeueReusableCellWithIdentifier:advertiseCell];
                    if (!cell)
                    {
                        cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:advertiseCell ];
                        cell.textLabel.textColor=[UIColor colorWithHexString:@"848484"];
                        cell.textLabel.font=[UIFont systemFontOfSize:13.0f];
                        cell.textLabel.textAlignment=NSTextAlignmentCenter;
                        cell.selectionStyle=UITableViewCellSelectionStyleNone;
                        [cell setAccessoryType:UITableViewCellAccessoryNone];
                        [cell setBackgroundColor:COLOR_F8F8F8];
                        
                        //增加下划线
                        UIView  *underLine = [[UIView alloc] initWithFrame:CGRectZero];
                        [underLine setBackgroundColor:COLOR_E7E7E7];
                        
                         underLine.frame = CGRectMake(10, 58 - 0.5, SCREEN_WIDTH - 20, 0.5);
                        [cell addSubview:underLine];
                    }
                    ZWNewsTalkModel *talkModel;
                    if (self.allDictionary[@"hotReview"])
                    {
                        if([self.allDictionary[@"hotReview"] count]>indexPath.row)
                            talkModel=self.allDictionary[@"hotReview"][indexPath.row];
                        talkModel.isHotComment=YES;
                        cell.textLabel.text=talkModel.newsTitle;
                    }
                    return cell;

                }
                static  NSString  *hotCell=@"hotTalkCell";
                ZWReviewCell* cell=[tableView dequeueReusableCellWithIdentifier:hotCell];
                if (!cell)
                {
                    
                    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ZWReviewCell" owner:self options:nil];
                    if([[nib objectAtIndex:0] isKindOfClass:[ZWReviewCell class]])
                    {
                        cell = [nib objectAtIndex:0];
                    }
                    cell.baseTabView=self;
                    cell.selectionStyle=UITableViewCellSelectionStyleNone;
                    [cell setAccessoryType:UITableViewCellAccessoryNone];
                }
                UIView *subView=[cell viewWithTag:2098];
                if (subView)
                {
                    [subView removeFromSuperview];
                    subView=nil;
                }
                cell.tag = indexPath.row;
                [cell.operationMagager animateShowOrHideOpretationView:NO auto:NO];
                ZWNewsTalkModel *talkModel;
                if (self.allDictionary[@"hotReview"])
                {
                    if([self.allDictionary[@"hotReview"] count]>indexPath.row)
                        talkModel=self.allDictionary[@"hotReview"][indexPath.row];
                    talkModel.isHotComment=YES;
                }
                else if (self.allDictionary[@"newsReview"])
                {
                    if([self.allDictionary[@"newsReview"] count]>indexPath.row)
                        talkModel=self.allDictionary[@"newsReview"][indexPath.row];
                }
                
                [cell setReviewData:talkModel];
                
                return cell;
            }
        }
        // 并友热读模块
        else
        {
            static NSString *hotReadCell=@"hotReadCell";
            ZWHotReadCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (!cell)
            {
                cell= [[ZWHotReadCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:hotReadCell];
            }
            cell.textLabel.numberOfLines=2;
            cell.textLabel.font=[UIFont systemFontOfSize:15];
            cell.textLabel.textColor=COLOR_333333;
            [cell setAccessoryType:UITableViewCellAccessoryNone];
            
            ZWNewsHotReadModel *readModel;
            if (_isLifeStyleNews)
            {
                cell.isLifeStyleCell=YES;
                NSArray *hotReadArray=self.allDictionary[HOTREADKEY];
                if (hotReadArray)
                {
                    //section从2开始
                    ZWLiftStyleIntroduceNewsModel *lifeModel=[hotReadArray objectAtIndex:indexPath.section-2];
                    readModel=[lifeModel.subModelArray objectAtIndex:indexPath.row];
                }

            }
            else
                readModel=(ZWNewsHotReadModel *)self.allDictionary[@"hotRead"][indexPath.row];
            cell.textLabel.text =readModel.newsTitle;
            [cell.imageView sd_setImageWithURL:[NSURL URLWithString:readModel.newsImageUrl]placeholderImage:[UIImage imageNamed:@"icon_banner_ad"]];
            return cell;
        }
    }
    return nil;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section;
{
    if (self.allDictionary)
    {
        if (section==_hotTalkIndex)
        {
            if (self.allDictionary[@"hotReview"])
                return [self talkHeaderView];
            else if (self.allDictionary[NEWCOMMENTKEY])
                return nil;
        }
        else if(section==0 || section==1)
        {
            return nil;
        }
        else
        {
            if (!_isLifeStyleNews && section==2)
            {
                NSArray *subArray=self.allDictionary[HOTREADKEY];
                if(subArray.count<=0)
                    return nil;
                return [self readHeaderView:@"并友热读"  section:section];
            }
            else if(_isLifeStyleNews)
            {
                NSArray *hotReadArray=self.allDictionary[HOTREADKEY];
                if (hotReadArray)
                {
                    ZWLiftStyleIntroduceNewsModel *lifeModel=[hotReadArray objectAtIndex:section-2];
                    if (lifeModel.subModelArray.count<=0) {
                        return nil;
                    }
                    return [self readHeaderView:lifeModel.title section:section];
                }
            }
            return nil;
        }
    }
    return nil;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section==0 || section==1)
    {
        return 0.01f;
    }
    else if (section==_hotTalkIndex)
    {
        if (self.allDictionary[@"hotReview"])
            return 47;
        return 0.01f;
    }
    else
    {
        if (!_isLifeStyleNews && section==2)
        {
            NSArray *hotReadArray=self.allDictionary[HOTREADKEY];
            if (hotReadArray)
            {
                if(hotReadArray.count<=0)
                    return 0.01f;
            }
            return 47;
        }
        else if(_isLifeStyleNews)
        {

             return 47;
        }
        else
            return 0.01f;
    }
    return 0.01f;
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    /**
     *  点击广告
     */
    if (indexPath.section==1)
    {
        ZWArticleAdvertiseModel* articleMode=self.allDictionary[ARTICLE_MODE_KEY];
        if (articleMode.adversizeID)
        {
            [(ZWArticleDetailViewController*)self.baseViewController onTouchArticleAdversizeCell:articleMode];
        }
    }
    else if(indexPath.section==_hotTalkIndex)
    {
        if ([self.allDictionary[@"talkSofa"] boolValue])
        {
            return;
        }
        //检测键盘是否弹出
        UIView *tempView=[tableView cellForRowAtIndexPath:indexPath];
        if (![tempView isKindOfClass:[ZWReviewCell class]])
        {
            return;
        }
        //点击了评论广告
        if (indexPath.row==5 && _detailViewType==ZWDetailDefaultNews)
        {
            return;
        }
        __weak  ZWReviewCell *cell=(ZWReviewCell*)[tableView cellForRowAtIndexPath:indexPath ];
        if (_oldClickCell)
        {
            if (_oldClickCell!=cell)
            {
                [_oldClickCell.operationMagager animateShowOrHideOpretationView:NO auto:NO];
            }
        }
        [cell setEditing:YES animated:YES];
        UIView *textFieldview=[[self superview] viewWithTag:90876];
        UIView *textview=[[self superview] viewWithTag:98076];
        if ([textFieldview isKindOfClass:[UITextField class]] || [textview isKindOfClass:[UITextView class]])
        {
            UITextField *textField=(UITextField*)textFieldview;
            UITextView *textvView=(UITextView*)textview;
            if ([textField isFirstResponder]  || [textvView isFirstResponder])
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:HideKeyboardNotification object:nil];
                return;
            }
            
        }
        if([ZWUserInfoModel userID] && cell.reviewData.userId)
        {
            if ([[ZWUserInfoModel userID] intValue]==[cell.reviewData.userId intValue])
            {
                occasionalHint(@"不能操作自己的评论！");
                return;
            }
        }
        [cell.operationMagager animateShowOrHideOpretationView:YES auto:YES];
        _oldClickCell=cell;
    }
    else
    {
        ZWNewsHotReadModel *newsModel;
        if (_isLifeStyleNews)
        {
            [MobClick event:@"click_extended_reading_list"];
            NSArray *hotReadArray=self.allDictionary[HOTREADKEY];
            if (hotReadArray)
            {
                ZWLiftStyleIntroduceNewsModel *lifeModel=[hotReadArray objectAtIndex:indexPath.section-2];
                newsModel=[lifeModel.subModelArray objectAtIndex:indexPath.row];
            }
        }
        else
        {
            newsModel=(ZWNewsHotReadModel *)self.allDictionary[@"hotRead"][indexPath.row];
        }
        [(ZWArticleDetailViewController*)self.baseViewController onTouchHotReadCell:newsModel];
    }
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (self.allDictionary[@"hotReview"] )
    {
        if ([self.allDictionary[@"commentClose"] boolValue]  || [self.allDictionary[@"talkSofa"] boolValue])
        {
            return nil;
        }
        if (section==_hotTalkIndex && [self.allDictionary[LOADMORE] boolValue])
        {
            UIView *footView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 82)];
            UIButton *loadMoreBtn=[UIButton buttonWithType:UIButtonTypeCustom];
            loadMoreBtn.layer.borderWidth=0.5f;
            loadMoreBtn.layer.borderColor=[UIColor colorWithHexString:COLOR_STRING_00BAA2 alpha:0.5].CGColor;
            loadMoreBtn.frame=CGRectMake((SCREEN_WIDTH-130)/2, 25, 130, 32);
            [loadMoreBtn setTitle:@"查看更多评论" forState:UIControlStateNormal];
            [loadMoreBtn setTitleColor:COLOR_00BAA2 forState:UIControlStateNormal];
            loadMoreBtn.titleLabel.font=[UIFont systemFontOfSize:14];
            [loadMoreBtn addTarget:self action:@selector(readMoreComment) forControlEvents:UIControlEventTouchUpInside];
            [footView addSubview:loadMoreBtn];
            return footView;
        }
    }
    
    return nil;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if ([self.allDictionary[@"commentClose"] boolValue]  || [self.allDictionary[@"talkSofa"] boolValue])
    {
        return 0;
    }
    else if (section==_hotTalkIndex && [self.allDictionary[LOADMORE] boolValue])
    {
        return 82;
    }
    
    return 0;
}

#pragma mark - setUI Init -
/**移除评论的弹出视图*/
-(void)removeCommentPopView:(ZWReviewCell*)cell
{
    __weak typeof(self) weakSelf=self;
    [UIView animateWithDuration:0.3f animations:^
     {
         CGRect rect=weakSelf.popView.frame;
         rect.origin.x=SCREEN_WIDTH+10;
         weakSelf.popView.frame=rect;
         weakSelf.popView.alpha=0.0f;
         cell.approvalButton.alpha=1.0f;
     }
                     completion:^(BOOL finished)
     {
         [weakSelf.popView removeFromSuperview];
     }];
    return;
    
}
#pragma mark - Getter & Setter -
- (void)setPullTableIsLoadingMore:(BOOL)isLoadingMore
{
    if(!pullTableIsLoadingMore && isLoadingMore) {
        [[self loadMoreView] startAnimatingWithScrollView:self];
        pullTableIsLoadingMore = YES;
    } else if(pullTableIsLoadingMore && !isLoadingMore) {
        [[self loadMoreView] egoRefreshScrollViewDataSourceDidFinishedLoading:self];
        pullTableIsLoadingMore = NO;
    }
}
- (LoadMoreTableFooterView *)loadMoreView
{
    if(!_loadMoreView)
    {
        _loadMoreView = [[LoadMoreTableFooterView alloc] initWithFrame:CGRectMake(0, self.bounds.size.height, self.bounds.size.width, self.bounds.size.height)];
        _loadMoreView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        _loadMoreView.delegate = self;
    }
    return _loadMoreView;
}

-(UIView *)readHeaderView:(NSString*)sectionTitle section:(NSInteger)section
{
       UIView *hotSectionView=[_hotSectionViewDic objectForKey:[NSNumber numberWithInteger:section]];
       if (hotSectionView) {
           return hotSectionView;
       }

        UIView *topTalkContainView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 40+7)];
        topTalkContainView.backgroundColor=COLOR_E7E7E7;
        topTalkContainView.clipsToBounds=YES;
        //并友热读头部
        UIView *headerView=[[UIView alloc]initWithFrame:CGRectMake(0, 7,SCREEN_WIDTH,40)];
        [headerView setBackgroundColor:COLOR_F8F8F8];
        headerView.layer.borderColor=[UIColor clearColor].CGColor;
        headerView.tag=100;
        UIImageView *readimg=[[UIImageView alloc]initWithFrame:CGRectMake(12, 14, 4, 19)];
        [readimg setImage:[UIImage imageNamed:@"head"]];
        [headerView addSubview:readimg];
        UILabel *readlab=[[UILabel alloc]initWithFrame:CGRectMake(2+15, 9, 250, 30)];
        [readlab setTextColor:COLOR_00BAA2];
        sectionTitle=[NSString stringWithFormat:@" %@",sectionTitle];
        [readlab setText:sectionTitle];
        
        [readlab setFont:[UIFont systemFontOfSize: 18]];
        [headerView addSubview:readlab];
        [topTalkContainView addSubview:headerView];
        [_hotSectionViewDic setObject:topTalkContainView forKey:[NSNumber numberWithInteger:section]];
         return topTalkContainView;
}
-(UIView *)newTalkHeaderView
{
    if (!_newTalkHeaderView)
    {
        UIView *topTalkView=[[UIView alloc]initWithFrame:CGRectMake(0, 0,SCREEN_WIDTH, 40)];
        [topTalkView setBackgroundColor:COLOR_F8F8F8];
        topTalkView.layer.borderColor=[UIColor clearColor].CGColor;
        topTalkView.tag=100;
        UIImageView *talkimg=[[UIImageView alloc]initWithFrame:CGRectMake(12, 14, 4, 19)];
        [talkimg setImage:[UIImage imageNamed:@"head"]];
        [topTalkView addSubview:talkimg];
        UILabel *talklabl=[[UILabel alloc]initWithFrame:CGRectMake(15+2, 9, 100, 30)];
        [talklabl setTextColor:COLOR_00BAA2];
        [talklabl setText:@" 最新评论"];
        [talklabl setFont:[UIFont systemFontOfSize: 18]];
        [topTalkView addSubview:talklabl];
        
        _newTalkHeaderView= topTalkView;
    }
    return _newTalkHeaderView;
}

-(UIView *)talkHeaderView
{
    if (!_talkHeaderView)
    {
        UIView *topTalkContainView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 40+7)];
        topTalkContainView.backgroundColor=COLOR_E7E7E7;
        topTalkContainView.layer.borderColor=[UIColor blackColor].CGColor;
        topTalkContainView.clipsToBounds=YES;
        UIView *topTalkView=[[UIView alloc]initWithFrame:CGRectMake(0, 7,SCREEN_WIDTH, 40)];
        [topTalkView setBackgroundColor:COLOR_F8F8F8];
        topTalkView.tag=100;
        UIImageView *talkimg=[[UIImageView alloc]initWithFrame:CGRectMake(12, 14, 4, 19)];
        [talkimg setImage:[UIImage imageNamed:@"head"]];
        [topTalkView addSubview:talkimg];
        UILabel *talklabl=[[UILabel alloc]initWithFrame:CGRectMake(15+2, 9, 150, 30)];
        [talklabl setTextColor:COLOR_00BAA2];
        [talklabl setText:@" 并友热议"];
        [talklabl setFont:[UIFont systemFontOfSize: 18]];
        [topTalkView addSubview:talklabl];
        [topTalkContainView addSubview:topTalkView];
        
        if (_detailViewType==ZWDetailVideo)
        {
            topTalkView.frame=topTalkContainView.bounds;
            talkimg.frame=CGRectMake(12, (47-19)/2, 4, 19);
            talklabl.frame=CGRectMake(15+2,(47-30)/2, 150, 30);
        }
        _talkHeaderView= topTalkContainView;
    }
    return _talkHeaderView;
}
/**创建广告视图*/
-(UIView*)createAdvertisingView
{
    UIView *adverstView=[[UIView alloc] initWithFrame:CGRectMake(5, 0, SCREEN_WIDTH-10, 100)];
    UIImageView *adversImageView=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH-10, 80)];
    [adversImageView sd_setImageWithURL:[NSURL URLWithString:@""] placeholderImage:[UIImage imageNamed:@""]];
    return adverstView;
}
#pragma mark - event handle -
/**查看更多的评论*/
-(void)readMoreComment
{
    ZWNewsModel *modle=[[ZWNewsModel alloc] init];
    modle.newsId=self.newsId;
    modle.channel=self.channelId;
    modle.newsSourceType=self.newsSourceType;
    ZWArticleDetailViewController *commmentController=[[ZWArticleDetailViewController alloc] initWithNewsModel:modle];
    commmentController.detailViewType=ZWDetailComment;
    /**获取父类导航*/
    UIViewController *controller=(UIViewController*)self.superview.nextResponder;
    [controller.navigationController pushViewController:commmentController animated:YES];
}
/**评论点赞*/
-(void)chickLikeTalk:(int)likeAction from:(ZWNewsTalkModel *)from index:(int)index isFromHot:(BOOL)isFromHot
{
    __weak typeof(self) weakSelf=self;
    if (![ZWUserInfoModel login]) {
        ZWIntegralStatisticsModel* obj = [ZWIntegralStatisticsModel loadCustomObjectWithKey:kUserDefaultsPointData];
        NSString *sumIntegration= [NSString stringWithFormat:@"%.2f",[ZWIntegralStatisticsModel sumIntegrationBy:obj]];
        if ([sumIntegration floatValue]>0)
        {
            NSString *today=[NSDate todayString];
            NSString *lastDate=[NSUserDefaults loadValueForKey:BELAUD_NEWS];
            if (![today isEqualToString:lastDate]) {
                [NSUserDefaults saveValue:today ForKey:BELAUD_NEWS];
                [((ZWArticleDetailViewController*)weakSelf.baseViewController) loadLoginViewByLikeOrHate];
            }
            
        }
    }
    __weak ZWNewsTalkModel*likeModel=nil;
    if (isFromHot)
    {
        likeModel=(ZWNewsTalkModel *)self.allDictionary[@"hotReview"][index];
    }
    else
    {
        likeModel=(ZWNewsTalkModel *)self.allDictionary[@"newsReview"][index];
    }
    [likeModel setPraiseCount:[NSNumber numberWithInt:([likeModel.praiseCount intValue]+(likeAction==1?1:-1))]];
    [likeModel setAlreadyApproval:likeAction==1?YES:NO];
    //存储点赞标示状态
    [self changeHotTalkInfoWith:likeModel type:Approval_TalkInfo likeAction:likeAction];
    
    [[ZWNewsNetworkManager sharedInstance] uploadLikeTalk:[ZWUserInfoModel userID]
                                                   action:[NSNumber numberWithInt:likeAction]
                                                channelId:self.channelId
                                                commentId:[NSNumber numberWithInt:[from.commentId intValue]]
                                                   newsId:[NSNumber numberWithInt:[self.newsId intValue]]
                                                     from:from.userId
                                                  isCache:NO
                                                   succed:^(id result)
     {
         
         [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:likeAction>0?YES:NO] forKey:[NSString stringWithFormat:@"%d_good",[likeModel.commentId intValue]]];
         [[NSUserDefaults standardUserDefaults] synchronize];
         
         if(_oldClickCell)
         {
             ZWCommentPopView* commentPopview=[_oldClickCell viewWithTag:commentViewTag];
             if (commentPopview)
             {
                 [commentPopview changeBtnState:ZWClickGood value:(likeAction==1?YES:NO)];
             }
         }
         ZWLog(@"赞请求成功");
         //  occasionalHint(@"点赞成功");
         if (![ZWUserInfoModel userID]) {
             if (![ZWReviewLikeHistoryList queryAlreadyReviewLikeNoUser:weakSelf.newsId]) {
                 [ZWReviewLikeHistoryList addAlreadyReviewLikeNoUser:weakSelf.newsId];
                 [weakSelf changeLocalReviewLike:[ZWIntegralStatisticsModel saveIntergralItemData:IntegralReviewLike]];
             }
         }else
         {
             if (![ZWReviewLikeHistoryList queryAlreadyReviewLikeUser:weakSelf.newsId]) {
                 [ZWReviewLikeHistoryList addAlreadyReviewLikeUser:weakSelf.newsId];
                 [weakSelf changeLocalReviewLike:[ZWIntegralStatisticsModel saveIntergralItemData:IntegralReviewLike]];
             }
         }
     }
                                                   failed:^(NSString *errorString)
     {
         
         ZWLog(@"赞请求失败");
         
     }];
    
}
#pragma mark - upadate local info (such as integral)-
/**点击了举报*/
-(void)chickReportTalk:(NSNumber *)commentId index:(int)index isHotComment:(BOOL)isHotComment
{
    __weak ZWNewsTalkModel*reportModel;
    if (isHotComment)
    {
        reportModel=(ZWNewsTalkModel *)self.allDictionary[@"hotReview"][index];
    }
    else
    {
        reportModel=(ZWNewsTalkModel *)self.allDictionary[@"newsReview"][index];
    }
    reportModel.alreadyReport=YES;
    
    //存储举报标示状态
    [self changeHotTalkInfoWith:reportModel type:Report_TalkInfo likeAction:2];
    [[ZWNewsNetworkManager sharedInstance] uploadReportTalk:[ZWUserInfoModel userID]
                                                  commentId:commentId
                                                    isCache:NO
                                                     succed:^(id result)
     {
         [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:[NSString stringWithFormat:@"%d_report",[reportModel.commentId intValue]]];
         [[NSUserDefaults standardUserDefaults]synchronize];
         ZWLog(@"举报请求成功");
     }
                                                     failed:^(NSString *errorString)
     {
         ZWLog(@"举报请求失败");
     }];
}

/**本地加分*/
-(void)changeLocalReviewLike:(ZWIntegralRuleModel *)itemRule
{
    //评论点赞加1 然后存储本地
    ZWIntegralStatisticsModel* obj = [ZWIntegralStatisticsModel loadCustomObjectWithKey:kUserDefaultsPointData];
    if (obj) {
        if ([obj.reviewLike intValue]<[itemRule.pointMax intValue]) {
            [obj setReviewLike:[NSNumber numberWithFloat:([obj.reviewLike floatValue]+[itemRule.pointValue floatValue])]];
            [ZWIntegralStatisticsModel saveCustomObject:obj];
            NSString *totalIncome=[NSString stringWithFormat:@"%.2f",[ZWIntegralStatisticsModel sumIntegrationBy:obj]];
            [[NSNotificationCenter defaultCenter] postNotificationName:IntegralTotalIncome object:totalIncome];
        }
    }
}
//改变热议点赞与举报信息 并判断是否需要缓存
-(void)changeHotTalkInfoWith:(ZWNewsTalkModel *)talkModel
                        type:(News_TalkInfo)type
                  likeAction:(int)likeAction
{
    //查询热议数据
    NSFetchRequest* request=[[NSFetchRequest alloc] init];
    NSEntityDescription* hotTalk=[NSEntityDescription entityForName:@"TalkInfoList" inManagedObjectContext:self.myDelegate.managedObjectContext];
    [request setEntity:hotTalk];
    //查询条件
    NSPredicate* predicate=[NSPredicate predicateWithFormat:@"userId==%@&&commentId==%@",talkModel.userId,talkModel.commentId];
    [request setPredicate:predicate];
    NSError* error=nil;
    NSMutableArray* mutableFetchResult=[[self.myDelegate.managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    ZWLog(@"The count of entry: %d",(int)mutableFetchResult.count);
    if (mutableFetchResult==nil) {
        ZWLog(@"Error:%@",error);
    }else{
        if (mutableFetchResult.count==0) {
            //没有此条评论标示需新建
            TalkInfoList *talk=(TalkInfoList *)[NSEntityDescription insertNewObjectForEntityForName:@"TalkInfoList" inManagedObjectContext:self.myDelegate.managedObjectContext];
            [talk setUserId:talkModel.userId];
            [talk setCommentId:talkModel.commentId];
            if (type==Approval_TalkInfo) {
                if (likeAction==1) {
                    [talk setAlreadyApproval:[NSNumber numberWithBool:YES]];
                }else if(likeAction==0)
                {
                    [talk setAlreadyApproval:[NSNumber numberWithBool:NO]];
                }
                [talkModel setAlreadyReport:NO];
            }else if(type==Report_TalkInfo)
            {
                [talk setAlreadyReport:[NSNumber numberWithBool:YES]];
                [talkModel setAlreadyApproval:NO];
            }
            NSError* oneError;
            BOOL isSaveSuccess=[self.myDelegate.managedObjectContext save:&error];
            if (!isSaveSuccess) {
                ZWLog(@"oneError:%@",oneError);
            }else{
                ZWLog(@"HotTalk one Save successful!");
            }
        }
        else
        {
            //存在此评论标示则不需要创建 直接去修改
            for (TalkInfoList *talkModel in mutableFetchResult)
            {
                if (type==Approval_TalkInfo)
                {
                    if (likeAction==1)
                    {
                        [talkModel setAlreadyApproval:[NSNumber numberWithBool:YES]];
                    }
                    else if(likeAction==0)
                    {
                        [talkModel setAlreadyApproval:[NSNumber numberWithBool:NO]];
                        //判断如果该评论也没有举报过 既删除此评论标示 让出内存
                        if (![talkModel.alreadyReport boolValue]) {
                            [self.myDelegate.managedObjectContext deleteObject:talkModel];
                        }
                        NSError* threeError;
                        BOOL isSaveSuccess=[self.myDelegate.managedObjectContext save:&error];
                        if (!isSaveSuccess) {
                            ZWLog(@"deleteError:%@",threeError);
                        }else{
                            ZWLog(@"HotTalk delete successful!");
                        }
                        return;
                    }
                }
                else if(type==Report_TalkInfo)
                {
                    [talkModel setAlreadyReport:[NSNumber numberWithBool:YES]];
                }
                NSError* twoError;
                BOOL isSaveSuccess=[self.myDelegate.managedObjectContext save:&error];
                if (!isSaveSuccess) {
                    ZWLog(@"twoError:%@",twoError);
                }else{
                    ZWLog(@"HotTalk two Save successful!");
                }
                
            }
        }
    }
}
#pragma mark - network -
-(void)sendHotTalkIsGetRequest
{
    if (_isRequestHotTalkInterface) {
        return;
    }
    _isRequestHotTalkInterface=YES;
    [[ZWNewsNetworkManager sharedInstance] userActionStatisticsWithNewsId:_newsId channelId:_channelId isLifeStye:NO isHotRead:NO readPercent:nil  publishTime:nil readNewsType:nil  succeeded:nil  failed:^(NSString* errorString)
     {
         ZWLog(@"sendHotTalkIsGetRequest faild:%@", errorString);
     }];
}
@end
