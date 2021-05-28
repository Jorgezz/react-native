//
//  KRNHomeViewController.h
//  KRNSDK_Example
//
//  Created by jiaozhiyu on 2021/4/18.
//  Copyright © 2021 lilely. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RCTBridge, RCTTurboModuleManager;

NS_ASSUME_NONNULL_BEGIN

@interface KRNHomeViewController : UIViewController
@property (nonatomic, readwrite) RCTBridge *bridge;
@end

NS_ASSUME_NONNULL_END
