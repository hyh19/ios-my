#import "FBActivityHelper.h"
#import "SSZipArchive.h"
#import "FCFileManager.h"

@implementation FBActivityHelper

+ (void)downloadZipFileForActivity:(NSString *)activity completionBlock:(void(^)(void))completion{
    NSString *URLString = [FBActivityHelper URLStringForActivity:activity];
    NSURL *URL = [NSURL URLWithString:URLString];
    NSString *zipPath = [FBActivityHelper zipPathForActivity:activity];
    
    if ([FCFileManager existsItemAtPath:zipPath]) {
        if (completion) {
            completion();
        }
    } else {
        
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
        NSURLRequest *request = [NSURLRequest requestWithURL:URL];
        
        NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
            NSLog(@"downloadProgress is %@", downloadProgress);
        } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
            return [NSURL fileURLWithPath:zipPath];
        } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
            if (completion) {
                completion();
            }
        }];
        
        [downloadTask resume];
    }
    
}

+ (NSArray *)filesWithActivity:(NSString *)activit {
    NSString *zipPath = [FBActivityHelper zipPathForActivity:activit];
    NSArray *imageFiles = [FBActivityHelper listFilesAtZipPath:zipPath withExtension:@".png"];
    return imageFiles;
}

+ (NSDictionary *)filesWithActivityText:(NSString *)activit{
    NSDictionary *dict = [[NSDictionary alloc] init];
    NSString *zipPath = [FBActivityHelper zipPathForActivity:activit];
    NSArray *jsonFiles = [FBActivityHelper listFilesAtZipPath:zipPath withExtension:@".txt"];
    NSString *filePath = [jsonFiles firstObject];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    if (data) {
        dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
    }
    return dict;
}

/** 保存的路径 */
+ (NSString *)zipPathForActivity:(NSString *)activit {
    NSString *URLString = [FBActivityHelper URLStringForActivity:activit];
    NSURL *URL = [NSURL URLWithString:URLString];
    NSString *zipPath = [FCFileManager pathForDocumentsDirectoryWithPath:[URL lastPathComponent]];
    return zipPath;
}

/** 下载地址 */
+ (NSString *)URLStringForActivity:(NSString *)activit {
    NSString *URLString = [NSString stringWithFormat:@"%@%@", kRequestURLImageGift, activit];
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
            return nil;
        }
    }
    
    NSArray *files = [FCFileManager listFilesInDirectoryAtPath:dirPath withExtension:extension];
    return files;
}

@end
