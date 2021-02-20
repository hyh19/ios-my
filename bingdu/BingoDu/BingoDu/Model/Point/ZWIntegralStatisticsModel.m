#import "ZWIntegralStatisticsModel.h"
#import "ZWShareNewsHistoryList.h"
#import "ZWReadNewsHistoryList.h"
#import "ZWReviewNewsHistoryList.h"
#import "ZWReviewLikeHistoryList.h"
#import "NSDate+NHZW.h"

@implementation ZWIntegralStatisticsModel
@synthesize loginFrequency;
@synthesize registration;
@synthesize shareRead;
@synthesize reviewLike;
@synthesize reviewCoverLike;
@synthesize review;
@synthesize readNews;
@synthesize lookAdvertising;
@synthesize shareExtract;
@synthesize shareConvert;
@synthesize shareByRead;
@synthesize otherIntegral;
@synthesize exerciseIntegral;
@synthesize userSignIntegral;

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static ZWIntegralStatisticsModel *_Integral;
    dispatch_once(&onceToken, ^{
        _Integral = [[ZWIntegralStatisticsModel alloc] init];

    });
    return _Integral;
}

-(ZWPointNetworkManager *)integralManager
{
    if (!_integralManager) {
        _integralManager=[[ZWPointNetworkManager alloc]init];
    }
    return _integralManager;
}

- (id) initWithCoder: (NSCoder *)coder
{
    if (self = [super init])
    {
        self.loginFrequency = [coder decodeObjectForKey:@"loginFrequency"];
        self.registration = [coder decodeObjectForKey:@"registration"];
        self.shareRead = [coder decodeObjectForKey:@"shareRead"];
        self.reviewLike = [coder decodeObjectForKey:@"reviewLike"];
        self.reviewCoverLike = [coder decodeObjectForKey:@"reviewCoverLike"];
        self.review = [coder decodeObjectForKey:@"review"];
        self.readNews = [coder decodeObjectForKey:@"readNews"];
        self.lookAdvertising = [coder decodeObjectForKey:@"lookAdvertising"];
        self.shareExtract = [coder decodeObjectForKey:@"shareExtract"];
        self.shareConvert = [coder decodeObjectForKey:@"shareConvert"];
        self.curDataTime = [coder decodeObjectForKey:@"curDataTime"];
        self.shareByRead =[coder decodeObjectForKey:@"shareByRead"];
        self.otherIntegral =[coder decodeObjectForKey:@"otherIntegral"];
        self.exerciseIntegral =[coder decodeObjectForKey:@"exerciseIntegral"];
        self.userSignIntegral = [coder decodeObjectForKey:@"userSignIntegral"];
//        self.totalIncome = [coder decodeObjectForKey:@"totalIncome"];
    }
    return self;
}
- (void) encodeWithCoder: (NSCoder *)coder
{
    [coder encodeObject:self.loginFrequency forKey:@"loginFrequency"];
    [coder encodeObject:self.registration forKey:@"registration"];
    [coder encodeObject:self.shareRead forKey:@"shareRead"];
    [coder encodeObject:self.reviewLike forKey:@"reviewLike"];
    [coder encodeObject:self.reviewCoverLike forKey:@"reviewCoverLike"];
    [coder encodeObject:self.review forKey:@"review"];
    [coder encodeObject:self.readNews forKey:@"readNews"];
    [coder encodeObject:self.lookAdvertising forKey:@"lookAdvertising"];
    [coder encodeObject:self.shareExtract forKey:@"shareExtract"];
    [coder encodeObject:self.shareConvert forKey:@"shareConvert"];
    [coder encodeObject:self.curDataTime forKey:@"curDataTime"];
    [coder encodeObject:self.shareByRead forKey:@"shareByRead"];
    [coder encodeObject:self.otherIntegral forKey:@"otherIntegral"];
    [coder encodeObject:self.exerciseIntegral forKey:@"exerciseIntegral"];
    [coder encodeObject:self.userSignIntegral forKey:@"userSignIntegral"];
//    [coder encodeObject:self.totalIncome forKey:@"totalIncome"];
}
+ (void)saveCustomObject:(ZWIntegralStatisticsModel *)obj
{
    NSData *myEncodedObject = [NSKeyedArchiver archivedDataWithRootObject:obj];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:myEncodedObject forKey:kUserDefaultsPointData];
    [defaults  synchronize];
}
+(float)sumIntegrationBy:(ZWIntegralStatisticsModel*)obj
{
    float sum=0.0;
    sum=[obj.loginFrequency floatValue]+
        [obj.registration floatValue] +
        [obj.shareRead floatValue] +
        [obj.reviewLike floatValue]+
        [obj.reviewCoverLike floatValue]+
        [obj.review floatValue]+
        [obj.readNews floatValue]+
        [obj.lookAdvertising floatValue]+
        [obj.shareExtract floatValue]+
        [obj.shareConvert floatValue]+
        [obj.shareByRead floatValue]+
        [obj.otherIntegral floatValue]+
        [obj.exerciseIntegral floatValue]+
        [obj.userSignIntegral floatValue];
    return sum;
}
+ (ZWIntegralStatisticsModel *)loadCustomObjectWithKey:(NSString *)key
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *myEncodedObject = [defaults objectForKey:key];
    ZWIntegralStatisticsModel *obj = (ZWIntegralStatisticsModel *)[NSKeyedUnarchiver unarchiveObjectWithData: myEncodedObject];
    return obj;
}

// 比较覆盖本地积分数据
+ (void )arrangeData:(NSDictionary *)result
{
    ZWIntegralStatisticsModel* obj = [ZWIntegralStatisticsModel loadCustomObjectWithKey:kUserDefaultsPointData];
    //其实应该必定是客户端本地积分大于等于服务端积分（除非特定情况） 所以也不需判断
    for (NSDictionary *dic in result[@"pointDetails"]) {
        switch ([dic[@"opType"] intValue]) {
            case 1:
            {  //登陆
                NSNumber *loginFrequency=[NSNumber numberWithFloat:[dic[@"opPoint"] floatValue]];
                [obj setLoginFrequency:loginFrequency];
                break;
            }
            case 2:
            {  //分享新闻
                NSNumber *shareRead=[NSNumber numberWithFloat:[dic[@"opPoint"] floatValue]];
                [obj setShareRead:shareRead];
                break;
            }
            case 3:
            {  //分享带来注册
                NSNumber *registration=[NSNumber numberWithFloat:[dic[@"opPoint"] floatValue]];
                [obj setRegistration:registration];
                break;
            }
            case 4:
            {  //分享并带来阅读
                NSNumber *shareByRead=[NSNumber numberWithFloat:[dic[@"opPoint"] floatValue]];
                [obj setShareByRead:shareByRead];
                break;
            }
            case 5:
            {  //对评论点赞
                NSNumber *reviewLike=[NSNumber numberWithFloat:[dic[@"opPoint"] floatValue]];
                [obj setReviewLike:reviewLike];
                break;
            }
            case 6:
            {  //评论被点赞
                NSNumber *reviewCoverLike=[NSNumber numberWithFloat:[dic[@"opPoint"] floatValue]];
                [obj setReviewCoverLike:reviewCoverLike];
                break;
            }
            case 7:
            {  //对新闻评论
                NSNumber *review=[NSNumber numberWithFloat:[dic[@"opPoint"] floatValue]];
                [obj setReview:review];
                [obj setReview:[NSNumber numberWithFloat:[dic[@"opPoint"] floatValue]]];
                break;
            }
            case 8:
            {  //阅读新闻
                NSNumber *readNews=[NSNumber numberWithFloat:[dic[@"opPoint"] floatValue]];
                [obj setReadNews:readNews];
                break;
            }
            case 9:
            {  //点击广告
                NSNumber *lookAdvertising=[NSNumber numberWithFloat:[dic[@"opPoint"] floatValue]];
                [obj setLookAdvertising:lookAdvertising];
                break;
            }
            case 10:
            {  //提现分享
                NSNumber *shareExtract=[NSNumber numberWithFloat:[dic[@"opPoint"] floatValue]];
                [obj setShareExtract:shareExtract];
                break;
            }
            case 11:
            {  //兑换商品
                NSNumber *shareConvert=[NSNumber numberWithFloat:[dic[@"opPoint"] floatValue]];
                [obj setShareConvert:shareConvert];
                break;
            }
            case 12:
            {  //绑定与其他
                [obj setOtherIntegral:[NSNumber numberWithFloat:[dic[@"opPoint"] floatValue]]];
                break;
            }
            case 13:
            {  //活动
                [obj setExerciseIntegral:[NSNumber numberWithFloat:[dic[@"opPoint"] floatValue]]];
                break;
            }
            case 14:
            {  //签到
                [obj setUserSignIntegral:[NSNumber numberWithFloat:[dic[@"opPoint"] floatValue]]];
                break;
            }
            default:
            break;
        }
    }
    [ZWIntegralStatisticsModel saveCustomObject:obj];
}

+(ZWIntegralRuleModel*)saveIntergralItemData:(ZWIntegralType)type
{
    return [ZWIntegralStatisticsModel loadDefaultIntegralRule][type];
}
+(NSMutableArray *)loadDefaultIntegralRule
{
    NSDictionary *ruleDic;
    NSUserDefaults *userDefatluts = [NSUserDefaults standardUserDefaults];
    if ([userDefatluts objectForKey:@"intergralRule"]) {
        ruleDic=[userDefatluts objectForKey:@"intergralRule"];
    }else
    {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"DefaultIntegralRule.json" ofType:nil];
        ruleDic = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:path] options:NSJSONReadingMutableContainers error:nil];
    }
    NSMutableArray *baseRuleData=[[NSMutableArray alloc]init];
    for (NSDictionary *dic in ruleDic[@"rules"]) {
        ZWIntegralRuleModel *ruleItem=[[ZWIntegralRuleModel alloc]initRuleData:dic];
        [baseRuleData safe_addObject:ruleItem];
    }
    return baseRuleData;
}
+(void)initNewData:(ZWIntegralStatisticsModel *)obj
{
    [ZWIntegralStatisticsModel initCurNewData:obj];
    [obj setOtherIntegral:[NSNumber numberWithFloat:0.0]];
    [obj setExerciseIntegral:[NSNumber numberWithFloat:0.0]];
    [ZWIntegralStatisticsModel saveCustomObject:obj];
}
+(void)initCurNewData:(ZWIntegralStatisticsModel *)obj
{
    [obj setLoginFrequency:[NSNumber numberWithFloat:0.0]];
    [obj setRegistration:[NSNumber numberWithFloat:0.0]];
    [obj setShareRead:[NSNumber numberWithFloat:0.0]];
    [obj setShareByRead:[NSNumber numberWithFloat:0.0]];
    [obj setReviewLike:[NSNumber numberWithFloat:0.0]];
    [obj setReviewCoverLike:[NSNumber numberWithFloat:0.0]];
    [obj setReview:[NSNumber numberWithFloat:0.0]];
    [obj setReadNews:[NSNumber numberWithFloat:0.0]];
    [obj setLookAdvertising:[NSNumber numberWithFloat:0.0]];
    [obj setShareExtract: [NSNumber numberWithFloat:0.0]];
    [obj setShareConvert:[NSNumber numberWithFloat:0.0]];
    [obj setUserSignIntegral:[NSNumber numberWithFloat:0.0]];
    [obj setCurDataTime:[NSDate todayString]];
}
+ (void)upoadLocalIntegralWithFinish:(void (^)(BOOL success))finish
{
    //导入本地积分标示并清空
    [ZWShareNewsHistoryList importLocalAlreadyShareNewsNoUser];
    [ZWShareNewsHistoryList cleanAlreadyShareNewsNoUser];
    [ZWReadNewsHistoryList importLocalAlreadyReadNewsNoUser];
    [ZWReadNewsHistoryList cleanAlreadyReadNewsNoUser];
    [ZWReviewLikeHistoryList importLocalAlreadyReviewLikeNoUser];
    [ZWReviewLikeHistoryList cleanAlreadyReviewLikeNoUser];
    
    //登陆成功提交本地积分到服务器
    [[[ZWIntegralStatisticsModel sharedInstance] integralManager] uploadLocalUserIntegralData:
     [ZWUserInfoModel userID]
                                                details:[ZWIntegralStatisticsModel sumArray]
                                                isCache:NO
                                                 succed:^(id result)
     {
         [self synchronizationIntegralWithFinish:^(BOOL success) {
             finish(success);
         }];
     } failed:^(NSString *errorString) {
         finish(NO);
     }];
}

+ (void)synchronizationIntegralWithFinish:(void (^)(BOOL success))finish
{
    //同步服务器积分
    [[[ZWIntegralStatisticsModel sharedInstance] integralManager] loadSyncUserIntegralData:[ZWUserInfoModel userID]
                                                                                   isCache:NO
                                                                                    succed:^(id result) {
                                                                                        [ZWIntegralStatisticsModel arrangeData:result];
                                                                                        ZWIntegralStatisticsModel* obj = [ZWIntegralStatisticsModel loadCustomObjectWithKey:kUserDefaultsPointData];
                                                                                        NSString * totalIncome= [NSString stringWithFormat:@"%.2f",[ZWIntegralStatisticsModel sumIntegrationBy:obj]];
                                                                                        [[NSNotificationCenter defaultCenter] postNotificationName:IntegralTotalIncome object:totalIncome];
                                                                                        finish(YES);
                                                                                    }
                                                                                    failed:^(NSString *errorString) {
                                                                                        finish(NO);
                                                                                    }];
}

//定义上传格式
+(NSMutableArray *)sumArray
{
    //查询规则
    NSMutableArray *baseRuleData=[ZWIntegralStatisticsModel loadDefaultIntegralRule];
    NSMutableArray *temArray=[[NSMutableArray alloc]init];
    ZWIntegralStatisticsModel* model = [ZWIntegralStatisticsModel loadCustomObjectWithKey:kUserDefaultsPointData];
    for (int i=0;i<10;i++) {
        NSMutableDictionary *dic=[[NSMutableDictionary alloc]init];
        switch (i) {
            case 0:
            {
                ZWIntegralRuleModel *itemRule=(ZWIntegralRuleModel *)baseRuleData[IntegralLoginFrequency];
                [dic safe_setObject:[NSNumber numberWithInt:([model.loginFrequency intValue]/[itemRule.pointValue intValue])] forKey:@"opNum"];
                [dic safe_setObject:@"1" forKey:@"opType"];
                [temArray safe_addObject:dic];
                break;
            }
            case 1:
            {
                ZWIntegralRuleModel *itemRule=(ZWIntegralRuleModel *)baseRuleData[IntegralRegistration];
                [dic safe_setObject:[NSNumber numberWithInt:([model.registration intValue]/[itemRule.pointValue intValue])] forKey:@"opNum"];
                [dic safe_setObject:@"3" forKey:@"opType"];
                [temArray safe_addObject:dic];
                break;
            }
            case 2:
            {
                ZWIntegralRuleModel *itemRule=(ZWIntegralRuleModel *)baseRuleData[IntegralShareRead];
                [dic safe_setObject:[NSNumber numberWithInt:([model.shareRead intValue]/[itemRule.pointValue intValue])] forKey:@"opNum"];
                [dic safe_setObject:@"2" forKey:@"opType"];
                [temArray safe_addObject:dic];
                break;
            }
            case 3:
            {
                ZWIntegralRuleModel *itemRule=(ZWIntegralRuleModel *)baseRuleData[IntegralShareByRead];
                int num =(int)([model.shareByRead floatValue]/[itemRule.pointValue floatValue]);
                [dic safe_setObject:[NSNumber numberWithInt:num] forKey:@"opNum"];
                [dic safe_setObject:@"4" forKey:@"opType"];
                [temArray safe_addObject:dic];
                break;
            }
            case 4:
            {
                ZWIntegralRuleModel *itemRule=(ZWIntegralRuleModel *)baseRuleData[IntegralReviewLike];
                [dic safe_setObject:[NSNumber numberWithInt:(int)([model.reviewLike floatValue]/[itemRule.pointValue floatValue])] forKey:@"opNum"];
                [dic safe_setObject:@"5" forKey:@"opType"];
                [temArray safe_addObject:dic];
                break;
            }
            case 5:
            {
                ZWIntegralRuleModel *itemRule=(ZWIntegralRuleModel *)baseRuleData[IntegralReviewCoverLike];
                [dic safe_setObject:[NSNumber numberWithInt:(int)([model.reviewCoverLike floatValue]/[itemRule.pointValue floatValue])] forKey:@"opNum"];
                [dic safe_setObject:@"6" forKey:@"opType"];
                [temArray safe_addObject:dic];
                break;
            }
            case 6:
            {
                ZWIntegralRuleModel *itemRule=(ZWIntegralRuleModel *)baseRuleData[IntegralReview];
                int num =(int)([model.review floatValue]/[itemRule.pointValue floatValue]);
                [dic safe_setObject:[NSNumber numberWithInt:num] forKey:@"opNum"];
                [dic safe_setObject:@"7" forKey:@"opType"];
                [temArray safe_addObject:dic];
                break;
            }
            case 7:
            {
                ZWIntegralRuleModel *itemRule=(ZWIntegralRuleModel *)baseRuleData[IntegralReadNews];
                int num =(int)([model.readNews floatValue]/[itemRule.pointValue floatValue]);
                [dic safe_setObject:[NSNumber numberWithInt:num] forKey:@"opNum"];
                [dic safe_setObject:@"8" forKey:@"opType"];
                [temArray safe_addObject:dic];
                break;
            }
            case 8:
            {
                ZWIntegralRuleModel *itemRule=(ZWIntegralRuleModel *)baseRuleData[IntegralLookAdvertising];
                [dic safe_setObject:[NSNumber numberWithInt:(int)([model.lookAdvertising floatValue]/[itemRule.pointValue floatValue])] forKey:@"opNum"];
                [dic safe_setObject:@"9" forKey:@"opType"];
                [temArray safe_addObject:dic];
                break;
            }
            case 9:
            {
                ZWIntegralRuleModel *itemRule=(ZWIntegralRuleModel *)baseRuleData[IntegralShareExtract];
                [dic safe_setObject:[NSNumber numberWithInt:(int)([model.shareExtract floatValue]/[itemRule.pointValue floatValue])] forKey:@"opNum"];
                [dic safe_setObject:@"10" forKey:@"opType"];
                [temArray safe_addObject:dic];
                break;
            }
            case 10:
            {
                ZWIntegralRuleModel *itemRule=(ZWIntegralRuleModel *)baseRuleData[IntegralShareConvert];
                [dic safe_setObject:[NSNumber numberWithInt:(int)([model.shareConvert floatValue]/[itemRule.pointValue floatValue])]  forKey:@"opNum"];
                [dic safe_setObject:@"11" forKey:@"opType"];
                [temArray safe_addObject:dic];
                break;
            }
            default:
                break;
        }
    }
    return temArray;
}

@end
