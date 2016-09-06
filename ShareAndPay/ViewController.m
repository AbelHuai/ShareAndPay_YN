//
//  ViewController.m
//  ShareAndPay
//
//  Created by Abel on 16/9/5.
//  Copyright © 2016年 杨南. All rights reserved.
//

#import "ViewController.h"
#import "ShareView.h"

#import "WXApi.h"
#import <ShareSDK/ShareSDK.h>
#import "Order.h"
#import "DataSigner.h"
#import <AlipaySDK/AlipaySDK.h>

#import "openssl_wrapper.h"

#define APP_HEIGHYREAL [ UIScreen mainScreen ].bounds.size.height
#define APP_WIDTHYREAL [ UIScreen mainScreen ].bounds.size.width

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIButton *share;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}
- (IBAction)share:(id)sender {
    NSDictionary *shareDic = [NSDictionary dictionaryWithObjectsAndKeys:@"13123",@"title",
                              @"12313",@"content",
                              @"12313",@"imageurl",
                              @"1231",@"url",nil];
    
    ShareView *shareView = [[ShareView alloc] initWithFrame:CGRectMake(0, 0, APP_WIDTHYREAL, APP_HEIGHYREAL) shareView:shareDic delegate:nil];
    [self.view.window addSubview:shareView];
}
- (IBAction)aliPay:(id)sender {
    [self alipay:nil];
}
- (IBAction)WeChatPayment:(id)sender {
    [self weChatPay:nil];
}

//微信
- (void)weChatPay:(NSDictionary *)weChatPayDic
{
    //调起微信支付
    PayReq* req = [[PayReq alloc] init];
    
    req.partnerId = [NSString stringWithFormat:@"%@",[[weChatPayDic objectForKey:@"payment_parma"] objectForKey:@"partnerId"]];
    req.prepayId= [NSString stringWithFormat:@"%@",[[weChatPayDic objectForKey:@"payment_parma"] objectForKey:@"prepayId"]];
    req.package = [NSString stringWithFormat:@"%@",[[weChatPayDic objectForKey:@"payment_parma"] objectForKey:@"package"]];
    req.nonceStr= [NSString stringWithFormat:@"%@",[[weChatPayDic objectForKey:@"payment_parma"] objectForKey:@"nonceStr"]];
    req.timeStamp= [[NSString stringWithFormat:@"%@",[[weChatPayDic objectForKey:@"payment_parma"] objectForKey:@"timeStamp"]] intValue];
    req.sign= [NSString stringWithFormat:@"%@",[[weChatPayDic objectForKey:@"payment_parma"] objectForKey:@"sign"]];
    NSLog(@"appid=%@\npartid=%@\nprepayid=%@\nnoncestr=%@\ntimestamp=%ld\npackage=%@\nsign=%@",[[weChatPayDic objectForKey:@"payment_parma"] objectForKey:@"appid"],req.partnerId,req.prepayId,req.nonceStr,(long)req.timeStamp,req.package,req.sign );
    if ([WXApi isWXAppInstalled]) {
        [WXApi sendReq:req];
    }else{
        //手机没有安装微信，不能完成支付T.T
        [[[UIAlertView alloc] initWithTitle:@"提示:"
                                    message:@"手机未安装微信，不能完成支付!"
                                   delegate:nil
                          cancelButtonTitle:@"确定"
                          otherButtonTitles:nil] show];
    }
    
}

//支付宝
- (void)alipay:(NSDictionary *)alipayDic
{
//    /*
//     *商户的唯一的parnter和seller。
//     *签约后，支付宝会为每个商户分配一个唯一的 parnter 和 seller。
//     */
//
//    /*============================================================================*/
//    /*=======================需要填写商户app申请的===================================*/
//    /*============================================================================*/
//    NSString *partner = [NSString stringWithFormat:@"%@",[[alipayDic objectForKey:@"payment_parma"] objectForKey:@"partner"]];
//    NSString *seller = [NSString stringWithFormat:@"%@",[[alipayDic objectForKey:@"payment_parma"] objectForKey:@"seller"]];
////    NSString *privateKey = [NSString stringWithFormat:@"%@",[[alipayDic objectForKey:@"payment_parma"] objectForKey:@"private_key"]];
//    /*============================================================================*/
//    /*============================================================================*/
//    /*============================================================================*/
//
//    //partner和seller获取失败,提示
//    if ([partner length] == 0 ||
//        [seller length] == 0 ||
//        [privateKey length] == 0)
//    {
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
//                                                        message:@"缺少partner或者seller或者私钥。"
//                                                       delegate:self
//                                              cancelButtonTitle:@"确定"
//                                              otherButtonTitles:nil];
//        [alert show];
//        return;
//    }
//    /*
//     *生成订单信息及签名
//     */
//    //将商品信息赋予AlixPayOrder的成员变量
//    Order *order = [[Order alloc] init];
//    order.partner = partner;
//    order.sellerID = seller;
////    order.outTradeNO = [self generateTradeNO]; //订单ID（由商家自行制定）
//    order.outTradeNO = [NSString stringWithFormat:@"%@",[alipayDic objectForKey:@"out_trade_no"]]; //订单ID（由商家自行制定）
//
//    order.subject =  [NSString stringWithFormat:@"%@",[[alipayDic objectForKey:@"payment_parma"] objectForKey:@"subject"]]; //商品标题
//    order.body =  [NSString stringWithFormat:@"%@",[[alipayDic objectForKey:@"payment_parma"] objectForKey:@"body"]]; //商品描述
//    order.totalFee = [NSString stringWithFormat:@"%.2f",[[NSString stringWithFormat:@"%@",[[alipayDic objectForKey:@"payment_parma"] objectForKey:@"totalFee"]] floatValue]]; //商品价格
//    order.notifyURL = [NSString stringWithFormat:@"%@",[[alipayDic objectForKey:@"payment_parma"] objectForKey:@"notifyURL"]]; //回调URL
//    order.service = @"mobile.securitypay.pay";
//    order.paymentType = @"1";
//    order.inputCharset = @"utf-8";
//    order.itBPay = @"30m";
//    order.showURL = @"m.alipay.com";
////
////    //应用注册scheme,在AlixPayDemo-Info.plist定义URL types
   
////    //将商品信息拼接成字符串
//    NSString *orderSpec = [order description];
//    NSLog(@"orderSpec = %@",orderSpec);
//
////    NSString *signedString =  [NSString stringWithFormat:@"%@",[[alipayDic objectForKey:@"payment_parma"] objectForKey:@"sign"]];
//
////    获取私钥并将商户信息签名,外部商户可以根据情况存放私钥和签名,只需要遵循RSA签名规范,并将签名字符串base64编码和UrlEncode
////    id<DataSigner> signer = CreateRSADataSigner(privateKey);
////    NSString *signedString = [signer signString:orderSpec];
    
    NSString *appScheme = @"ShareAndPay";
    NSString *orderSpec =  [NSString stringWithFormat:@"%@",[[alipayDic objectForKey:@"payment_parma"] objectForKey:@"orderSpec"]];
    //将签名成功字符串格式化为｀订单字符串,请严格按照该格式
    //    NSString *orderString = nil;
    if (orderSpec != nil) {
        //        orderString = [NSString stringWithFormat:@"%@&sign=\"%@\"&sign_type=\"%@\"",
        //                       orderSpec, signedString, @"RSA"];
        
        [[AlipaySDK defaultService] payOrder:orderSpec fromScheme:appScheme callback:^(NSDictionary *resultDic) {
            NSLog(@"reslut = %@",resultDic);
            if ([resultDic[@"resultStatus"] intValue]==9000) {
                //进入充值列表页面
                NSLog(@"支付成功");
            
            }
            else
                if([resultDic[@"resultStatus"] intValue]==6001){
                    [[[UIAlertView alloc] initWithTitle:@"提示:"
                                                message:@"用户取消付款"
                                               delegate:nil
                                      cancelButtonTitle:@"确定"
                                      otherButtonTitles:nil] show];
                }else if([resultDic[@"resultStatus"] intValue]==4000){
                    [[[UIAlertView alloc] initWithTitle:@"提示:"
                                                message:@"支付失败!"
                                               delegate:nil
                                      cancelButtonTitle:@"确定"
                                      otherButtonTitles:nil] show];
                }else if([resultDic[@"resultStatus"] intValue]==8000){
                    [[[UIAlertView alloc] initWithTitle:@"提示:"
                                                message:@"正在处理中!"
                                               delegate:nil
                                      cancelButtonTitle:@"确定"
                                      otherButtonTitles:nil] show];
                }else if([resultDic[@"resultStatus"] intValue]==6002){
                    [[[UIAlertView alloc] initWithTitle:@"提示:"
                                                message:@"网络连接出错!"
                                               delegate:nil
                                      cancelButtonTitle:@"确定"
                                      otherButtonTitles:nil] show];
                    
                }
        }];
    }
}
#pragma mark NSNotificationCenter
- (void)handleWXPayResult:(NSNotification*)notification{
    /*
     WXSuccess           = 0,    **< 成功
     WXErrCodeCommon     = -1,   **< 普通错误类型    *
     WXErrCodeUserCancel = -2,   **< 用户点击取消并返回    *
     WXErrCodeSentFail   = -3,   **< 发送失败    *
     WXErrCodeAuthDeny   = -4,   **< 授权失败    *
     WXErrCodeUnsupport  = -5,   **< 微信不支持    *
     */
    
    NSDictionary *info = [notification userInfo];
    NSInteger errCode = [info[@"errCode"] integerValue];
    
    switch (errCode) {
        case WXSuccess:
        {
            //发通知刷新页面
            
        }
            break;
            
        case WXErrCodeUserCancel:{
            [[[UIAlertView alloc] initWithTitle:@"提示:"
                                        message:@"用户取消付款"
                                       delegate:nil
                              cancelButtonTitle:@"确定"
                              otherButtonTitles:nil] show];
        }
            break;
            
        default:
        {
            [[[UIAlertView alloc] initWithTitle:@"提示:"
                                        message:@"支付失败!"
                                       delegate:nil
                              cancelButtonTitle:@"确定"
                              otherButtonTitles:nil] show];
        }
            break;
    }
}
#pragma mark NSNotificationCenter
- (void)handleAliPayResult:(NSNotification*)notification{
    
    
    NSDictionary *resultDic = [notification userInfo];
    if ([resultDic[@"resultStatus"] intValue]==9000) {
        //进入充值列表页面
        NSLog(@"支付成功");
        //发通知刷新页面
       
        
    }else if([resultDic[@"resultStatus"] intValue]==6001){
        [[[UIAlertView alloc] initWithTitle:@"提示:"
                                    message:@"用户取消付款"
                                   delegate:nil
                          cancelButtonTitle:@"确定"
                          otherButtonTitles:nil] show];
    }else if([resultDic[@"resultStatus"] intValue]==4000){
        [[[UIAlertView alloc] initWithTitle:@"提示:"
                                    message:@"支付失败!"
                                   delegate:nil
                          cancelButtonTitle:@"确定"
                          otherButtonTitles:nil] show];
    }else if([resultDic[@"resultStatus"] intValue]==8000){
        [[[UIAlertView alloc] initWithTitle:@"提示:"
                                    message:@"正在处理中!"
                                   delegate:nil
                          cancelButtonTitle:@"确定"
                          otherButtonTitles:nil] show];
    }else if([resultDic[@"resultStatus"] intValue]==6002){
        [[[UIAlertView alloc] initWithTitle:@"提示:"
                                    message:@"网络连接出错!"
                                   delegate:nil
                          cancelButtonTitle:@"确定"
                          otherButtonTitles:nil] show];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
