#import "ZWImageChannelCell.h"
#import "UIImageView+WebCache.h"
#import "CustomURLCache.h"
#import "ZWPicModel.h"

@interface ZWImageChannelCell ()

/**海报图片*/
@property (weak, nonatomic) IBOutlet UIImageView *coverImageView;

/**标题*/
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

/**标签*/
@property (weak, nonatomic) IBOutlet UILabel *markLabel;

/**回复*/
@property (weak, nonatomic) IBOutlet UILabel *reviewLabel;

/**回复的图片*/
@property (weak, nonatomic) IBOutlet UIImageView *reviewImageView;

@end

@implementation ZWImageChannelCell

- (void)awakeFromNib {
    // Initialization code
    self.backgroundColor = [UIColor whiteColor];
    self.layer.borderWidth = 0.5;
    self.layer.borderColor = [[UIColor colorWithRed:207./255 green:207./255 blue:207./255 alpha:0.5] CGColor];
}

#pragma mark - Getter & Setter
- (void)setNewsModel:(ZWNewsModel *)newsModel
{
    if(_newsModel != newsModel)
    {
        _newsModel = newsModel;
        self.titleLabel.text = newsModel.newsTitle;
        self.reviewLabel.text = newsModel.cNum;
        //时时更新评论数的frame
        CGRect frame = [NSString heightForString:newsModel.cNum fontSize:13 andSize:CGSizeMake(50, 20)];
        CGRect reviewFrame = self.reviewLabel.frame;
        reviewFrame.origin.x += (reviewFrame.size.width-frame.size.width);
        reviewFrame.size.width = frame.size.width;
        self.reviewLabel.frame = reviewFrame;
        CGRect imageFrame = self.reviewImageView.frame;
        imageFrame.origin.x = reviewFrame.origin.x - 5 - self.reviewImageView.frame.size.width;
        self.reviewImageView.frame = imageFrame;
        [self.reviewLabel sizeToFit];
        [self.reviewLabel updateConstraints];
        [self.reviewImageView updateConstraints];
        
        if(newsModel.picList.count > 0)
        {
            if ([(ZWPicModel *)newsModel.picList[0] picUrl].length>0) {
                ZWPicModel *picModel = newsModel.picList[0];
                if (picModel.picUrl.length) {
                    [self.coverImageView sd_setImageWithURL:[NSURL URLWithString:picModel.picUrl] placeholderImage:[UIImage imageNamed:@"icon_banner_list"]];
                }
            }
        }
    }
}


@end
