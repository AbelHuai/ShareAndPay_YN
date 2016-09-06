//
//  ShareView.m
//  VcHappy
//
//  Created by happyvc on 16/1/4.
//  Copyright © 2016年 杨南. All rights reserved.
//

#import "ShareView.h"
#import "AppDelegate.h"

#define VIEWHEIGHT 160
#define APP_HEIGHYREAL [ UIScreen mainScreen ].bounds.size.height
#define APP_WIDTHYREAL [ UIScreen mainScreen ].bounds.size.width
#define SAFERELEASE_VIEW(x)  if(x != nil){[x removeFromSuperview];x = nil;}

@implementation ShareView
{
    UIView *_view;
    UIView *_viewBG;
    CGFloat _height;
    
}

- (id)initWithFrame:(CGRect)frame
          shareView:(NSDictionary *)shareDic
           delegate:(id<ShareViewDelegate>)delegate
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.delegate = delegate;
        self.shareDic = shareDic;
        
        _viewBG = [[UIView alloc] initWithFrame:CGRectMake(0, 0, APP_WIDTHYREAL, APP_HEIGHYREAL)];
        _viewBG.backgroundColor = [UIColor blackColor];
        _viewBG.alpha = 0.1;
        _viewBG.userInteractionEnabled = YES;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelAction)];
        [_viewBG addGestureRecognizer:tap];
        
        [self addSubview:_viewBG];
    
        NSArray *imageArray = [NSArray arrayWithObjects:@"find_icon_wechat.png",@"find_icon_circle_of_friends.png",@"find_icon_qq.png",@"find_icon_qq_zone.png", nil];
        NSArray *titleArray = [NSArray arrayWithObjects:@"微信好友",@"朋友圈",@"QQ好友",@"QQ空间", nil];
        if(imageArray.count%4==0){
            _height = 90*(imageArray.count/4)+15+40;
        }else{
          _height = 90*((imageArray.count/4)+1)+15;
        }
        
        
        _view = [[UIView alloc] initWithFrame:CGRectMake(0, APP_HEIGHYREAL, APP_WIDTHYREAL, _height)];
        _view.backgroundColor = [UIColor whiteColor];
        _view.userInteractionEnabled = YES;
        [self addSubview:_view];
        
        
        [UIView animateWithDuration:0.3 animations:^{
            _view.frame = CGRectMake(0, APP_HEIGHYREAL-_height, APP_WIDTHYREAL, _height);
        }];
        
        
        //126 126
        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, _view.frame.size.width,_height)];
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.showsVerticalScrollIndicator = NO;
        scrollView.pagingEnabled = YES;
        scrollView.bounces = NO;
        scrollView.userInteractionEnabled = YES;
        scrollView.backgroundColor = [UIColor whiteColor];
        [_view addSubview:scrollView];
        
        for(int i=0;i<imageArray.count;i++){
            UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(25+((APP_WIDTHYREAL-250)/3+50)*(i%4), 15+90*(i/4), 50, 50)];
//            [btn setTitle:@"取消" forState:0];
            btn.tag = 1001+i;
            [btn setImage:[UIImage imageNamed:[imageArray objectAtIndex:i]] forState:0];
            [btn setTitleColor:[UIColor grayColor] forState:0];
            btn.backgroundColor = [UIColor whiteColor];
            btn.titleLabel.font = [UIFont systemFontOfSize:14];
            [btn addTarget:self action:@selector(btnClickAction:) forControlEvents:UIControlEventTouchUpInside];
            [scrollView addSubview:btn];
            
            
            UILabel *labelTitle = [[UILabel alloc] initWithFrame:CGRectMake(20+((APP_WIDTHYREAL-280)/3+60)*(i%4), 70+90*(i/4), 60, 20)];
            labelTitle.backgroundColor = [UIColor clearColor];
            labelTitle.font = [UIFont systemFontOfSize:13];
            labelTitle.textAlignment = NSTextAlignmentCenter;
            labelTitle.text = [titleArray objectAtIndex:i];
            labelTitle.textColor = [UIColor grayColor];
            [scrollView addSubview:labelTitle];
            
        }
        
    }
    return self;
}

- (void)btnClickAction:(UIButton *)btn
{
    NSString *title = [NSString stringWithFormat:@"%@",self.shareDic[@"title"]];
    NSString *content = [NSString stringWithFormat:@"%@",self.shareDic[@"content"]];
    NSString *imageURL = [NSString stringWithFormat:@"%@",self.shareDic [@"imageurl"]];
    NSString *url = [NSString stringWithFormat:@"%@",self.shareDic [@"url"]];

    SSDKPlatformType shareType;
    NSInteger tag = btn.tag;
    switch (tag) {
        case 1001:{
            shareType = SSDKPlatformSubTypeWechatSession;
            break;
        }
        case 1002:{
            shareType = SSDKPlatformSubTypeWechatTimeline;
            break;
        }
        case 1003:{
            shareType = SSDKPlatformTypeQQ;
            break;
        }
        case 1004:{
            shareType = SSDKPlatformSubTypeQZone;
            break;
        }
        case 1005:{
            shareType = SSDKPlatformTypeSinaWeibo;
            break;
        }
        default:
            break;
    }
    //创建分享参数
    NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
    
    [shareParams SSDKSetupShareParamsByText:content
                                     images:imageURL //传入要分享的图片
                                        url:[NSURL URLWithString:url]
                                      title:title
                                       type:SSDKContentTypeAuto];
    
    //进行分享
    [ShareSDK share:shareType //传入分享的平台类型
         parameters:shareParams
     onStateChanged:^(SSDKResponseState state, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error) {
         if (state == SSDKResponseStateSuccess){//分享成功
             
         }
         else if (state == SSDKResponseStateFail){//分享失败
            
         }else if (state == SSDKResponseStateCancel){//取消分享
             
         }
     }];
    
}
- (void)cancelAction
{
    [UIView animateWithDuration:0.3 animations:^{
        _view.frame = CGRectMake(0, APP_HEIGHYREAL, APP_WIDTHYREAL, _height);
    }];
    [self performSelector:@selector(XXXX) withObject:nil afterDelay:0.3];
}
- (void)XXXX
{
    SAFERELEASE_VIEW(_viewBG);
    SAFERELEASE_VIEW(_view);
    [self removeFromSuperview];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
