/*
 *  TexWindowController.j
 *  WebTex
 *
 *  Created by Adriano Scoditti on 7/6/10.
 *  Copyright LIG 2010. All rights reserved.
*/

@import <AppKit/AppKit.j>
@import <Foundation/Foundation.j>
@import "LPMultiLineTextField.j"
@import "ConsoleWindowController.j"
@import "PathsManager.j"
@import "UploadPanel.j"

WTTexManagerDidCompileSourceNotification = @"WTTexManagerDidCompileSourceNotification";
WTTexManagerDidSaveSourceNotification = @"WTTexManagerDidSaveSourceNotification";

WTTypesetToolbarItemIdentifier = @"WTTypesetToolbarItemIdentifier";
WTPrintSourceToolbarItemIdentifier = @"WTPrintSourceToolbarItemIdentifier";
WTPrintPDFToolbarItemIdentifier = @"WTPrintPDFToolbarItemIdentifier";
WTTemplatesToolbarItemIdentifier = @"WTTemplatesToolbarItemIdentifier";
WTImportFileToolbarItemIdentifier = @"WTImportFileToolbarItemIdentifier";

toolbarVisibleOldValue = NO;

@implementation CPWindow (ToolbarBug)

- (void)toggleToolbarShown:(id)aSender
{
    var toolbar = [self toolbar];
     
    toolbarVisibleOldValue = !toolbarVisibleOldValue; 
    
    [toolbar setVisible:![toolbar isVisible]];
}

 - (void)_noteToolbarChanged
{
    var frame = CGRectMakeCopy([self frame]),
        newFrame;
 
    [_windowView noteToolbarChanged];
 
    if (_isFullPlatformWindow)
        newFrame = [_platformWindow visibleFrame];
    else
    {
        newFrame = CGRectMakeCopy([self frame]);
        if (toolbarVisibleOldValue)
            newFrame.size.height += CGRectGetHeight([[[self toolbar] _toolbarView] frame]);
        else
            newFrame.size.height -= CGRectGetHeight([[[self toolbar] _toolbarView] frame]);
        newFrame.origin = frame.origin;
    }
     
    [self setFrame:newFrame];
    /*
    [_windowView setAnimatingToolbar:YES];
    [self setFrame:frame];
    [self setFrame:newFrame display:YES animate:YES];
    [_windowView setAnimatingToolbar:NO];
    */
}

@end

@implementation TexWindowController : CPWindowController
{
    var textView;
    var list_connection;
    var read_connection;
    var save_connection;
    var compile_connection;
    
    var available_templates;
}

- (void) windowWillLoad {
}

- (void) windowDidLoad {
    textView = [[LPMultiLineTextField alloc] initWithFrame: [[[self window] contentView] bounds]];
    [textView setEditable:YES];
    [textView setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
    [textView setStringValue:"Text Placeholder"];
    [[[self window] contentView] addSubview:textView];
    
    //var newFrame = CGRectMakeCopy([[self window] frame]);
    //newFrame.size.height = CGRectGetHeight([[[self toolbar] _toolbarView] frame]);
    [self listsTemplateNames];
}

- (void) reload {
    [textView setNeedsDisplay:YES];
}

- (CPString)stringValue
{
    return [textView stringValue];
}

/*
** Connection Requests
*/

- (void) loadFileNamed:(CPString)aName
{
    //READ
    var body = "texpath=" + [PathsManager documentsPathRelativeToPHP] + aName;
    var request = [CPURLRequest requestWithURL:[PathsManager absolutePhpURL] + "ReadSource.php"];
    [request setHTTPMethod:"POST"];
    [request setValue:"application/x-www-form-urlencoded" forHTTPHeaderField:"Content-Type"];
    [request setValue:[body length] forHTTPHeaderField:"Content-Length"];
    [request setHTTPBody:body];
    
    read_connection = [CPURLConnection connectionWithRequest:request delegate:self];
}

- (void) loadTemplateNamed:(CPString)aName
{
    //READ
    var body = "texpath=" + [PathsManager templatesPathRelativeToPHP] + aName;
    var request = [CPURLRequest requestWithURL:[PathsManager absolutePhpURL] + "ReadSource.php"];
    [request setHTTPMethod:"POST"];
    [request setValue:"application/x-www-form-urlencoded" forHTTPHeaderField:"Content-Type"];
    [request setValue:[body length] forHTTPHeaderField:"Content-Length"];
    [request setHTTPBody:body];
    
    read_connection = [CPURLConnection connectionWithRequest:request delegate:self];
}

- (void) loadFileWithURL:(CPURL)aFileURL
{
    //READ
    var fileName = [aFileURL lastPathComponent];
    var body = "texpath=" + [PathsManager documentsPathRelativeToPHP] + aName;
    var request = [CPURLRequest requestWithURL:[PathsManager absolutePhpURL] + "ReadSource.php"];
    [request setHTTPMethod:"POST"];
    [request setValue:"application/x-www-form-urlencoded" forHTTPHeaderField:"Content-Type"];
    [request setValue:[body length] forHTTPHeaderField:"Content-Length"];
    [request setHTTPBody:body];
    
    read_connection = [CPURLConnection connectionWithRequest:request delegate:self];
}

//- (void) saveFile {
//    //SAVE
//    var text = [textView stringValue];
//    var body = "texcontent="+text+"&texpath=" + [PathsManager document];
//    var request = [CPURLRequest requestWithURL:[PathsManager absolutePhpURL] + "SaveSource.php"];
//    [request setHTTPMethod:"POST"];
//    [request setValue:"application/x-www-form-urlencoded" forHTTPHeaderField:"Content-Type"];
//    [request setValue:[body length] forHTTPHeaderField:"Content-Length"];
//    [request setHTTPBody:body];
//    save_connection = [CPURLConnection connectionWithRequest:request delegate:self];
//}

- (void) saveFileWithName:(CPString)aName
{
    //SAVE
    var text = [textView stringValue];
    var body = "texcontent="+escape(text)+"&texpath=" + [PathsManager documentsPathRelativeToPHP] + aName;
    var request = [CPURLRequest requestWithURL:[PathsManager absolutePhpURL] + "SaveSource.php"];
    [request setHTTPMethod:"POST"];
    [request setValue:"application/x-www-form-urlencoded" forHTTPHeaderField:"Content-Type"];
    [request setValue:[body length] forHTTPHeaderField:"Content-Length"];
    [request setHTTPBody:body];
    save_connection = [CPURLConnection connectionWithRequest:request delegate:self];

}

- (void) compileFileWithName:(CPString)aName
{
    //COMPILE
    var body = "texpath=" + [PathsManager documentsPathRelativeToPHP] + "/" + aName;
    var request = [CPURLRequest requestWithURL:[PathsManager absolutePhpURL] + "Compile.php"];
    [request setHTTPMethod:"POST"];
    [request setValue:"application/x-www-form-urlencoded" forHTTPHeaderField:"Content-Type"];
    [request setValue:[body length] forHTTPHeaderField:"Content-Length"];
    [request setHTTPBody:body];
    compile_connection = [CPURLConnection connectionWithRequest:request delegate:self];
}

- (void) listsTemplateNames
{
    //RETRIVE FILES
    var body = "dirpath=" + [PathsManager templatesPathRelativeToPHP];
    var request = [CPURLRequest requestWithURL:[PathsManager absolutePhpURL] + "ListSources.php"];
    [request setHTTPMethod:"POST"];
    [request setValue:"application/x-www-form-urlencoded" forHTTPHeaderField:"Content-Type"];
    [request setValue:[body length] forHTTPHeaderField:"Content-Length"];
    [request setHTTPBody:body];
    
    list_connection = [CPURLConnection connectionWithRequest:request delegate:self];
}

/*
** Connection callbacks
*/

- (void)connection:(CPURLConnection) connection didReceiveData:(CPString)data
{
    var defaultCenter = [CPNotificationCenter defaultCenter];
    if (connection == read_connection) {
        [textView setStringValue:data];
    } else if (connection == save_connection) {
        [defaultCenter postNotificationName:WTTexManagerDidSaveSourceNotification
                                  object:self]; 
    } else if ((connection == compile_connection)) {
        [[ConsoleWindowController sharedConsole] log:data];
        [defaultCenter postNotificationName:WTTexManagerDidCompileSourceNotification
                                  object:self];
    } else if (connection == list_connection) {
        available_templates = [data componentsSeparatedByString:" "];
        
        var toolbar = [[CPToolbar alloc] initWithIdentifier:"LaTex"];
        [toolbar setDisplayMode:CPToolbarDisplayModeIconOnly]; //Empty in this release of cappuccino
        [toolbar setDelegate:self];
        [toolbar setVisible:!toolbarVisibleOldValue];
        [[self window] setToolbar:toolbar];
    }
}

- (void)connection:(CPURLConnection)connection didFailWithError:(CPString)error
{
    [[ConsoleWindowController sharedConsole] log:data];
}

/*
** Toolbar Delegate
*/

// Return an array of toolbar item identifier (all the toolbar items that may be present in the toolbar)
- (CPArray)toolbarAllowedItemIdentifiers:(CPToolbar)aToolbar
{
   return [WTTypesetToolbarItemIdentifier,
            CPToolbarFlexibleSpaceItemIdentifier,
            WTImportFileToolbarItemIdentifier,
            WTTemplatesToolbarItemIdentifier,
            CPToolbarFlexibleSpaceItemIdentifier,
            WTPrintSourceToolbarItemIdentifier, 
            WTPrintPDFToolbarItemIdentifier];
}

// Return an array of toolbar item identifier (the default toolbar items that are present in the toolbar)
- (CPArray)toolbarDefaultItemIdentifiers:(CPToolbar)aToolbar
{
   return [WTTypesetToolbarItemIdentifier,
            CPToolbarFlexibleSpaceItemIdentifier,
            WTImportFileToolbarItemIdentifier,
            WTTemplatesToolbarItemIdentifier,
            CPToolbarFlexibleSpaceItemIdentifier,
            WTPrintSourceToolbarItemIdentifier, 
            WTPrintPDFToolbarItemIdentifier];
}

- (CPToolbarItem)toolbar:(CPToolbar)aToolbar itemForItemIdentifier:(CPString)anItemIdentifier willBeInsertedIntoToolbar:(BOOL)aFlag
{
    var toolbarItem = [[CPToolbarItem alloc] initWithItemIdentifier:anItemIdentifier];
    var button_width = 100;
    var button_height = 25;

    if (anItemIdentifier == WTTypesetToolbarItemIdentifier)
    {   
        var button = [[CPButton alloc] initWithFrame: CGRectMake(0, 0, button_width, button_height)];
        [button setTitle:@"Typeset"];
        [button setTarget:self];
        [button setAction:@selector(typeset:)];
        [button setAutoresizingMask:CPViewMinXMargin | CPViewMinYMargin ];
        
        [toolbarItem setView: button];
        [toolbarItem setLabel:"Typeset"];

        [toolbarItem setMinSize:CGSizeMake(button_width, button_height)];
        [toolbarItem setMaxSize:CGSizeMake(button_width, button_height)];   
    }
    else if (anItemIdentifier == WTPrintSourceToolbarItemIdentifier)
    {
        var button = [[CPButton alloc] initWithFrame: CGRectMake(0, 0, button_width, button_height)];
        [button setTitle:@"Print Source"];
        [button setTarget:self];
        [button setAction:@selector(printSource:)];
        [button setAutoresizingMask:CPViewMinXMargin | CPViewMinYMargin ];
        
        [toolbarItem setView: button];
        [toolbarItem setLabel:"Print Source"];

        [toolbarItem setMinSize:CGSizeMake(button_width, button_height)];
        [toolbarItem setMaxSize:CGSizeMake(button_width, button_height)]; 
    }
    else if (anItemIdentifier == WTPrintPDFToolbarItemIdentifier) {
        
        var button = [[CPButton alloc] initWithFrame: CGRectMake(0, 0, button_width, button_height)];
        [button setTitle:@"Download PDF"];
        [button setTarget:self];
        [button setAction:@selector(downloadPDF:)];
        [button setAutoresizingMask:CPViewMinXMargin | CPViewMinYMargin ];
        
        [toolbarItem setView: button];
        [toolbarItem setLabel:"Download PDF"];

        [toolbarItem setMinSize:CGSizeMake(button_width, button_height)];
        [toolbarItem setMaxSize:CGSizeMake(button_width, button_height)]; 
    }
    else if (anItemIdentifier == WTTemplatesToolbarItemIdentifier) {
        templatesPopUp = [[CPPopUpButton alloc] initWithFrame: CGRectMake(0, 0, button_width, button_height) pullsDown:YES];
        [templatesPopUp setTitle:@"Templates"];
        [templatesPopUp setAutoresizingMask:CPViewMinXMargin | CPViewMinYMargin ];
        [templatesPopUp setTarget:self];
        [templatesPopUp setAction:@selector(popUpSelected:)];
        
        [toolbarItem setView:templatesPopUp];
        [toolbarItem setLabel:"Templates"];
        
        [templatesPopUp addItemsWithTitles:available_templates];

        [toolbarItem setMinSize:CGSizeMake(button_width, button_height)];
        [toolbarItem setMaxSize:CGSizeMake(button_width, button_height)]; 
    }
    else if (anItemIdentifier == WTImportFileToolbarItemIdentifier) {
        var button = [[CPButton alloc] initWithFrame: CGRectMake(0, 0, button_width, button_height)];
        [button setTitle:@"Import"];
        [button setTarget:[[CPApplication sharedApplication] delegate]]; //AppController
        [button setAction:@selector(import:)];
        [button setAutoresizingMask:CPViewMinXMargin | CPViewMinYMargin ];
        
        [toolbarItem setView: button];
        [toolbarItem setLabel:"Import"];

        [toolbarItem setMinSize:CGSizeMake(button_width, button_height)];
        [toolbarItem setMaxSize:CGSizeMake(button_width, button_height)]; 
    }
    
    return toolbarItem;
}

/*
** Toolbar buttons callbacks
*/

- (void) typeset: (id)sender
{
    var docs = [self documents];
    var count = [docs count];
    var index = 0;
    for (; index<count; index++) {
        var doc = [docs objectAtIndex:index];
        [doc saveDocument:sender];
    }
}

- (void) printSource: (id)sender
{
    var docs = [self documents];
    var count = [docs count];
    var index = 0;
    for (; index<count; index++) {
        var doc = [docs objectAtIndex:index];
        [doc printSource:sender];
    }
}

- (void) downloadPDF: (id)sender
{
    var docs = [self documents];
    var count = [docs count];
    var index = 0;
    for (; index<count; index++) {
        var doc = [docs objectAtIndex:index];
        [doc downloadPDF:sender];
    }
}

- (void)popUpSelected:(id)sender
{
    [self loadTemplateNamed:[sender titleOfSelectedItem]];
}

@end