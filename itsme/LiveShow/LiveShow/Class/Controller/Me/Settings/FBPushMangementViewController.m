//
//  XXPushMangementViewController.m
//  LiveShow
//
//  Created by lgh on 16/2/16.
//  Copyright © 2016年 XX. All rights reserved.
//
#import "FBNotificationCell.h"
#import "FBPushMangementViewController.h"
#import "FBProfileNetWorkManager.h"
#import "FBLoginInfoModel.h"
#import "FBNotifierModel.h"


#define kCellHeight 60
@interface FBPushMangementViewController ()

@property (nonatomic, strong) UITableViewCell *messageRemindCell;

@property (nonatomic, assign) NSInteger notifyStatus;
@property (nonatomic, strong) UISwitch *notifyStatusSwitch;

@property (nonatomic, strong) NSArray *nofityListArray;


@end

@implementation FBPushMangementViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"推送管理";
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([FBNotificationCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([FBNotificationCell class])];
    [self getNofityStatus];
    [self loadNotifyList];
    
}

- (NSArray *)nofityListArray {
    if (_nofityListArray == nil) {
        _nofityListArray = [NSArray array];
    }
    return _nofityListArray;
}


- (void)addSomeoneToNotifyBlackWithID:(NSNumber *)ID {
    NSString *UID = [NSString stringWithFormat:@"%@",ID];
    [[FBProfileNetWorkManager sharedInstance] addSomeoneToNotifyBlackWithUserID:UID success:^(id result) {
        NSLog(@"取消推送通知成功:%@",result);
    } failure:^(NSString *errorString) {
        NSLog(@"取消推送通知失败:%@",errorString);
    } finally:^{
        NSLog(@"完成取消推送通知");
    }];
}

- (void)removeSomeoneToNotifyBlackWithID:(NSNumber *)ID {
    NSString *UID = [NSString stringWithFormat:@"%@",ID];
    [[FBProfileNetWorkManager sharedInstance] removeSomeoneToNotifyBlackWithUserID:UID success:^(id result) {
        NSLog(@"开启推送通知成功:%@",result);
    } failure:^(NSString *errorString) {
        NSLog(@"开启推送通知成功:%@",errorString);
    } finally:^{
        NSLog(@"完成开启推送通知");
    }];
}

- (void)getNofityStatus {
    [[FBProfileNetWorkManager sharedInstance] getNotifyStatusWithUserID:[[FBLoginInfoModel sharedInstance] userID] success:^(id result) {
        NSString *stat = result[@"stat"];
        [[NSUserDefaults standardUserDefaults] setBool:stat.boolValue forKey:@"messageRemindCell"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } failure:^(NSString *errorString) {
        NSLog(@"获取推送状态出错:%@",errorString);
    } finally:^{
    }];
}

- (void)switchNofityStatus:(UISwitch *)sender {
    NSLog(@"改变%d",sender.isOn);
    [[FBProfileNetWorkManager sharedInstance] switchNotifyStatusWithStat:sender.isOn success:^(id result) {
        NSLog(@"改变开关状态%@",result);
        [[NSUserDefaults standardUserDefaults] setBool:sender.on forKey:@"messageRemindCell"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } failure:^(NSString *errorString) {
        NSLog(@"改变出错开关状态出错%@",errorString);
    } finally:^{
    }];
}

- (void)loadNotifyList {
    [[FBProfileNetWorkManager sharedInstance] loadNotifyStatusListWithUserID:[[FBLoginInfoModel sharedInstance] userID] startRow:0 count:20 success:^(id result) {
        self.nofityListArray = [FBNotifierModel mj_objectArrayWithKeyValuesArray:result[@"users"]];
    } failure:^(NSString *errorString) {
    } finally:^{
        [self.tableView reloadData];
    }];
}

- (void)clickPushSwitch:(UISwitch *)sender {
    [self switchNofityStatus:sender];
    [self.tableView reloadData];
}


- (UITableViewCell *)messageRemindCell {
    if (_messageRemindCell == nil) {
        _messageRemindCell = [[UITableViewCell alloc] init];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 15, SCREEN_WIDTH, 60)];
        label.text = @"直播消息提醒";
        [label sizeToFit];
        [_messageRemindCell addSubview:label];
        _notifyStatusSwitch = [[UISwitch alloc] init];
        [_notifyStatusSwitch addTarget:self action:@selector(clickPushSwitch:) forControlEvents:UIControlEventValueChanged];
        _notifyStatusSwitch.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"messageRemindCell"];
        [_messageRemindCell addSubview:_notifyStatusSwitch];
        [_notifyStatusSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.equalTo(CGSizeMake(50, 30));
            make.right.equalTo(_messageRemindCell.mas_right).offset(-9);
            make.centerY.equalTo(_messageRemindCell);
        }];
    }
    return _messageRemindCell;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (_notifyStatusSwitch.on) {
        return 2;
    } else {
        return 1;
    }
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {return 1;}
    else {return self.nofityListArray.count;}
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        UITableViewCell *cell = self.messageRemindCell;
        
        return cell;
    } else {
        FBNotificationCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([FBNotificationCell class]) forIndexPath:indexPath];
        cell.notifier = self.nofityListArray[indexPath.row];
        
        
        __weak typeof(cell)weakCell = cell;
        cell.statusSwitchBlock = ^(UISwitch *Switch){
            if (Switch.on) {
                [self removeSomeoneToNotifyBlackWithID:weakCell.notifier.user.uid];
            } else {
                [self addSomeoneToNotifyBlackWithID:weakCell.notifier.user.uid];
            }
        };
        
        return cell;
    }

}

#pragma mark - Table view delegate


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kCellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 15;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 20;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (section == 0) {
         UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 20)];
        label.font = [UIFont systemFontOfSize:13];
        label.backgroundColor = [UIColor hx_colorWithHexString:@"f7f7f7"];
        label.text = @"    关闭某个人的消息提醒,不再收到TA的提示";
        return label;
    }
    return nil;

}

@end
