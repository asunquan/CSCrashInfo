//
//  CSCrash.m
//  CSCrashDemo
//
//  Created by Suns孙泉 on 2016/11/3.
//  Copyright © 2016年 cyou-inc.com. All rights reserved.
//

#import "CSCrash.h"

#include <execinfo.h>
#import <UIKit/UIKit.h>
#import "sys/utsname.h"

@implementation CSCrash

{
    void(^completeBlock)(NSString *name, NSString *reason, NSArray *callStack);
    BOOL willSave;
}

static CSCrash *instance = nil;

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[[self class] alloc] init];
    });
    return instance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [super allocWithZone:zone];
    });
    return instance;
}

+ (void)startUncaughtExceptionHandler:(void (^)(NSString *, NSString *, NSArray *))completion
{
    instance = [self sharedInstance];
    
    instance->completeBlock = completion;
    
    // 设置异常处理方法
    NSSetUncaughtExceptionHandler(HandleUncaughtException);
    
    // 设置信号异常处理方法
    SetSignalExceptionHandler();
}

+ (void)needWriteExceptionFile:(BOOL)isNeeded
{
    instance = [self sharedInstance];
    
    instance->willSave = isNeeded;
}

void HandleUncaughtException(NSException *exception)
{
    NSString *name = exception.name;
    NSString *reason = exception.reason;
    NSArray *callStack = exception.callStackSymbols;
    
    instance->completeBlock(name, reason, callStack);
    
    if (instance->willSave)
        [CSCrash saveExceptionName:name reason:reason callStackInfo:callStack];
}

void SetSignalExceptionHandler()
{
    // SIGHUP: 本信号在用户终端连接(正常或非正常)结束时发出, 通常是在终端的控制进程结束时, 通知同一session内的各个作业, 这时它们与控制终端不再关联
    signal(SIGHUP, HandleSignalException);
    // SIGINT: 程序终止(interrupt)信号, 在用户键入INTR字符(通常是Ctrl-C)时发出, 用于通知前台进程组终止进程
    signal(SIGINT, HandleSignalException);
    // SIGQUIT: 和SIGINT类似, 但由QUIT字符(通常是Ctrl-\)来控制, 进程在因收到SIGQUIT退出时会产生core文件, 在这个意义上类似于一个程序错误信号
    signal(SIGQUIT, HandleSignalException);
    // SIGILL: 执行了非法指令, 通常是因为可执行文件本身出现错误, 或者试图执行数据段, 堆栈溢出时也有可能产生这个信号
    signal(SIGILL, HandleSignalException);
    // SIGTRAP: 由断点指令或其它trap指令产生, 由debugger使用
    signal(SIGTRAP, HandleSignalException);
    // SIGABRT: 调用abort()生成的信号
    signal(SIGABRT, HandleSignalException);
    // SIGFPE: 在发生致命的算术运算错误时发出, 不仅包括浮点运算错误, 还包括溢出及除数为0等其它所有的算术的错误
    signal(SIGFPE, HandleSignalException);
    // SIGKILL: 用来立即结束程序的运行, 本信号不能被阻塞、处理和忽略。如果管理员发现某个进程终止不了，可尝试发送这个信号
    signal(SIGKILL, HandleSignalException);
    // SIGBUS: 非法地址, 包括内存地址对齐出错, 比如访问一个四个字长的整数, 但其地址不是4的倍数
    // 它与SIGSEGV的区别在于后者是由于对合法存储地址的非法访问触发的(如访问不属于自己存储空间或只读存储空间)
    signal(SIGBUS, HandleSignalException);
    // SIGSEGV: 试图访问未分配给自己的内存, 或试图往没有写权限的内存地址写数据
    signal(SIGSEGV, HandleSignalException);
    // SIGSYS: 非法的系统调用
    signal(SIGSYS, HandleSignalException);
    // SIGPIPE: 管道破裂, 这个信号通常在进程间通信产生, 比如采用FIFO(管道)通信的两个进程, 读管道没打开或者意外终止就往管道写, 写进程会收到SIGPIPE信号, 此外用Socket通信的两个进程, 写进程在写Socket的时候, 读进程已经终止
    signal(SIGPIPE, HandleSignalException);
    // SIGALRM: 时钟定时信号, 计算的是实际的时间或时钟时间, alarm()使用该信号
    signal(SIGALRM, HandleSignalException);
    // SIGTERM: 程序结束(terminate)信号, 与SIGKILL不同的是该信号可以被阻塞和处理, 通常用来要求程序自己正常退出, shell命令kill缺省产生这个信号, 如果进程终止不了, 我们才会尝试SIGKILL
    signal(SIGTERM, HandleSignalException);
    // SIGURG: 有"紧急"数据或out-of-band数据到达socket时产生
    signal(SIGURG, HandleSignalException);
    // SIGSTOP: 停止(stopped)进程的执行, 注意它和terminate以及interrupt的区别: 该进程还未结束, 只是暂停执行, 本信号不能被阻塞, 处理或忽略
    signal(SIGSTOP, HandleSignalException);
    // SIGTSTP: 停止进程的运行, 但该信号可以被处理和忽略, 用户键入SUSP字符时(通常是Ctrl-Z)发出这个信号
    signal(SIGTSTP, HandleSignalException);
    // SIGCONT: 让一个停止(stopped)的进程继续执行, 本信号不能被阻塞, 可以用一个handler来让程序在由stopped状态变为继续执行时完成特定的工作, 例如, 重新显示提示符
    signal(SIGCONT, HandleSignalException);
    // SIGCHLD: 子进程结束时, 父进程会收到这个信号
    signal(SIGCHLD, HandleSignalException);
    // SIGTTIN: 当后台作业要从用户终端读数据时, 该作业中的所有进程会收到SIGTTIN信号, 缺省时这些进程会停止执行
    signal(SIGTTIN, HandleSignalException);
    // SIGTTOU: 类似于SIGTTIN, 但在写终端(或修改终端模式)时收到
    signal(SIGTTOU, HandleSignalException);
    // SIGXCPU: 超过CPU时间资源限制, 这个限制可以由getrlimit/setrlimit来读取/改变
    signal(SIGXCPU, HandleSignalException);
    // SIGXFSZ: 当进程企图扩大文件以至于超过文件大小资源限制
    signal(SIGXFSZ, HandleSignalException);
    // SIGVTALRM: 虚拟时钟信号. 类似于SIGALRM, 但是计算的是该进程占用的CPU时间
    signal(SIGVTALRM, HandleSignalException);
    // SIGPROF: 类似于SIGALRM/SIGVTALRM, 但包括该进程用的CPU时间以及系统调用的时间
    signal(SIGPROF, HandleSignalException);
}

void HandleSignalException(int signal)
{
    NSString *reason = nil;
    switch (signal) {
        case SIGHUP:
            reason = [NSString stringWithFormat:@"Signal SIGHUP was raised!\n"];
            break;
        case SIGINT:
            reason = [NSString stringWithFormat:@"Signal SIGINT was raised!\n"];
            break;
        case SIGQUIT:
            reason = [NSString stringWithFormat:@"Signal SIGQUIT was raised!\n"];
            break;
        case SIGILL:
            reason = [NSString stringWithFormat:@"Signal SIGILL was raised!\n"];
            break;
        case SIGTRAP:
            reason = [NSString stringWithFormat:@"Signal SIGTRAP was raised!\n"];
            break;
        case SIGABRT:
            reason = [NSString stringWithFormat:@"Signal SIGABRT was raised!\n"];
            break;
        case SIGFPE:
            reason = [NSString stringWithFormat:@"Signal SIGFPE was raised!\n"];
            break;
        case SIGKILL:
            reason = [NSString stringWithFormat:@"Signal SIGKILL was raised!\n"];
            break;
        case SIGBUS:
            reason = [NSString stringWithFormat:@"Signal SIGBUS was raised!\n"];
            break;
        case SIGSEGV:
            reason = [NSString stringWithFormat:@"Signal SIGSEGV was raised!\n"];
            break;
        case SIGSYS:
            reason = [NSString stringWithFormat:@"Signal SIGSYS was raised!\n"];
            break;
        case SIGPIPE:
            reason = [NSString stringWithFormat:@"Signal SIGPIPE was raised!\n"];
            break;
        case SIGALRM:
            reason = [NSString stringWithFormat:@"Signal SIGALRM was raised!\n"];
            break;
        case SIGTERM:
            reason = [NSString stringWithFormat:@"Signal SIGTERM was raised!\n"];
            break;
        case SIGURG:
            reason = [NSString stringWithFormat:@"Signal SIGURG was raised!\n"];
            break;
        case SIGSTOP:
            reason = [NSString stringWithFormat:@"Signal SIGSTOP was raised!\n"];
            break;
        case SIGTSTP:
            reason = [NSString stringWithFormat:@"Signal SIGTSTP was raised!\n"];
            break;
        case SIGCONT:
            reason = [NSString stringWithFormat:@"Signal SIGCONT was raised!\n"];
            break;
        case SIGCHLD:
            reason = [NSString stringWithFormat:@"Signal SIGCHLD was raised!\n"];
            break;
        case SIGTTIN:
            reason = [NSString stringWithFormat:@"Signal SIGTTIN was raised!\n"];
            break;
        case SIGTTOU:
            reason = [NSString stringWithFormat:@"Signal SIGTTOU was raised!\n"];
            break;
        case SIGXCPU:
            reason = [NSString stringWithFormat:@"Signal SIGXCPU was raised!\n"];
            break;
        case SIGXFSZ:
            reason = [NSString stringWithFormat:@"Signal SIGXFSZ was raised!\n"];
            break;
        case SIGVTALRM:
            reason = [NSString stringWithFormat:@"Signal SIGVTALRM was raised!\n"];
            break;
        case SIGPROF:
            reason = [NSString stringWithFormat:@"Signal SIGPROF was raised!\n"];
            break;
        default:
            reason = [NSString stringWithFormat:@"Signal %d was raised!",signal];
    }
    
    NSString *name = @"SignalException";
    NSArray *callStack = [CSCrash backtrace];
    
    instance->completeBlock(name, reason, callStack);
    
    if (instance->willSave)
        [CSCrash saveExceptionName:name reason:reason callStackInfo:callStack];
}

// 获取调用堆栈
+ (NSArray *)backtrace
{
    // 指针列表
    void *callstack[128];
    // backtrace用来获取当前线程的调用堆栈，获取的信息存放在这里的callstack中
    // 128用来指定当前的buffer中可以保存多少个void *元素
    // 返回值是实际获取的指针个数
    int frames = backtrace(callstack, 128);
    // backtrace_symbols将从backtrace函数获取的信息转化为一个字符串数组
    // 返回一个指向字符串数组的指针
    // 每个字符串包含了一个相对于callstack中对应元素的可打印信息，包括函数名、偏移地址、实际返回地址
    char **strs = backtrace_symbols(callstack, frames);
    
    int i;
    NSMutableArray *backtrace = [NSMutableArray arrayWithCapacity:frames];
    for (i = 0; i < frames; i ++)
    {
        [backtrace addObject:[NSString stringWithUTF8String:strs[i]]];
    }
    free(strs);
    
    return backtrace;
}

// 保存异常信息
+ (void)saveExceptionName:(NSString *)name
                   reason:(NSString *)reason
            callStackInfo:(NSArray *)callStack
{
    NSString *userDate = [self getUserDate];
    NSString *systemInfo = [self getSystemInfo];
    NSString *deviceModel = [self getDeviceModel];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [paths objectAtIndex:0];
    NSString *newDocDir = [docDir stringByAppendingPathComponent:@"/CrashLog"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath:newDocDir])
    {
        [fileManager createDirectoryAtPath:newDocDir
               withIntermediateDirectories:YES
                                attributes:nil
                                     error:nil];
    }
    
    NSString *logName = [NSString stringWithFormat:@"%@.log", userDate];
    NSString *logPath = [newDocDir stringByAppendingPathComponent:logName];
    
    NSString *content = [NSString stringWithFormat:@"%@\n%@\n%@\n%@\n%@\n%@", name, reason, callStack, userDate, systemInfo, deviceModel];
    
    [fileManager createFileAtPath:logPath
                         contents:[content dataUsingEncoding:NSUTF8StringEncoding]
                       attributes:nil];
}

+ (NSString *)getUserDate
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    formatter.dateFormat =@"yyyy-MM-dd HH:mm:ss";
    NSString * userDate =[formatter stringFromDate:[NSDate date]];
    
    return userDate;
}

+ (NSString *)getSystemInfo
{
    NSString *systemName = [[UIDevice currentDevice] systemName];
    systemName = [systemName stringByAppendingString:[[UIDevice currentDevice] systemVersion]];
    return systemName;
}

+ (NSString *)getDeviceModel
{
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *deviceModel = [NSString stringWithCString:systemInfo.machine
                                                encoding:NSUTF8StringEncoding];
    return deviceModel;
}

@end
