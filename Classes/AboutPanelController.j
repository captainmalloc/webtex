/*
 *  AboutPanelController.j
 *  WebTex
 *
 *  Created by Adriano Scoditti on 7/6/10.
 *  Copyright LIG 2010. All rights reserved.
*/

@import <AppKit/AppKit.j>
@import <Foundation/Foundation.j>
@import <AppKit/CPWebView.j>

@implementation AboutPanelController : CPWindowController
{
    var webview;
}

- (void) windowDidLoad {
    webview = [[CPWebView alloc] initWithFrame:[[[self window] contentView] bounds]];
    [webview setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
    [[[self window] contentView] addSubview:webview];
    
    [webview setMainFrameURL:[[CPBundle mainBundle] pathForResource:"About.html"]];
    //[webview setMainFrameURL:"http://www.google.com"];
    
}

@end