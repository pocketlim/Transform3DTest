//
//  ViewController.m
//  Transform3DTest
//
//  Created by Lim on 11/11/14.
//  Copyright (c) 2014 Lim. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIView *rotationView;
@property (nonatomic, strong) UIImageView *gradientView;
@property (nonatomic, strong) UILabel *testLabel;
@property (nonatomic, strong) UIPanGestureRecognizer *panGR;

@property (nonatomic, strong) NSTimer *resetTimer;

@property (nonatomic, assign) CGFloat absTranslationAmount;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.frame = [self appFrame];
    
    // Do any additional setup after loading the view, typically from a nib.
    self.rotationView = [[UIView alloc] initWithFrame:[self appFrame]];
    self.rotationView.backgroundColor = [UIColor colorWithRed:0 green:1 blue:1 alpha:1.0f];
    
    self.rotationView.userInteractionEnabled = YES;
    
    [self.view addSubview:self.rotationView];
    
//    UIImage *gradientImage = [UIImage imageNamed:@"loading_gradient_47"];
//    gradientImage = [gradientImage resizableImageWithCapInsets:UIEdgeInsetsMake(4, 0, 4, 0)];
//    self.gradientView = [[UIImageView alloc] initWithImage:gradientImage];
//
//    [self.rotationView addSubview:self.gradientView];
    
    self.testLabel = [[UILabel alloc] initWithFrame:[self appFrame]];
    self.testLabel.backgroundColor = [UIColor clearColor];
    self.testLabel.text = @"Use this text to orient your view/rotation in 3D space.\n\nAs you pan your finger, this view will rotate using a CATransform3D along the anchor point {0, 0.5}\n\nRunning the app in the debugger will print out the layer and view frames, as well as the CATransform3D rotation itself.\n\nLifting your finger will reset the views after 1 second.\n\nThe issue only occurs when you're rotated in landscape mode and rotate the view toward yourself (like opening a door toward yourself). After a specified amount of rotation, the frames of the view become infinite.";
    self.testLabel.numberOfLines = 0;
    self.testLabel.lineBreakMode = NSLineBreakByWordWrapping;
    
    [self.rotationView addSubview:self.testLabel];
    
    self.panGR = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGestures:)];
    [self.rotationView addGestureRecognizer:self.panGR];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    [self layoutAllFrames];
}

- (void)layoutAllFrames
{
    self.rotationView.frame = [self appFrame];
    self.gradientView.frame = self.rotationView.bounds;
    self.testLabel.frame = CGRectMake(15, 0, self.rotationView.bounds.size.width - 30, self.rotationView.bounds.size.height);
}

#pragma mark - Rotation methods

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

#pragma mark - Helpers

- (CGRect)appFrame
{
    return [UIScreen mainScreen].bounds;
}

#pragma mark - Transforms

- (void)resetAllViews:(NSTimer *)timer
{
    [self setupViewForRotation];
    [self layoutAllFrames];
}

- (void)setupViewForRotation
{
    self.rotationView.layer.transform = CATransform3DIdentity;
    [self setAnchorPoint:CGPointMake(0, 0.5) forView:self.rotationView];
}

#define M34_PERSPECTIVE_DIVISOR -600.0

- (CATransform3D)transformForRotateForward:(CGFloat)amount
{
    CGFloat rotateVolume = -1 * amount * M_PI_2 * 0.005;
    
    CATransform3D rotateForward = CATransform3DIdentity;
    rotateForward.m34 = 1.0 / M34_PERSPECTIVE_DIVISOR;
    rotateForward = CATransform3DRotate(rotateForward, /*M_PI_2 * -1*/ rotateVolume, 0.0f, 1.0f, 0.0f);
    
    return rotateForward;
}

- (void)setAnchorPoint:(CGPoint)anchorPoint forView:(UIView *)view
{
    CGPoint newPoint = CGPointMake(view.bounds.size.width * anchorPoint.x, view.bounds.size.height * anchorPoint.y);
    CGPoint oldPoint = CGPointMake(view.bounds.size.width * view.layer.anchorPoint.x, view.bounds.size.height * view.layer.anchorPoint.y);
    
    newPoint = CGPointApplyAffineTransform(newPoint, view.transform);
    oldPoint = CGPointApplyAffineTransform(oldPoint, view.transform);
    
    CGPoint position = CGPointMake(view.layer.position.x, view.layer.position.y);
    
    position.x -= oldPoint.x;
    position.x += newPoint.x;
    
    position.y -= oldPoint.y;
    position.y += newPoint.y;
    
    view.layer.position = position;
    view.layer.anchorPoint = anchorPoint;
}

#pragma mark - Helper methods

- (void)logRotationAmount:(CATransform3D)transform
{
    NSLog(@"{ %f, %f, %f, %f\n  %f, %f, %f, %f\n  %f, %f, %f, %f\n  %f, %f, %f, %f }",
          transform.m11, transform.m12, transform.m13, transform.m14,
          transform.m21, transform.m22, transform.m23, transform.m24,
          transform.m31, transform.m32, transform.m33, transform.m34,
          transform.m41, transform.m42, transform.m43, transform.m44);
}

#pragma mark - Gesture Recognizer methods

- (void)handlePanGestures:(UIPanGestureRecognizer *)gr
{
    switch (gr.state) {
        case UIGestureRecognizerStateBegan: {
            [self.resetTimer invalidate];

            [self setupViewForRotation];
            self.absTranslationAmount = 0;
        }
            break;
            
        case UIGestureRecognizerStateChanged: {
            CGPoint translatePoint = [gr translationInView:self.rotationView];
            
            // add and rotate the view
            self.absTranslationAmount -= translatePoint.x;
            CATransform3D rotationForCurrentPoint = [self transformForRotateForward:self.absTranslationAmount];
            self.rotationView.layer.transform = rotationForCurrentPoint;
            
            // debug printout
            [self logRotationAmount:rotationForCurrentPoint];
            NSLog(@"view: %@", self.rotationView);
            NSLog(@"layer: %@", self.rotationView.layer);
            
            // reset translation
            [gr setTranslation:CGPointZero inView:self.rotationView];
        }
            break;
    
        case UIGestureRecognizerStateEnded: {
            // reset all frames after a timeout
            self.resetTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(resetAllViews:) userInfo:nil repeats:NO];
            NSLog(@"Resetting views in 1.0 sec...");
            break;
        }
            
        default:
            break;
    }
}

@end
