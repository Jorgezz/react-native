//
//  NSDate+Format.m
//  KRNSDK_Example
//
//  Created by jiaozhiyu on 2021/5/27.
//  Copyright © 2021 lilely. All rights reserved.
//

#import "NSDate+Format.h"

@interface KSDateFormatterHelper : NSObject
@property (nonatomic, strong) NSDateFormatter *sharedFormatter;
@end

@implementation KSDateFormatterHelper

+ (instancetype)sharedInstance {
    static KSDateFormatterHelper *helper = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        helper = [[KSDateFormatterHelper alloc] init];
        helper.sharedFormatter = [[NSDateFormatter alloc] init];
        [helper.sharedFormatter setLocale:[NSLocale currentLocale]];
    });
    return helper;
}

@end

@implementation NSDate (Format)

- (NSString *)stringWithFormat:(NSString *)format {
    NSDateFormatter *formatter = [KSDateFormatterHelper sharedInstance].sharedFormatter;
    [formatter setDateFormat:format];
    return [formatter stringFromDate:self];
}

@end

