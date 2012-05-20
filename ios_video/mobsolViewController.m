//
//  mobsolViewController.m
//  ios_video
//
//  Created by Lieven Govaerts on 29/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "mobsolViewController.h"
#import "ConnCompFilter.h"
#import "MyCannyEdgeDetectionFilter.h"

@interface mobsolViewController ()

@end

@implementation mobsolViewController

- (void)viewDidLoad
{
    GPUImageOutput<GPUImageInput> *edge_filter;

    [super viewDidLoad];
    
    videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPresetiFrame1280x720 cameraPosition:AVCaptureDevicePositionBack];
    edge_filter = [[MyCannyEdgeDetectionFilter alloc] init];

    GPUImageRotationFilter *rotationFilter = [[GPUImageRotationFilter alloc] initWithRotation:kGPUImageRotateRight];

    [videoCamera addTarget:rotationFilter];
    [rotationFilter addTarget:edge_filter];
    GPUImageView *filterView = (GPUImageView *)self.view;
    [edge_filter addTarget:filterView];

    [videoCamera startCameraCapture];
    
    double delayToStartRecording = 0.5;
    dispatch_time_t startTime = dispatch_time(DISPATCH_TIME_NOW, delayToStartRecording * NSEC_PER_SEC);
    dispatch_after(startTime, dispatch_get_main_queue(), ^(void){
        NSLog(@"Start recording");
        
        double delayInSeconds = 10.0;
        dispatch_time_t stopTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(stopTime, dispatch_get_main_queue(), ^(void) {
            videoCamera.audioEncodingTarget = nil;
            NSLog(@"Movie completed");
        });
    });
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
