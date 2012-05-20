//
//  MySobelEdgeDetectionFilter.m
//  ios_video
//
//  Created by Lieven Govaerts on 19/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MySobelEdgeDetectionFilter.h"
#import "GPUImageGrayscaleFilter.h"
#import "GPUImage3x3ConvolutionFilter.h"

//   Code from "Graphics Shaders: Theory and Practice" by M. Bailey and S. Cunningham 
NSString *const kMySobelEdgeDetectionFragmentShaderString = SHADER_STRING
(
 precision highp float;
 
 varying vec2 textureCoordinate;
 varying vec2 leftTextureCoordinate;
 varying vec2 rightTextureCoordinate;
 
 varying vec2 topTextureCoordinate;
 varying vec2 topLeftTextureCoordinate;
 varying vec2 topRightTextureCoordinate;
 
 varying vec2 bottomTextureCoordinate;
 varying vec2 bottomLeftTextureCoordinate;
 varying vec2 bottomRightTextureCoordinate;
 
 uniform sampler2D inputImageTexture;
 
 const highp vec3 W = vec3(0.2125, 0.7154, 0.0721);

 void main()
 {
     // luminance filter first, lum component is stored in .r
     float topLeftIntensity = texture2D(inputImageTexture, topLeftTextureCoordinate).r;
     float topIntensity = texture2D(inputImageTexture, topTextureCoordinate).r;
     float topRightIntensity = texture2D(inputImageTexture, topRightTextureCoordinate).r;
     float leftIntensity = texture2D(inputImageTexture, leftTextureCoordinate).r;
     float rightIntensity = texture2D(inputImageTexture, rightTextureCoordinate).r;
     float bottomLeftIntensity = texture2D(inputImageTexture, bottomLeftTextureCoordinate).r;
     float bottomIntensity = texture2D(inputImageTexture, bottomTextureCoordinate).r;
     float bottomRightIntensity = texture2D(inputImageTexture, bottomRightTextureCoordinate).r;

     float Gy = topLeftIntensity + 2.0 * topIntensity + topRightIntensity - bottomLeftIntensity - 2.0 * bottomIntensity - bottomRightIntensity;
     float Gx = -bottomLeftIntensity - 2.0 * leftIntensity - topLeftIntensity + bottomRightIntensity + 2.0 * rightIntensity + topRightIntensity;
     
     float strength = length(vec2(Gx, Gy));
     
     highp float edge_dir = atan(Gx, Gy) * 180.0 / M_PI;
     edge_dir += 180.0;
     edge_dir = mod(edge_dir, 180.0);
     
     // TODO: get rid of "if" block
     if (strength > 0.1) {
/*
         // assign edge to range
         if ((edge_dir <= 22.5) || (edge_dir > 157.5)) {
             edge_dir = 0.0;
             gl_FragColor = vec4(1.0, 1, 0, 1.0); // yellow
         }
         if ((edge_dir > 22.5) && (edge_dir <= 67.5)) {
             edge_dir = 45.0;
             gl_FragColor = vec4(0.0, 1.0, 0, 1.0); // green
         }
         if ((edge_dir > 67.5) && (edge_dir <= 112.5)) {
             edge_dir = 90.0;
             gl_FragColor = vec4(0.0, 0, 1.0, 1.0); // blue
         }
         if ((edge_dir > 112.5) && (edge_dir <= 157.5)) {
             edge_dir = 135.0;
             gl_FragColor = vec4(1.0, 0, 0, 1.0); // red
         }
*/

         // assign edge to range
         if (((edge_dir < 22.5) && (edge_dir > -22.5)) || (edge_dir > 157.5) || (edge_dir < -157.5)) {
             edge_dir = 0.0;
             gl_FragColor = vec4(1.0, 1, 0, 1.0); // yellow
         }
         if (((edge_dir > 22.5) && (edge_dir < 67.5)) || ((edge_dir < -112.5) && (edge_dir > -157.5))) {
             edge_dir = 45.0;
             gl_FragColor = vec4(0.0, 1.0, 0, 1.0); // green
         }
         if (((edge_dir > 67.5) && (edge_dir < 112.5)) || ((edge_dir < -67.5) && (edge_dir > -112.5))) {
             edge_dir = 90.0;
             gl_FragColor = vec4(0.0, 0, 1.0, 1.0); // blue
         }
         if (((edge_dir > 112.5) && (edge_dir < 157.5)) || ((edge_dir < -22.5) && (edge_dir > -67.5))) {
             edge_dir = 135.0;
             gl_FragColor = vec4(1.0, 0, 0, 1.0); // red
         }

     }
     else
         gl_FragColor = vec4(0.0, 0, 0, 1.0); // black         
 }
 );

@implementation MySobelEdgeDetectionFilter

@synthesize imageWidthFactor = _imageWidthFactor; 
@synthesize imageHeightFactor = _imageHeightFactor; 

#pragma mark -
#pragma mark Initialization and teardown

- (id)init;
{
    if (!(self = [self initWithFragmentShaderFromString:kMySobelEdgeDetectionFragmentShaderString]))
    {
		return nil;
    }
    
    return self;
}


- (id)initWithFragmentShaderFromString:(NSString *)fragmentShaderString;
{
    // Do a luminance pass first to reduce the calculations performed at each fragment in the edge detection phase
    
    if (!(self = [super initWithFirstStageVertexShaderFromString:kGPUImageVertexShaderString firstStageFragmentShaderFromString:kGPUImageLuminanceFragmentShaderString secondStageVertexShaderFromString:kGPUImageNearbyTexelSamplingVertexShaderString secondStageFragmentShaderFromString:fragmentShaderString]))
    {
		return nil;
    }
    
    hasOverriddenImageSizeFactor = NO;
    
    imageWidthFactorUniform = [secondFilterProgram uniformIndex:@"imageWidthFactor"];
    imageHeightFactorUniform = [secondFilterProgram uniformIndex:@"imageHeightFactor"];
    
    return self;
}

- (void)setupFilterForSize:(CGSize)filterFrameSize;
{
    if (!hasOverriddenImageSizeFactor)
    {
        _imageWidthFactor = filterFrameSize.width;
        _imageHeightFactor = filterFrameSize.height;
        
        [GPUImageOpenGLESContext useImageProcessingContext];
        [secondFilterProgram use];
        glUniform1f(imageWidthFactorUniform, 1.0 / _imageWidthFactor);
        glUniform1f(imageHeightFactorUniform, 1.0 / _imageHeightFactor);
    }
}

#pragma mark -
#pragma mark Accessors

- (void)setImageWidthFactor:(CGFloat)newValue;
{
    hasOverriddenImageSizeFactor = YES;
    _imageWidthFactor = newValue;
    
    [GPUImageOpenGLESContext useImageProcessingContext];
    [secondFilterProgram use];
    glUniform1f(imageWidthFactorUniform, 1.0 / _imageWidthFactor);
}

- (void)setImageHeightFactor:(CGFloat)newValue;
{
    hasOverriddenImageSizeFactor = YES;
    _imageHeightFactor = newValue;
    
    [GPUImageOpenGLESContext useImageProcessingContext];
    [secondFilterProgram use];
    glUniform1f(imageHeightFactorUniform, 1.0 / _imageHeightFactor);
}

@end

