//
//  AppDelegate.m
//  ShareAndPay
//
//  Created by Abel on 16/9/5.
//  Copyright © 2016年 杨南. All rights reserved.
//

#import "AppDelegate.h"
//添加ShareSDK包预编译头
#import <ShareSDK/ShareSDK.h>
#import <ShareSDKConnector/ShareSDKConnector.h>

//腾讯开放平台（对应QQ和QQ空间）SDK头文件
#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/QQApiInterface.h>

//微信SDK头文件
#import "WXApi.h"

//新浪微博SDK头文件
#import "WeiboSDK.h"
//新浪微博SDK需要在项目Build Settings中的Other Linker Flags添加"-ObjC"
#import <AlipaySDK/AlipaySDK.h>

#define APP_ID          @"wx5f8edd9a7c93c0fc"               //APPID
#define APP_SECRET      @"8466f79b4f71d53cdd58a053eab87040" //appsecret

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [self setShareSDKKey];
    
    //注册微信支付
    [WXApi registerApp:APP_ID withDescription:@"CloudPurchaseEra"];
    
    return YES;
}
/*
 配置shareSDK
 */
- (void)setShareSDKKey
{
    /**
     *  设置ShareSDK的appKey，如果尚未在ShareSDK官网注册过App，请移步到http://mob.com/login 登录后台进行应用注册，
     *  在将生成的AppKey传入到此方法中。
     *  方法中的第二个第三个参数为需要连接社交平台SDK时触发，
     *  在此事件中写入连接代码。第四个参数则为配置本地社交平台时触发，根据返回的平台类型来配置平台信息。
     *  如果您使用的时服务端托管平台信息时，第二、四项参数可以传入nil，第三项参数则根据服务端托管平台来决定要连接的社交SDK。
     */
    [ShareSDK registerApp:@"iosv1101"
     
          activePlatforms:@[
                            @(SSDKPlatformTypeSinaWeibo),
                            @(SSDKPlatformTypeWechat),
                            @(SSDKPlatformTypeQQ)]
                 onImport:^(SSDKPlatformType platformType)
     {
         switch (platformType)
         {
             case SSDKPlatformTypeWechat:
                 [ShareSDKConnector connectWeChat:[WXApi class]];
                 break;
             case SSDKPlatformTypeQQ:
                 [ShareSDKConnector connectQQ:[QQApiInterface class] tencentOAuthClass:[TencentOAuth class]];
                 break;
             case SSDKPlatformTypeSinaWeibo:
                 [ShareSDKConnector connectWeibo:[WeiboSDK class]];
                 break;
             
             default:
                 break;
         }
     }
          onConfiguration:^(SSDKPlatformType platformType, NSMutableDictionary *appInfo)
     {
         switch (platformType)
         {
             case SSDKPlatformTypeSinaWeibo:
                 //设置新浪微博应用信息,其中authType设置为使用SSO＋Web形式授权
                 [appInfo SSDKSetupSinaWeiboByAppKey:@"568898243"
                                           appSecret:@"38a4f8204cc784f81f9f0daaf31e02e3"
                                         redirectUri:@"http://www.sharesdk.cn"
                                            authType:SSDKAuthTypeBoth];
                 break;
             case SSDKPlatformTypeWechat:
                 [appInfo SSDKSetupWeChatByAppId:@"wx4868b35061f87885"
                                       appSecret:@"64020361b8ec4c99936c0e3999a9f249"];
                 break;
             case SSDKPlatformTypeQQ:
                 [appInfo SSDKSetupQQByAppId:@"100371282"
                                      appKey:@"aed9b0303e3ed1e27bae87c33761161d"
                                    authType:SSDKAuthTypeBoth];
                 break;
             case SSDKPlatformTypeRenren:
                 [appInfo        SSDKSetupRenRenByAppId:@"226427"
                                                 appKey:@"fc5b8aed373c4c27a05b712acba0f8c3"
                                              secretKey:@"f29df781abdd4f49beca5a2194676ca4"
                                               authType:SSDKAuthTypeBoth];
                 break;
             
             default:
                 break;
         }
     }];
    
}
- (BOOL)application:(UIApplication *)application
      handleOpenURL:(NSURL *)url
{
   
    if ([url.host isEqualToString:@"safepay"]) {
        //跳转支付宝钱包进行支付，处理支付结果
        [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
            
        }];
        return YES;
    }
   
    return YES;
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{

    if ([url.host isEqualToString:@"safepay"]) {
        //跳转支付宝钱包进行支付，处理支付结果
        [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
          
        }];
        return YES;
    }
   
    return YES;
}
// NOTE: 9.0以后使用新API接口
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString*, id> *)options
{
    if ([url.host isEqualToString:@"safepay"]) {
        //跳转支付宝钱包进行支付，处理支付结果
        [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
           
            
            
            
        }];
        return YES;
    }
   return YES;
}
-(void)onResp:(BaseResp*)resp{
    if([resp isKindOfClass:[PayResp class]]){
        //支付返回结果，实际支付结果需要去微信服务器端查询
        //发通知支付结果
        [[NSNotificationCenter defaultCenter] postNotificationName:@"wechatPay"
                                                            object:self
                                                          userInfo:@{@"errCode":@(resp.errCode)}];
        switch (resp.errCode) {
            case WXSuccess:
                NSLog(@"微信支付成功－PaySuccess，retcode = %d", resp.errCode);
                break;
                
            default:
                NSLog(@"微信支付错误，retcode = %d, retstr = %@", resp.errCode,resp.errStr);
                break;
                
        }
    }
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
