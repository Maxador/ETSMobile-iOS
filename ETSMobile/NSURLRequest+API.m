//
//  NSURLRequest+API.m
//  ETSMobile
//
//  Created by Jean-Philippe Martin on 2013-11-06.
//  Copyright (c) 2013 ApplETS. All rights reserved.
//

#import "NSURLRequest+API.h"
#import "NSURL+API.h"
#import "ETSAuthenticationViewController.h"

@interface NSURLRequest (API_PRIVATE)
+ (id)JSONRequestWithURL:(NSURL *)URL;
@end

@implementation NSURLRequest (API_PRIVATE)

+ (id)JSONRequestWithURL:(NSURL *)URL
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:URL];
    
    [request setHTTPMethod: @"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"UTF-8;" forHTTPHeaderField:@"Accept-Charset"];
    [request setCachePolicy: NSURLRequestReloadIgnoringCacheData];
    
    return request;
}

@end

@implementation NSURLRequest (API)

+ (id)requestForCourses
{
    NSMutableURLRequest *request = [NSURLRequest JSONRequestWithURL:[NSURL URLForCourses]];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    if ([ETSAuthenticationViewController passwordInKeychain]) [parameters setObject:[ETSAuthenticationViewController passwordInKeychain] forKey:@"motPasse"];
    if ([ETSAuthenticationViewController usernameInKeychain]) [parameters setObject:[ETSAuthenticationViewController usernameInKeychain] forKey:@"codeAccesUniversel"];
    
    NSError *error = nil;
    [request setHTTPBody:[NSJSONSerialization dataWithJSONObject:parameters options:kNilOptions error:&error]];

    return request;
}

@end