//
//  CSCrash.h
//  CSCrashDemo
//
//  Created by Suns孙泉 on 2016/11/3.
//  Copyright © 2016年 cyou-inc.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CSCrash : NSObject

/**
 *      启动异常日志捕捉器
 */
+ (void)startUncaughtExceptionHandler:(void(^)(NSString *name, NSString *reason, NSArray *callStack))completion;

/**
 *      是否需要将异常日志写到本地
 */
+ (void)needWriteExceptionFile:(BOOL)isNeeded;

@end
