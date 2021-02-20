#import "FBLiveBaseViewController+Guide.h"

@implementation FBLiveBaseViewController (Guide)

- (void)showCameraTip {
    [self showTipWithType:kTipSetCamera];
}

- (void)showShareTip {
    [self showTipWithType:kTipShareLive];
}

- (void)showAvatarTip {
    [self showTipWithType:kTipSetAvatar];
}

- (void)showThanksTip {
    [self showTipWithType:kTipThankUsers];
}

- (void)showFollowTip {
    [self showTipWithType:kTipFollowBroadcaster];
}

- (void)showChatTip {
    [self showTipWithType:kTipTalkToBroadcaster];
}

- (void)showSendGiftTip {
    [self showTipWithType:kTipSendGift];
}

- (void)showBroadcastorRemindUsersToFollowTip {
    [self showTipWithType:kTipRemindFollowMe];
}

#pragma mark - Help -
- (void)showTipWithType:(FBTipAndGuideType)type {
    [self.infoContainer.contentView showTipWithType:type];
}

@end
