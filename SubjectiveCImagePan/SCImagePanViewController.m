//
//  SCImagePanViewController.m
//  SubjectiveCImagePan
//
//  Created by Sam Page on 16/02/14.
//  Copyright (c) 2014 Sam Page. All rights reserved.
//

#import "SCImagePanViewController.h"
#import "SCImagePanScrollBarView.h"
#import "PanScrollImageView.h"

@interface SCImagePanViewController () <UIScrollViewDelegate>

@property (nonatomic, strong) CMMotionManager *motionManager;
@property (nonatomic, strong) CADisplayLink *displayLink;

@property (nonatomic, strong) PanScrollImageView *panningScrollView;
@property (nonatomic, strong) SCImagePanScrollBarView *scrollBarViewHorizontal;

@property (nonatomic, assign, getter = isMotionBasedPanEnabled) BOOL motionBasedPanEnabled;

@end

@implementation SCImagePanViewController

#pragma mark - init / dealloc

- (id)initWithMotionManager:(CMMotionManager *)motionManager
{
    if (self = [super initWithNibName:nil bundle:nil])
    {
        self.motionManager = motionManager;
        self.motionBasedPanEnabled = YES;
    }
    return self;
}

- (void)dealloc
{
    [_displayLink invalidate];
    [_motionManager stopDeviceMotionUpdates];
}

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
        
    self.view.backgroundColor = [UIColor blackColor];
    
    self.panningScrollView = [[PanScrollImageView alloc] initWithFrame:self.view.bounds];
    
    [self.view addSubview:self.panningScrollView];
    
    self.scrollBarViewHorizontal = [[SCImagePanScrollBarView alloc] initWithFrame:self.view.bounds edgeInsets:UIEdgeInsetsMake(0.f, 10.f, 50.f, 10.f)];
    self.scrollBarViewHorizontal.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    self.scrollBarViewHorizontal.userInteractionEnabled = NO;
    [self.view addSubview:self.scrollBarViewHorizontal];

    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkUpdate:)];
    [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.panningScrollView.contentOffset = CGPointMake((self.panningScrollView.contentSize.width / 2.f) - (CGRectGetWidth(self.panningScrollView.bounds)) / 2.f,
                                                       (self.panningScrollView.contentSize.height / 2.f) - (CGRectGetHeight(self.panningScrollView.bounds)) / 2.f);
    
    [self.motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMDeviceMotion *motion, NSError *error) {
        [self calculateRotationBasedOnDeviceMotionRotationRate:motion];
    }];
}

#pragma mark - update view after rotation

- (void)viewWillLayoutSubviews
{
    // Super
    [super viewWillLayoutSubviews];

}

#pragma mark - Public

- (void)configureWithImage:(UIImage *)image
{
    [self.panningScrollView configureWithImage:image];
}

- (void)calculateRotationBasedOnDeviceMotionRotationRate:(CMDeviceMotion *)motion
{
    [self.panningScrollView calculateRotationBasedOnDeviceMotionRotationRate:motion];
}

- (void)displayLinkUpdate:(CADisplayLink *)displayLink
{
    [self.panningScrollView displayLinkUpdate:displayLink barView:self.scrollBarViewHorizontal];
}


@end