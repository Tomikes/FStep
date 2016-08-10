//
//  TCCommoAPIClient.m
//  FStep
//
//  Created by mike on 8/4/16.
//  Copyright © 2016 mike. All rights reserved.
//

#import "TCCommoAPIClient.h"

@implementation TCCommoAPIClient

+ (instancetype)sharedInstance {
    static TCCommoAPIClient *_client = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _client = [TCCommoAPIClient clientWithBaseURL:nil];
    });
    return _client;
}

@end
