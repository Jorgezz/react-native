//
//  TraceManager.h
//  RNTester
//
//  Created by jiaozhiyu on 2021/4/25.
//  Copyright © 2021 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#define USE_MAIN_QUEUE 1

@interface RCTTraceManager : NSObject

+ (instancetype)sharedManager;

- (void)init:(NSString *)path;
- (void)start;
- (void)finish;
- (void)begin:(NSString *)name;
- (void)begin:(NSString *)category name:(NSString *)name;
- (void)begin:(NSString *)category name:(NSString *)name key:(NSString *)key value:(NSString *)value;
- (void)end:(NSString *)name;
- (void)end:(NSString *)category name:(NSString *)name;
- (void)instant:(NSString *)category name:(NSString *)name;
- (void)asyncBegin:(NSString *)name identifier:(NSString *)identifier;
- (void)asyncBegin:(NSString *)category name:(NSString *)name identifier:(NSString *)identifier;
- (void)asyncEnd:(NSString *)name identifier:(NSString *)identifier;
- (void)asyncEnd:(NSString *)category name:(NSString *)name identifier:(NSString *)identifier;
- (void)setProcessName:(NSString *)name;
- (void)setThreadName:(NSString *)name;

@end

NS_ASSUME_NONNULL_END
