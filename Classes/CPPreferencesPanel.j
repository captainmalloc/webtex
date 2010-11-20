/*
 *  CPPreferencesPanel.j
 *  WebTex
 *
 *  Created by Adriano on 12/6/10.
 *  Copyright LIG 2010. All rights reserved.
*/

@import <Foundation/Foundation.j>
@import <AppKit/CPPanel.j>

@import "ConsoleWindowController.j"
@import "PathsManager.j"
@import "CPCookie_Additions.j"
@import "AppController.j"

//var prefPanelSharedInstance = nil;
//var guiinitialized = NO;

@implementation CPPreferencesPanel : CPPanel
{
    var topHintTextField;
    var userTextField;
    var passwordTextField;
    
    var autoLoginCheckBox;
}

+(id) preferencesPanel {
//    if (prefPanelSharedInstance == nil)
//    {
//        prefPanelSharedInstance = [[CPPreferencesPanel alloc] init];
//    }
//    
//    return prefPanelSharedInstance;
    return [[CPPreferencesPanel alloc] init];
}

- (CPInteger)runModal
{
    [self buildGUI];
    
    //Check if autologin is already active
    var autologinCoockie = [CPCookie cookieWithName:WebTexAutologinCoockieItemIdentifier];
    var autologinCoockieValue = [autologinCoockie value];
    if (![autologinCoockieValue isEqualToString:""]) {
        [autoLoginCheckBox setState:CPOnState];
        [userTextField setObjectValue:autologinCoockieValue];
        [topHintTextField setObjectValue:@"Autologin is already active on this browser."];
    }
    [CPApp runModalForWindow:self];
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
    
    [self setTitle:@"Preferences"];
    [self setFrame:CGRectMake(0,0,450,260)];
    [self center];
    
    var contentView = [self contentView];
    var contentBounds = [contentView bounds];
    
    //TABVIEW IS UGLY
    //var tabview = [[CPTabView alloc] initWithFrame:contentBounds];
    //[contentView addSubview:tabview];
    //    
    //var loginTabViewItem = [[CPTabViewItem alloc] initWithIdentifier:@"Login"];
    //[loginTabViewItem setLabel:@"Login"];
    //var loginTabContentView = [[CPView alloc] initWithFrame:CGRectMakeZero()];
    //[loginTabViewItem setView:loginTabContentView];
    //[tabview addTabViewItem:loginTabViewItem];
    
    var hintTextField_frame = CGRectMake(border_inset, border_inset, 
                                        CGRectGetWidth(contentBounds)-border_inset, textField_default_height);
    var hintTextField = [[CPTextField alloc] initWithFrame:hintTextField_frame];
    topHintTextField = hintTextField;
    
    [hintTextField setObjectValue:@"Enter username and password than check to autologin."];
    [hintTextField setFont:[CPFont systemFontOfSize:12]];
    //[hintTextField setTextColor:[CPColor whiteColor]];
    [hintTextField setAlignment:CPCenterTextAlignment];
    [contentView addSubview:hintTextField]; 
    
    autoLoginCheckBox = [CPCheckBox checkBoxWithTitle:@"Autologin"];
    var autoLoginCheckBox_frame = [autoLoginCheckBox frame];
    var autoLoginCheckBox_size = CGSizeMake(CGRectGetWidth(autoLoginCheckBox_frame),CGRectGetHeight(autoLoginCheckBox_frame));
    var autoLoginCheckBox_frame = CGRectMake(CGRectGetMaxX(contentBounds)/2-autoLoginCheckBox_size.width/2, 
                                             CGRectGetMaxY(hintTextField_frame)+inter_components_inset, 
                                             autoLoginCheckBox_size.width, autoLoginCheckBox_size.height);
    [autoLoginCheckBox setFrame:autoLoginCheckBox_frame];
    [autoLoginCheckBox setAction:@selector(checkData:)];
    [autoLoginCheckBox setTarget:self];
    [contentView addSubview:autoLoginCheckBox];
    
    var i = 0;
    var textField_frame;
    var textFields = [];
    var hintTextField_values;
    var textField_values;
    var secures;
    
    hintTextField_values = [@"Username: ", @"Password: "];
    textField_values = [@"username", @"password"];
    secures = [NO, YES];
    var reference_frame = CGRectMakeCopy(autoLoginCheckBox_frame);
    reference_frame.origin.y += inter_components_inset;
    var count = [hintTextField_values count];
    for (;i<count;i++) {
        hintTextField_frame = CGRectMake(border_inset, CGRectGetMaxY(reference_frame)+inter_components_inset, 
                                        textField_default_width, textField_default_height);
        hintTextField = [[CPTextField alloc] initWithFrame:hintTextField_frame];
        [hintTextField setObjectValue:[hintTextField_values objectAtIndex:i]];
        [hintTextField setFont:[CPFont systemFontOfSize:12]];
        [hintTextField setAlignment:CPCenterTextAlignment];
        [contentView addSubview:hintTextField];
    
        textField_frame = CGRectMake(CGRectGetMaxX(hintTextField_frame)+inter_components_inset, CGRectGetMinY(hintTextField_frame)-5,
                                        CGRectGetWidth(contentBounds)-CGRectGetMaxX(hintTextField_frame)-border_inset, 
                                        textField_default_height);
        var textField = [[CPTextField alloc] initWithFrame:textField_frame];
        [textFields addObject:textField];
        [textField setEditable:YES];
        [textField setSelectable:YES];
        [textField setDrawsBackground:YES];
        [textField setBezelStyle:CPTextFieldRoundedBezel];
        [textField setBezeled:YES];
        [textField setPlaceholderString:[textField_values objectAtIndex:i]];
        [textField setSecure:[secures objectAtIndex:i]];
        [textField setFont:[CPFont systemFontOfSize:12]];
        [textField setAlignment:CPCenterTextAlignment];
        [contentView addSubview:textField];
        
        reference_frame = CGRectMakeCopy(hintTextField_frame);
    }
    userTextField = [textFields objectAtIndex:0];
    passwordTextField = [textFields objectAtIndex:1];
    
    
    var confirm_button_frame = CGRectMake(CGRectGetMaxX(contentBounds)-border_inset-button_width,
                                        CGRectGetMaxY(contentBounds)-border_inset-button_height, 
                                        button_width, button_height);

    var close = [[CPButton alloc] initWithFrame:confirm_button_frame];
    [close setTitle:@"Close"];
    [close setAction:@selector(close:)];
    [close setTarget:self];
    [close setAutoresizingMask:CPViewMinXMargin| CPViewMinYMargin ];
    [contentView addSubview:close];
}

/*
** Buttons Callbacks
*/

- (void)checkData:(id)sender
{
    var check_state = [sender state];
    switch (check_state) {  
        case CPOnState:
            [topHintTextField setObjectValue:@"Checking your data..."];
            [topHintTextField setTextColor:[CPColor blueColor]];
    
            var body = "username=" + [userTextField objectValue] + "&password=" + [passwordTextField objectValue];
            var request = [CPURLRequest requestWithURL:[PathsManager absolutePhpURL] + "checklogin.php"];
            [request setHTTPMethod:"POST"];
            [request setValue:"application/x-www-form-urlencoded" forHTTPHeaderField:"Content-Type"];
            [request setValue:[body length] forHTTPHeaderField:"Content-Length"];
            [request setHTTPBody:body];
    
            var connection = [CPURLConnection connectionWithRequest:request delegate:self];
            break;
        default:
            [topHintTextField setObjectValue:@"Autologin Deactivated."];
            //Destroy coockies
            [CPCookie removeCookieWithName:WebTexAutologinCoockieItemIdentifier];
            break;
    }
}

- (void)close:(id)sender {
    [CPApp abortModal];
    [self close];
}

/*
** Connection callbacks
*/

- (void)connection:(CPURLConnection) connection didReceiveData:(CPString)data
{
    switch ([data intValue]) {
        case 0:
            [topHintTextField setObjectValue:@"Bad username or password."];
            [topHintTextField setTextColor:[CPColor redColor]];
            [autoLoginCheckBox setState:CPOffState];
            break;
        default:
            [topHintTextField setObjectValue:@"Autologin Activated."];
            //Set Coockies
            var loginCoockie = [CPCookie cookieWithName:WebTexAutologinCoockieItemIdentifier 
                                               andValue:[userTextField objectValue] 
                                                forDays:200];
            break;
    }
}

- (void)connection:(CPURLConnection)connection didFailWithError:(CPString)error
{
    [[ConsoleWindowController sharedConsole] log:data];
}

@end