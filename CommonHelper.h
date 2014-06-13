//
//  CommonHelper.h
//  VideoEditDemo
//
//  Created by mr.cao on 14-6-13.
//  Copyright (c) 2014年 mrcao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CommonHelper : NSObject
+(CommonHelper *)sharedInstance;
-(MBProgressHUD *) showHud:(id<MBProgressHUDDelegate>) delegate title:(NSString *) title  selector:(SEL) selector arg:(id) arg  targetView:(UIView *)targetView;

@end
