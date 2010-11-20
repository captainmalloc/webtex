/*
 *  ConsoleWindowController.j
 *  WebTex
 *
 *  Created by Adriano Scoditti on 6/6/10.
 *  Copyright LIG 2010. All rights reserved.
*/

@import <AppKit/AppKit.j>
@import <Foundation/Foundation.j>
@import "LPMultiLineTextField.j"

@implementation ConsoleWindowController : CPWindowController
{
    var sharedInstance = nil;
    var textView;
    var currentStringValue;
}

+ (id) sharedConsole {
    return sharedInstance;
}

- (id) initWithWindow: (CPWindow) win
{
    if (self = [super initWithWindow:win])
    {
        sharedInstance = self;
        
    }
    return self;
}

- (void) windowDidLoad {
    textView = [[LPMultiLineTextField alloc] initWithFrame:[[[self window] contentView] bounds]];
    [textView setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
    [[[self window] contentView] addSubview:textView];
    [textView setDelegate:self];
    [textView setEditable:YES];
    currentStringValue = "Console...";
    [textView setStringValue: currentStringValue];
}

- (void)log:(CPString)aLog
{
    currentStringValue = currentStringValue + "\n" + aLog;
    [textView setStringValue: currentStringValue];
}

@end