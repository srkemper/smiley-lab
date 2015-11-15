//
//  ViewController.m
//  CanvasDemo
//
//  Created by Sean Kemper on 11/12/15.
//  Copyright © 2015 Sean Kemper. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIView *trayView;
@property (assign, nonatomic) CGPoint original;
@property (assign, nonatomic) CGPoint newFaceOriginal;
@property (weak, nonatomic) IBOutlet UIImageView *downImageView;
@property (strong, nonatomic) UIImageView *newlyCreatedFace;
@property (assign, nonatomic) CGAffineTransform originalTransform;
- (IBAction)onPanGesture:(UIPanGestureRecognizer *)sender;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onPanSmiley:(UIPanGestureRecognizer *)sender {
    CGPoint translation = [sender translationInView:self.view];
    CGPoint location = [sender locationInView:self.view];
    if (sender.state == UIGestureRecognizerStateBegan) {
        self.newFaceOriginal = location;
        // Gesture recognizers know the view they are attached to
        UIImageView *imageView = (UIImageView *)sender.view;
        
        // Create a new image view that has the same image as the one currently panning
        self.newlyCreatedFace = [[UIImageView alloc] initWithImage:imageView.image];
        
        // Add the new face to the tray's parent view.
        [self.view addSubview:self.newlyCreatedFace];
        
        // Initialize the position of the new face.
        self.newlyCreatedFace.center = imageView.center;
        
        // Since the original face is in the tray, but the new face is in the
        // main view, you have to offset the coordinates
        CGPoint faceCenter = self.newlyCreatedFace.center;
        self.newlyCreatedFace.center = CGPointMake(faceCenter.x,
                                                   faceCenter.y + self.trayView.frame.origin.y);
        
        UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onCustomPan:)];
        UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(onCustomPinch:)];
        UIRotationGestureRecognizer *rotateGestureRecognizer = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(onCustomRotate:)];
        
        [self.newlyCreatedFace addGestureRecognizer:panGestureRecognizer];
        [self.newlyCreatedFace addGestureRecognizer:pinchGestureRecognizer];
        [self.newlyCreatedFace addGestureRecognizer:rotateGestureRecognizer];
        
        self.newlyCreatedFace.userInteractionEnabled = YES;
        
    } else if (sender.state == UIGestureRecognizerStateChanged) {
        self.newlyCreatedFace.center = CGPointMake(self.newFaceOriginal.x + translation.x, self.newFaceOriginal.y + translation.y);
    } else if (sender.state == UIGestureRecognizerStateEnded) {
        
    }

}

- (IBAction)onCustomRotate:(UIRotationGestureRecognizer *)sender {
    UIImageView *imageView = (UIImageView *)sender.view;
    
    if (sender.state == UIGestureRecognizerStateBegan) {
        self.originalTransform = imageView.transform;
    } else if (sender.state == UIGestureRecognizerStateChanged) {
        imageView.transform = CGAffineTransformRotate(self.originalTransform, sender.rotation);
    } else if (sender.state == UIGestureRecognizerStateEnded) {
        
    }
}

- (IBAction)onCustomPinch:(UIPinchGestureRecognizer *)sender {
    UIImageView *imageView = (UIImageView *)sender.view;

    if (sender.state == UIGestureRecognizerStateBegan) {
        self.originalTransform = imageView.transform;
    } else if (sender.state == UIGestureRecognizerStateChanged) {
        imageView.transform = CGAffineTransformScale(self.originalTransform, sender.scale * .5, sender.scale * .5);
    } else if (sender.state == UIGestureRecognizerStateEnded) {
        
    }
}

- (void)onCustomPan:(UIPanGestureRecognizer *)sender {
    UIImageView *imageView = (UIImageView *)sender.view;
    
    CGPoint location = [sender locationInView:self.view];
    CGPoint translation = [sender translationInView:self.view];
    
    if (sender.state == UIGestureRecognizerStateBegan) {
        NSLog(@"Gesture began at: %@", NSStringFromCGPoint(location));
        self.original = imageView.center;
    } else if (sender.state == UIGestureRecognizerStateChanged) {
        NSLog(@"Gesture changed at: %@", NSStringFromCGPoint(location));
        imageView.center = CGPointMake(self.original.x + translation.x, self.original.y + translation.y);
    } else if (sender.state == UIGestureRecognizerStateEnded) {
        NSLog(@"Gesture ended at: %@", NSStringFromCGPoint(location));
    }
}


- (IBAction)onPanGesture:(UIPanGestureRecognizer *)sender {
    // Absolute (x,y) coordinates in parentView
    CGPoint location = [sender locationInView:self.view];
    CGPoint translation = [sender translationInView:self.view];
    
    CGPoint velocity = [sender velocityInView:self.view];
    
    if (sender.state == UIGestureRecognizerStateBegan) {
        NSLog(@"Gesture began at: %@", NSStringFromCGPoint(location));
        self.original = self.trayView.center;
    } else if (sender.state == UIGestureRecognizerStateChanged) {
        NSLog(@"Gesture changed at: %@", NSStringFromCGPoint(location));
        if (self.original.y + translation.y < self.view.frame.size.height - self.trayView.frame.size.height/2) {
            return;
        } else {
            self.trayView.center = CGPointMake(self.original.x, self.original.y + translation.y);
        }
    } else if (sender.state == UIGestureRecognizerStateEnded) {
        NSLog(@"Gesture ended at: %@", NSStringFromCGPoint(location));
        if (velocity.y > 0) {
            self.trayView.center = CGPointMake(self.original.x, self.view.frame.size.height + self.trayView.frame.size.height/2 - self.downImageView.frame.size.height);
            [UIView animateWithDuration:0.2 animations:^{
               self.downImageView.transform = CGAffineTransformMakeRotation(M_PI);
            }];
        } else {
            self.trayView.center = CGPointMake(self.original.x, self.view.frame.size.height - self.trayView.frame.size.height/2);
            [UIView animateWithDuration:0.2 animations:^{
                self.downImageView.transform = CGAffineTransformMakeRotation(2 * M_PI);
            }];
        }
    }
}
@end
