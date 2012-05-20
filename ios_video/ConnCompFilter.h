//
//  ConnCompFilter.h
//  ios_video
//
//  Created by Lieven Govaerts on 01/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GPUImageFilter.h"

@interface ConnCompFilter : GPUImageFilter
{
    GLuint _positionSlot;
    GLuint _colorSlot;
    
    GLint imageWidthFactorUniform, imageHeightFactorUniform;
}

@end
