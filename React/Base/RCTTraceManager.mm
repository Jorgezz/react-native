//
//  TraceManager.m
//  RNTester
//
//  Created by jiaozhiyu on 2021/4/25.
//  Copyright © 2021 Facebook. All rights reserved.
//

#import "RCTTraceManager.h"
#include <base/MiniTrace.h>

@implementation RCTTraceManager

+ (instancetype)sharedManager {
  static RCTTraceManager *sharedInstance;
  static dispatch_once_t once_token;
  dispatch_once(&once_token, ^{
    sharedInstance = [RCTTraceManager new];
  });
  return sharedInstance;
}

- (void)init:(NSString *)path {
  facebook::react::mtr_init(path.UTF8String);
}

- (void)start {
  facebook::react::mtr_start();
}

- (void)finish {
  facebook::react::mtr_shutdown();
}

- (void)begin:(NSString *)name {
  [RCTTraceManager.sharedManager begin:@"main" name:name key:@"" value:@""];
}

- (void)begin:(NSString *)category name:(NSString *)name {
  [RCTTraceManager.sharedManager begin:category name:name key:@"" value:@""];
}

- (void)begin:(NSString *)category name:(NSString *)name key:(NSString *)key value:(NSString *)value {
  if (key.length == 0 || value.length ==0) {
    facebook::react::internal_mtr_raw_event(category.UTF8String, name.UTF8String, 'B', 0);
  } else {
    facebook::react::internal_mtr_raw_event_arg(category.UTF8String, name.UTF8String, 'B', 0, facebook::react::MTR_ARG_TYPE_STRING_COPY, key.UTF8String, &value);
  }
}

- (void)end:(NSString *)name {
    [RCTTraceManager.sharedManager end:@"main" name:name];
}

- (void)end:(NSString *)category name:(NSString *)name {
  facebook::react::internal_mtr_raw_event(category.UTF8String, name.UTF8String, 'E', 0);
}

- (void)instant:(NSString *)category name:(NSString *)name {
  facebook::react::internal_mtr_raw_event(category.UTF8String, name.UTF8String, 'I', 0);
}

- (void)asyncBegin:(NSString *)name identifier:(NSString *)identifier {
  [self asyncBegin:@"main" name:name identifier:identifier];
}

- (void)asyncBegin:(NSString *)category name:(NSString *)name identifier:(NSString *)identifier {
  facebook::react::internal_mtr_raw_event(category.UTF8String, name.UTF8String, 's', &identifier);
}

- (void)asyncEnd:(NSString *)name identifier:(NSString *)identifier {
  [self asyncEnd:@"main" name:name identifier:identifier];
}

- (void)asyncEnd:(NSString *)category name:(NSString *)name identifier:(NSString *)identifier {
  facebook::react::internal_mtr_raw_event(category.UTF8String, name.UTF8String, 'f', &identifier);
}

- (void)setProcessName:(NSString *)name {
    facebook::react::internal_mtr_raw_event_arg("", "process_name", 'M', 0, facebook::react::MTR_ARG_TYPE_STRING_COPY, "name", (void *)name.UTF8String);
}

- (void)setThreadName:(NSString *)name {
    facebook::react::internal_mtr_raw_event_arg("", "thread_name", 'M', 0, facebook::react::MTR_ARG_TYPE_STRING_COPY, "name", (void *)name.UTF8String);
}

@end
