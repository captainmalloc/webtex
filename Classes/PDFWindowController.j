/*
 *  PDFWindowController.j
 *  WebTex
 *
 *  Created by Adriano Scoditti on 6/6/10.
 *  Copyright LIG 2010. All rights reserved.
*/

@import <AppKit/AppKit.j>
@import <Foundation/Foundation.j>
@import <AppKit/CPWebView.j>
@import "PathsManager.j"
@import "ConsoleWindowController.j"

@implementation PDFWindowController : CPWindowController
{
    CPWebView webview;
    var file_name @accessors;
}

- (void) windowDidLoad {
    webview = [[CPWebView alloc] initWithFrame:[[[self window] contentView] bounds]];
    [webview setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
    [[[self window] contentView] addSubview:webview];
}

- (CPWebView)PDFWebView
{
    return webview;
}

- (void) loadFileNamed:(CPString)aName
{
    if (file_name && [file_name isEqualToString:aName]) {
        //[[ConsoleWindowController sharedConsole] log: "***\n*** Don't need to load pdf ***\n***"];
        return;
    }
    file_name = aName;
    [self generatePDFWebFrame];
}

- (void) reload {
    [[ConsoleWindowController sharedConsole] log: "***\n*** Reload pdf ***\n***"];
    [webview reload:self];
}

- (void) forceReload {
    [webview removeFromSuperview];
    webview = [[CPWebView alloc] initWithFrame:[[[self window] contentView] bounds]];
    [webview setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
    [[[self window] contentView] addSubview:webview];
    [self generatePDFWebFrame];
}

- (void) generatePDFWebFrame {
    var body = "pdfrelpath=" + [PathsManager documentsPathRelativeToPHP] + file_name + "&pdfabspath=" + [PathsManager absoluteDocumentDir] + file_name;
    var request = [CPURLRequest requestWithURL:[PathsManager absolutePhpURL] + "GeniFrame.php"];
    [request setHTTPMethod:"POST"];
    [request setValue:"application/x-www-form-urlencoded" forHTTPHeaderField:"Content-Type"];
    [request setValue:[body length] forHTTPHeaderField:"Content-Length"];
    [request setHTTPBody:body];
    var connection = [CPURLConnection connectionWithRequest:request delegate:self];
}

/*
** Connection callbacks
*/
- (void)connection:(CPURLConnection) connection didReceiveData:(CPString)data
{
    [[ConsoleWindowController sharedConsole] log:data];
    var pdfwebpage = [PathsManager absoluteDocumentDir] + data; 
    [webview setMainFrameURL:pdfwebpage];
    [[ConsoleWindowController sharedConsole] log:data];
}

- (void)connection:(CPURLConnection)connection didFailWithError:(CPString)error
{
    [[ConsoleWindowController sharedConsole] log:data];
}

@end