/*
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "AppDelegate.h"

#import <React/RCTLinkingManager.h>

#if !TARGET_OS_TV && !TARGET_OS_UIKITFORMAC
#import <React/RCTPushNotificationManager.h>
#endif

#import <React/RCTTraceManager.h>
#include <sys/time.h>
#include <base/MiniTrace.h>
#import "NSDate+Format.h"

@implementation AppDelegate

- (void)startTracing {
    NSDictionary *appInfo = [[NSBundle mainBundle] infoDictionary];
    NSString *traceName = @"";
  #if DEBUG || BETA
    traceName = [appInfo[@"CFBundleDisplayName"] stringByAppendingFormat:@"%@_%@.json", @"_debug_trace_", [[NSDate date] stringWithFormat: @"YYYY-MM-dd-HH_mm_ss"]];
  #else
    traceName = [appInfo[@"CFBundleDisplayName"] stringByAppendingFormat:@"%@_%@.json", @"_release_trace_", [[NSDate date] stringWithFormat: @"YYYY-MM-dd-HH_mm_ss"]];
  #endif
    [RCTTraceManager.sharedManager init:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:traceName]];
    [[RCTTraceManager sharedManager] start];
}

- (BOOL)application:(__unused UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  [self startTracing];
  [RCTTraceManager.sharedManager start];
  [RCTTraceManager.sharedManager setThreadName:@"main-thread"];

  [RCTTraceManager.sharedManager begin:@"AppDelegate::didFinishLaunchingWithOptions"];

  RCTEnableTurboModule(YES);
  
  self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
  
  [RCTTraceManager.sharedManager begin:@"AppDelegate::window::attachRootView"];

  _rootVC = [[KRNHomeViewController alloc] init];
  UINavigationController *navRoot = [[UINavigationController alloc] initWithRootViewController:_rootVC];
  navRoot.navigationBar.hidden = NO;
  [self.window setRootViewController:navRoot];
  [self.window makeKeyAndVisible];
  [RCTTraceManager.sharedManager end:@"AppDelegate::window::attachRootView"];

  [RCTTraceManager.sharedManager end:@"AppDelegate::didFinishLaunchingWithOptions"];
  return YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
  [RCTTraceManager.sharedManager finish];
}

- (BOOL)application:(UIApplication *)app
            openURL:(NSURL *)url
            options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options
{
  return [RCTLinkingManager application:app openURL:url options:options];
}

#pragma mark - Push Notifications
#if !TARGET_OS_TV && !TARGET_OS_UIKITFORMAC

// Required to register for notifications
- (void)application:(__unused UIApplication *)application
    didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
  [RCTPushNotificationManager didRegisterUserNotificationSettings:notificationSettings];
}

// Required for the remoteNotificationsRegistered event.
- (void)application:(__unused UIApplication *)application
    didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
  [RCTPushNotificationManager didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
}

// Required for the remoteNotificationRegistrationError event.
- (void)application:(__unused UIApplication *)application
    didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
  [RCTPushNotificationManager didFailToRegisterForRemoteNotificationsWithError:error];
}

// Required for the remoteNotificationReceived event.
- (void)application:(__unused UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)notification
{
  [RCTPushNotificationManager didReceiveRemoteNotification:notification];
}

// Required for the localNotificationReceived event.
- (void)application:(__unused UIApplication *)application
    didReceiveLocalNotification:(UILocalNotification *)notification
{
  [RCTPushNotificationManager didReceiveLocalNotification:notification];
}

#endif

@end
