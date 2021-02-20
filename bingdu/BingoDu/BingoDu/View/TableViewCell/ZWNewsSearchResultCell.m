#import "ZWNewsSearchResultCell.h"
#import "UILabel+HYBAttributedCategory.h"
#import "NSString+NHZW.h"

@interface ZWNewsSearchResultCell ()

/**新闻标题*/
@property (strong, nonatomic) UILabel *newsTitle;

/**日期*/
@property (strong, nonatomic) UILabel *newsDate;

@end

@implementation ZWNewsSearchResultCell

#pragma mark -init
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.backgroundColor = COLOR_F8F8F8;
        [self.contentView addSubview:[self newsTitle]];
        [self.contentView addSubview:[self newsDate]];
    }
    return self;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

#pragma mark - Getter & Setter
- (UILabel *)newsTitle
{
    if(!_newsTitle)
    {
        _newsTitle = [[UILabel alloc] initWithFrame:CGRectMake(15, 13, SCREEN_WIDTH-30, 36)];
        _newsTitle.backgroundColor = [UIColor clearColor];
        _newsTitle.font = [UIFont systemFontOfSize:15];
        _newsTitle.numberOfLines = 2;
    }
    return _newsTitle;
}

- (UILabel *)newsDate
{
    if(!_newsDate)
    {
        _newsDate = [[UILabel alloc] initWithFrame:CGRectMake(15, 13, SCREEN_WIDTH-30, 36)];
        _newsDate.backgroundColor = [UIColor clearColor];
        _newsDate.textColor = COLOR_848484;
        _newsDate.font = [UIFont systemFontOfSize:12];
    }
    return _newsDate;
}

- (void)setNewsModel:(ZWNewsModel *)newsModel
{
    if(_newsModel != newsModel)
    {
        _newsModel = newsModel;
        if(newsModel)
        {
            [self.newsTitle hyb_setAttributedText:newsModel.newsTitle];
            
            self.newsTitle.font = [UIFont systemFontOfSize:15];
            
            self.newsDate.text = newsModel.publishTime;
            
            CGFloat height = [self.newsTitle.text labelHeightWithNumberOfLines:2 fontSize:15 labelWidth:SCREEN_WIDTH-30];
            
            self.newsTitle.frame = CGRectMake(15, 13, SCREEN_WIDTH-30, height);
            
            [self.newsDate setFrame:CGRectMake(15, self.newsTitle.frame.origin.y + self.newsTitle.frame.size.height + 9, SCREEN_WIDTH-30, 13)];
        }
    }
}

@end
