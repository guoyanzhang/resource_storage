//
//  AnnoFloatBarView.h
//  MobileRTCSample
//
//  Created by Chao Bai on 2018/6/12.
//  Copyright © 2018 Zoom Video Communications, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AnnoFloatBarViewDelegate <NSObject>

@optional

- (BOOL)onClickStartAnnotate;
- (BOOL)onClickStopAnnotate;

@end

@interface AnnoFloatBarView : UIView

@property (retain, nonatomic) UIButton * action;
@property (retain, nonatomic) UIButton * pen;
@property (retain, nonatomic) UIButton * spotlight;
@property (retain, nonatomic) UIButton * erase;

@property (assign, nonatomic) BOOL isAnnotate;

@property (assign, nonatomic) id<AnnoFloatBarViewDelegate>  delegate;

- (void)stopAnnotate;

@end
