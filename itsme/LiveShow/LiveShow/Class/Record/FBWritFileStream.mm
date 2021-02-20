//
//  FBWritFileStream.m
//  LiveShow
//
//  Created by chenfanshun on 26/02/16.
//  Copyright © 2016年 chenfanshun. All rights reserved.
//

#import "FBWritFileStream.h"
#import "flv.h"

@interface FBWritFileStream()

{
    NSFileHandle* _fileHandle;
}

@end

@implementation FBWritFileStream

-(id)initWithPath:(NSString*)pathName
{
    if(self = [super init]) {
        //path
        NSArray *paths = NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString* path = [documentsDirectory stringByAppendingPathComponent:pathName];
        
        NSFileManager* manager = [NSFileManager defaultManager];
        if(![manager fileExistsAtPath:path]){
            flv::Header header;
            header.SetAudioPresent(true);
            header.SetVideoPresent(false);
            
            std::string headerString;
            header.Encode(headerString);
            
            NSData* conent = [NSData dataWithBytes:headerString.c_str() length:headerString.length()];
            
            BOOL success = [manager createFileAtPath:path contents:conent attributes:nil];
            NSLog(@"status:%zd, headersize....:%zd", success, conent.length);
        }
        _fileHandle = [NSFileHandle fileHandleForWritingAtPath:path];
    }
    return self;
}

-(void)dealloc
{
    [self closeFile];
}

-(void)writeDataToFile:(NSData*)data
{
    [_fileHandle seekToEndOfFile];
    
    if(data != nil) {
        [_fileHandle writeData:data];
        NSLog(@"writing data:...size: %zd", data.length);
    } else {
        NSLog(@"not data...");
    }
}

-(void)closeFile
{
    [_fileHandle closeFile];
    _fileHandle = nil;
}


@end
