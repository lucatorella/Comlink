//
//  COMNotificationHandler.m
//  Comlink
//
//  Created by Luca Torella on 11/04/2015.
//

#import "COMNotificationHelper.h"

static NSString * const ComlinkNotificationName = @"ComlinkNotificationName";

/*
 From Apple documentation: Notification delivery is registered for the main thread.
 */

static void notificationCallback(CFNotificationCenterRef center,
                                 void * observer,
                                 CFStringRef name,
                                 void const * object,
                                 CFDictionaryRef userInfo) {
    NSString *identifier = (__bridge NSString *)name;
    [[NSNotificationCenter defaultCenter] postNotificationName:ComlinkNotificationName
                                                        object:nil
                                                      userInfo:@{@"identifier" : identifier}];
}

@implementation COMNotificationHelper

+ (void)registerForNotificationsWithIdentifier:(NSString * __nonnull)identifier {
    CFNotificationCenterRef const center = CFNotificationCenterGetDarwinNotifyCenter();
    CFStringRef str = (__bridge CFStringRef)identifier;
    CFNotificationCenterAddObserver(center,
                                    (__bridge const void *)(self),
                                    notificationCallback,
                                    str,
                                    NULL,
                                    CFNotificationSuspensionBehaviorDeliverImmediately);
}

+ (void)unregisterForNotificationsWithIdentifier:(NSString * __nonnull)identifier {
    CFNotificationCenterRef const center = CFNotificationCenterGetDarwinNotifyCenter();
    CFStringRef str = (__bridge CFStringRef)identifier;
    CFNotificationCenterRemoveObserver(center,
                                       (__bridge const void *)(self),
                                       str,
                                       NULL);
}

+ (void)unregisterForEveryNotification
{
    CFNotificationCenterRef const center = CFNotificationCenterGetDarwinNotifyCenter();
    CFNotificationCenterRemoveEveryObserver(center, (__bridge const void *)(self));
}

+ (void)sendNotificationWithIdentifier:(NSString * __nonnull)identifier {
    CFNotificationCenterRef const center = CFNotificationCenterGetDarwinNotifyCenter();
    CFDictionaryRef const userInfo = NULL;
    BOOL const deliverImmediately = YES;
    CFStringRef str = (__bridge CFStringRef)identifier;
    CFNotificationCenterPostNotification(center, str, NULL, userInfo, deliverImmediately);
}

@end
