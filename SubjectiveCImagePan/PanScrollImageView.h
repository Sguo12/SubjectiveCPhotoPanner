//
//  PanScrollImageView.h
//  SubjectiveCImagePan
//
//  Created by Steven Guo on 6/22/14.
//  Copyright (c) 2014 Sam Page. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SCImagePanScrollBarView;
@class CMDeviceMotion;

@interface PanScrollImageView : UIScrollView

- (void)calculateRotationBasedOnDeviceMotionRotationRate:(CMDeviceMotion *)motion;
- (void)displayLinkUpdate:(CADisplayLink *)displayLink barView:(SCImagePanScrollBarView *)scrollBarView;
- (void)configureWithImage:(UIImage *)image;

@end
