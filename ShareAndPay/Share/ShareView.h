//
//  ShareView.h
//  VcHappy
//
//  Created by happyvc on 16/1/4.
//  Copyright © 2016年 杨南. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ShareSDK/ShareSDK.h>

@protocol ShareViewDelegate <NSObject>

- (void)selectedTouchFlag:(NSInteger)flag;

@end
//
@interface ShareView : UIView

- (id)initWithFrame:(CGRect)frame
   shareView:(NSDictionary *)shareDic
           delegate:(id<ShareViewDelegate>)delegate;

@property(assign,nonatomic)id<ShareViewDelegate> delegate;

@property(copy,nonatomic)NSDictionary *shareDic;

@end
