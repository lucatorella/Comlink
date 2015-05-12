//
//  COMNotificationHelper.h
//  Comlink
//
//  Created by Luca Torella on 11/04/2015.
//

@import CoreFoundation;
@import Foundation;

/**
 This class is used to handle CFNotificationCenter callback which requires a plain C function.
 This class is considered internal to the framework and shouldn't be used.
 */

NS_ASSUME_NONNULL_BEGIN

@interface COMNotificationHelper : NSObject

+ (void)registerForNotificationsWithIdentifier:(NSString *)identifier;
+ (void)unregisterForNotificationsWithIdentifier:(NSString *)identifier;
+ (void)unregisterForEveryNotification;
+ (void)sendNotificationWithIdentifier:(NSString *)identifier;

@end

NS_ASSUME_NONNULL_END
