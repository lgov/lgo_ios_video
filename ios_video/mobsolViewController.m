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
#import "MySobelEdgeDetectionFilter.h"

@interface mobsolViewController ()

@end

@implementation mobsolViewController

- (void)viewDidLoad
{
    GPUImageOutput<GPUImageInput> *edge_filter;
    
    [super viewDidLoad];

    edge_filter = [[MyCannyEdgeDetectionFilter alloc] init];

#define PHOTO 0
#define CAMERA 0
#define VIDEOFILE 1    

#if VIDEOFILE
    GPUImageMovie *movieFile;
    
    NSString *pathToMovie = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Movie.m4v"];
    NSURL *movieURL = [NSURL fileURLWithPath:pathToMovie];

    movieFile = [[GPUImageMovie alloc] initWithURL:movieURL];
    movieFile.runBenchmark = YES;
    [movieFile addTarget:edge_filter];
#endif
    GPUImageView *filterView = (GPUImageView *)self.view;
    [edge_filter addTarget:filterView];

#if VIDEOFILE
    [movieFile startProcessing];
#endif

#if CAMERA
    videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPresetiFrame1280x720 cameraPosition:AVCaptureDevicePositionBack];
    videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    
//    [videoCamera addTarget:edge_filter];
#endif

#if PHOTO
    GPUImagePicture *sourcePicture;
    
    NSArray *sysPaths = NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask, YES );
    NSString *docDirectory = [sysPaths objectAtIndex:0];
    NSString *filePath = [NSString stringWithFormat:@"%@/test_small.png", docDirectory];
    UIImage *inputImage = [[UIImage alloc] initWithContentsOfFile:filePath];
    
    sourcePicture = [[GPUImagePicture alloc] initWithImage:inputImage smoothlyScaleOutput:YES];

    [sourcePicture addTarget:edge_filter];

    [sourcePicture processImage];
#endif

#if CAMERA
    [videoCamera addTarget:filterView];

#if 1

    GPUImageMovieWriter *movieWriter;

    // In addition to displaying to the screen, write out a processed version of the movie to disk
    NSString *pathToMovie = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Movie.m4v"];
    unlink([pathToMovie UTF8String]); // If a file already exists, AVAssetWriter won't let you record new frames, so delete the old movie
    NSURL *movieURL = [NSURL fileURLWithPath:pathToMovie];
    
    movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:movieURL size:CGSizeMake(720.0, 1280.0)];
    [videoCamera addTarget:movieWriter];
#endif
    
    [videoCamera startCameraCapture];
#if 1
    [movieWriter startRecording];
    
    double delayInSeconds = 15.0;
    dispatch_time_t stopTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(stopTime, dispatch_get_main_queue(), ^(void){
        
        [edge_filter removeTarget:movieWriter];
        videoCamera.audioEncodingTarget = nil;
        [movieWriter finishRecording];
        NSLog(@"Movie completed");
    });
#endif
#endif
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
