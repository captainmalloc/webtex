/*
 *  CPFileView.j
 *  WebTex
 *
 *  Created by Adriano Scoditti on 9/6/10.
 *  Copyright LIG 2010. All rights reserved.
*/

@import <AppKit/AppKit.j>
@import <Foundation/Foundation.j>
@import "CPFileRepresentationComponents.j"

@import "ConsoleWindowController.j"

label_height = 20;

@implementation CPFileView : CPView
{
    CPView _wrapper;
    CPImageView _imageView;
    CPTextField _label;
}

- (void)setRepresentedObject:(id)anObject
{
    if (!_wrapper)
    {
        var rect = CGRectMake(0, 0, 200, 100); //Any Frame will be fine!
        _wrapper = [[CPView alloc] initWithFrame:rect];
        
        var img_frame = CGRectInset(rect, label_height, label_height);
        _imageView = [[CPImageView alloc] initWithFrame:img_frame];
        //[_imageView setImageScaling:CPScaleToFit];
        //[_imageView setImageScaling:CPScaleNone];
        [_imageView setImageScaling:CPScaleProportionally];
        [_imageView setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
        [_wrapper addSubview:_imageView];
        
        _label = [CPTextField labelWithTitle:"Placeholder"];
        [_label setEditable:NO];
        [_label setAlignment:CPCenterTextAlignment];
        [_wrapper addSubview:_label];
        
        [self addSubview:_wrapper];
    }
    [_imageView setImage:[anObject image]];
    [_label setStringValue:[anObject description]];
    //[_label setBackgroundColor:[CPColor grayColor]];
    [_label sizeToFit];
    [_label setFrame:CGRectMake(CGRectGetMinX([_imageView frame]),CGRectGetMaxY([_imageView frame]),CGRectGetWidth([_imageView frame]), CGRectGetHeight([_imageView frame]))];
}

- (void)setSelected:(BOOL)isSelected
{
    //var selectionColor = [CPColor colorWithRed:0.69 green:0.73 blue:0.76 alpha:1.0];
    var selectionColor = [CPColor colorWithRed:0.37 green:0.51 blue:0.72 alpha:1.0];
    [self setBackgroundColor:isSelected ? selectionColor : nil];
}

@end