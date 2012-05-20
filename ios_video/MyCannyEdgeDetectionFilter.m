//
//  MyCannyEdgeDetectionFilter.m
//  ios_video
//
//  Created by Lieven Govaerts on 19/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MyCannyEdgeDetectionFilter.h"
#import "MySobelEdgeDetectionFilter.h"
#import "GPUImageGaussianBlurFilter.h"
#import "GPUImageThresholdEdgeDetection.h"
#import "GPUImageSketchFilter.h"

@implementation MyCannyEdgeDetectionFilter

@synthesize threshold;
@synthesize blurSize;
@synthesize imageWidthFactor;
@synthesize imageHeightFactor;

- (id)init;
{
    if (!(self = [super init]))
    {
		return nil;
    }
    
    // First pass: apply a variable Gaussian blur
    blurFilter = [[GPUImageGaussianBlurFilter alloc] init];
    [self addFilter:blurFilter];
    
    // Second pass: run the Sobel edge detection on this blurred image
    edgeDetectionFilter = [[MySobelEdgeDetectionFilter alloc] init];
    [self addFilter:edgeDetectionFilter];
    
    // Texture location 0 needs to be the sharp image for both the blur and the second stage processing
    [blurFilter addTarget:edgeDetectionFilter];
    
    self.initialFilters = [NSArray arrayWithObject:blurFilter];
    self.terminalFilter = edgeDetectionFilter;
    
    self.blurSize = 1.5;
    self.threshold = 0.9;
    
    return self;
}

#pragma mark -
#pragma mark Accessors

- (void)setBlurSize:(CGFloat)newValue;
{
    blurFilter.blurSize = newValue;
}

- (CGFloat)blurSize;
{
    return blurFilter.blurSize;
}

- (void)setImageWidthFactor:(CGFloat)newValue;
{
    edgeDetectionFilter.imageWidthFactor = newValue;
}

- (CGFloat)imageWidthFactor;
{
    return edgeDetectionFilter.imageWidthFactor;
}

- (void)setImageHeightFactor:(CGFloat)newValue;
{
    edgeDetectionFilter.imageHeightFactor = newValue;
}

- (CGFloat)imageHeightFactor;
{
    return edgeDetectionFilter.imageHeightFactor;
}

- (void)setThreshold:(CGFloat)newValue;
{
}

- (CGFloat)threshold;
{
    return 0;
}

@end
