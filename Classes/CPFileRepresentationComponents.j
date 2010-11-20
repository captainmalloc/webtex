/*
 *  CPFileRepresentationComponents.j
 *  WebTex
 *
 *  Created by Adriano Scoditti on 9/6/10.
 *  Copyright LIG 2010. All rights reserved.
*/

@import <Foundation/Foundation.j>

@implementation CPFileRepresentationComponents : CPObject
{
    var _image;
    var _description;
}

- (id)initWithImage:(CPImage)anImage description:(CPString)description {
    self = [super init];
    if (self) {
        _image = anImage;
        _description = description;
    }
    return self;
}

- (CPImage)image 
{  
    return _image;
}

- (CPString)description
{
    return _description;
}

@end