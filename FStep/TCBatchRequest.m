//
//  TCBatchRequest.m
//  FStep
//
//  Created by mike on 8/4/16.
//  Copyright © 2016 mike. All rights reserved.
//

#import "TCBatchRequest.h"

@interface TCBatchRequest()

@property (nonatomic, strong, readwrite) NSString *URLString;
@property (nonatomic, copy, readwrite) NSDictionary *parameters;
@property (nonatomic, assign, readwrite) TCRequestAction action;

@end

@implementation TCBatchRequest

/**
 *
 *  构造批量请求对象
 *
 *  @param URLString 请求url
 *  @param parameters 请求参数
 *
 *  @return TCBatchRequest
 */
- (instancetype)initWithURL:(NSString *)URLString
                 parameters:(NSDictionary *)parameters {
    
    if (self = [super init]) {
        _URLString = URLString;
        _parameters = parameters;
        _action = POST;
    }
    return self;
}

/**
 *  构造批量GET请求对象
 *
 *  @param URLString  请求URL
 *  @param parameters 请求参数
 *
 *  @return TCBatchRequest
 */
+ (instancetype)GET:(NSString *)URLString
         parameters:(NSDictionary *)parameters {
    
    TCBatchRequest *batchRequest = [[TCBatchRequest alloc] initWithURL:URLString parameters:parameters];
    batchRequest.action = GET;
    return batchRequest;
}

/**
 *  构造批量POST请求对象
 *
 *  @param URLString  请求URL
 *  @param parameters 请求参数
 *
 *  @return TCBatchRequest
 */
+ (instancetype)POST:(NSString *)URLString
          parameters:(NSDictionary *)parameters {
    
    TCBatchRequest *batchRequest = [[TCBatchRequest alloc] initWithURL:URLString parameters:parameters];
    batchRequest.action = POST;
    return batchRequest;
}

- (NSString *)description {
    if (self.parameters) {
        return [NSString stringWithFormat:@"%@-%@", [self.URLString description], [self.parameters description]];
    } else {
        return [NSString stringWithFormat:@"%@", [self.URLString description]];
    }
}


@end
