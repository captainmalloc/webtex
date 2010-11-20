/*
 * CPCookie_Additions.j
 *
 * Created by Philippe Laval on 2009/04/11.
 * Copyright 2009 Philippe Laval. All rights reserved.
 *
 * Source under MIT and LGPL licences.
 * (This code can be included in cappuccino CPCookie.j code)
 */

@import <Foundation/CPObject.j>
@import <AppKit/CPCookie.j>

@implementation CPCookie (Additions)
 
+ (void) removeCookieWithName:(CSString)aName
{
	[CPCookie cookieWithName:aName andValue:"" forDays:-1 inDomain:nil atPath:@"/"];
}

+ (void) removeCookieWithName:(CSString)aName inDomain:(CPString)domain
{
	[CPCookie cookieWithName:aName andValue:"" forDays:-1 inDomain:domain atPath:@"/"];
}

// This will remove the cookie
+ (void) removeCookieWithName:(CSString)aName inDomain:(CPString)domain atPath:(CPString)path
{
	[CPCookie cookieWithName:aName andValue:"" forDays:-1 inDomain:domain atPath:path];
}

// This will create a cookie with the current stored value (if present) or an empty string (if not present)
+ (CPCookie) cookieWithName:(CPString)aName
{
	return [[CPCookie alloc] initWithName:aName];
}

// This will create a new cookie which will last until the user quit the browser
+ (CPCookie)cookieWithName:(CPString)aName andValue:(CPString)aValue inDomain:(CPString)domain
{
    return [[CPCookie alloc] initWithName:aName andValue:aValue forDays:0 inDomain:domain];
}

// This will create a new cookie which will last for some days
+ (CPCookie)cookieWithName:(CPString)aName andValue:(CPString)aValue forDays:(int)days inDomain:(CPString)domain atPath:(CPString)path
{
    return [[CPCookie alloc] initWithName:aName andValue:aValue forDays:days inDomain:domain atPath:path];
}

// This will create a new cookie which will last for some days
+ (CPCookie)cookieWithName:(CPString)aName andValue:(CPString)aValue forDays:(int)days inDomain:(CPString)domain
{
    return [[CPCookie alloc] initWithName:aName andValue:aValue forDays:days inDomain:domain];
}

// This will create a new cookie which will last for some days
+ (CPCookie)cookieWithName:(CPString)aName andValue:(CPString)aValue forDays:(int)days
{
    return [[CPCookie alloc] initWithName:aName andValue:aValue forDays:days];
}


// This will create a new cookie which will last for some days
// 0 days means : the cookie will be distroyed when the user quit the browser
// domain may be nil (the cookie is for the domain currently used by the cappuccino application)
// path may be nil (will default to "/" for all the domain)
- (id)initWithName:(CPString)aName andValue:(CPString)aValue forDays:(int)days inDomain:(CPString)domain atPath:(CPString)path
{
    self = [super init];
    if (self)
	{
		var expires;
		
    	_cookieName  = aName;
    	_cookieValue = aValue;

	    if(days)
		{
			var date = new Date();
			date.setTime(date.getTime()+(days*24*60*60*1000));
			
			_expires = date.toGMTString();
	        expires = "; expires="+_expires;
		}
	    else 
		{	
			_expires = "";
	        expires = _expires;
		}

	    if(domain)
	        domain = "; domain="+domain;
	    else 
	        domain = "";
	
		if (path)
			path = "; path="+path
		else
			path = "; path=/"

		document.cookie = _cookieName+"="+_cookieValue+expires+path+domain;        
	}

    return self;
}

- (id)initWithName:(CPString)aName andValue:(CPString)aValue forDays:(int)days inDomain:(CPString)domain
{
	// "/" means a cookie for all the domain
    self = [self initWithName:aName andValue:aValue forDays:days inDomain:domain atPath:"/"];
	return self;
}

- (id)initWithName:(CPString)aName andValue:(CPString)aValue forDays:(int)days
{
	// nil means : we will use the default domain (the one for the html page hosting the cappuccino application)
	// "/" means a cookie for all the domain
    self = [self initWithName:aName andValue:aValue forDays:days inDomain:nil atPath:"/"];
	return self;
}

/*!
    Returns the cookie's domain
*/
/*
- (CPString)domain
{
    return _domain;
}
*/

 
@end