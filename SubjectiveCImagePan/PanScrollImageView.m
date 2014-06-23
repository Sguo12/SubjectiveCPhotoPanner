//
//  PanScrollImageView.m
//  SubjectiveCImagePan
//
//  Created by Steven Guo on 6/22/14.
//  Copyright (c) 2014 Sam Page. All rights reserved.
//

#import <CoreMotion/CoreMotion.h>
#import "PanScrollImageView.h"
#import "SCImagePanScrollBarView.h"

static CGFloat kMovementSmoothing = 0.3f;
static CGFloat kAnimationDuration = 0.3f;
static CGFloat kRotationMultiplier = 5.f;

@interface PanScrollImageView() <UIScrollViewDelegate>

@property (nonatomic, strong) UIImageView *panningImageView;

@property (nonatomic, assign, getter = isMotionBasedPanEnabled) BOOL motionBasedPanEnabled;

@end

@implementation PanScrollImageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void) setup
{
    self.motionBasedPanEnabled = YES;
    
    self.contentSize = CGSizeZero;
    
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    self.backgroundColor = [UIColor blackColor];
    self.delegate = self;
    self.scrollEnabled = NO;
    self.alwaysBounceVertical = NO;
    self.maximumZoomScale = 2.f;

    self.panningImageView = [[UIImageView alloc] initWithFrame:self.bounds];
    self.panningImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    self.panningImageView.backgroundColor = [UIColor blackColor];
    self.panningImageView.contentMode = UIViewContentModeScaleAspectFit;
    
    [self addSubview:self.panningImageView];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleMotionBasedPan:)];
    [self addGestureRecognizer:tapGestureRecognizer];
    
    [self.pinchGestureRecognizer addTarget:self action:@selector(pinchGestureRecognized:)];
}

#pragma mark - Zoom toggling

- (void)toggleMotionBasedPan:(id)sender
{
    BOOL motionBasedPanWasEnabled = self.isMotionBasedPanEnabled;
    if (motionBasedPanWasEnabled)
    {
        self.motionBasedPanEnabled = NO;
    }
    
    [UIView animateWithDuration:kAnimationDuration
                     animations:^{
                         [self updateViewsForMotionBasedPanEnabled:!motionBasedPanWasEnabled];
                     } completion:^(BOOL finished) {
                         if (motionBasedPanWasEnabled == NO)
                         {
                             self.motionBasedPanEnabled = YES;
                         }
                     }];
}

- (void)updateViewsForMotionBasedPanEnabled:(BOOL)motionBasedPanEnabled
{
    if (motionBasedPanEnabled)
    {
        [self updateScrollViewZoomToMaximumForImage:self.panningImageView.image];
        self.scrollEnabled = NO;
    }
    else
    {
        self.zoomScale = 1.f;
        self.scrollEnabled = YES;
    }
}

#pragma mark - Helpers

- (CGPoint)clampedContentOffsetForHorizontalOffset:(CGFloat)horizontalOffset;
{
    CGFloat maximumXOffset = self.contentSize.width - CGRectGetWidth(self.bounds);
    CGFloat minimumXOffset = 0.f;
    
    CGFloat clampedXOffset = fmaxf(minimumXOffset, fmin(horizontalOffset, maximumXOffset));
    CGFloat centeredY = (self.contentSize.height / 2.f) - (CGRectGetHeight(self.bounds)) / 2.f;
    
    return CGPointMake(clampedXOffset, centeredY);
}

#pragma mark - Zooming

- (CGFloat)maximumZoomScaleForImage:(UIImage *)image
{
    return (CGRectGetHeight(self.bounds) / CGRectGetWidth(self.bounds)) * (image.size.width / image.size.height);
}

- (void)updateScrollViewZoomToMaximumForImage:(UIImage *)image
{
    CGFloat zoomScale = [self maximumZoomScaleForImage:image];
    
    self.maximumZoomScale = zoomScale * 2;
    self.zoomScale = zoomScale;
}

#pragma mark - Pinch gesture

- (void)pinchGestureRecognized:(id)sender
{
    self.motionBasedPanEnabled = NO;
    self.scrollEnabled = YES;
}


#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.panningImageView;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
//    [scrollView setContentOffset:[self clampedContentOffsetForHorizontalOffset:scrollView.contentOffset.x] animated:YES];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (decelerate == NO)
    {
        NSLog(@"11111");
//        [scrollView setContentOffset:[self clampedContentOffsetForHorizontalOffset:scrollView.contentOffset.x] animated:YES];
    }
    NSLog(@"22222");
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    NSLog(@"0000000");
  //  [scrollView setContentOffset:[self clampedContentOffsetForHorizontalOffset:scrollView.contentOffset.x] animated:YES];
}

#pragma mark - Public

- (void)configureWithImage:(UIImage *)image
{
    /*
    self.contentSize = image.size;
    CGFloat width = image.size.width / image.size.height * self.bounds.size.height;
    self.panningImageView.frame = CGRectMake(0, 0, width, self.bounds.size.height);
*/
    self.panningImageView.image = image;
    [self updateScrollViewZoomToMaximumForImage:image];    
}

#pragma mark - Motion Handling

- (void)calculateRotationBasedOnDeviceMotionRotationRate:(CMDeviceMotion *)motion
{
    if (self.isMotionBasedPanEnabled)
    {
        CGFloat xRotationRate = motion.rotationRate.x;
        CGFloat yRotationRate = motion.rotationRate.y;
        CGFloat zRotationRate = motion.rotationRate.z;
        
        if (fabs(yRotationRate) > (fabs(xRotationRate) + fabs(zRotationRate)))
        {
            CGFloat invertedYRotationRate = yRotationRate * -1;
            
            CGFloat zoomScale = [self maximumZoomScaleForImage:self.panningImageView.image];
            CGFloat interpretedXOffset = self.contentOffset.x + (invertedYRotationRate * zoomScale * kRotationMultiplier);
            
            CGPoint contentOffset = [self clampedContentOffsetForHorizontalOffset:interpretedXOffset];
            
            [UIView animateWithDuration:kMovementSmoothing
                                  delay:0.0f
                                options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionCurveEaseOut
                             animations:^{
                                 [self setContentOffset:contentOffset animated:NO];
                             } completion:NULL];
        }
    }
}

#pragma mark - CADisplayLink

- (void)displayLinkUpdate:(CADisplayLink *)displayLink barView:(SCImagePanScrollBarView *)scrollBarView
{
    CALayer *panningImageViewPresentationLayer = self.panningImageView.layer.presentationLayer;
    CALayer *panningScrollViewPresentationLayer = self.layer.presentationLayer;
    
    CGFloat horizontalContentOffset = CGRectGetMinX(panningScrollViewPresentationLayer.bounds);
    
    CGFloat contentWidth = CGRectGetWidth(panningImageViewPresentationLayer.frame);
    CGFloat visibleWidth = CGRectGetWidth(self.bounds);
    
    CGFloat clampedXOffsetAsPercentage = fmax(0.f, fmin(1.f, horizontalContentOffset / (contentWidth - visibleWidth)));
    
    CGFloat scrollBarWidthPercentage = visibleWidth / contentWidth;
    CGFloat scrollableAreaPercentage = 1.0 - scrollBarWidthPercentage;
    
    [scrollBarView updateWithScrollAmount:clampedXOffsetAsPercentage forScrollableWidth:scrollBarWidthPercentage inScrollableArea:scrollableAreaPercentage];
}

@end
