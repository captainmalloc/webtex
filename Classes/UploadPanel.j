/*
 *  UploadPanel.j
 *  WebTex
 *
 *  Created by Adriano on 13/6/10.
 *  Copyright LIG 2010. All rights reserved.
*/

@import <Foundation/Foundation.j>
@import "PathsManager.j"
@import "FileUpload.j"

var icons_size = 50.0;

@implementation UploadPanel : CPPanel
{
    var topHintTextField;
    var upload_buttton;
    var filesView;
}

+(id)uploadPanel {
    return [[UploadPanel alloc] init];
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
    
    [self setTitle:@"Upload"];
    [self setFrame:CGRectMake(0,0,500,300)];
    [self center];
    
    var contentView = [self contentView];
    var contentBounds = [contentView bounds];
    
    var hintTextField_frame = CGRectMake(border_inset, border_inset, 
                                        CGRectGetWidth(contentBounds)-border_inset, textField_default_height);
    var hintTextField = [[CPTextField alloc] initWithFrame:hintTextField_frame];
    topHintTextField = hintTextField;
    [hintTextField setObjectValue:@""];
    [hintTextField setFont:[CPFont systemFontOfSize:12]];
    //[hintTextField setTextColor:[CPColor whiteColor]];
    [hintTextField setAlignment:CPCenterTextAlignment];
    [contentView addSubview:hintTextField]; 
    
    
    var scroll_view_frame = CGRectMake(contentBounds.origin.x+border_inset,
                                           CGRectGetMaxY(hintTextField_frame), 
                                           contentBounds.size.width-border_inset*2,
                                           contentBounds.size.height-border_inset*2-button_height-CGRectGetHeight(hintTextField_frame)-inter_components_inset*2);
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
        
    var itemPrototype = [[CPCollectionViewItem alloc] init],
        fileView = [[CPFileView alloc] initWithFrame:CGRectMakeZero()];
        
    [itemPrototype setView:fileView];
    
    [filesView setItemPrototype:itemPrototype];
    [scroll_view setDocumentView:filesView];
    
    var ok_button_frame = CGRectMake(contentBounds.size.width-border_inset-button_width, 
                                   contentBounds.size.height-border_inset-button_height, 
                                    button_width, button_height);
    var ok_button = [[CPButton alloc] initWithFrame:ok_button_frame];
    [ok_button setTitle:@"Close"];
    [ok_button setAction:@selector(close:)];
    [ok_button setTarget:self];
    [ok_button setAutoresizingMask:CPViewMinXMargin | CPViewMaxXMargin | CPViewMinYMargin | CPViewMaxYMargin];
    [contentView addSubview:ok_button];
    
    var urlString = [PathsManager absolutePhpURL] + "upload.php";
    //var urlString = "Resources/php/upload.php";
    var upload_buttton_frame = CGRectMake(border_inset, 
                                         CGRectGetHeight(contentBounds)-border_inset-button_height, 
                                         button_width, button_height);
    upload_buttton = [[UploadButton alloc] initWithFrame:upload_buttton_frame];
    [upload_buttton setTitle:"Choose Files"];
    [upload_buttton setBordered:YES];
    [upload_buttton allowsMultipleFiles:YES];
    [upload_buttton setURL:urlString];
    [upload_buttton setDelegate:self]; 
    [upload_buttton setValue:[PathsManager uploadDirRelativeToPHP] forParameter:"updirrelpath"];
    [upload_buttton setValue:[PathsManager userUploadDirRelativeToPHP] forParameter:"usrupdirrelpath"];
    [contentView addSubview:upload_buttton];
    
    var submit_button_frame = CGRectMake(CGRectGetMaxX(upload_buttton_frame)+inter_components_inset, 
                                         CGRectGetMinY(upload_buttton_frame), 
                                         button_width, button_height);
    var submit_button = [[CPButton alloc] initWithFrame: submit_button_frame];
    [submit_button setTitle:@"submit"];
    [submit_button setAction:@selector(submit:)];
    [submit_button setTarget:self];
    [submit_button setAutoresizingMask:CPViewMinXMargin | CPViewMaxXMargin | CPViewMinYMargin | CPViewMaxYMargin];
    [contentView addSubview:submit_button];
}

- (void)close:(id)sender {
    //[CPApp abortModal];
    [self close];
}

- (void)submit:(id)sender {
    [upload_buttton submit];
}

/*
**  FileUpload delegate
*/

-(void) uploadButton:(UploadButton)button didChangeSelection:(CPArray)selection
{
    [[ConsoleWindowController sharedConsole] log:"Selection has been made: " + selection];
    var count = [selection count];
    var files = [CPArray arrayWithCapacity:count];
    var index = 0;

    var defaultImage = [[CPImage alloc]
                        initWithContentsOfFile:"Resources/FileIcon.png"
                                            size:CGSizeMake(icons_size, icons_size)];
    for (; index < count; ++index) {
        var name = [selection objectAtIndex:index];
        if (![name isEqualToString:""])
            [files addObject:[[CPFileRepresentationComponents alloc] initWithImage:defaultImage
                                                                description:name]
            ];
    }
    [filesView setContent:files];
}

-(void) uploadButton:(UploadButton)button didFailWithError:(CPString)anError
{
    [topHintTextField setObjectValue:@"Upload failed!"];
    [topHintTextField setTextColor:[CPColor redColor]];
}

-(void) uploadButton:(UploadButton)button didFinishUploadWithData:(CPString)response
{
    [topHintTextField setObjectValue:@"Uploading finished. Use \"uploads/filename\" URI in LaTex"];
    [topHintTextField setTextColor:[CPColor blueColor]];
    [button resetSelection];
}

-(void) uploadButtonDidBeginUpload:(UploadButton)button
{
    [topHintTextField setObjectValue:@"Uploading your files..."];
    [topHintTextField setTextColor:[CPColor blueColor]];
}

@end