//
//  XXBlackListCell.m
//  LiveShow
//
//  Created by lgh on 16/2/16.
//  Copyright © 2016年 XX. All rights reserved.
//
#import "FBContactsModel.h"
#import "FBBlackListCell.h"
#import "FBUserInfoModel.h"


@interface FBBlackListCell ()
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *nickNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *summaryLabel;
@property (weak, nonatomic) IBOutlet UIImageView *genderImageView;
@property (weak, nonatomic) IBOutlet UIImageView *levelImageView;
@end

@implementation FBBlackListCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setContacts:(FBContactsModel *)contacts {
    _contacts = contacts;
    
    [_avatarImageView fb_setImageWithName:_contacts.user.portrait size:CGSizeMake(120, 120) placeholderImage:kDefaultImageAvatar completed:nil];
    _nickNameLabel.text = _contacts.user.nick;
    _genderImageView.image = _contacts.user.gender == 0 ? [UIImage imageNamed:@"pub_icon_female"] : [UIImage imageNamed:@"pub_icon_male"];
    _levelImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"rank_%@",_contacts.user.ulevel]];
    _summaryLabel.text = _contacts.user.Description;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
