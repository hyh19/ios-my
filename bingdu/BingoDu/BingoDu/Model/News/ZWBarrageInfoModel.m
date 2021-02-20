
#import "ZWBarrageInfoModel.h"

@implementation ZWBarrageInfoModel

+(id)initModelFromBarrageItem:(ZWBarrageItemView *)barrageItem
{
    ZWBarrageInfoModel *infoModel = [[ZWBarrageInfoModel alloc] init];
    
    [infoModel setOriginX:[(CALayer *)[barrageItem.layer presentationLayer] position].x - barrageItem.frame.size.width/2];
    
    [infoModel setOriginY:barrageItem.frame.origin.y];
    
    [infoModel setTag:barrageItem.tag];
    
    [infoModel setModel:barrageItem.model];
    
    return infoModel;
}
@end
