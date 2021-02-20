#import "UIImageView+FB.h"
#import "FBImageHelper.h"
#import "mopi.h"

@implementation UIImageView (FB)


- (void)fb_setImageWithName:(NSString *)imageName size:(CGSize)size placeholderImage:(UIImage *)placeholder completed:(void(^)())completedBlock {
    NSString *imageURLString = [NSString stringWithFormat:@"%@?url=%@&w=%d&h=%d", kRequestURLImageScale, imageName, (int)size.width, (int)size.height];
    __weak typeof(self) wself = self;
    [self sd_setImageWithURL:[NSURL URLWithString:imageURLString] placeholderImage:placeholder completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (error) {
            //
        } else {
            if (image) {
                NSData *data = UIImagePNGRepresentation(image);
                wself.image = [UIImage imageWithData:data];
                if (completedBlock) {
                    completedBlock();
                }
            } else {
                wself.image = kDefaultImageAvatar;
            }
        }
    }];
}

- (void)fb_setGiftImageWithName:(NSString *)imageName placeholderImage:(UIImage *)placeholder completed:(CompletedBlock)completedBlock {
    NSString *baseURL = kRequestURLImageGift;
    NSString *imageURLString = nil;
    if ([baseURL hasSuffix:@"/"]) {
        imageURLString = [NSString stringWithFormat:@"%@%@", baseURL, imageName];
    } else {
        imageURLString = [NSString stringWithFormat:@"%@/%@", baseURL, imageName];
    }
    __weak typeof(self) wself = self;
    [self sd_setImageWithURL:[NSURL URLWithString:imageURLString] placeholderImage:placeholder completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (error) {
            //
        } else {
            if (image) {
                NSData *data = UIImagePNGRepresentation(image);
                wself.image = [UIImage imageWithData:data];
                if (completedBlock) {
                    completedBlock();
                }
            } else {
                wself.image = kDefaultImageAvatar;
            }
        }
    }];
}

- (void)fb_setGaussianBlurImageWithName:(NSString *)imageName size:(CGSize)size placeholderImage:(UIImage *)placeholder
{
    [self fb_setGaussianBlurImageWithName:imageName size:size radius:kDefaultGaussianBlurRadius placeholderImage:placeholder];
}

- (void)fb_setGaussianBlurImageWithName:(NSString *)imageName size:(CGSize)size radius:(NSInteger)radius placeholderImage:(UIImage *)placeholder
{
    __weak typeof(self)weakSelf = self;
    NSString *imageURLString = [NSString stringWithFormat:@"%@?url=%@&w=%d&h=%d", kRequestURLImageScale, imageName, (int)size.width, (int)size.height];
    [self sd_setImageWithURL:[NSURL URLWithString:imageURLString] placeholderImage:placeholder options:SDWebImageAvoidAutoSetImage completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if(weakSelf) {
            [weakSelf fb_setGaussianBlurImage:image radius:radius useScale:YES placeholderImage:placeholder];
        }
    }];
}

- (void)fb_setGaussianBlurImage:(UIImage*)image radius:(NSInteger)radius useScale:(BOOL)useScale placeholderImage:(UIImage *)placeholder
{
    if(placeholder) {
        self.image = placeholder;
    }
    
    //后台模式不进行高斯模糊（opengl 不能在后台模式下执行）
    if(UIApplicationStateBackground ==  [[UIApplication sharedApplication] applicationState]) {
        return;
    }
    
    int width = (int)CGImageGetWidth(image.CGImage);
    int height = (int)CGImageGetHeight(image.CGImage);
    if(width && height) {
        __weak typeof(self)weakSelf = self;
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            //高斯模糊
            UInt32 type[2];
            type[0] = mopi::FilterType::GAUSSIANBLUR_FILTER;
            type[1] = mopi::FilterType::GAUSSIANBLUR_FILTER;
            NSTimeInterval timeBegin = [[NSDate date] timeIntervalSince1970];
            if(mopi::Filters* filter = mopi::CreateFilters(width, height, 2, type)) {
                filter->SetOption(0, mopi::FilterOption::GaussianBlur::HORIZONTAL);
                filter->SetOption(1, mopi::FilterOption::GaussianBlur::VERTICAL);
                if(radius) {
                    filter->SetOption(0, mopi::FilterOption::GaussianBlur::RADIUS, radius);
                    filter->SetOption(1, mopi::FilterOption::GaussianBlur::RADIUS, radius);
                }
                //先转成rgba格式数据
                UInt8 *rgba = [FBImageHelper convertUIImageToBitmapRGBA8:image];
                UInt8 *output = (UInt8 *)malloc(width*height*4*sizeof(UInt8));
                filter->Process(rgba, output);
                
                UIImage* processImg = [FBImageHelper convertBitmapRGBA8ToUIImage:output withWidth:width withHeight:height];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    weakSelf.image = processImg;
                });
                //释放内存
                free(rgba);
                free(output);
                
                filter->Dispose();
            }
            NSTimeInterval timeCount = [[NSDate date] timeIntervalSince1970] - timeBegin;
            NSLog(@"gpu use time: %.3f", timeCount);
        });
        
    }
}

@end

@interface UIImageView ()
//用来记录 释放定时器
@property (nonatomic, strong) NSTimer *aTimer;

@end

static void const *timerKey = &timerKey;

@implementation UIImageView (Animation)

- (void)fb_startAnimatingWithImageFiles:(NSArray *)imageFiles duration:(NSTimeInterval)duration repeatCount:(NSInteger)repeatCount completed:(CompletedBlock)completedBlock {
    if ([self.aTimer isValid]) {
        [self.aTimer invalidate];
        self.aTimer = nil;
    }
    
    __block NSInteger index = 0;
    __block NSInteger count = [imageFiles count];
    NSTimeInterval interval = duration/count;
    // 重复次数，从1开始
    __block NSInteger repeated = 1;
    __weak typeof(self) wself = self;
    self.aTimer = [NSTimer bk_scheduledTimerWithTimeInterval:interval block:^(NSTimer *timer) {
        if (index < count) {
            UIImage *image = [UIImage imageWithContentsOfFile:imageFiles[index]];
            wself.image = image;
            ++index;
        } else {
            ++repeated;
            index = 0;
            if (repeatCount > 0) {
                if (repeated > repeatCount) {
                    if ([timer isValid]) {
                        [timer invalidate];
                        timer = nil;
                    }
                    if (completedBlock) {
                        completedBlock();
                    }
                }
            }
        }
    } repeats:YES];
}


- (NSTimer *)aTimer {
    return objc_getAssociatedObject(self, timerKey);
}

- (void)setATimer:(NSTimer *)aTimer {
    objc_setAssociatedObject(self, timerKey, aTimer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)dealloc {
    [self.aTimer invalidate];
    self.aTimer = nil;
}

@end
