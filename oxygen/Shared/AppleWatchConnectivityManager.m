//
//  AppleWatchConnectivityManager.m
//  oxygen
//
//  Created by jia yu on 2021/12/27.
//

#import "AppleWatchConnectivityManager.h"

AppleWatchConnectivityManager *sharedObject;

@implementation AppleWatchConnectivityManager
#if TARGET_OS_IOS
//+(AppleWatchConnectivityManager *)shared{
//    if (nil == sharedObject){
//        sharedObject = [[AppleWatchConnectivityManager alloc] init];
//    }
//    return sharedObject;
//}
#else
#endif

+(AppleWatchConnectivityManager *)shared{
    if (nil == sharedObject){
        sharedObject = [[AppleWatchConnectivityManager alloc] init];
    }
    return sharedObject;
}


@end
