//
//  TCBatchRequest.h
//  FStep
//
//  Created by mike on 8/4/16.
//  Copyright © 2016 mike. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TCBaseAPIClient.h"
@interface TCBatchRequest : NSObject

@property (nonatomic, strong, readonly) NSString *URLString;
@property (nonatomic, copy, readonly) NSDictionary *parameters;
@property (nonatomic, assign, readonly) TCRequestAction action;

/**
 *  构造批量请求对象
 *
 *  @param URLString  请求URL
 *  @param parameters 请求参数
 *
 *  @return TCBatchRequest
 */
- (instancetype)initWithURL:(NSString *)URLString
                 parameters:(NSDictionary *)parameters;

/**
 *  构造批量get请求对象
 *
 *  @param URLString  请求URL
 *  @param parameters 请求参数
 *
 *  @return TCBatchRequest
 */
+ (instancetype)GET:(NSString *)URLString
         parameters:(NSDictionary *)parameters;

/**
 *  构造批量POST请求对象
 *
 *  @param URLString  请求URL
 *  @param parameters 请求参数
 *
 *  @return TCBatchRequest
 */
+ (instancetype)POST:(NSString *)URLString
          parameters:(NSDictionary *)parameters;


@end
