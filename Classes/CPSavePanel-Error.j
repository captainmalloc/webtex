/*
 *  CPPanel-Error.j
 *  WebTex
 *
 *  Created by Adriano Scoditti on 8/6/10.
 *  Copyright LIG 2010. All rights reserved.
*/

@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>

@implementation CPSavePanel (CPPanel_Error)

- (CPInteger)runModal
{
    [[ConsoleWindowController sharedConsole] log:"*** runmodal called ***"];
    // FIXME: Is this correct???
     [[CPRunLoop currentRunLoop] limitDateForMode:CPDefaultRunLoopMode];
 
     if (typeof window["cpSavePanel"] === "function")
     {
         var resultObject = window.cpSavePanel({
                 isExtensionHidden: _isExtensionHidden,
                 canSelectHiddenExtension: _canSelectHiddenExtension,
                 allowsOtherFileTypes: _allowsOtherFileTypes,
                 canCreateDirectories: _canCreateDirectories,
                 allowedFileTypes: _allowedFileTypes
             }),
             result = resultObject.button;
 
         _URL = result ? [CPURL URLWithString:resultObject.URL] : nil;
     }
     else
     {
         // FIXME: This is not the best way to do this.
         var documentName = window.prompt("Document Name:"),
             result = documentName !== null;
        
         //_URL = result ? [[self class] proposedFileURLWithDocumentName:documentName] : nil;
         _URL = [CPURL URLWithString:documentName];
     }
 
     return result;
}

@end