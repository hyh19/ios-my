//
//  FBSearchTagCell.m
//  LiveShow
//
//  Created by tak on 16/8/10.
//  Copyright © 2016年 FB. All rights reserved.
//

#import "FBSearchTagCell.h"
#import "UIScreen+Devices.h"

@interface FBSearchTagCell ()

/** 上部分容器 */
@property (nonatomic, strong) UIView *topView;

/** 下部分容器 */
@property (nonatomic, strong) UIView *bottomView;

/** 标签 */
@property (nonatomic, strong) UILabel *tagLabel;

/** 数量 */
@property (nonatomic, strong) UILabel *tagCountLabel;

/** 箭头 */
@property (nonatomic, strong) UIImageView *arrowImageView;

/** 底部线 */
@property (nonatomic, strong) UIView *lineView;

@property (nonatomic, strong) NSMutableArray *avatarArray;

@property (nonatomic, strong) NSMutableDictionary *avatarModelDic;
@end

@implementation FBSearchTagCell

+ (instancetype)searchTagCell:(UITableView *)tableView {
    FBSearchTagCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(self)];
    if (!cell) {
        cell = [[FBSearchTagCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass(self)];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self addSubview:self.topView];
        [self addSubview:self.bottomView];
        
        [self.topView addSubview:self.tagLabel];
        [self.topView addSubview:self.tagCountLabel];
        [self.topView addSubview:self.arrowImageView];
        [self.topView addSubview:self.lineView];
        
        [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.equalTo(self);
            make.height.equalTo(@45);
        }];
        
        [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.topView.mas_bottom);
            make.left.right.equalTo(self);
            make.height.equalTo(@120);
        }];
        
        [self.tagLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.topView);
            make.left.equalTo(self.topView).offset(20);
        }];
        
        [self.arrowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.topView);
            make.right.equalTo(self.topView.mas_right).offset(-20);
        }];
        
        [self.tagCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.topView);
            make.right.equalTo(self.arrowImageView.mas_left).offset(-10);
        }];
        
        [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.right.equalTo(self);
            make.left.equalTo(self).offset(20);
            make.height.equalTo(@0.5);
        }];
        
    }
    return self;
}


- (void)setTags:(FBTagsModel *)tags {
    self.avatarModelDic = nil;
    _tags = tags;
    self.tagLabel.text = _tags.name;
    self.tagCountLabel.text = [_tags.num stringValue];
    int num = [_tags.num intValue];
    int liveNum = [_tags.live_num intValue];
    
    if (_tags.num.intValue < 3) {
        if (num == 0) {
            self.hidden = YES;
        } else {
            self.hidden = NO;
        }
        self.bottomView.hidden = YES;
    } else {
        self.bottomView.hidden = NO;
        if (liveNum == 3) {
            for (int i = 0; i < 3; i++) {
                FBSearchAvatarView *portrait = self.avatarArray[i];
                FBLiveInfoModel *liveModel = _tags.lives[i];
                portrait.model = liveModel;
                [self.avatarModelDic setObject:liveModel forKey:@(i)];
            }
        } else if (liveNum == 2) {
            for (int i = 0; i < 2; i++) {
                FBSearchAvatarView *portrait = self.avatarArray[i];
                FBLiveInfoModel *liveModel = _tags.lives[i];
                portrait.model = liveModel;
                [self.avatarModelDic setObject:liveModel forKey:@(i)];
            }
            
            FBSearchAvatarView *portrait = self.avatarArray[2];
            FBRecordModel *record = _tags.record[0];
            portrait.model = record;
            [self.avatarModelDic setObject:record forKey:@(2)];
            
        } else if (liveNum == 1) {
            FBSearchAvatarView *portrait = self.avatarArray[0];
            FBLiveInfoModel *liveModel = _tags.lives[0];
            portrait.model = liveModel;
            [self.avatarModelDic setObject:liveModel forKey:@(0)];
            
            for (int i = 0; i < 2; i++) {
                FBSearchAvatarView *portrait = self.avatarArray[i+1];
                FBRecordModel *record = _tags.record[i];
                portrait.model = record;
                [self.avatarModelDic setObject:record forKey:@(i+1)];
            }
        } else {
            for (int i = 0; i < 3; i++) {
                FBSearchAvatarView *portrait = self.avatarArray[i];
                FBRecordModel *record = _tags.record[i];
                portrait.model = record;
                [self.avatarModelDic setObject:record forKey:@(i)];
            }
        }
    }
}


- (void)avatarDidClick:(FBSearchAvatarView *)avatarView {
    id model = self.avatarModelDic[@(avatarView.tag - 300)];
    if (self.onClickAvatar) {
        self.onClickAvatar(model);
    }
}

- (UILabel *)tagLabel {
    if (!_tagLabel) {
        _tagLabel = [[UILabel alloc] init];
        _tagLabel.font = [UIFont systemFontOfSize:17];
        _tagLabel.textColor = [UIColor hx_colorWithHexString:@"#444444"];
        _tagLabel.text = @"#";
        [_tagLabel sizeToFit];
    }
    return _tagLabel;
}

- (UILabel *)tagCountLabel {
    if (!_tagCountLabel) {
        _tagCountLabel = [[UILabel alloc] init];
        _tagCountLabel.font = [UIFont systemFontOfSize:15];
        _tagCountLabel.textColor = [UIColor hx_colorWithHexString:@"#888888"];
        _tagCountLabel.text = @"1";
        [_tagCountLabel sizeToFit];
    }
    return _tagCountLabel;
}

- (UIImageView *)arrowImageView {
    if (!_arrowImageView) {
        _arrowImageView = [[UIImageView alloc] init];
        _arrowImageView.image = [UIImage imageNamed:@"public_icon_black_arrow"];
        [_arrowImageView sizeToFit];
    }
    return _arrowImageView;
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = COLOR_e3e3e3;
    }
    return _lineView;
}

- (UIView *)topView {
    if (!_topView) {
        _topView = [[UIView alloc] init];
    }
    return _topView;
}

- (UIView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[UIView alloc] init];
        CGFloat width = ([[UIScreen mainScreen] isFourPhone] || [[UIScreen mainScreen] isiPhoneFourSOrBelow])? 90 : 110;
//        CGFloat width = 110;
        CGFloat leftRightPadding = 20;
        CGFloat centerPadding = (SCREEN_WIDTH - width * 3 - leftRightPadding * 2 )/2;
        CGFloat y = 0;
        for (int i = 0; i < 3; i++) {
            FBSearchAvatarView *avatar = [[FBSearchAvatarView alloc] init];
            avatar.tag = 300 + i;
            [avatar addTarget:self action:@selector(avatarDidClick:) forControlEvents:UIControlEventTouchUpInside];
            avatar.size = CGSizeMake(width, width);
            avatar.y = y;
            if (i == 0) {
                avatar.x = leftRightPadding;
            } else if (i == 1) {
                avatar.x = leftRightPadding + width + centerPadding;
            } else {
                avatar.x = leftRightPadding + (width + centerPadding) * 2;
            }
//            avatar.frame = CGRectMake(padding + (padding + width) * i, y, width, width);
            [self.avatarArray addObject:avatar];
            [_bottomView addSubview:avatar];
        }
    }
    return _bottomView;
}

- (NSMutableArray *)avatarArray {
    if (!_avatarArray) {
        _avatarArray = [NSMutableArray array];
    }
    return _avatarArray;
}

- (NSMutableDictionary *)avatarModelDic {
    if (!_avatarModelDic) {
        _avatarModelDic = [NSMutableDictionary dictionaryWithCapacity:3];
    }
    return _avatarModelDic;
}


@end






/*----------------------------------FBSearchAvatarView--------------------------------------*/

@interface FBSearchAvatarView ()
@property (nonatomic, strong) UIView *liveStatusView;
@property (nonatomic, strong) UILabel *liveStatusLabel;
@property (nonatomic, weak) UILabel *viewerCountLabel;
@property (nonatomic, strong) UIImageView *bottomImageView;
@end

@implementation FBSearchAvatarView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.liveStatusView];
        [self.liveStatusView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).offset(6);
            make.left.equalTo(self);
            make.size.equalTo(CGSizeMake(38, 20));
        }];

        
        [self.liveStatusView addSubview:self.liveStatusLabel];
        [self.liveStatusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(UIEdgeInsetsMake(0, 3, 0, 0));
        }];
        
        [self addSubview:self.bottomImageView];
        [self.bottomImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(self);
            make.height.equalTo(@20);
        }];
    }
    return self;
}

- (void)setModel:(id)model {
    if ([model isKindOfClass:[FBRecordModel class]]) {
        FBRecordModel *record = (FBRecordModel *)model;
        self.liveStatusLabel.text = @"Replay";
        self.liveStatusView.backgroundColor = [UIColor hx_colorWithHexString:@"ffc600" alpha:0.75];
        self.viewerCountLabel.text = [record.clickNumber stringValue];
        [self fb_setImageWithName:record.user.portrait size:CGSizeMake(110, 110) forState:UIControlStateNormal placeholderImage:kDefaultImageAvatar];
    } else if ([model isKindOfClass:[FBLiveInfoModel class]]) {
        FBLiveInfoModel *liveModel = model;
        self.liveStatusLabel.text = @"Live";
        self.liveStatusView.backgroundColor = [UIColor hx_colorWithHexString:@"ff3b30" alpha:0.75];
        self.viewerCountLabel.text = [liveModel.spectatorNumber stringValue];
        [self fb_setImageWithName:liveModel.broadcaster.portrait size:CGSizeMake(110, 110) forState:UIControlStateNormal placeholderImage:kDefaultImageAvatar];
    } else {
        NSLog(@"model = %@",model);
    }
}

- (UIView *)liveStatusView {
    if (!_liveStatusView) {
        _liveStatusView = [[UIView alloc] init];
        _liveStatusView.backgroundColor = [UIColor hx_colorWithHexString:@"ff3b30" alpha:0.75];
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, 38, 20) byRoundingCorners:UIRectCornerTopRight | UIRectCornerBottomRight cornerRadii:CGSizeMake(12, 12)];
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.frame = CGRectMake(0, 0, 38, 20);
        maskLayer.path = maskPath.CGPath;
        _liveStatusView.layer.mask = maskLayer;
    }
    return _liveStatusView;
}

- (UILabel *)liveStatusLabel {
    if (!_liveStatusLabel) {
        _liveStatusLabel = [[UILabel alloc] init];
        _liveStatusLabel.text = @"Live";
        _liveStatusLabel.textColor = [UIColor hx_colorWithHexString:@"ffffff"];
        _liveStatusLabel.font = [UIFont systemFontOfSize:10];
    }
    return _liveStatusLabel;
}

- (UIImageView *)bottomImageView {
    if (!_bottomImageView) {
        _bottomImageView = [[UIImageView alloc] init];
        _bottomImageView.image = [UIImage imageNamed:@"search_icon_background"];
        UIImageView *eye = [[UIImageView alloc] init];
        eye.image = [UIImage imageNamed:@"search_icon_eye"];
        [eye sizeToFit];
        eye.origin = CGPointMake(6, 6);
        [_bottomImageView addSubview:eye];
        
        UILabel *count = [[UILabel alloc] init];
        _viewerCountLabel = count;
        count.textColor = [UIColor whiteColor];
        count.font = [UIFont systemFontOfSize:12];
        count.text = @"1000";
        [count sizeToFit];
        count.origin = CGPointMake(23, 2);
        [_bottomImageView addSubview:count];
    }
    return _bottomImageView;
}
@end
