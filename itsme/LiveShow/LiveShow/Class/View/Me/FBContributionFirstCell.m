//
//  FBContributionFirstCell.m
//  LiveShow
//
//  Created by tak on 11/10/16.
//  Copyright © 2016 FB. All rights reserved.
//

#import "FBContributionFirstCell.h"

@interface FBContributionFirstCell ()
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *nickLabel;
@property (weak, nonatomic) IBOutlet UIImageView *genderImageView;
@property (weak, nonatomic) IBOutlet UIView *levelBackgroundView;
@property (weak, nonatomic) IBOutlet UIImageView *levelImageView;
@property (weak, nonatomic) IBOutlet UILabel *levelLabel;
@property (weak, nonatomic) IBOutlet UILabel *sendLabel;

@end

@implementation FBContributionFirstCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.avatarImageView.image = [UIImage imageNamed:kLogoDefaultAvatar];
//    self.avatarImageView.layer.shadowRadius = 2.0;
//    self.avatarImageView.layer.shadowOffset = CGSizeMake(1, 1);
    self.avatarImageView.layer.borderWidth = 2.0;
    self.avatarImageView.layer.borderColor = [[UIColor hx_colorWithHexString:@"ffc921"] CGColor];

}

- (void)setContribution:(FBContributionModel *)contribution {
    _contribution = contribution;
    [_avatarImageView fb_setImageWithName:_contribution.user.portrait size:CGSizeMake(120, 120) placeholderImage:kDefaultImageAvatar completed:nil];
    _nickLabel.text = _contribution.user.nick;
    
    _genderImageView.image = _contribution.user.gender.intValue == 0 ? [UIImage imageNamed:@"pub_icon_female"] : [UIImage imageNamed:@"pub_icon_male"];
    
    if (_contribution.user.ulevel.intValue >= 1 && _contribution.user.ulevel.intValue <= 7) {
        _levelImageView.image = [UIImage imageNamed:@"pub_icon_star"];
        _levelBackgroundView.backgroundColor = COLOR_ASSIST_TEXT;
    } else if (_contribution.user.ulevel.intValue >= 8 && _contribution.user.ulevel.intValue <= 16) {
        _levelImageView.image = [UIImage imageNamed:@"pub_icon_moon"];
        _levelBackgroundView.backgroundColor = COLOR_4A87F6;
    } else if (_contribution.user.ulevel.intValue >= 17 && _contribution.user.ulevel.intValue <= 31) {
        _levelImageView.image = [UIImage imageNamed:@"pub_icon_sun"];
        _levelBackgroundView.backgroundColor = COLOR_FA9F47;
    } else if (_contribution.user.ulevel.intValue >= 32 && _contribution.user.ulevel.intValue <= 63) {
        _levelImageView.image = [UIImage imageNamed:@"pub_icon_crown"];
        _levelBackgroundView.backgroundColor = COLOR_FAD247;
    } else if (_contribution.user.ulevel.intValue >= 64 && _contribution.user.ulevel.intValue <= 127) {
        _levelImageView.image = [UIImage imageNamed:@"pub_icon_golden_crown"];
        _levelBackgroundView.backgroundColor = COLOR_5061E4;
    } else {
        _levelImageView.image = [UIImage imageNamed:@"pub_icon_purple_crown"];
        _levelBackgroundView.backgroundColor = COLOR_AC47FA;
    }
    
    _levelLabel.text = [_contribution.user.ulevel stringValue];
    
    NSString *desc = [NSString stringWithFormat:@"%@ %@ %@",kLocalizationSendCoins, _contribution.contribution, kLocalizationDiamonds];
    NSMutableAttributedString *attDesc = [[NSMutableAttributedString alloc] initWithString:desc];
    NSRange range = [desc rangeOfString:_contribution.contribution];
    [attDesc addAttribute:NSForegroundColorAttributeName value:COLOR_MAIN range:range];
    _sendLabel.attributedText = attDesc;
    
}

@end
