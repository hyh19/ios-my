//
//  FBMsgPacketHelper.m
//  LiveShow
//
//  Created by chenfanshun on 08/03/16.
//  Copyright © 2016年 FB. All rights reserved.
//

#import "FBMsgPacketHelper.h"
#import "FBMsgService.h"

//十进制转十六进制
NSString *ToHex(int tmpid)
{
    NSString *endtmp=@"";
    NSString *nLetterValue;
    NSString *nStrat;
    int ttmpig=tmpid%16;
    int tmp=tmpid/16;
    switch (ttmpig)
    {
        case 10:
            nLetterValue =@"a";break;
        case 11:
            nLetterValue =@"b";break;
        case 12:
            nLetterValue =@"c";break;
        case 13:
            nLetterValue =@"d";break;
        case 14:
            nLetterValue =@"e";break;
        case 15:
            nLetterValue =@"f";break;
        default:nLetterValue=[[NSString alloc]initWithFormat:@"%i",ttmpig];
            
    }
    switch (tmp)
    {
        case 10:
            nStrat =@"a";break;
        case 11:
            nStrat =@"b";break;
        case 12:
            nStrat =@"c";break;
        case 13:
            nStrat =@"d";break;
        case 14:
            nStrat =@"e";break;
        case 15:
            nStrat =@"f";break;
        default:nStrat=[[NSString alloc]initWithFormat:@"%i",tmp];
            
    }
    endtmp=[[NSString alloc]initWithFormat:@"%@%@",nStrat,nLetterValue];
    return endtmp;
}


@implementation FBIMPushModel


@end

@implementation FBPushNotifyModel


@end

@implementation FBMsgPacketHelper

+(NSString*)packIMMsg:(NSString*)msg to:(NSUInteger)to_uid
{
    NSString* packString =@"";
    @try {
        NSMutableDictionary* param = [NSMutableDictionary dictionary];
        param[@"id"] = @(to_uid);
        param[@"type"] = @(kMsgTypePrivateChat);
        param[@"msg"] = msg;
        /**
         *  @since 2.0.0
         *  @brief 服务端要求用整型
         */
        param[@"from_user"] = @([[FBLoginInfoModel sharedInstance].userID integerValue]);
        param[@"synckey"] = @(2);
        param[@"time"] = @([[NSDate date] timeIntervalSince1970]);
        
        NSData* jsonData = [NSJSONSerialization dataWithJSONObject:param options:0 error:nil];
        if(jsonData) {
            packString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        } else {
            NSLog(@"packIMMsg failure");
        }
    }
    @catch (NSException *exception) {
        
    }
    return packString;
}

+(NSString*)packRoomMsg:(NSString*)msg from:(FBUserInfoModel*)model withSubType:(NSInteger)subType
{
    NSString* packString = @"";
    @try {
        //user
        NSDictionary* user = [[self class] packUser:model];
        
        NSMutableDictionary* param = [NSMutableDictionary dictionary];
        param[@"message"] = msg;
        param[@"fromUser"] = user;
        param[@"type"] = @(kMsgTypeRoomChat);
        param[@"subtype"] = @(subType);
        
        NSData* jsonData = [NSJSONSerialization dataWithJSONObject:param options:0 error:nil];
        if(jsonData) {
            packString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        } else {
            NSLog(@"packRoomMsg failure");
        }
    }
    @catch (NSException *exception) {
        
    }
    return packString;
}

+(NSString*)packGiftMsgFrom:(FBUserInfoModel*)from to:(FBUserInfoModel*)to gift:(FBGiftModel*)model giftCount:(NSInteger)count withTransactionId:(NSString*)transaction_id
{
    NSString* packString = @"";
    @try {
        NSDictionary* dicFrom = [[self class] packUser:from];
        NSDictionary* dicTo = [[self class] packUser:to];
        NSDictionary* dicGift = [[self class] packGift:model];
        
        NSMutableDictionary* param = [NSMutableDictionary dictionary];
        param[@"toUser"] = dicTo;
        param[@"fromUser"] = dicFrom;
        param[@"count"] = @(count);
        param[@"gift"] = dicGift;
        param[@"type"] = @(KMsgTypeGift);
        param[@"transaction_id"] = transaction_id;
        
        NSData* jsonData = [NSJSONSerialization dataWithJSONObject:param options:0 error:nil];
        if(jsonData) {
            packString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        } else {
            NSLog(@"packGiftMsg failure");
        }
    }
    @catch (NSException *exception) {
        
    }
    return packString;
    
}

+(NSString*)packFirstHitMsgFrom:(FBUserInfoModel*)from color:(UIColor*)color
{
    NSString* packString = @"";
    @try {
        NSDictionary* dicUser = [[self class] packUser:from];
        NSString* strColor = [[self class] colorToHexString:color];
        
        NSMutableDictionary* param = [NSMutableDictionary dictionary];
        param[@"fromUser"] = dicUser;
        param[@"message"] = strColor;
        param[@"type"] = @(KMsgTypeFirstHit);
        
        NSData* jsonData = [NSJSONSerialization dataWithJSONObject:param options:0 error:nil];
        if(jsonData) {
            packString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        } else {
            NSLog(@"packFirstHitMsg failure");
        }
    }
    @catch (NSException *exception) {
        return packString;
    }
    return packString;
}

+(NSString*)packLikeMsgFrom:(FBUserInfoModel*)from color:(UIColor*)color
{
    NSString* packString = @"";
    @try {
        NSString* strColor = [[self class] colorToHexString:color];
        NSDictionary *uinfo = [[self class] packUidOnly:from.userID];

        NSMutableDictionary* param = [NSMutableDictionary dictionary];
        param[@"fromUser"] = uinfo;
        param[@"message"] = strColor;
        param[@"type"] = @(KMsgTypeLike);

        NSData* jsonData = [NSJSONSerialization dataWithJSONObject:param options:0 error:nil];
        if(jsonData) {
            packString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        } else {
            NSLog(@"packLikeMsg failure");
        }
    }
    @catch (NSException *exception) {
        return packString;
    }
    return packString;
}

+(NSString*)packBulletMsg:(NSString*)msg from:(FBUserInfoModel*)model withTransactionId:(NSString*)transaction_id
{
    NSString* packString = @"";
    @try {
        //user
        NSDictionary* user = [[self class] packUser:model];
        
        NSMutableDictionary* param = [NSMutableDictionary dictionary];
        param[@"message"] = msg;
        param[@"fromUser"] = user;
        param[@"type"] = @(kMsgTypeBullet);
        param[@"transaction_id"] = transaction_id;
        
        NSData* jsonData = [NSJSONSerialization dataWithJSONObject:param options:0 error:nil];
        if(jsonData) {
            packString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        } else {
            NSLog(@"packBulletMsg failure");
        }
    }
    @catch (NSException *exception) {
        
    }
    return packString;
}

+(NSString*)packBroadcasterState:(NSInteger)status from:(FBUserInfoModel*)model
{
    NSString* packString = @"";
    @try {
        //user
        NSDictionary* user = [[self class] packUser:model];
        
        //msg
        NSMutableDictionary *msg = [NSMutableDictionary dictionary];
        msg[@"state"] = @(status);
        
        NSMutableDictionary* param = [NSMutableDictionary dictionary];
        param[@"message"] = msg;
        param[@"fromUser"] = user;
        param[@"type"] = @(kMsgTypeBrocasterStatus);
        
        NSData* jsonData = [NSJSONSerialization dataWithJSONObject:param options:0 error:nil];
        if(jsonData) {
            packString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        } else {
            NSLog(@"packBulletMsg failure");
        }
    }
    @catch (NSException *exception) {
        
    }
    return packString;
}

+(NSString*)packExitOpenLiveMsg:(NSString*)reason
{
    NSString* packString = @"";
    @try {
        NSMutableDictionary* param = [NSMutableDictionary dictionary];
        param[@"reason"] = reason;
        param[@"type"] = @(KMsgTypeExitOpenLive);
        
        NSData* jsonData = [NSJSONSerialization dataWithJSONObject:param options:0 error:nil];
        if(jsonData) {
            packString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        } else {
            NSLog(@"packExitOpenLiveMsg failure");
        }
    }
    @catch (NSException *exception) {
        
    }
    return packString;
}

+(NSString*)packDiamondTotalCountMessage:(NSInteger)count form:(FBUserInfoModel*)model
{
    NSString* packString = @"";
    @try {
        //user
        NSDictionary* user = [[self class] packUser:model];
        
        //msg
        NSMutableDictionary *msg = [NSMutableDictionary dictionary];
        msg[@"count"] = @(count);
        
        NSMutableDictionary* param = [NSMutableDictionary dictionary];
        param[@"type"] = @(kMsgTypeDiamondTotalCount);
        param[@"fromUser"] = user;
        param[@"message"] = msg;
        
        NSData* jsonData = [NSJSONSerialization dataWithJSONObject:param options:0 error:nil];
        if(jsonData) {
            packString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        } else {
            NSLog(@"packDiamondTotalCountMessage failure");
        }
    }
    @catch (NSException *exception) {
        
    }
    return packString;
}

+(NSDictionary*)packUidOnly:(NSString*)uid
{
    NSMutableDictionary* user = [NSMutableDictionary dictionary];
    /**
     *  @since 2.0.0
     *  @brief 服务端要求用整型
     */
    user[@"id"] = @([uid integerValue]);
    return user;
}

+(NSDictionary*)packUser:(FBUserInfoModel*)model
{
    NSMutableDictionary* user = [NSMutableDictionary dictionary];
    NSNumber *verified = [NSNumber numberWithFloat:[model.verified intValue]];
    user[@"description"] = model.Description;
    user[@"verified_reason"] = @"";
    user[@"veri_info"] = @"";
    user[@"third_platform"] = @"";
    user[@"location"] = model.location;
    user[@"nick"] = model.nick;
    user[@"portrait"] = model.portrait;
    user[@"rank_veri"] = @(0);
    user[@"ulevel"] = model.ulevel;
    /**
     *  @since 2.0.0
     *  @brief 服务端要求用整型
     */
    user[@"id"] = @([model.userID integerValue]);
    user[@"verified"] = model.isVerifiedBroadcastor ? verified : @(0);
    user[@"gender"] = model.gender;
    return user;
}

+(NSDictionary*)packGift:(FBGiftModel*)model
{
    NSMutableDictionary* gif = [NSMutableDictionary dictionary];
    gif[@"name"] = model.name;
    gif[@"image"] = model.image;
    gif[@"icon"] = model.icon;
    gif[@"gold"] = model.gold;
    gif[@"id"] = model.giftID;
    gif[@"type"] = model.type;
    gif[@"exp"] = model.exp;
    gif[@"img_bag"] = model.imageZip;
    return gif;
}

+(NSDictionary*)unpackRoomMsg:(NSString*)msg withType:(NSInteger)type
{
    NSMutableDictionary* dicResult = [NSMutableDictionary dictionary];
    
    @try {
        NSData* data = [msg dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary* param = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        
        switch (type) {
            case kMsgTypeRoomChat:
            case kMsgTypeBullet:
            {
                FBUserInfoModel* from = [FBUserInfoModel mj_objectWithKeyValues:param[@"fromUser"]];
                NSString* msg = param[@"message"];
                
                dicResult[FROMUSER_KEY] = from;
                dicResult[MESSAGE_KEY] = msg;
                
                if(kMsgTypeRoomChat == type) {
                    dicResult[MESSAGE_SUBTYPE_KEY] = param[@"subtype"];
                }
            }
                break;
            case KMsgTypeGift:
            {
                FBUserInfoModel* from = [FBUserInfoModel mj_objectWithKeyValues:param[@"fromUser"]];
                FBUserInfoModel* to = [FBUserInfoModel mj_objectWithKeyValues:param[@"toUser"]];
                
                FBGiftModel* gift = [FBGiftModel mj_objectWithKeyValues:param[@"gift"]];
                //gifmodel
                dicResult[FROMUSER_KEY] = from;
                dicResult[TOUSER_KEY] = to;
                dicResult[GIFT_KEY] = gift;
                dicResult[GIFTCOUNT_KEY] = param[@"count"];
            }
                break;
            case KMsgTypeLike:
            case KMsgTypeFirstHit:
            {
                FBUserInfoModel* from = [FBUserInfoModel mj_objectWithKeyValues:param[@"fromUser"]];
                
                
                NSString *strColor = param[@"message"];
                UIColor *color = nil;
                if(nil == strColor) {
                    color = [FBUtility randomLikeColor];
                } else {
                    color = [HXColor hx_colorWithHexString:strColor];
                }
                
                dicResult[FROMUSER_KEY] = from;
                dicResult[COLOR_KEY] = color;
            }
                break;
            case KMsgTypeExitOpenLive:
            {
                
            }
                break;
            case kMsgTypeBrocasterStatus:
            {
                NSDictionary *dicMsg = param[@"message"];
                dicResult[BROADCASTSTATE_KEY] = dicMsg[@"state"];
            }
                break;
            case kMsgTypeDiamondTotalCount:
            {
                NSDictionary *dicMsg = param[@"message"];
                dicResult[DIAMONDCOUNT_KEY] = dicMsg[@"count"];
            }
                break;
            case kMsgTypeBanOpenLive:
            {
                NSDictionary *dicMsg = param[@"message"];
                dicResult[BANED_DAY] = dicMsg[@"day"];
            }
                break;
            case kMsgTypeRoomManager:
            {
                NSString *message = param[@"msg"];
                NSData* dataMsg = [message dataUsingEncoding:NSUTF8StringEncoding];
                NSDictionary* paramMsg = [NSJSONSerialization JSONObjectWithData:dataMsg options:0 error:nil];
                
                FBUserInfoModel *userModel;
                NSString *event = param[@"event"];
                if([event isValid] && ([event isEqualToString:kEventSetManager] || [event isEqualToString:kEventUnsetManager])) {
                    userModel = [FBUserInfoModel mj_objectWithKeyValues:paramMsg[@"uinfo"]];
                } else {
                    userModel = [FBUserInfoModel mj_objectWithKeyValues:paramMsg[@"ban_uinfo"]];
                }
                
                
                
                FBRoomManagerModel *model = [[FBRoomManagerModel alloc] init];
                model.live_id = param[@"lid"];
                model.event = event;
                model.uid = param[@"uid"];
                model.user = userModel;
                dicResult[CHANNELMANAGER_KEY] = model;
            }
                break;
            case kMsgTypeUserEnter: {
                FBUserInfoModel *fromUser = [FBUserInfoModel mj_objectWithKeyValues:param[@"fromUser"]];
                dicResult[FROMUSER_KEY] = fromUser;
                dicResult[USER_ENTER_INFO_KEY] = param[@"detail"];
            }
                break;
            default:
                break;
        }
        
    } @catch (NSException *exception) {
        NSLog(@"unpackRoomMsg exception");
    }
    return dicResult;
}

+(NSDictionary*)unpackPushMsg:(NSString*)msg
{
    NSMutableDictionary* dicResult = [NSMutableDictionary dictionary];
    
    @try {
        NSData* data = [msg dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary* param = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        
        NSInteger type = [param[@"type"] integerValue];
        dicResult[@"type"] = @(type);
        
        //msg里面还是json
        NSString* msgBody = param[@"msg"];
        NSData* dataBody = [msgBody dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary* dicMsg = [NSJSONSerialization JSONObjectWithData:dataBody options:0 error:nil];
        
        FBUserInfoModel* user = [FBUserInfoModel mj_objectWithKeyValues:dicMsg[@"creator"]];
        
        FBPushNotifyModel* model = [[FBPushNotifyModel alloc] init];
        
        model.base_id = [NSString stringWithFormat:@"%@", dicResult[@"base_id"]];
        model.user = user;
        model.city = dicMsg[@"city"];
        model.live_id = [NSString stringWithFormat:@"%@", dicMsg[@"id"]];
        model.group = [dicMsg[@"group"] integerValue];
        model.action = [dicMsg[@"action"] integerValue];
        model.text = dicMsg[@"text"];
        
        dicResult[PUSHNOTIFY_KEY] = model;
        
    } @catch (NSException *exception) {
        
    }
    return dicResult;
}

+(NSString*)colorToHexString:(UIColor*)color
{
    CGFloat r, g, b, a;
    [color getRed:&r green:&g blue:&b alpha:&a];
    NSString *strR = ToHex(r*255);
    NSString *strG = ToHex(g*255);
    NSString *strB = ToHex(b*255);
    NSString* result = [NSString stringWithFormat:@"#%@%@%@", strR, strG, strB];
    return result;
}

@end
