/*
 *  TexDocument.j
 *  WebTex
 *
 *  Created by Adriano Scoditti on 7/6/10.
 *  Copyright LIG 2010. All rights reserved.
*/

@import <Foundation/Foundation.j>
@import <AppKit/CPDocument.j>
@import "PathsManager.j"
@import "ConsoleWindowController.j"
@import "CPSavePanel-Error.j"

@import "TexWindowController.j"
@import "PDFWindowController.j"
@import "CPPrintPanel.j"

@import <AppKit/CPDocumentController.j>

var WIN_VERTICAL_OFFSET=5;
var WIN_HORIZONTAL_OFFSET=5;
var CONSOLE_HEIGHT=200;

var WindowMenuTitleItemIdentifier = @"Windows";

@implementation CPDocument (MyReadAndSaveURLWindowMenuCompatible)

- (void)saveToURL:(CPURL)anAbsoluteURL ofType:(CPString)aTypeName forSaveOperation:(CPSaveOperationType)aSaveOperation delegate:(id)aDelegate didSaveSelector:(SEL)aDidSaveSelector contextInfo:(id)aContextInfo
{
    //Probably this is nasty but the window controller doesn't know when a document is being saved or
    //saved as, so I need to retrieve here the index of this document on the window menu and later use
    //it to update the name of this document on the menu itself... 
    var indexOnWinsMenu = [[CPDocumentController sharedDocumentController] indexOfWindowMenuForDocument:self];
    
    //Check the extension of the proposed filename
    var aName = [anAbsoluteURL absoluteString];
    var supportedFileType = [self fileType];
    if (![[aName pathExtension] isEqualToString:supportedFileType]) {
        aName += "." + supportedFileType;
    }
    
    [texwincontroller saveFileWithName:aName];
    [self setFileURL:[CPURL URLWithString:aName]];
    [self _sendDocumentSavedNotification:YES]; //For compatibility reasons, the original method does!
    
    [[CPDocumentController sharedDocumentController] refreshItemOnWindowMenuForDocument:self atIndex:indexOnWinsMenu];
}

@end

var _recentDocumentURLs = nil;

@implementation CPDocumentController (BugsCorrection)

- (void)clearRecentDocuments:(id)sender
{
    [[self recentDocumentURLs] removeAllObjects];
    [self _updateRecentDocumentsMenu];
    [self _updateRecentDocumentsMenu]; //There is a bug in the Cappuccino code regarding the menu separator
    if ([sender respondsToSelector:@selector(_menuItemView)])
        [[sender _menuItemView] highlight:NO];
}

- (void)noteNewRecentDocumentURL:(CPString)aURL
{
    var recentDocs = [self recentDocumentURLs];
    var index = 0;
    var count = [recentDocs count];
    var shouldAdd = YES;
    for (;shouldAdd && index<count; index++) {
        var temp = [recentDocs objectAtIndex:index];
        if ([[temp absoluteString] isEqualToString:aURL]) {
            shouldAdd = NO;
        }
    }
    if (shouldAdd) {
        [[self recentDocumentURLs] addObject:[CPURL URLWithString:aURL]];
        [self _updateRecentDocumentsMenu];
    }
}

- (CPArray)recentDocumentURLs {
    if (_recentDocumentURLs == nil) {
        _recentDocumentURLs = [[CPArray alloc] init];
    }
        
    return _recentDocumentURLs;
}

- (void)_openRecentDocument:(id)sender
{
    [self openDocumentWithContentsOfURL:[CPURL URLWithString:[sender title]] display:YES error:nil];
}

@end


@implementation CPDocumentController (WindowMenu)

- (void)addDocument:(CPDocument)aDocument
{
    [_documents addObject:aDocument];
    [self addItemOnWindowMenuWithDocument:aDocument];
}
 
- (void)removeDocument:(CPDocument)aDocument
{
    [_documents removeObjectIdenticalTo:aDocument];
    [self removeItemOnWindowMenuWithDocument:aDocument];
}

- (void) addItemOnWindowMenuWithDocument:(CPDocument)aDocument
{
    var aTitle = [aDocument displayName];
    var winsMenu = [[[CPApp mainMenu] itemWithTitle:WindowMenuTitleItemIdentifier] submenu];
    [winsMenu addItemWithTitle:aTitle action:@selector(orderFrontOpenedDocument:) keyEquivalent:nil];
}

- (void) removeItemOnWindowMenuWithDocument:(CPDocument)aDocument
{
    var aTitle = [aDocument displayName];
    var winsMenu = [[[CPApp mainMenu] itemWithTitle:WindowMenuTitleItemIdentifier] submenu];
    [winsMenu removeItemAtIndex:[winsMenu indexOfItemWithTitle:aTitle]];
}

- (void) refreshItemOnWindowMenuForDocument:(CPDocument)aDocument atIndex:(var)index
{
    var winsMenu = [[[CPApp mainMenu] itemWithTitle:WindowMenuTitleItemIdentifier] submenu];
    var menuItem = [winsMenu  itemAtIndex:index];
    [menuItem setTitle:[aDocument displayName]];
}

- (var) indexOfWindowMenuForDocument:(CPDocument)aDocument {
    var winsMenu = [[[CPApp mainMenu] itemWithTitle:WindowMenuTitleItemIdentifier] submenu];
    var index = [winsMenu indexOfItemWithTitle:[aDocument displayName]];
    return index;
}

- (IBAction) orderFrontOpenedDocument:(id)sender
{
    var theDocument;
    var theDocumentDisplayName = [sender title];
    var docs = [self documents];
    var count = [docs count];
    var index = 0;
    for (; index<count; index++) {
        var curr = [docs objectAtIndex:index];
        if ([[curr displayName] isEqualToString:theDocumentDisplayName]) {
            theDocument = curr;
            index = count+1;
        }
    }
    [theDocument showWindows];
}

@end

@implementation TexDocument : CPDocument
{
    var consolewincontroller;
    var texwincontroller;
    var pdfwincontroller;
}

//- (CPString)windowCibName
//{
//	// Implement this to return a nib to load OR implement -makeWindowControllers to manually create your controllers.
//    return @"TexDocument";
//}

- (void) makeWindowControllers
{  
    texwincontroller = [[TexWindowController alloc] initWithWindow:[[CPWindow alloc]
                                                                        initWithContentRect:CGRectMakeZero()
                                                                        styleMask:CPTitledWindowMask|CPResizableWindowMask]];
    pdfwincontroller = [[PDFWindowController alloc] initWithWindow:[[CPWindow alloc]
                                                                        initWithContentRect:CGRectMakeZero()
                                                                        styleMask:CPTitledWindowMask|CPResizableWindowMask]];
    [self arrangeAnimating:NO];
    
    [texwincontroller windowDidLoad];
    [pdfwincontroller windowDidLoad];
    
    var defaultCenter = [CPNotificationCenter defaultCenter];
    [defaultCenter addObserver:self
                           selector:@selector(texManagerDidCompile:)
                               name:WTTexManagerDidCompileSourceNotification
                             object:texwincontroller];
    [defaultCenter addObserver:self
                           selector:@selector(texManagerDidSave:)
                               name:WTTexManagerDidSaveSourceNotification
                             object:texwincontroller];
    
    [self addWindowController:texwincontroller];
    [self addWindowController:pdfwincontroller];
    //[pdfwincontroller showWindow:self];
}

- (void)openFileURL:(CPURL)aFileURL {
    [texwincontroller loadFileNamed:[aFileURL absoluteString]];
    var pdfURL = [aFileURL lastPathComponent];
    pdfURL = [pdfURL stringByReplacingOccurrencesOfString:"tex" withString:"pdf"]
    [pdfwincontroller loadFileNamed:pdfURL];
    [self setFileURL:aFileURL];
}

-(void)arrangeAnimating:(BOOL)animateAndShowWindows
{   
    var visibleFrame = [[CPPlatformWindow primaryPlatformWindow] contentBounds];
    //var visibleFrame = [[theWindow platformWindow] contentBounds];
    var menuBarHeight = [[CPApp mainMenu] menuBarHeight];
    
    var texframe = CGRectMake(visibleFrame.origin.x+WIN_HORIZONTAL_OFFSET, 
                              visibleFrame.origin.y+menuBarHeight+WIN_VERTICAL_OFFSET, 
                              visibleFrame.size.width/2-WIN_HORIZONTAL_OFFSET*2, 
                              visibleFrame.size.height-menuBarHeight-WIN_VERTICAL_OFFSET*2);
                              
    [[texwincontroller window] setFrame:texframe display:YES animate:animateAndShowWindows];
                              
    var pdfframe = CGRectMake(visibleFrame.origin.x+visibleFrame.size.width/2+WIN_HORIZONTAL_OFFSET, 
                                    visibleFrame.origin.y+menuBarHeight+WIN_VERTICAL_OFFSET, 
                                    visibleFrame.size.width/2-WIN_HORIZONTAL_OFFSET*2, 
                                    visibleFrame.size.height-menuBarHeight-WIN_VERTICAL_OFFSET*2-CONSOLE_HEIGHT);
    
    [[pdfwincontroller window] setFrame:pdfframe display:YES animate:animateAndShowWindows];
    
    var consoleframe = CGRectMake(visibleFrame.origin.x+visibleFrame.size.width/2+WIN_HORIZONTAL_OFFSET, 
                                  pdfframe.origin.y+pdfframe.size.height+30, 
                                  visibleFrame.size.width/2-WIN_HORIZONTAL_OFFSET*2, 
                                  CONSOLE_HEIGHT-30);
    
    [[[ConsoleWindowController sharedConsole] window] setFrame:consoleframe display:YES animate:animateAndShowWindows];
    
    if (animateAndShowWindows)
        [self showWindows];
}

- (CPData)dataOfType:(CPString)typeName error:({CPError})outError
{
    // Insert code here to write your document to data of the specified type. If the given outError != NULL, ensure that you set *outError when returning nil.

    // You can also choose to override -fileWrapperOfType:error:, -writeToURL:ofType:error:, or -writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.

    // For applications targeted for Panther or earlier systems, you should use the deprecated API -dataRepresentationOfType:. In this case you can also choose to override -fileWrapperRepresentationOfType: or -writeToFile:ofType: instead.
    
    [[ConsoleWindowController sharedConsole] log:"*** dataOfType: ***"];

    return nil;
}

- (BOOL)readFromData:(CPData)data ofType:(CPString)typeName error:({CPError})outError
{
    // Insert code here to read your document from the given data of the specified type.  If the given outError != NULL, ensure that you set *outError when returning NO.

    // You can also choose to override -readFromFileWrapper:ofType:error: or -readFromURL:ofType:error: instead. 
    
    // For applications targeted for Panther or earlier systems, you should use the deprecated API -loadDataRepresentation:ofType. In this case you can also choose to override -readFromFile:ofType: or -loadFileWrapperRepresentation:ofType: instead.
    
    [[ConsoleWindowController sharedConsole] log:"*** readFromData: ***"];
    
    return YES;
}

- (void)readFromURL:(CPURL)anAbsoluteURL ofType:(CPString)aType delegate:(id)aDelegate didReadSelector:(SEL)aDidReadSelector contextInfo:(id)aContextInfo
{
    [self makeWindowControllers];
    [self openFileURL:anAbsoluteURL];
    [self showWindows];
}

/*
** Menu actions
*/

- (IBAction)close:(id)sender
{
    [CPMenu setMenuBarTitle:""];
    [super close];
}

- (IBAction)saveDocument:(id)sender
{
    [super saveDocument:sender];
    var pdfURL = [[self fileURL] absoluteString];
    pdfURL = [pdfURL stringByReplacingOccurrencesOfString:"tex" withString:"pdf"]
    [pdfwincontroller loadFileNamed:pdfURL];
}

- (IBAction)saveDocumentAs:(id)sender
{
    [super saveDocumentAs:sender];
    var pdfURL = [[self fileURL] absoluteString];
    pdfURL = [pdfURL stringByReplacingOccurrencesOfString:"tex" withString:"pdf"]
    [pdfwincontroller loadFileNamed:pdfURL];
}

- (IBAction)revertDocumentToSaved:(id)sender
{
    [texwincontroller loadFileNamed:[[self fileURL] absoluteString]];
}

-(IBAction)printSource:(id)sender
{
    //var printPlatformWin = [[CPPlatformWindow alloc] init];
    //[printPlatformWin orderFront:self];
    
    //[printWin setPlatformWindow:printPlatformWin];
    var printPanel = [CPPrintPanel printPanel];
    var webview = [[CPWebView alloc] initWithFrame:CGRectMake(0,0,500,550)];
    [webview setAutoresizingMask:CPViewWidthSizable| CPViewHeightSizable];
    [printPanel setWebView:webview];
    [printPanel runModal];
    [webview loadHTMLString:"<html><head></head><body><pre><code>" + [texwincontroller stringValue] + "</pre></code></body></html>"];
}

-(IBAction)downloadPDF:(id)sender
{
    fileName = [pdfwincontroller file_name];
    if (fileName)
        //window.location.href=[[CPBundle mainBundle] resourcePath] + [PathsManager latexDir] + fileName;
        //window.open([[CPBundle mainBundle] resourcePath] + [PathsManager latexDir] + fileName);
        window.open([PathsManager absoluteDocumentDir] + fileName);
    else
        [[ConsoleWindowController sharedConsole] log:"*** No PDF available for the selected document ***"];
}

-(IBAction)forceReloadPDF:(id)sender
{
    [pdfwincontroller forceReload];
}

/*
** Tex-PDF sync notification callbacks
*/

- (void)texManagerDidSave:(CPNotification)aNotification
{
    [texwincontroller compileFileWithName:[[self fileURL] absoluteString]];
}


- (void)texManagerDidCompile:(CPNotification)aNotification
{
    //[self reloadPDF:nil];
    [pdfwincontroller reload];
}

@end