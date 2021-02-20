#import "FBGiftAnimationHelper.h"

@implementation FBGiftAnimationHelper

+ (NSURLSessionDownloadTask *)downloadZipFileForGift:(FBGiftModel *)gift {
    return [FBGiftAnimationHelper downloadZipFileForGift:gift completionHandler:nil];
}

+ (NSURLSessionDownloadTask *)downloadZipFileForGift:(FBGiftModel *)gift completionHandler:(void (^)(NSArray *imageFiles, NSInteger animationType, NSTimeInterval duration))completionHandler {
    NSString *URLString = [FBGiftAnimationHelper URLStringForGift:gift];
    NSURL *URL = [NSURL URLWithString:URLString];
    NSString *zipPath = [FBGiftAnimationHelper zipPathForGift:gift];
    if ([FCFileManager existsItemAtPath:zipPath]) {
        NSArray *imageFiles = [FBGiftAnimationHelper animationImagesWithGift:gift];
        FBGiftAnimationInfoModel *info = [FBGiftAnimationHelper animationInfoWithGift:gift];
        if (completionHandler) {
            completionHandler(imageFiles, [info.type integerValue], [info.time doubleValue]/1000);
        }
    } else {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
        NSURLRequest *request = [NSURLRequest requestWithURL:URL];
        NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
            return [NSURL fileURLWithPath:zipPath];
        } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
            NSArray *imageFiles = [FBGiftAnimationHelper animationImagesWithGift:gift];
            FBGiftAnimationInfoModel *info = [FBGiftAnimationHelper animationInfoWithGift:gift];
            if (completionHandler) {
                completionHandler(imageFiles, [info.type integerValue], [info.time doubleValue]/1000);
            }
        }];
        [downloadTask resume];
        return downloadTask;
    }
    return nil;
}

+ (BOOL)existsZipWithGift:(FBGiftModel *)gift {
    NSString *zipPath = [FBGiftAnimationHelper zipPathForGift:gift];
    if ([FCFileManager existsItemAtPath:zipPath]) {
        return YES;
    }
    return NO;
}

+ (NSArray *)animationImagesWithGift:(FBGiftModel *)gift {
    NSString *zipPath = [FBGiftAnimationHelper zipPathForGift:gift];
    NSArray *imageFiles = [FBGiftAnimationHelper listFilesAtZipPath:zipPath withExtension:@".png"];
    return imageFiles;
}

+ (FBGiftAnimationInfoModel *)animationInfoWithGift:(FBGiftModel *)gift {
    NSString *zipPath = [FBGiftAnimationHelper zipPathForGift:gift];
    NSArray *jsonFiles = [FBGiftAnimationHelper listFilesAtZipPath:zipPath withExtension:@".json"];
    NSString *filePath = [jsonFiles firstObject];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    FBGiftAnimationInfoModel *model = [FBGiftAnimationInfoModel mj_objectWithKeyValues:data];
    return model;
}

/** 保存的路径 */
+ (NSString *)zipPathForGift:(FBGiftModel *)gift {
    NSString *URLString = [FBGiftAnimationHelper URLStringForGift:gift];
    NSURL *URL = [NSURL URLWithString:URLString];
    NSString *zipPath = [FCFileManager pathForDocumentsDirectoryWithPath:[URL lastPathComponent]];
    return zipPath;
}

/** 下载地址 */
+ (NSString *)URLStringForGift:(FBGiftModel *)gift {
    NSString *URLString = [NSString stringWithFormat:@"%@%@", kRequestURLImageGift, gift.imageZip];
    return URLString;
}

/** 读取压缩包内的文件列表 */
+ (NSArray *)listFilesAtZipPath:(NSString *)zipPath withExtension:(NSString *)extension {
    
    // 解压文件所存放的文件夹名称
    NSString *dirName = [[zipPath stringByDeletingPathExtension] lastPathComponent];
    
    // 解压文件所存放的文件夹路径
    NSString *dirPath = [FCFileManager pathForDocumentsDirectoryWithPath:dirName];
    if (!dirPath) {
        return nil;
    }
    
    if (![FCFileManager existsItemAtPath:dirPath]) {
        // 如果文件夹不存在，则创建文件夹
        [FCFileManager createDirectoriesForPath:dirPath];
        
        // 解压到文件夹
        BOOL success = [SSZipArchive unzipFileAtPath:zipPath
                                       toDestination:dirPath];
        if (!success) {
            //解压失败的话 删除刚刚创建的文件
            [FCFileManager removeItemAtPath:dirPath];
            return nil;
        }
    }
    
    NSArray *files = [FCFileManager listFilesInDirectoryAtPath:dirPath withExtension:extension];
    return files;
}

@end
