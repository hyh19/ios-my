//
//  FBLibLog.h
//  LiveShow
//
//  Created by chenfanshun on 09/03/16.
//  Copyright © 2016年 FB. All rights reserved.
//

#ifndef FBLibLog_h
#define FBLibLog_h

#define USE_FBLIBLOG

#ifdef USE_FBLIBLOG
#define FBLIBLOG(format, ...)  NSLog(format, ## __VA_ARGS__)
#else
#define FBLIBLOG(format, ...)
#endif

#endif /* FBLibLog_h */
