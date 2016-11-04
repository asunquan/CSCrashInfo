# CSCrashInfo
Get exception info which caused appliaction crash, only call one method, what others CSCrash will do. 

一个辅助捕获程序崩溃信息的小玩意, 使用时只需调用一个方法即可.

/**
 *      启动异常日志捕捉器
 */
+ (void)startUncaughtExceptionHandler:(void(^)(NSString *name, NSString *reason, NSArray *callStack))completion;

回调信息解释
name: 崩溃异常信息名如NSRangException
reason: 导致崩溃异常发生的原因
callStack: 此时的堆栈信息

/**
 *      是否需要将异常日志写到本地
 */
+ (void)needWriteExceptionFile:(BOOL)isNeeded;

默认为NO, 如需写入可以设置为YES, 可以根据情况自行修改写入文件的具体内容.
