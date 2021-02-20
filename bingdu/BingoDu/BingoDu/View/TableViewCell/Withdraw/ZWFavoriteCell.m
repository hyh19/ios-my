#import "ZWFavoriteCell.h"
#import "UIImageView+WebCache.h"
#import "NewsPicList.h"

@interface ZWFavoriteCell()

/** 新闻缩略图*/
@property (weak, nonatomic) IBOutlet UIImageView *imgView;

/** 新闻标题*/
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

/** 新闻频道*/
@property (weak, nonatomic) IBOutlet UILabel *channelLabel;

/** 新闻发布的时间*/
@property (weak, nonatomic) IBOutlet UILabel *publishTimeLabel;

@end

@implementation ZWFavoriteCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setData:(ZWFavoriteModel *)data {
    _data = data;
    if (_data) {
        NSString *publishTime = [NSString stringWithFormat:@"发布时间：%@", _data.publishTime];
        self.publishTimeLabel.text = publishTime;
        self.titleLabel.text = _data.newsTitle;
        self.channelLabel.text = _data.channelName;
        if (_data.picList && _data.picList.count > 0) {
            NewsPicList *pic = _data.picList[0];
            [self.imgView sd_setImageWithURL:[NSURL URLWithString:pic.picUrl] placeholderImage:[UIImage imageNamed:@"icon_banner_list"]];
        } else {
            [self.imgView setImage:[UIImage imageNamed:@"icon_banner_list"]];
        }
    }
}

@end
