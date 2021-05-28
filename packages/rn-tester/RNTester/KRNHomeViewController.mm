//
//  KRNHomeViewController.m
//  KRNSDK_Example
//
//  Created by jiaozhiyu on 2021/4/18.
//  Copyright © 2021 lilely. All rights reserved.
//

#import "KRNHomeViewController.h"

#ifndef RCT_USE_HERMES
#if __has_include(<hermes/hermes.h>)
#define RCT_USE_HERMES 1
#else
#define RCT_USE_HERMES 0
#endif
#endif

#if RCT_USE_HERMES
#import <reacthermes/HermesExecutorFactory.h>
#else
#import <React/JSCExecutorFactory.h>
#endif

#import <React/RCTBridge.h>
#import <React/RCTBundleURLProvider.h>
#import <React/RCTCxxBridgeDelegate.h>
#import <React/RCTDataRequestHandler.h>
#import <React/RCTFileRequestHandler.h>
#import <React/RCTGIFImageDecoder.h>
#import <React/RCTHTTPRequestHandler.h>
#import <React/RCTImageLoader.h>
#import <React/RCTJSIExecutorRuntimeInstaller.h>
#import <React/RCTJavaScriptLoader.h>
//#import <React/RCTLinkingManager.h>
#import <React/RCTLocalAssetImageLoader.h>
#import <React/RCTNetworking.h>
#import <React/RCTRootView.h>

#import <cxxreact/JSExecutor.h>

#if !TARGET_OS_TV && !TARGET_OS_UIKITFORMAC
#import <React/RCTPushNotificationManager.h>
#endif

#ifdef RN_FABRIC_ENABLED
#import <React/RCTFabricSurfaceHostingProxyRootView.h>
#import <React/RCTSurfacePresenter.h>
#import <React/RCTSurfacePresenterBridgeAdapter.h>

#import <react/config/ReactNativeConfig.h>
#endif

#import <ReactCommon/RCTTurboModuleManager.h>
#import "RNTesterTurboModuleProvider.h"

#import <React/RCTTraceManager.h>
#include <sys/time.h>
#include <base/MiniTrace.h>
#import "NSDate+Format.h"

@interface KRNHomeViewController ()<RCTCxxBridgeDelegate, RCTTurboModuleManagerDelegate> {
#ifdef RN_FABRIC_ENABLED
  RCTSurfacePresenterBridgeAdapter *_bridgeAdapter;
  std::shared_ptr<const facebook::react::ReactNativeConfig> _reactNativeConfig;
  facebook::react::ContextContainer::Shared _contextContainer;
#endif

  RCTTurboModuleManager *_turboModuleManager;
}
@property (nonatomic) UIAlertController *alertController;
@property (nonatomic) UIColor *buttonColor;
@property (nonatomic) UILabel *alertTipsLabel;
@end

@implementation KRNHomeViewController

- (void)viewDidLoad {
  self.title = @"KDS Demo";
  [super viewDidLoad];
  self.view.backgroundColor = UIColor.whiteColor;
  _buttonColor = [UIColor.blackColor colorWithAlphaComponent:0.2];
  [self addTip];
  [self addOpenKrnPageButton];
  [self addSplitLine];
  [self addPreloadButton];
  [self addHotOpenKrnPageButton];
}

- (void)addTip {
  UILabel *userNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 74, 50, 20)];
  userNameLabel.font = [UIFont systemFontOfSize:15];
  userNameLabel.textColor = UIColor.darkGrayColor;
  [userNameLabel setText:@"测试："];
  [self.view addSubview:userNameLabel];
}

- (void)addSplitLine {
  UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 150, UIScreen.mainScreen.bounds.size.width, 1.0)];
  line.backgroundColor = _buttonColor;
  [self.view addSubview:line];
}

#pragma mark - buttons
- (void)addOpenKrnPageButton {
  UIButton *openKRNBtn = [self createButton:@"冷起测试-启动"
                                     action:@selector(coldOpenKrnPage)];
  openKRNBtn.frame = CGRectMake(10, 100, 110, 40);
  [self.view addSubview:openKRNBtn];
}

- (void)addPreloadButton {
  UIButton *preloadEngineBtn = [self createButton:@"热启第1步-预热(点击等5秒)"
                                           action:@selector(preloadEngine)];
  preloadEngineBtn.frame = CGRectMake(10, 160, 210, 40);
  [self.view addSubview:preloadEngineBtn];
}

- (void)addHotOpenKrnPageButton {
  UIButton *hotOpenKRNBtn = [self createButton:@"热启第2步-启动"
                                        action:@selector(hotOpenKrnPage)];
  hotOpenKRNBtn.frame = CGRectMake(10, 205, 125, 40);
  [self.view addSubview:hotOpenKRNBtn];
}

- (UIButton *)createButton:(NSString *)title
                    action:(SEL)action {
  return [self createButton:title titlColor:nil btnColor:nil fontSize:0 action:action];
}

- (UIButton *)createButton:(NSString *)title
                 titlColor:(UIColor *)titleColor
                  btnColor:(UIColor *)btnColor
                  fontSize:(CGFloat)fontSize
                    action:(SEL)action {
  UIButton *customButton = [UIButton buttonWithType:UIButtonTypeCustom];
  customButton.backgroundColor = titleColor ?: _buttonColor;
  [customButton setTitle:title forState:UIControlStateNormal];
  [customButton setTitleColor:titleColor ?: UIColor.blackColor forState:UIControlStateNormal];
  customButton.titleLabel.font = [UIFont systemFontOfSize:fontSize !=0 ? fontSize : 15];
  customButton.titleLabel.textAlignment = NSTextAlignmentLeft;
  [customButton addTarget:self
                   action:action
         forControlEvents:UIControlEventTouchUpInside];
  return customButton;
}

#pragma mark - actions
- (void)coldOpenKrnPage {
  [self showTips:@"RNTester Demo cold test!"];
  [RCTTraceManager.sharedManager begin:@"KRNHomeViewController::coldOpenKrnPage"];
  [self preloadEngine];
  NSDictionary *initProps = @{};
  NSString *_routeUri = [[NSUserDefaults standardUserDefaults] stringForKey:@"route"];
  if (_routeUri) {
    initProps =
        @{@"exampleFromAppetizeParams" : [NSString stringWithFormat:@"rntester://example/%@Example", _routeUri]};
  }
  UIView *rootView = [[RCTRootView alloc] initWithBridge:self.bridge moduleName:@"RNTesterApp" initialProperties:initProps];
  UIViewController *rootViewController = [UIViewController new];
  rootViewController.view = rootView;
  [RCTTraceManager.sharedManager end:@"KRNHomeViewController::coldOpenKrnPage"];
  t1_rn_launch_cost = [[NSDate date] timeIntervalSince1970];
  NSLog(@"t1 start: %f \n",  t1_rn_launch_cost);
  [self.navigationController pushViewController:rootViewController animated:YES];

}

NSTimeInterval t1_rn_preload_launch_cost = 0;
- (void)preloadEngine {
  [RCTTraceManager.sharedManager begin:@"KRNHomeViewController::preloadEngine"];

  [self showTips:@"RN Engine preload start!"];
  
  [RCTTraceManager.sharedManager begin:@"RCTBridge::Create"];
  _bridge = [[RCTBridge alloc] initWithDelegate:self launchOptions:nil];
  [RCTTraceManager.sharedManager end:@"RCTBridge::Create"];
  
  struct timeval tv;
  gettimeofday(&tv, NULL);
  between_bridge_create_and_run_bundle_js = tv.tv_sec*1000000.0 + tv.tv_usec;

  t1_rn_preload_launch_cost = [[NSDate date] timeIntervalSince1970];
  NSLog(@"preloadEngine start: %f",  t1_rn_preload_launch_cost);
  NSLog(@"preloadEngine cost: %f", [[NSDate date] timeIntervalSince1970] - t1_rn_preload_launch_cost);
  
  //    [self showTips:@"Preload" message:@"RN Engine preload sucess" showCancel:NO];
  [self showTips:@"RN Engine preload sucess!"];
  [RCTTraceManager.sharedManager end:@"KRNHomeViewController::preloadEngine"];
}

- (void)hotOpenKrnPage {
  if (!_bridge) {
    [self showTips:@"Warning: has not preload before hot open page!"];
    //        [self showTips:@"warning:" message:@"has not preload before hot open page!" showCancel:NO];
  } else {
    NSDictionary *initProps = @{};
    NSString *_routeUri = [[NSUserDefaults standardUserDefaults] stringForKey:@"route"];
    if (_routeUri) {
      initProps =
          @{@"exampleFromAppetizeParams" : [NSString stringWithFormat:@"rntester://example/%@Example", _routeUri]};
    }
    UIView *rootView = [[RCTRootView alloc] initWithBridge:_bridge moduleName:@"RNTesterApp" initialProperties:initProps];
    UIViewController *rootViewController = [UIViewController new];
    rootViewController.view = rootView;
    [self.navigationController pushViewController:rootViewController animated:YES];
  }
}

#pragma mark - tips alert
- (void)showTips:(NSString *)message {
  [self removeTips];
  self.alertTipsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, 100)];
  self.alertTipsLabel.adjustsFontSizeToFitWidth = YES;
  self.alertTipsLabel.font = [UIFont systemFontOfSize:15];
  self.alertTipsLabel.textColor = UIColor.darkGrayColor;
  self.alertTipsLabel.textAlignment = NSTextAlignmentCenter;
  CGRect rect = self.alertTipsLabel.frame;
  rect.origin.y = UIScreen.mainScreen.bounds.size.height * 0.8;
  self.alertTipsLabel.frame = rect;
  [self.alertTipsLabel setText:message];
  [self.view layoutIfNeeded];
  [self.view addSubview:self.alertTipsLabel];
}

- (void)removeTips {
  [self.alertTipsLabel removeFromSuperview];
}

- (void)showTips:(NSString *)title message:(NSString *)message showCancel:(BOOL)cancelShow {
  UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                           message:message
                                                                    preferredStyle:UIAlertControllerStyleAlert];
  if (cancelShow) {
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
      NSLog(@"action: %@", action);
    }];
    [alertController addAction:cancelAction];
  }
  UIAlertAction *resetAction = [UIAlertAction actionWithTitle:@"I have known" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
    NSLog(@"action: %@", action);
  }];
  [alertController addAction:resetAction];
  _alertController = alertController;
  [self presentViewController:alertController animated:YES completion:NULL];
}

- (NSURL *)sourceURLForBridge:(__unused RCTBridge *)bridge
{
//  NSURL *sourceUrl = [NSURL URLWithString:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:@"main.jsbundle"]];
//  return sourceUrl;
  return [[RCTBundleURLProvider sharedSettings] jsBundleURLForBundleRoot:@"packages/rn-tester/js/RNTesterApp.ios"
                                                        fallbackResource:nil];
}

- (void)loadSourceForBridge:(RCTBridge *)bridge
                 onProgress:(RCTSourceLoadProgressBlock)onProgress
                 onComplete:(RCTSourceLoadBlock)loadCallback
{
  [RCTJavaScriptLoader loadBundleAtURL:[self sourceURLForBridge:bridge] onProgress:onProgress onComplete:loadCallback];
}

#pragma mark - RCTCxxBridgeDelegate
- (std::unique_ptr<facebook::react::JSExecutorFactory>)jsExecutorFactoryForBridge:(RCTBridge *)bridge
{
  _turboModuleManager = [[RCTTurboModuleManager alloc] initWithBridge:bridge
                                                             delegate:self
                                                            jsInvoker:bridge.jsCallInvoker];
  [bridge setRCTTurboModuleRegistry:_turboModuleManager];

#if RCT_DEV
  /**
   * Eagerly initialize RCTDevMenu so CMD + d, CMD + i, and CMD + r work.
   * This is a stop gap until we have a system to eagerly init Turbo Modules.
   */
  [_turboModuleManager moduleForName:"RCTDevMenu"];
#endif

  __weak __typeof(self) weakSelf = self;
#if RCT_USE_HERMES
  return std::make_unique<facebook::react::HermesExecutorFactory>(
#else
  return std::make_unique<facebook::react::JSCExecutorFactory>(
#endif
      facebook::react::RCTJSIExecutorRuntimeInstaller([weakSelf, bridge](facebook::jsi::Runtime &runtime) {
        if (!bridge) {
          return;
        }
        __typeof(self) strongSelf = weakSelf;
        if (strongSelf) {
          facebook::react::RuntimeExecutor syncRuntimeExecutor =
              [&](std::function<void(facebook::jsi::Runtime & runtime_)> &&callback) { callback(runtime); };
          [strongSelf->_turboModuleManager installJSBindingWithRuntimeExecutor:syncRuntimeExecutor];
        }
      }));
}

#pragma mark RCTTurboModuleManagerDelegate

- (Class)getModuleClassFromName:(const char *)name
{
  return facebook::react::RNTesterTurboModuleClassProvider(name);
}

- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:(const std::string &)name
                                                      jsInvoker:(std::shared_ptr<facebook::react::CallInvoker>)jsInvoker
{
  return facebook::react::RNTesterTurboModuleProvider(name, jsInvoker);
}

- (id<RCTTurboModule>)getModuleInstanceFromClass:(Class)moduleClass
{
  if (moduleClass == RCTImageLoader.class) {
    return [[moduleClass alloc] initWithRedirectDelegate:nil
        loadersProvider:^NSArray<id<RCTImageURLLoader>> *(RCTModuleRegistry * moduleRegistry) {
          return @ [[RCTLocalAssetImageLoader new]];
        }
        decodersProvider:^NSArray<id<RCTImageDataDecoder>> *(RCTModuleRegistry * moduleRegistry) {
          return @ [[RCTGIFImageDecoder new]];
        }];
  } else if (moduleClass == RCTNetworking.class) {
    return [[moduleClass alloc] initWithHandlersProvider:^NSArray<id<RCTURLRequestHandler>> *(RCTModuleRegistry * moduleRegistry) {
      return @[
        [RCTHTTPRequestHandler new],
        [RCTDataRequestHandler new],
        [RCTFileRequestHandler new],
      ];
    }];
  }
  // No custom initializer here.
  return [moduleClass new];
}



@end
