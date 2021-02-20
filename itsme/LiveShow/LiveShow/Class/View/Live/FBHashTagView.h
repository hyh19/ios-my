//
//  FBHashTagView.h
//  LiveShow
//
//  Created by chenfanshun on 10/08/16.
//  Copyright © 2016年 FB. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FBHashTagView : UIView

@property(nonatomic, copy) void (^onTagClick)(NSString *tagString, BOOL isSelected);

/**
 *  设置tags
 *
 *  @param tags <#tags description#>
 */
-(void)setHashTags:(NSArray*)tags;

/**
 *  获取当前选择的tag
 *
 *  @return <#return value description#>
 */
-(NSArray*)getSelectTags;

/**
 *  通过text来更新tags的状态
 *
 *  @param text <#text description#>
 */
-(void)updateStateWithText:(NSString*)text;

- (CGSize)fittedSize;

@end
