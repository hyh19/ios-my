//
//  XXBlackListViewController.m
//  LiveShow
//
//  Created by lgh on 16/2/16.
//  Copyright © 2016年 XX. All rights reserved.
//
#import "FBContactsCell.h"
#import "FBBlackListViewController.h"
#import "FBProfileNetWorkManager.h"
#import "FBLoginInfoModel.h"
#import "FBContactsModel.h"
#import "FBTAViewController.h"
#import "FBFailureView.h"

#define kRowHeight 60
#define kTipViewHeight 35

@interface FBBlackListViewController ()
@property (nonatomic, strong) NSArray *blackArray;
@property (nonatomic, strong) FBFailureView *failureView;
@property (nonatomic, strong) UIView *tipView;
@property (nonatomic, assign) NSInteger index;
@end

@implementation FBBlackListViewController

- (NSArray *)blackArray {
    if (_blackArray == nil) {
        _blackArray = [NSArray array];
    }
    return _blackArray;
}

- (FBFailureView *)failureView {
    if (!_failureView) {
        _failureView = [[FBFailureView alloc] initWithFrame:self.view.bounds image:kLogoFailureView message:kLocalizationDefaultContent];
    }
    return _failureView;
}

- (UIView *)tipView {
    if (!_tipView) {
        _tipView = [[UIView alloc] initWithFrame:CGRectMake(0, -kTipViewHeight, SCREEN_WIDTH, kTipViewHeight)];
        UILabel *label = [[UILabel alloc] init];
        [_tipView addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_tipView.mas_centerX);
            make.centerY.equalTo(_tipView.mas_centerY);
        }];
        label.text = kLocalizationSlideToCancelBlock;
        label.font = [UIFont systemFontOfSize:13];
        label.textColor = COLOR_999999;
        [label sizeToFit];
        label.textAlignment = NSTextAlignmentCenter;
    }
    return _tipView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = kLocalizationLabelBlackList;
    [self.view addSubview:self.failureView];
    _failureView.hidden = YES;
    [self setupTableView];
    [self loadBlackList];
   
    
}


#pragma UI
- (void)startTipViewAnimation {
     [self.view addSubview:self.tipView];
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.translation.y"];
    animation.delegate = self;
    animation.autoreverses = YES;
    animation.toValue = @(kTipViewHeight + 10);
    animation.duration = 1;
    [self.tableView.layer addAnimation:animation forKey:nil];
}

- (void)setupTableView {
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([FBContactsCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([FBContactsCell class])];
    self.tableView.backgroundColor = COLOR_F0F7F6;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableFooterView = [[UIView alloc] init];
}

# pragma mark - network
- (void)loadBlackList {
    [MBProgressHUD showHUDAddedTo:self.tableView animated:YES];
    [[FBProfileNetWorkManager sharedInstance] loadBlackListWithUserID:[FBLoginInfoModel sharedInstance].userID start:0 count:20 success:^(id result) {
        NSLog(@"黑名单列表:%@",result);
        self.blackArray = [FBContactsModel mj_objectArrayWithKeyValuesArray:result[@"users"]];
        if (self.blackArray.count != 0) {
            self.failureView.hidden = YES;
            [self.tableView reloadData];
            if (_index == 0) {
                [self startTipViewAnimation];
                _index++;
            }

        } else {
            self.failureView.hidden = NO;
        }
        [MBProgressHUD hideAllHUDsForView:self.tableView animated:YES];
    } failure:^(NSString *errorString) {
        NSLog(@"加载黑名单列表错误:%@",errorString);
    } finally:^{
        
    }];
}

- (void)removeBlackListWithUserID:(NSString *)ID {
        __weak typeof(self) weakSelf = self;
    [[FBProfileNetWorkManager sharedInstance] removeFromBlackListWithUserID:ID success:^(id result) {
        NSLog(@"解除拉黑result:%@",result);
        [weakSelf loadBlackList];
    } failure:^(NSString *errorString) {
        NSLog(@"解除拉黑失败%@",errorString);
    } finally:^{
    }];
}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.blackArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FBContactsCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([FBContactsCell class]) forIndexPath:indexPath];
    cell.contacts = self.blackArray[indexPath.row];
    return cell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kRowHeight;
}



-(NSString*)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kLocalizationUnblack;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    FBContactsModel *model = self.blackArray[indexPath.row];
    NSString *ID = model.user.userID;
    [self removeBlackListWithUserID:ID];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    FBContactsModel *cellModel = self.blackArray[indexPath.row];
    FBTAViewController *taViewController = [[FBTAViewController alloc] initWithModel:cellModel.user];
    taViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:taViewController animated:YES];
}


- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    [self.tipView removeFromSuperview];
}

@end
