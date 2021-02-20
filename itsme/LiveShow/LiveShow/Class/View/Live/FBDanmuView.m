//
//  FBDanmuView.m
//  LiveShow
//
//  Created by tak on 16/5/3.
//  Copyright © 2016年 FB. All rights reserved.
//
#import "FBDanmuItem.h"
#import "FBDanmuView.h"

/** 通道间距 */
#define kPathPadding 3

/** 弹幕高度 */
#define kItemHeight 36

/** 弹幕速度 dp/s */
#define kVelocity 70

/** 弹幕间距 */
#define kItemPadding 20

@interface FBDanmuView ()

/** 弹道标识 */
@property (nonatomic, assign) NSUInteger index;

/** 总消息数组 */
@property (nonatomic, strong) NSMutableArray *msgArray;

/** 弹幕数组 */
@property (nonatomic, strong) NSMutableArray *itemsArray;

@end

@implementation FBDanmuView

- (NSMutableArray *)msgArray {
    if (!_msgArray) {
        _msgArray = [[NSMutableArray alloc] init];
    }
    return _msgArray;
}


- (NSMutableArray *)itemsArray {
    if (!_itemsArray) {
        _itemsArray = [[NSMutableArray alloc] initWithCapacity:4];
        for (int i = 0; i < 4; ++i) {
            NSMutableArray *itemArray = [[NSMutableArray alloc] init];
            [_itemsArray addObject:itemArray];
        }
    }
    return _itemsArray;
}


- (void)receivedMessage:(FBMessageModel *)msg {
    
    //创建弹幕
    FBDanmuItem *item = [self setupItemWithMsg:msg];
    
    //保存到对应弹道的弹幕数组
    [[self.itemsArray safe_objectAtIndex:_index] safe_addObject:item];
    
    //切换到下一个弹道
    _index++;
    _index = _index % 4;

    //加到总弹幕数组
    [self.msgArray addObject:item];
    
    //加到弹幕容器view
    [self addSubview:item];
    
    //执行动画
    [self showAnimationWithItem:item];
    
}


//计算文本宽度
- (CGFloat)calculateWidth:(NSString *)str {
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithObject:[UIFont systemFontOfSize:14] forKey:NSFontAttributeName];
    return [str boundingRectWithSize:CGSizeMake(MAXFLOAT, 0.0) options:NSStringDrawingUsesLineFragmentOrigin attributes:dic context:nil].size.width;
}

- (CGFloat)itemX {
    CGFloat itemX = self.width;
    if (_index < self.itemsArray.count) {
        NSMutableArray *itemArray = self.itemsArray[_index];
        //如果数组有值 取出最后一个item的x
        if (itemArray.count > 0) {
            FBDanmuItem *lastItem = itemArray.lastObject;
            CALayer *layer = lastItem.layer.presentationLayer;
            CGRect frame = layer.frame;
            if (frame.origin.x > - frame.size.width) {
                itemX = frame.origin.x + lastItem.width + kItemPadding;
            }
        }
    }
    return itemX;
}


- (FBDanmuItem *)setupItemWithMsg:(FBMessageModel *)msg {
    FBDanmuItem *item = [[FBDanmuItem alloc] init];
    item.x = [self itemX];
    item.y = _index * (kItemHeight + kPathPadding);
    item.height = kItemHeight;
    item.hidden = YES;
    item.message = msg;
    //消息的宽
    CGFloat msgWidth = [self calculateWidth:msg.content];
    //名字的宽
    CGFloat nameWidth = [self calculateWidth:msg.fromUser.nick];
    //36头像宽度 16各控件间距
    item.width = msgWidth + nameWidth + 36 + 16;
    return item;
}

//执行动画
- (void)showAnimationWithItem:(FBDanmuItem *)item {
    //计算动画花费时间
    NSTimeInterval time = (SCREEN_WIDTH + item.width + item.x) / kVelocity;

    [UIView animateWithDuration:time delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        _isDanmu = YES;
        item.hidden = NO;
        item.x = - (SCREEN_WIDTH + item.width);
    } completion:^(BOOL finished) {
        [self.msgArray removeObject:item];
        [item removeFromSuperview];
        if (self.msgArray.count == 0) {
            _isDanmu = NO;
            [self.itemsArray removeAllObjects];
            self.itemsArray = nil;
        }
    }];
}


@end
