//
//  FBTagsLivesViewController.m
//  LiveShow
//
//  Created by tak on 16/8/11.
//  Copyright © 2016年 FB. All rights reserved.
//
#import "FBLiveInfoCell.h"
#import "FBTagsLivesViewController.h"
#import "FBLiveRoomViewController.h"
#import "FBHotLivesViewController.h"

@interface FBTagsLivesViewController ()

@property (nonatomic, strong) NSMutableArray *lives;

@property (nonatomic, copy) NSString *tag;

@end

@implementation FBTagsLivesViewController

- (instancetype)initWithTag:(NSString *)tag {
    if (self = [super init]) {
        NSString *newTag = [tag removeSubString:@"#"];
        _tag = newTag;
    }
    return self;

}

- (NSMutableArray *)lives {
    if (!_lives) {
        _lives = [[NSMutableArray alloc] init];
    }
    return _lives;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerClass:[FBLiveInfoCell class] forCellReuseIdentifier:NSStringFromClass([FBLiveInfoCell class])];
    self.tableView.separatorStyle = UITableViewCellSelectionStyleNone;
    self.navigationItem.title = _tag;
    self.tableView.backgroundColor = COLOR_F0F7F6;
    [self requestTagLivesList];
    
}

- (void)requestTagLivesList {
    __weak typeof(self) weakSelf = self;
    [[FBLiveSquareNetworkManager sharedInstance] loadLivesListWithTag:_tag success:^(id result) {
        self.lives = [FBLiveInfoModel mj_objectArrayWithKeyValuesArray:result[@"lives"]];
        
        if (!self.lives.count) {
            FBFailureView *view = [[FBFailureView alloc] initWithFrame:CGRectZero image:kLogoFailureView height:60 message:kLocalizationTagNone detail:kLocalizationFollowingMore buttonTitle:kLocalizationWatchLive event:^{
                // 点击跳入热门第一个直播室内
                if ([FBHotLivesViewController topLive]) {
                    [weakSelf pushLiveRoomViewControllerFocusLive:[FBHotLivesViewController topLive]];
                }
            }];
            self.tableView.backgroundView = view;
        } else {
            self.tableView.backgroundView = nil;
        }

        
        [self.tableView reloadData];
    } failure:nil finally:nil];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.lives.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FBLiveInfoCell *cell = (FBLiveInfoCell *)[tableView dequeueReusableCellWithIdentifier:NSStringFromClass([FBLiveInfoCell class]) forIndexPath:indexPath];
    cell.model = self.lives[indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return SCREEN_WIDTH + 60 + 7 + 45;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    [self pushLiveRoomViewControllerFocusLive:self.lives[indexPath.row]];
}

/** 进入直播间 */
- (void)pushLiveRoomViewControllerFocusLive:(FBLiveInfoModel *)live {
    FBLiveRoomViewController *nextViewController = [[FBLiveRoomViewController alloc] initWithLives:self.lives focusLive:live];
    nextViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:nextViewController animated:YES];
}
@end
