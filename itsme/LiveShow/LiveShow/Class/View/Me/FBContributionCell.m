//
//  FBContributionCell.m
//  LiveShow
//
//  Created by tak on 16/6/2.
//  Copyright © 2016年 FB. All rights reserved.
//

#import "FBContributionCell.h"
#import "FBContributionModel.h"

@interface FBContributionCell ()

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *nickLabel;
@property (weak, nonatomic) IBOutlet UILabel *diamondsLabel;
@property (weak, nonatomic) IBOutlet UIImageView *genderImageView;
@property (weak, nonatomic) IBOutlet UIView *levelBackgroundView;
@property (weak, nonatomic) IBOutlet UIImageView *levelIconView;
@property (weak, nonatomic) IBOutlet UILabel *levelLabel;
@property (weak, nonatomic) IBOutlet UIImageView *verifyIcon;

@end

@implementation FBContributionCell


- (void)awakeFromNib {
    [super awakeFromNib];
    self.avatarImageView.image = [UIImage imageNamed:kLogoDefaultAvatar];
}


- (void)setContribution:(FBContributionModel *)contribution {
    _contribution = contribution;

    [_avatarImageView fb_setImageWithName:_contribution.user.portrait size:CGSizeMake(120, 120) placeholderImage:kDefaultImageAvatar completed:nil];
    _nickLabel.text = _contribution.user.nick;

    _genderImageView.image = _contribution.user.gender.intValue == 0 ? [UIImage imageNamed:@"pub_icon_female"] : [UIImage imageNamed:@"pub_icon_male"];
    
    if (_contribution.user.ulevel.intValue >= 1 && _contribution.user.ulevel.intValue <= 7) {
        _levelIconView.image = [UIImage imageNamed:@"pub_icon_star"];
        _levelBackgroundView.backgroundColor = COLOR_ASSIST_TEXT;
    } else if (_contribution.user.ulevel.intValue >= 8 && _contribution.user.ulevel.intValue <= 16) {
        _levelIconView.image = [UIImage imageNamed:@"pub_icon_moon"];
        _levelBackgroundView.backgroundColor = COLOR_4A87F6;
    } else if (_contribution.user.ulevel.intValue >= 17 && _contribution.user.ulevel.intValue <= 31) {
        _levelIconView.image = [UIImage imageNamed:@"pub_icon_sun"];
        _levelBackgroundView.backgroundColor = COLOR_FA9F47;
    } else if (_contribution.user.ulevel.intValue >= 32 && _contribution.user.ulevel.intValue <= 63) {
        _levelIconView.image = [UIImage imageNamed:@"pub_icon_crown"];
        _levelBackgroundView.backgroundColor = COLOR_FAD247;
    } else if (_contribution.user.ulevel.intValue >= 64 && _contribution.user.ulevel.intValue <= 127) {
        _levelIconView.image = [UIImage imageNamed:@"pub_icon_golden_crown"];
        _levelBackgroundView.backgroundColor = COLOR_5061E4;
    } else {
        _levelIconView.image = [UIImage imageNamed:@"pub_icon_purple_crown"];
        _levelBackgroundView.backgroundColor = COLOR_AC47FA;
    }
    
    _levelLabel.text = [_contribution.user.ulevel stringValue];
    
    NSString *desc = [NSString stringWithFormat:@"%@ %@ %@",kLocalizationSendCoins, _contribution.contribution, kLocalizationDiamonds];
    NSMutableAttributedString *attDesc = [[NSMutableAttributedString alloc] initWithString:desc];
    NSRange range = [desc rangeOfString:_contribution.contribution];
    [attDesc addAttribute:NSForegroundColorAttributeName value:COLOR_MAIN range:range];
    _diamondsLabel.attributedText = attDesc;
    
    _verifyIcon.hidden = !_contribution.user.isVerifiedBroadcastor;

}

- (void)setupCellWithIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < 3) {
        self.numberLabel.hidden = YES;
        self.top3ImageView.hidden = NO;
        self.top3ImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"onlive_icon_%zd",indexPath.row + 1]];
    } else {
        self.numberLabel.hidden = NO;
        self.top3ImageView.hidden = YES;
        self.numberLabel.text = [NSString stringWithFormat:@"%zd",indexPath.row + 1];
    }
    
    if (indexPath.row % 2 != 0) {
        self.backgroundColor = [UIColor hx_colorWithHexString:@"fdfdfd"];
    } else {
        self.backgroundColor = [UIColor hx_colorWithHexString:@"ffffff"];
    }
}

@end

