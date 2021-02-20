//
//  XXAvatarController.m
//  LiveShow
//
//  Created by lgh on 16/2/5.
//  Copyright © 2016年 XX. All rights reserved.
//

#import "FBAvatarController.h"


@interface FBAvatarController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate, FBAvatarViewDelegeate>

@property (nonatomic, strong) FBAvatarView *avatarView;

@end

@implementation FBAvatarController

- (FBAvatarView *)avatarView {
    if (!_avatarView) {
        _avatarView = [[FBAvatarView alloc] initWithFrame:self.view.bounds type:self.type];
        _avatarView.delegate = self;
    }
    return _avatarView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.avatarView];
    if (_imageName.length != 0) {
        [MBProgressHUD showHUDAddedTo:self.avatarView.avatarImageView animated:YES];
        [self.avatarView.avatarImageView fb_setImageWithName:_imageName size:CGSizeMake(400, 400) placeholderImage:kDefaultImageAvatar completed:^{
            [MBProgressHUD hideAllHUDsForView:self.avatarView.avatarImageView animated:YES];
        }];
    } else {
        self.avatarView.avatarImageView.image = kDefaultImageAvatar;
    }

}


#pragma mark UIImagePickerControllerDelegate

- (void)photoAciton: (UIImagePickerControllerSourceType ) sourceType {
    UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
    pickerController.allowsEditing = YES;
    pickerController.sourceType = sourceType;
    pickerController.delegate = self;
    [self presentViewController:pickerController animated:YES completion:nil];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    UIImage *image = info[UIImagePickerControllerEditedImage];
    NSData *imageData = UIImageJPEGRepresentation(image, 0.3);
    self.avatarView.avatarImageView.image = image;
    [self showHUDWithTip:kLocalizationLoading delay:0 autoHide:NO];
    [[FBProfileNetWorkManager sharedInstance] updateUserPortrait:imageData constructingBody:^(id formData) {
        [formData appendPartWithFileData:imageData name:@"portrait" fileName:@"user_head_photo.jpg" mimeType:@"image/jpeg"];
    } success:^(id result) {
        if ([result[@"dm_error"] intValue] == 0) {
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            [self showHUDWithTip:kLocalizationSuccessfully delay:2 autoHide:YES];
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationUpdateProfile object:self];
        }
    } failure:^(NSString *errorString) {
        [self showHUDWithTip:kLocalizationError delay:2 autoHide:YES];
    } finally:^{
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        [MBProgressHUD hideAllHUDsForView:self.avatarView.avatarImageView animated:YES];
    }];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)showHUDWithTip:(NSString *)tip delay:(NSTimeInterval)delay autoHide:(BOOL)isAutoHide{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.labelText = tip;
    hud.margin = 10.f;
    hud.removeFromSuperViewOnHide = YES;
    if (isAutoHide) {
        [hud hide:YES afterDelay:delay];
    }
}


#pragma mark FBAvatarViewDelegate

- (void)takePhoto:(FBAvatarView *)avatarView button:(UIButton *)button {
    
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        return ;
    }
    [self photoAciton:UIImagePickerControllerSourceTypeCamera];
}


- (void)selectFromAlbums:(FBAvatarView *)avatarView button:(UIButton *)button {
    
    [self photoAciton:UIImagePickerControllerSourceTypePhotoLibrary];
}



- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (!error) {
        [self showHUDWithTip:kLocalizationSuccessfully delay:2 autoHide:YES];
    } else {
        [self showHUDWithTip:kLocalizationError delay:2 autoHide:YES];
    }
    
}

- (void)onClickAvatarView {
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
