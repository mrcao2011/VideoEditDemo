//
//  CommonHelper.m
//  VideoEditDemo
//
//  Created by mr.cao on 14-6-13.
//  Copyright (c) 2014年 mrcao. All rights reserved.
//

#import "CommonHelper.h"
static CommonHelper *instance;

@implementation CommonHelper


+(CommonHelper *)sharedInstance
{
    //if(instance==nil)
    //{
    //    instance=[[CommonHelper alloc] init];
    // }
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{instance=[[self alloc]init];});
    return instance;
    
}


-(MBProgressHUD *) showHud:(id<MBProgressHUDDelegate>) delegate title:(NSString *) title  selector:(SEL) selector arg:(id) arg  targetView:(UIView *)targetView
{
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:targetView];
    [targetView addSubview:hud];
    hud.removeFromSuperViewOnHide = YES;
    hud.delegate = delegate;
    hud.labelText = title;
    hud.mode=MBProgressHUDModeDeterminate;
    [hud showWhileExecuting:selector
                   onTarget:delegate
                 withObject:arg
                   animated:YES];
    return hud;
}



@end
