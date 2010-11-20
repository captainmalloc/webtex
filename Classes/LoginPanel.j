/*
 *  LoginPanel.j
 *  WebTex
 *
 *  Created by Adriano on 11/6/10.
 *  Copyright LIG 2010. All rights reserved.
*/

@import <Foundation/Foundation.j>
@import <AppKit/CPPanel.j>

@import "ConsoleWindowController.j"
@import "PathsManager.j"

//var loginPanelSharedInstance = nil;

@implementation LoginPanel : CPPanel
{
    var loginDelegate @accessors;
    
    var topHintTextField;
    var userTextField;
    var passwordTextField;
    var confirmPasswordTextField;
    var mailTextField;
    
    var login_connection;
    var register_connection;
}

+(id)loginPanel {
//    if (loginPanelSharedInstance == nil)
//    {
//        loginPanelSharedInstance = [[LoginPanel alloc] init];
//    }
//    
//    return loginPanelSharedInstance;
    return [[LoginPanel alloc] init];
}

- (CPInteger)runModal:(BOOL)registerFlag
{
    var button_width = 100;
    var button_height = 25;
    var textField_default_width = 120;
    var textField_default_height = 30;
    var border_inset = 20;
    var inter_components_inset = 8;
    
    //self.styleMask = CPHUDBackgroundWindowMask|CPTitledWindowMask;
    if (registerFlag) {
        [self setTitle:@"Register"];
        [self setFrame:CGRectMake(0,0,450,300)];
    } else {
        [self setTitle:@"Login"];
        [self setFrame:CGRectMake(0,0,450,240)];
    }
    [self center];
    
    var contentView = [self contentView];
    var contentBounds = [contentView bounds];
    
    var hintTextField_frame = CGRectMake(border_inset, border_inset, 
                                        CGRectGetWidth(contentBounds)-border_inset, textField_default_height);
    var hintTextField = [[CPTextField alloc] initWithFrame:hintTextField_frame];
    topHintTextField = hintTextField;
//    if (registerFlag)
//        [hintTextField setObjectValue:@"Enter email, username, password and password confirmation than Register."];
//    else
//        [hintTextField setObjectValue:@"Enter your username and password than confirm Login."];
    [hintTextField setObjectValue:@"Enter all fields than confirm."];
    [hintTextField setFont:[CPFont systemFontOfSize:12]];
    //[hintTextField setTextColor:[CPColor whiteColor]];
    [hintTextField setAlignment:CPCenterTextAlignment];
    [contentView addSubview:hintTextField]; 
    
    var i = 0;
    var textField_frame;
    var textFields = [];
    var hintTextField_values;
    var textField_values;
    var secures;
    
    if (registerFlag) {
        hintTextField_values = [@"e-mail: ", @"Username: ", @"Password: ", @"Confirm Password: "];
        textField_values = [@"email", @"username", @"password", @"password confirmation"];
        secures = [NO, NO, YES, YES];
    } else {
        hintTextField_values = [@"Username: ", @"Password: "];
        textField_values = [@"username", @"password"];
        secures = [NO, YES];
    }
    
    var count = [hintTextField_values count];
    for (;i<count;i++) {
        hintTextField_frame = CGRectMake(border_inset, CGRectGetMaxY(hintTextField_frame)+inter_components_inset, 
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
    }
    if (registerFlag) {
        mailTextField = [textFields objectAtIndex:0];
        userTextField = [textFields objectAtIndex:1];
        passwordTextField = [textFields objectAtIndex:2];
        confirmPasswordTextField = [textFields objectAtIndex:3];
    } else {
        userTextField = [textFields objectAtIndex:0];
        passwordTextField = [textFields objectAtIndex:1];
    }
    
    var confirm_button_frame = CGRectMake(CGRectGetMaxX(contentBounds)-border_inset-button_width,
                                        CGRectGetMaxY(contentBounds)-border_inset-button_height, 
                                        button_width, button_height);
    if (registerFlag) {
        var register_button = [[CPButton alloc] initWithFrame:confirm_button_frame];
        [register_button setTitle:@"Register"];
        [register_button setAction:@selector(register:)];
        [register_button setTarget:self];
        [register_button setAutoresizingMask:CPViewMinXMargin| CPViewMinYMargin ];
        [contentView addSubview:register_button];
    } else {
        var login_button = [[CPButton alloc] initWithFrame:confirm_button_frame];
        [login_button setTitle:@"Login"];
        [login_button setAction:@selector(login:)];
        [login_button setTarget:self];
        [login_button setAutoresizingMask:CPViewMinXMargin| CPViewMinYMargin ];
        [contentView addSubview:login_button];
    }
    
    var cancel_button_frame = CGRectMake(confirm_button_frame.origin.x-inter_components_inset-button_width, 
                                         confirm_button_frame.origin.y, 
                                         button_width, button_height);
    var cancel_button = [[CPButton alloc] initWithFrame: cancel_button_frame];
    [cancel_button setTitle:@"Cancel"];
    [cancel_button setAction:@selector(cancel:)];
    [cancel_button setTarget:self];
    [cancel_button setAutoresizingMask:CPViewMinXMargin | CPViewMaxXMargin | CPViewMinYMargin | CPViewMaxYMargin];
    [contentView addSubview:cancel_button];
    
    [CPApp runModalForWindow:self];
    return 0;
}

- (void)login:(id)sender
{
    [topHintTextField setObjectValue:@"Checking your data..."];
    [topHintTextField setTextColor:[CPColor blueColor]];
    
    var body = "username=" + [userTextField objectValue] + "&password=" + [passwordTextField objectValue];
    var request = [CPURLRequest requestWithURL:[PathsManager absolutePhpURL] + "checklogin.php"];
    [request setHTTPMethod:"POST"];
    [request setValue:"application/x-www-form-urlencoded" forHTTPHeaderField:"Content-Type"];
    [request setValue:[body length] forHTTPHeaderField:"Content-Length"];
    [request setHTTPBody:body];
    
    login_connection = [CPURLConnection connectionWithRequest:request delegate:self];
}

- (void)register:(id)sender {
    [topHintTextField setObjectValue:@"Checking your data..."];
    [topHintTextField setTextColor:[CPColor blueColor]];

    var email = [mailTextField objectValue];
    var re_email = new RegExp("[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+(?:[a-zA-Z]{2}|com|org|net|edu|gov|mil|biz|info|mobi|name|aero|asia|jobs|museum)");
    if (!re_email.test(email)) {
        [topHintTextField setObjectValue:@"Enter a valid email address."];
        [topHintTextField setTextColor:[CPColor redColor]];
    } else if ([[passwordTextField objectValue] length] < 6) { 
        [topHintTextField setObjectValue:@"Passwords too short 6 characters required."];
        [topHintTextField setTextColor:[CPColor redColor]];
    } else if ( ![[passwordTextField objectValue] isEqualToString:[confirmPasswordTextField objectValue]]) {
        [topHintTextField setObjectValue:@"Passwords don't match."];
        [topHintTextField setTextColor:[CPColor redColor]];
    } else {
        var body = "userspath=" + [PathsManager usersPathRelativeToPHP] + "&username=" + [userTextField objectValue] + "&password=" + [passwordTextField objectValue] + "&email=" + [mailTextField objectValue];
        var request = [CPURLRequest requestWithURL:[PathsManager absolutePhpURL] + "checklogin.php"];
        [request setHTTPMethod:"POST"];
        [request setValue:"application/x-www-form-urlencoded" forHTTPHeaderField:"Content-Type"];
        [request setValue:[body length] forHTTPHeaderField:"Content-Length"];
        [request setHTTPBody:body];
    
        register_connection = [CPURLConnection connectionWithRequest:request delegate:self];
    }
}

- (void)cancel:(id)sender {
    if ([loginDelegate respondsToSelector:@selector(performCancelLogin)])
        [loginDelegate performCancelLogin];
    [CPApp abortModal];
    [self close];
}

/*
** Connection callbacks
*/

- (void)connection:(CPURLConnection) connection didReceiveData:(CPString)data
{
    if (connection==login_connection) {
        switch ([data intValue]) {
            case 0:
                [topHintTextField setObjectValue:@"Bad username or password."];
                [topHintTextField setTextColor:[CPColor redColor]];
                break;
            default:
                if ([loginDelegate respondsToSelector:@selector(performLoginWithUser:)])
                    [loginDelegate performLoginWithUser:[userTextField objectValue]];
                [CPApp abortModal];
                [self close];
                break;
        }
    }
    if (connection == register_connection) {     
        switch ([data intValue]) {
            case 1:
                [topHintTextField setObjectValue:@"The chosen username already exists."];
                [topHintTextField setTextColor:[CPColor redColor]];
                break;
            default:
                if ([loginDelegate respondsToSelector:@selector(performLoginWithUser:)])
                    [loginDelegate performLoginWithUser:[userTextField objectValue]];
                [CPApp abortModal];
                [self close];
                break;
        }
    }
}

- (void)connection:(CPURLConnection)connection didFailWithError:(CPString)error
{
    [[ConsoleWindowController sharedConsole] log:data];
}

@end