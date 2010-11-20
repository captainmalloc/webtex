/*
 *  PathsManager.j
 *  WebTex
 *
 *  Created by Adriano Scoditti on 7/6/10.ß
 *  Copyright LIG 2010. All rights reserved.
*/

@import <AppKit/AppKit.j>
@import <Foundation/Foundation.j>

@import "ConsoleWindowController.j"

var BASE_URL="http://localhost/~adriano/WebTex/";
//var BASE_URL="http://webtex.scoditti.com/";

var PHP_URI ="Resources/php/";
var USERS_URI = "Resources/users/"

var TEMPLATES_PATH="../templates/";
var USERS_PATH="../users/";

var CURRENT_USER = "";
var DEFAULT_USER = "guest";

var UPLOAD_PATH = "uploads/"

@implementation PathsManager : CPWindowController
{
}

+ (CPString)defaultUsername {
    return DEFAULT_USER;
}

+ (void)setCurrentUser:(CPString)aUsername {
    CURRENT_USER = aUsername + "/";
}

+ (CPString)currentUser {
    return CURRENT_USER;
}

+ (CPString)baseURL {
    return BASE_URL;
}

+ (CPString)usersPathRelativeToPHP {
    return USERS_PATH;
}

+ (CPString)absolutePhpURL {
    return [[self class] baseURL] + PHP_URI;
}

+ (CPString)templatesPathRelativeToPHP {
    return TEMPLATES_PATH;
}

+ (CPString)uploadDirRelativeToPHP {
    return UPLOAD_PATH;
}

+ (CPString)userUploadDirRelativeToPHP {
    return [self documentsPathRelativeToPHP] + UPLOAD_PATH;
}

+ (CPString)absoluteDocumentDir {
    return BASE_URL + USERS_URI + [[self class] currentUser];
}

+ (CPString)documentsPathRelativeToPHP {
    return USERS_PATH + [[self class] currentUser];
}

@end