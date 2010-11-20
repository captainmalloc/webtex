/*
 *  LoginManager.j
 *  WebTex
 *
 *  Created by Adriano on 11/6/10.
 *  Copyright LIG 2010. All rights reserved.
*/

@import <Foundation/Foundation.j>
@import "LoginPanel.j"
@import "ConsoleWindowController.j"
@import "PathsManager.j"
@import <AppKit/CPMenu.j>
@import <AppKit/CPMenuItem.j>

var loginManagerSharedInstance = nil;
var userManuTag = 10; //Any number... just check if already exists on nib

@implementation LoginManager : CPObject
{
}

+ (id)loginManager {
    if (loginManagerSharedInstance == nil)
    {
        loginManagerSharedInstance = [[LoginManager alloc] init];
        
        //Init the user menu tag
        var userMenu = [[CPApp mainMenu] itemWithTitle:@"User"];
        [userMenu setTag:userManuTag];
    }
    
    return loginManagerSharedInstance;
}

- (void)loginWithDefaultUser
{
    [self performLoginWithUser: [PathsManager defaultUsername]];
}

- (void)register {
    var panel = [LoginPanel loginPanel]
    [panel setLoginDelegate:self];
    [panel runModal:YES];
}

- (void)login {
    var panel = [LoginPanel loginPanel]
    [panel setLoginDelegate:self];
    [panel runModal:NO];
}

- (void)logout {
    [self performLoginWithUser:[PathsManager defaultUsername]];
}

/*
** Login Panel Delegate
*/

- (void)performLoginWithUser:(CPString)username
{
    [PathsManager setCurrentUser:username];
    var userMenu = [[CPApp mainMenu] itemWithTag:userManuTag];
    [userMenu setTitle:[username capitalizedString]];
}

- (void)performCancelLogin {
    //Nothing to do!
}

@end