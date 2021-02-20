#import "UIButton+FB.h"

@implementation UIButton (FB)

- (void)fb_setImageWithName:(NSString *)imageName size:(CGSize)size forState:(UIControlState)state placeholderImage:(UIImage *)placeholder {
    NSString *imageURLString = [NSString stringWithFormat:@"%@?url=%@&w=%d&h=%d", kRequestURLImageScale, imageName, (int)size.width, (int)size.height];
    [self sd_setImageWithURL:[NSURL URLWithString:imageURLString] forState:state placeholderImage:placeholder completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (image) {
            NSData *data = UIImagePNGRepresentation(image);
            [self setImage:[UIImage imageWithData:data] forState:state];
        } else {
            [self setImage:kDefaultImageAvatar forState:state];
        }

    }];
}

- (void)fb_setImageWithName:(NSString *)imageName forState:(UIControlState)state placeholderImage:(UIImage *)placeholder {
    NSString *imageURLString = [NSString stringWithFormat:@"%@?url=%@", kRequestURLImageScale, imageName];
    [self sd_setImageWithURL:[NSURL URLWithString:imageURLString] forState:state placeholderImage:placeholder completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (image) {
            NSData *data = UIImagePNGRepresentation(image);
            [self setImage:[UIImage imageWithData:data] forState:state];
        } else {
            [self setImage:kDefaultImageAvatar forState:state];
        }
        
    }];
}

- (void)fb_setBackgroundImageWithName:(NSString *)imageName size:(CGSize)size forState:(UIControlState)state placeholderImage:(UIImage *)placeholder {
    NSString *imageURLString = [NSString stringWithFormat:@"%@?url=%@&w=%d&h=%d", kRequestURLImageScale, imageName, (int)size.width, (int)size.height];
    [self sd_setBackgroundImageWithURL:[NSURL URLWithString:imageURLString] forState:state placeholderImage:placeholder completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (image) {
            NSData *data = UIImagePNGRepresentation(image);
            [self setBackgroundImage:[UIImage imageWithData:data] forState:state];
        } else {
            [self setBackgroundImage:kDefaultImageAvatar forState:state];
        }

    }];
}

- (void)fb_setBackgroundImageWithName:(NSString *)imageName size:(CGSize)size forState:(UIControlState)state placeholderImage:(UIImage *)placeholder completed:(void(^)(UIImage *image))completed{
    NSString *imageURLString = [NSString stringWithFormat:@"%@?url=%@&w=%d&h=%d", kRequestURLImageScale, imageName, (int)size.width, (int)size.height];
    NSLog(@"url:%@",imageURLString);
    [self sd_setBackgroundImageWithURL:[NSURL URLWithString:imageURLString] forState:state placeholderImage:placeholder completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (image) {
            NSData *data = UIImagePNGRepresentation(image);
            [self setBackgroundImage:[UIImage imageWithData:data] forState:state];
            completed(image);
        } else {
            [self setBackgroundImage:kDefaultImageAvatar forState:state];
            completed(kDefaultImageAvatar);
        }

    }];
}



- (void)fb_setBackgroundImageWithName:(NSString *)imageName forState:(UIControlState)state placeholderImage:(UIImage *)placeholder {
    NSString *imageURLString = [NSString stringWithFormat:@"%@?url=%@", kRequestURLImageScale, imageName];
    [self sd_setBackgroundImageWithURL:[NSURL URLWithString:imageURLString] forState:state placeholderImage:placeholder completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (image) {
            NSData *data = UIImagePNGRepresentation(image);
            [self setBackgroundImage:[UIImage imageWithData:data] forState:state];
        } else {
            [self setBackgroundImage:kDefaultImageAvatar forState:state];
        }
        
    }];
}

@end
