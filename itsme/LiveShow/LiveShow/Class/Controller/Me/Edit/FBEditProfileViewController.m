#import "FBNameViewController.h"
#import "FBEditProfileViewController.h"
#import "FBSignatureViewController.h"
#import "FBProfileNetWorkManager.h"
#import "FBEditGenderViewController.h"
#import "FBLoginInfoModel.h"
#import "FBEditProfileCell.h"
#import "FBAvatarController.h"

@interface FBEditProfileViewController ()<UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>


@property (nonatomic, strong) FBUserInfoModel *userInfo;

@property (nonatomic, strong) UIImage *portrait;

@end

@implementation FBEditProfileViewController

- (instancetype)initWithUserInfo:(FBUserInfoModel *)userInfo {
    if (self = [super init]) {
        self.userInfo = userInfo;
        self.tableView.separatorInset = UIEdgeInsetsMake(0, 20, 0, 0);
    }
    self.hidesBottomBarWhenPushed = YES;
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requestForUserInfo) name:kNotificationUpdateProfile object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.separatorColor = COLOR_e3e3e3;
    self.navigationItem.title = kLocalizationLabelEdit;

}

- (void)requestForUserInfo {
    [[FBProfileNetWorkManager sharedInstance] loadUserInfoWithUserID:self.userInfo.userID success:^(id result) {
        FBUserInfoModel *userInfo = [FBUserInfoModel mj_objectWithKeyValues:result[@"user"]];
          self.userInfo= userInfo;
        [self.tableView reloadData];
    } failure:nil finally:nil];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FBEditProfileCell *cell;
    if (indexPath.row == FBEditProfileCellTypePortrait) {
        cell = [[FBEditProfileCell alloc] initWithType:FBEditProfileCellTypePortrait];
        cell.typeLabel.text = kLocalizationProfileHead;
        if (self.portrait) {
            cell.portraitImageView.image = self.portrait;
        } else {
           cell.portraitImageView.image = self.userInfo.avatarImage;
        }
    } else if (indexPath.row == FBEditProfileCellTypeNick) {
        cell = [[FBEditProfileCell alloc] initWithType:FBEditProfileCellTypeNick];
        cell.typeLabel.text = kLocalizationNick;
        cell.nickLabel.text = self.userInfo.nick;
    } else if (indexPath.row == FBEditProfileCellTypeGender) {
        cell = [[FBEditProfileCell alloc] initWithType:FBEditProfileCellTypeGender];
        cell.typeLabel.text = kLocalizationGender;
        cell.genderImageView.image = ([self.userInfo.gender isEqualToNumber:@(0)] ? [UIImage imageNamed:@"edit_icon_female"] : [UIImage imageNamed:@"edit_icon_male"]);
    } else if (indexPath.row == FBEditProfileCellTypeMood) {
        cell = [[FBEditProfileCell alloc] initWithType:FBEditProfileCellTypeMood];
        cell.typeLabel.text = kLocalizationSignature;
    }
    return cell;
}

#pragma mark - Tableviewdelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == FBEditProfileCellTypePortrait) {
        [self presentAvatarViewController];
    } else if (indexPath.row == FBEditProfileCellTypeNick) {
        FBNameViewController *nameViewController = [[FBNameViewController alloc] init];
        nameViewController.nick = self.userInfo.nick;
        [self.navigationController pushViewController:nameViewController animated:YES];
    } else if (indexPath.row == FBEditProfileCellTypeGender) {
        FBEditGenderViewController *genderVC = [[FBEditGenderViewController alloc] init];
        genderVC.gender = self.userInfo.gender;
        [self presentViewController:genderVC animated:YES completion:nil];
    } else if (indexPath.row == FBEditProfileCellTypeMood) {
        FBSignatureViewController *signatureVC = [FBSignatureViewController signatureViewController];
        signatureVC.Description = self.userInfo.Description;
        [self.navigationController pushViewController:signatureVC animated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.row == FBEditProfileCellTypePortrait ? 70 : 50;
}

- (void)presentAvatarViewController {
    FBAvatarController *avatarController = [[FBAvatarController alloc] init];
    avatarController.type = FBAvatarViewTypeEdit;
    avatarController.imageName = [[FBLoginInfoModel sharedInstance] user].portrait;
    [self presentViewController:avatarController animated:YES completion:^{
    }];
}

@end
