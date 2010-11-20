/*
 *  ImportedPanel.j
 *  WebTex
 *
 *  Created by Adriano on 16/6/10.
 *  Copyright LIG 2010. All rights reserved.
*/

@import <Foundation/Foundation.j>
@import "PathsManager.j"
@import <Foundation/CPString.j>

WTTexManagerDidRetriveResourcesNamesNotification = @"WTTexManagerDidRetriveResourcesNamesNotification"
var icons_size = 50.0;

@implementation ImportedPanel : CPPanel
{
    var topHintTextField;
    var pasteboard_button;
    var filesView;
}

+(id)importedPanel {
    return [[ImportedPanel alloc] init];
}

- (CPInteger)runModal
{
    [self buildGUI];
    [self makeKeyAndOrderFront:nil];
    //[CPApp runModalForWindow:self];
    return 0;
}

- (void)buildGUI
{
    var button_width = 100;
    var button_height = 25;
    var textField_default_width = 120;
    var textField_default_height = 30;
    var border_inset = 20;
    var inter_components_inset = 8;
    
    [self setTitle:[PathsManager uploadDirRelativeToPHP]];
    [self setFrame:CGRectMake(0,0,500,300)];
    [self center];
    
    var contentView = [self contentView];
    var contentBounds = [contentView bounds];
    
//    var hintTextField_frame = CGRectMake(border_inset, border_inset, 
//                                        CGRectGetWidth(contentBounds)-border_inset, textField_default_height);
//    var hintTextField = [[CPTextField alloc] initWithFrame:hintTextField_frame];
//    topHintTextField = hintTextField;
//    [hintTextField setObjectValue:@"Your uploaded files"];
//    [hintTextField setFont:[CPFont systemFontOfSize:12]];
//    //[hintTextField setTextColor:[CPColor whiteColor]];
//    [hintTextField setAlignment:CPCenterTextAlignment];
//    [contentView addSubview:hintTextField]; 
//    
//    var scroll_view_frame = CGRectMake(contentBounds.origin.x+border_inset,
//                                           CGRectGetMaxY(hintTextField_frame), 
//                                           contentBounds.size.width-border_inset*2,
//                                           contentBounds.size.height-border_inset*2-button_height-CGRectGetHeight(hintTextField_frame)-inter_components_inset*2);
    var scroll_view_frame = CGRectMake(border_inset, border_inset, 
                                           contentBounds.size.width-border_inset*2,
                                           contentBounds.size.height-border_inset*2-button_height-inter_components_inset*2);
    var scroll_view = [[CPScrollView alloc] initWithFrame:scroll_view_frame];
    [scroll_view setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
    [scroll_view setAutohidesScrollers:YES];
    [[scroll_view contentView] setBackgroundColor:[CPColor whiteColor]];
    [contentView addSubview:scroll_view];

    filesView = [[CPCollectionView alloc] initWithFrame:[[scroll_view contentView] bounds]];
    [filesView setAutoresizingMask:CPViewWidthSizable];
    [filesView setMinItemSize:CGSizeMake(200, 100)];
    [filesView setMaxItemSize:CGSizeMake(200, 100)];
    [filesView setSelectable:NO];
    //[filesView setAllowsMultipleSelection:YES];
    [filesView setDelegate:self];
        
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
    
    var close_button_frame = CGRectMake(contentBounds.size.width-border_inset-button_width, 
                                   contentBounds.size.height-border_inset-button_height, 
                                    button_width, button_height);
    var close_button = [[CPButton alloc] initWithFrame:close_button_frame];
    [close_button setTitle:@"Close"];    
    [close_button setAction:@selector(close:)];
    [close_button setTarget:self];
    [close_button setAutoresizingMask:CPViewMinXMargin | CPViewMaxXMargin | CPViewMinYMargin | CPViewMaxYMargin];
    [contentView addSubview:close_button];
}

- (void)close:(id)sender {
    //[CPApp abortModal];
    [self close];
}

- (CPArray) fileList {
    var defaultCenter = [CPNotificationCenter defaultCenter];
    
    [defaultCenter addObserver:self
                      selector:@selector(panelDidRetriveFileList:)
                          name:WTTexManagerDidRetriveResourcesNamesNotification
                        object:nil];

            
    //RETRIVE FILES
    var body = "dirpath=" + [PathsManager userUploadDirRelativeToPHP];
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
                            initWithContentsOfFile:"Resources/FileIcon.png"
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
                          name:WTTexManagerDidRetriveResourcesNamesNotification
                        object:nil];
}

- (void)copySelectionToPasteboard {
    var selectedIndexes = [filesView selectionIndexes];
    var count = [selectedIndexes count];
    var range = CPMakeRange([selectedIndexes firstIndex], count);
    var indexesArray = [CPArray arrayWithCapacity:count];
    [selectedIndexes getIndexes:indexesArray maxCount:count inIndexRange:range];
    var filesname = "";
    var index = 0;
    var item;
    var item_index;
    var description;
    for (; index<count; index++) {
        item_index = [indexesArray objectAtIndex:index];
        item = [filesView itemAtIndex:item_index];
        description = [[item representedObject] description];
        filesname += [PathsManager uploadDirRelativeToPHP] + description + " ";
    }
    
    //Should copy filesname to pasteboard here!
}

/*
** Collection View Delegate
*/

-(void)collectionViewDidChangeSelection:(CPCollectionView)collectionView
{
    [self copySelectionToPasteboard];
}

/*
** Connection callbacks
*/

- (void)connection:(CPURLConnection) connection didReceiveData:(CPString)data
{
    var defaultCenter = [CPNotificationCenter defaultCenter];
    [defaultCenter postNotificationName:WTTexManagerDidRetriveResourcesNamesNotification
                                 object:data];
}

- (void)connection:(CPURLConnection)connection didFailWithError:(CPString)error
{
    [[ConsoleWindowController sharedConsole] log:data];
}

@end