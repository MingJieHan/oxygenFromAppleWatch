//
//  AppleWatchConnectivityManager.h
//  oxygen
//
//  Created by jia yu on 2021/12/27.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AppleWatchConnectivityManager : NSObject
#if TARGET_OS_IOS
+(AppleWatchConnectivityManager *)shared;
#else
+(AppleWatchConnectivityManager *)shared;
#endif
@end
NS_ASSUME_NONNULL_END
