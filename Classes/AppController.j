/*
 *  AppController.j
 *  WebTex
 *
 *  Created by Adriano Scoditti on 4/6/10.
 *  Copyright LIG 2010. All rights reserved.
*/

@import <Foundation/CPObject.j>
@import <AppKit/AppKit.j>
@import "LoginManager.j"
@import "CPOpenPanel+RunModal.j"
@import "PathsManager.j"
@import "TexDocument.j"

@import "TexWindowController.j"
@import "PDFWindowController.j"
@import "ConsoleWindowController.j"
@import "CPPreferencesPanel.j"
@import "AboutPanelController.j"
@import "ImportedPanel.j"

@import "CPCookie_Additions.j"

@import "FileUpload.j"

var WIN_VERTICAL_OFFSET=5;
var WIN_HORIZONTAL_OFFSET=5;
var CONSOLE_HEIGHT=200;

CPPlatformWindowDidResizeNotification = @"CPPlatformWindowDidResizeNotification";

WebTexAutologinCoockieItemIdentifier = @"WebTexAutoLogin";

@implementation AppController : CPObject
{
    var aboutPanelController;
}

- (void)applicationWillFinishLaunching:(CPNotification)aNotification
{
    var visibleFrame = [[CPPlatformWindow primaryPlatformWindow] contentBounds];
    var menuBarHeight = [[CPApp mainMenu] menuBarHeight];
    var consoleInitialWidth = 500;
    var consoleInitialHeight = 250;
    //
    // CONSOLE VIEW
    //
    var consoleframe = CGRectMake(visibleFrame.size.width/2-consoleInitialWidth/2,
                                    visibleFrame.size.height/2-consoleInitialHeight/2,
                                    consoleInitialWidth,
                                    consoleInitialHeight);
    var consolewincontroller = [[ConsoleWindowController alloc] initWithWindow:[[CPWindow alloc]
                                                                        initWithContentRect:consoleframe
                                                                        styleMask:CPTitledWindowMask|CPResizableWindowMask]];
    [consolewincontroller windowDidLoad];
    [consolewincontroller showWindow:self];
}

- (void)applicationDidFinishLaunching:(CPNotification)aNotification
{
    var autologinCoockie = [CPCookie cookieWithName:WebTexAutologinCoockieItemIdentifier];
    var autologinCoockieValue = [autologinCoockie value];
    if ([autologinCoockieValue isEqualToString:""])
        [[LoginManager loginManager] loginWithDefaultUser];
    else
        [[LoginManager loginManager] performLoginWithUser:autologinCoockieValue];
        
    window.onresize = function(event) {
        [self arrangeWindows:nil];
    }
    
    var mainMenu = [CPApp mainMenu];
    var uploadMenuItem = [[CPMenuItem alloc] initWithTitle:"Upload" action:nil keyEquivalent:nil];
    
//    //var urlString = [PathsManager absolutePhpURL] + "upload.php";
//    var urlString = "Resources/php/upload.php";
//    var fileUploadButton = [[UploadButton alloc] initWithFrame:CGRectMake(0, 0, 100, 25)];
//    //[fileUploadButton setFont:[mainMenu font]];
//    [fileUploadButton setTitle:"Upload"];
//    [fileUploadButton setBordered:NO];
//    [fileUploadButton sizeToFit];
//    
//    [fileUploadButton allowsMultipleFiles:YES];
//    [fileUploadButton setURL:urlString];
//    [fileUploadButton setDelegate:self]; 
//    [fileUploadButton setValue:[PathsManager documentsPathRelativeToPHP] forParameter:"updirrelpath"];
//    
//    [uploadMenuItem setView:fileUploadButton];
//    [mainMenu addItem:uploadMenuItem];
}

/*
** Menu actions
*/

- (IBAction)newDocument:(id)sender
{
    var sharedDocumentController = [CPDocumentController sharedDocumentController];

	var documents = [sharedDocumentController documents];
	var defaultType = [sharedDocumentController defaultType];

	[sharedDocumentController newDocument:self];
}

- (IBAction)openDocument:(id)sender
{
    var sharedDocumentController = [CPDocumentController sharedDocumentController];
    var documents = [sharedDocumentController documents];
	var defaultType = [sharedDocumentController defaultType];
    [sharedDocumentController openDocument:sender];
}

- (IBAction)performClose:(id)sender
{
    [[ConsoleWindowController sharedConsole] log:"Perform Close"];
}

- (IBAction)register:(id)sender
{
    [[CPDocumentController sharedDocumentController] closeAllDocumentsWithDelegate:nil
                                                               didCloseAllSelector:nil
                                                                       contextInfo:nil];
    [[CPDocumentController sharedDocumentController] clearRecentDocuments:nil];
    [CPMenu setMenuBarTitle:""];
    [[LoginManager loginManager] register];
}

- (IBAction)login:(id)sender
{
    [[CPDocumentController sharedDocumentController] closeAllDocumentsWithDelegate:nil
                                                               didCloseAllSelector:nil
                                                                       contextInfo:nil];
    [[CPDocumentController sharedDocumentController] clearRecentDocuments:nil];
    [CPMenu setMenuBarTitle:""];
    [[LoginManager loginManager] login];
}

- (IBAction)logout:(id)sender
{
    [[CPDocumentController sharedDocumentController] closeAllDocumentsWithDelegate:nil
                                                               didCloseAllSelector:nil
                                                                       contextInfo:nil];
    [[CPDocumentController sharedDocumentController] clearRecentDocuments:nil];
    [CPMenu setMenuBarTitle:""];
    [[LoginManager loginManager] logout];
}

-(IBAction)arrangeWindows:(id)sender
{ 
    var animate = NO;
    if (sender)
        animate = YES;
        
    var docs = [[CPDocumentController sharedDocumentController] documents];
    var count = [docs count];
    var index = 0;
    for (; index<count; index++) {
        [[docs objectAtIndex:index] arrangeAnimating:animate];
    }
}

- (IBAction) uploads: (id)sender
{
    [[ImportedPanel importedPanel] runModal];
}

- (IBAction)import:(id)sender
{
    [[UploadPanel uploadPanel] runModal];
}

- (IBAction) terminateApplication: (id)sender
{   
    [[CPDocumentController sharedDocumentController] closeAllDocumentsWithDelegate:nil
                                                               didCloseAllSelector:nil
                                                                       contextInfo:nil];
    [CPMenu setMenuBarTitle:""];
    [[LoginManager loginManager] logout];
}

//UploadButton delegate

//-(void) uploadButton:(UploadButton)button didChangeSelection:(CPArray)selection
//{
//    [[ConsoleWindowController sharedConsole] log:"Selection has been made: " + selection];
//
//    [button submit];
//}
//
//-(void) uploadButton:(UploadButton)button didFailWithError:(CPString)anError
//{
//    [[ConsoleWindowController sharedConsole] log:"Upload failed with this error: " + anError];
//}
//
//-(void) uploadButton:(UploadButton)button didFinishUploadWithData:(CPString)response
//{
//    [[ConsoleWindowController sharedConsole] log:"Upload finished with this response: " + response];
//    [button resetSelection];
//}
//
//-(void) uploadButtonDidBeginUpload:(UploadButton)button
//{
//    [[ConsoleWindowController sharedConsole] log:"Upload has begun with selection: " + [button selection]];
//}

/*
** Preferences Window
*/
- (IBAction)preferences:(id)sender
{
    [[CPPreferencesPanel preferencesPanel] runModal];
}

/*
** About Panel
*/

- (IBAction)orderFrontAboutPanel:(id)sender
{
    var visibleFrame = [[CPPlatformWindow primaryPlatformWindow] contentBounds];
    var panel_width = 400;
    var panel_height = 250;
    
    if (!aboutPanelController) {
        var aboutPanelController = [[AboutPanelController alloc] initWithWindow:[[CPWindow alloc]
                                                                        initWithContentRect:CGRectMake(visibleFrame.size.width/2-panel_width/2,
                                                                                                       visibleFrame.size.height/2-panel_height/2,
                                                                                                       panel_width,panel_height)
                                                                        styleMask:CPTitledWindowMask|CPClosableWindowMask|CPResizableWindowMask]];
        [aboutPanelController windowDidLoad];
    }
    [aboutPanelController showWindow:self];
}

@end
