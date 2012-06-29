//
//  CannyEdgeTrackingFilter.m
//  ios_video
//
//  Created by Lieven Govaerts on 20/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CannyEdgeTrackingFilter.h"
#import "GPUImage3x3ConvolutionFilter.h"

NSString *const kCannyEdgeTrackingFilterFragmentShaderString = SHADER_STRING
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
  
 void main()
 {
     float low_treshold = 20.0/255.0;
     float high_treshold = 200.0/255.0;

     float strength = texture2D(inputImageTexture, textureCoordinate).a;
     if (strength <= low_treshold) {
         gl_FragColor = vec4(vec3(0.0), 1.0); // black
         return;
     }

     float topLeftStrength = texture2D(inputImageTexture, topLeftTextureCoordinate).a;
     float topStrength = texture2D(inputImageTexture, topTextureCoordinate).a;
     float topRightStrength = texture2D(inputImageTexture, topRightTextureCoordinate).a;
     float leftStrength = texture2D(inputImageTexture, leftTextureCoordinate).a;
     float rightStrength = texture2D(inputImageTexture, rightTextureCoordinate).a;
     float bottomLeftStrength = texture2D(inputImageTexture, bottomLeftTextureCoordinate).a;
     float bottomStrength = texture2D(inputImageTexture, bottomTextureCoordinate).a;
     float bottomRightStrength = texture2D(inputImageTexture, bottomRightTextureCoordinate).a;
     
     float new_strength = -1.0;
     vec3 screen_color;

     gl_FragColor = vec4(vec3(0.1), 1.0); // black
     vec4 newStrength;
     if (edge_dir <= 45.0/180.0) { // 157,5..22,5
         new_strength = max(leftStrength.r, rightStrength.r);
         screen_color = vec3(1.0, 1.0, 0.0); // yellow         
     } else if (edge_dir <= 90.0/180.0) { // 22,5..67,5
         new_strength = max(bottomLeftStrength.r, topRightStrength.r);
         screen_color = vec3(0.0, 1.0, 0.0); // green
     } else if (edge_dir <= 135.0/180.0) { // 67,5..112,5
         new_strength = max(topStrength.r, bottomStrength.r);
         screen_color = vec3(0.0, 0.0, 1.0); // blue
     } else { // 112,5..157,5
         new_strength = max(topLeftStrength.r, bottomRightStrength.r);
         screen_color = vec3(1.0, 0.0, 0.0); // red
     }
     
     if (strength < new_strength)
         screen_color = vec3(0.0); // black
     
     gl_FragColor = vec4(vec3(screen_color), 1.0);
 }
 );

@implementation CannyEdgeTrackingFilter

- (id)init;
{
    if (!(self = [super initWithFragmentShaderFromString:kCannyEdgeTrackingFilterFragmentShaderString]))
    {
        return nil;
    }
    
    return self;
}

@end

