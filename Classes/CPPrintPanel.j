/*
 *  PrintWindowController.j
 *  WebTex
 *
 *  Created by Adriano on 10/6/10.
 *  Copyright LIG 2010. All rights reserved.
*/

//@import <AppKit/AppKit.j>
//@import <Foundation/Foundation.j>

@import <AppKit/CPPanel.j>
@import <AppKit/CPWebView.j>

@import "ConsoleWindowController.j"

@implementation CPPrintPanel : CPPanel
{
    var webview;
}

+ (id)printPanel
{
    return [[CPPrintPanel alloc] init];
}

- (void)setWebView:(CPWebView)aWebView
{
    webview = aWebView;
}

- (CPInteger)runModal 
{
    var button_width = 100;
    var button_height = 25;
    var border_inset = 20;
    var inter_components_inset = 8;
    
    [self setFrame:CGRectMake(0,0,500,550)];
    [self center];
    
    var contentView = [self contentView];
    var contentBounds = [contentView bounds];
    var webview_frame = contentBounds;
    webview_frame.size.height = webview_frame.size.height-border_inset-button_height-inter_components_inset;
    [webview setFrame:webview_frame];
    [webview setAutoresizingMask:CPViewWidthSizable| CPViewHeightSizable];
    [contentView addSubview:webview];
    
    var print_button_frame = CGRectMake(webview_frame.size.width-border_inset-button_width,
                                        webview_frame.size.height+inter_components_inset,
                                        button_width, button_height);
    var print_button = [[CPButton alloc] initWithFrame:print_button_frame];
    [print_button setTitle:@"Print"];
    [print_button setAction:@selector(print:)];
    [print_button setTarget:self];
    [print_button setAutoresizingMask:CPViewMinXMargin| CPViewMinYMargin ];
    [contentView addSubview:print_button];
    
    var cancel_button_frame = CGRectMake(print_button_frame.origin.x-inter_components_inset-button_width, 
                                         print_button_frame.origin.y, 
                                         button_width, button_height);
    var cancel_button = [[CPButton alloc] initWithFrame: cancel_button_frame];
    [cancel_button setTitle:@"Cancel"];
    [cancel_button setAction:@selector(cancel:)];
    [cancel_button setTarget:self];
    [cancel_button setAutoresizingMask:CPViewMinXMargin | CPViewMaxXMargin | CPViewMinYMargin | CPViewMaxYMargin];
    [contentView addSubview:cancel_button];
    
    //[webview loadHTMLString:"<html><head></head><body><pre><code>Loading...</pre></code></body></html>"];
    
    [CPApp runModalForWindow:self];
    
    return 0;
}

- (void)print:(id)sender
{
    [webview print:sender];
    [CPApp abortModal];
    [self close];
}

- (void)cancel:(id)sender {
    [CPApp abortModal];
    [self close];
}

@end