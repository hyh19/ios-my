#ifdef DEBUG
#define ZWLog(format,...)    NSLog(format,##__VA_ARGS__)
#else
#define ZWLog(format,...)    (void)0
#endif

