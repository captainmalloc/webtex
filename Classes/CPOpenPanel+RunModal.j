/*
 *  CPOpenPanel+RunModal.j
 *  WebTex
 *
 *  Created by Adriano Scoditti on 9/6/10.
 *  Copyright LIG 2010. All rights reserved.
*/

@import <Foundation/Foundation.j>
@import <AppKit/CPOpenPanel.j>
@import <AppKit/CPCollectionView.j>
@import <Foundation/CPIndexSet.j>
@import "CPFileView.j"
@import "CPFileRepresentationComponents.j"
@import "PathsManager.j"

WTTexManagerDidRetriveSourcesNamesNotification = @"WTTexManagerDidRetriveSourcesNamesNotification"
var filesView;
var icons_size = 50.0;

@implementation CPOpenPanel (CPOpenPanel_RunModal)

- (CPInteger)runModal {
    //[[ConsoleWindowController sharedConsole] log:"*** CPOpenPanel runModal***"];
    if (typeof window["cpOpenPanel"] === "function")
     {
         // FIXME: Is this correct???
         [[CPRunLoop currentRunLoop] limitDateForMode:CPDefaultRunLoopMode];
 
         var options = { directoryURL: [self directoryURL],
                         canChooseFiles: [self canChooseFiles],
                         canChooseDirectories: [self canChooseDirectories],
                         allowsMultipleSelection: [self allowsMultipleSelection] };
 
         var result = window.cpOpenPanel(options);
 
         _URLs = result.URLs;
 
         return result.button;
     }
     else
     {
         // FIXME: This is not the best way to do this.
//         var documentName = window.prompt("Document Name To Open:"),
//             result = documentName !== null;
//        
//         if (result)
//            result = ![documentName isEqualToString:""];
// 
//         //_URLs = result ? [CPArray arrayWithObject:[CPURL URLWithString:documentName]] : nil;
//         if (result) {
//            var allNames = [documentName componentsSeparatedByString:" "];
//            var index = 0,
//                count = [allNames count];
//            _URLs = [CPArray arrayWithCapacity:count];
// 
//            for (; index < count; ++index)
//                [_URLs addObject:[CPURL URLWithString:allNames[index]]];
//         }

        [self setFloatingPanel:YES];
        _styleMask= CPTitledWindowMask | CPClosableWindowMask | CPResizableWindowMask | CPBorderlessBridgeWindowMask;
        [self setTitle:"Choose a document to open..."];
        [self setFrame:CGRectMake(0,0,500,300)];
        [self center];
        
        var button_width = 100;
        var button_height = 25;
        var border_inset = 20;
        var inter_components_inset = 8;
        
        var contentView = [self contentView];
        var contentBounds = [contentView bounds];
        
        var ok_button_frame = CGRectMake(contentBounds.size.width-border_inset-button_width, 
                                                                    contentBounds.size.height-border_inset-button_height, 
                                                                    button_width, button_height);
        var ok_button = [[CPButton alloc] initWithFrame:ok_button_frame];
        [ok_button setTitle:@"Open"];
        [ok_button setAction:@selector(open:)];
        [ok_button setTarget:self];
        [ok_button setAutoresizingMask:CPViewMinXMargin | CPViewMaxXMargin | CPViewMinYMargin | CPViewMaxYMargin];
        [contentView addSubview:ok_button];
        
        var cancel_button_frame = CGRectMake(ok_button_frame.origin.x-inter_components_inset-button_width, 
                                                                    ok_button_frame.origin.y, 
                                                                    button_width, button_height);
        var cancel_button = [[CPButton alloc] initWithFrame: cancel_button_frame];
        [cancel_button setTitle:@"Cancel"];
        [cancel_button setAction:@selector(cancel:)];
        [cancel_button setTarget:self];
        [cancel_button setAutoresizingMask:CPViewMinXMargin | CPViewMaxXMargin | CPViewMinYMargin | CPViewMaxYMargin];
        [contentView addSubview:cancel_button];
        
        var scroll_view_frame = CGRectMake(contentBounds.origin.x+border_inset,
                                           contentBounds.origin.y+border_inset, 
                                           contentBounds.size.width-border_inset*2,
                                           contentBounds.size.height-border_inset*2-button_height-inter_components_inset);
        var scroll_view = [[CPScrollView alloc] initWithFrame:scroll_view_frame];
        [scroll_view setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
        [scroll_view setAutohidesScrollers:YES];
        [[scroll_view contentView] setBackgroundColor:[CPColor whiteColor]];
        [contentView addSubview:scroll_view];
        
        
        filesView = [[CPCollectionView alloc] initWithFrame:[[scroll_view contentView] bounds]];
        [filesView setAutoresizingMask:CPViewWidthSizable];
        [filesView setMinItemSize:CGSizeMake(200, 100)];
        [filesView setMaxItemSize:CGSizeMake(200, 100)];
        [filesView setAllowsMultipleSelection:YES];
        
        var itemPrototype = [[CPCollectionViewItem alloc] init],
            fileView = [[CPFileView alloc] initWithFrame:CGRectMakeZero()];
        
        [itemPrototype setView:fileView];
        
        [filesView setItemPrototype:itemPrototype];
        
        [scroll_view setDocumentView:filesView];
                                              
        [self fileList];
        
        var defaultImage = [[CPImage alloc]
                            initWithContentsOfFile:"Resources/loading-spiral.gif"
                                              size:CGSizeMake(icons_size, icons_size)];

        
        var placeholder = [
                        [[CPFileRepresentationComponents alloc] initWithImage:defaultImage
                                                                description:"Loading Documents..."]
 
                    ];
                    
        [filesView setContent:placeholder];
    
        //[self makeKeyAndOrderFront:nil];
        [CPApp runModalForWindow:self];
     }
     return 0;
}

- (CPArray) fileList {
    var defaultCenter = [CPNotificationCenter defaultCenter];
    
    [defaultCenter addObserver:self
                      selector:@selector(panelDidRetriveFileList:)
                          name:WTTexManagerDidRetriveSourcesNamesNotification
                        object:nil];

            
    //RETRIVE FILES
    var body = "dirpath=" + [PathsManager documentsPathRelativeToPHP] + "&allowedexts=tex";
    var request = [CPURLRequest requestWithURL:[PathsManager absolutePhpURL] + "ListSources.php"];
    [request setHTTPMethod:"POST"];
    [request setValue:"application/x-www-form-urlencoded" forHTTPHeaderField:"Content-Type"];
    [request setValue:[body length] forHTTPHeaderField:"Content-Length"];
    [request setHTTPBody:body];
    
    var connection = [CPURLConnection connectionWithRequest:request delegate:self];
    
    return nil;
}

- (void)panelDidRetriveFileList:(CPNotification)aNotification
{
    [[ConsoleWindowController sharedConsole] log:[aNotification object]];

    var data = [aNotification object];
    var names = [data componentsSeparatedByString:" "];
    var index = 0;
    var count = [names count];
    var files = [CPArray arrayWithCapacity:count];
    
    var defaultImage = [[CPImage alloc]
                            initWithContentsOfFile:"Resources/TexIcon.jpg"
                                              size:CGSizeMake(icons_size, icons_size)];
    for (; index < count; ++index) {
        var name = names[index];
        if (![name isEqualToString:""])
            [files addObject:[[CPFileRepresentationComponents alloc] initWithImage:defaultImage
                                                                description:name]
            ];
    }
    
    //Make first index selected
    if (count>0)
        [filesView setSelectionIndexes:[CPIndexSet indexSetWithIndex:0]];
                    
    [filesView setContent:files];
    
    var defaultCenter = [CPNotificationCenter defaultCenter];
    
    [defaultCenter removeObserver:self
                          name:WTTexManagerDidRetriveSourcesNamesNotification
                        object:nil];
}

/*
** Panel callbacks
*/

- (void)open:(id)sender {
//    var selection = [filesView selectionIndexes];
//    //TEMP
//    var first = [selection firstIndex];
//    var content = [filesView content];
//    var item = [filesView itemAtIndex:first];
//    var description = [[item representedObject] description];
//    _URLs = [CPArray arrayWithCapacity:1];
//    [_URLs addObject:[CPURL URLWithString:description]];
//    [[ConsoleWindowController sharedConsole] log:"***Should Open Document: " + description + " ***"];
//    [[[CPDocumentController sharedDocumentController]
//                                        openDocumentWithContentsOfURL:[CPURL URLWithString:description]
//                                        display:YES
//                                        error:nil]
//    ];
    var selectedIndexes = [filesView selectionIndexes];
    var count = [selectedIndexes count];
    var range = CPMakeRange([selectedIndexes firstIndex], count);
    var indexesArray = [CPArray arrayWithCapacity:count];
    [selectedIndexes getIndexes:indexesArray maxCount:count inIndexRange:range];
    _URLs = [CPArray arrayWithCapacity:count];
    var index = 0;
    var item;
    var item_index;
    var description;
    for (; index<count; index++) {
        item_index = [indexesArray objectAtIndex:index];
        item = [filesView itemAtIndex:item_index];
        description = [[item representedObject] description];
        [_URLs addObject:[CPURL URLWithString:description]];
    }
    
    count = [_URLs count];
    index = 0;
    for (; index < count; ++index)
         [[CPDocumentController sharedDocumentController] 
                                            openDocumentWithContentsOfURL:[CPURL URLWithString:_URLs[index]] 
                                            display:YES 
                                            error:nil];
    
    [CPApp abortModal];
    [self close];
}

- (void)cancel:(id)sender {
    [CPApp abortModal];
    [self close];
}

/*
** Connection callbacks
*/

- (void)connection:(CPURLConnection) connection didReceiveData:(CPString)data
{
    var defaultCenter = [CPNotificationCenter defaultCenter];
    [defaultCenter postNotificationName:WTTexManagerDidRetriveSourcesNamesNotification
                                 object:data];
}

- (void)connection:(CPURLConnection)connection didFailWithError:(CPString)error
{
    [[ConsoleWindowController sharedConsole] log:data];
}

@end