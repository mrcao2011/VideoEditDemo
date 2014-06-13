//
//  CCViewController.h
//  VideoEditDemo
//
//  Created by mr.cao on 14-6-13.
//  Copyright (c) 2014年 mrcao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JSVideoScrubber.h"
@interface CCViewController : UIViewController<MBProgressHUDDelegate>
{
    CGFloat originViedoWidth;//原视频图像的宽
    CGFloat originViedoHeight;//原视频图像的高
    CGFloat originViedoFPS;//原视频的频率
    CGFloat originDuration;

}
@property (nonatomic, strong) AVAssetImageGenerator *generator;
@property (nonatomic, strong) AVVideoComposition *composition;
@property (nonatomic, strong) NSMutableArray *imageArry;
@property (nonatomic, strong) JSVideoScrubber *jsVideoScrubber;
@property (nonatomic, strong)  UILabel *duration;
@property (nonatomic, strong)  UILabel *offset;
@property(nonatomic,weak)      MBProgressHUD *hud;

@property (nonatomic, strong)  UILabel *endoffset;
@property (nonatomic,strong) UIButton *viedoEditButton;
@property (nonatomic,strong) UIButton *viedoaddMusicButton;
@property (nonatomic,strong) UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic) CMTime requestedTimeToleranceBefore NS_AVAILABLE(10_7, 5_0);
@property (nonatomic) CMTime requestedTimeToleranceAfter NS_AVAILABLE(10_7, 5_0);
@end
