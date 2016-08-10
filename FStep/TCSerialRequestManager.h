//
//  THSerialRequestManager.h
//  TCNetworking
//
//  Created by 陈 胜 on 16/5/25.
//  Copyright © 2016年 陈胜. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TCSerialRequestOperation.h"

@interface TCSerialRequestManager : NSObject

/**
 *  以TCBaseAPIClient构造网络串行请求队列
 *
 *  @param client TCBaseAPIClient
 *
 *  @return THNetworkingSerialQueue
 */
+ (instancetype)instanceWithClient:(TCBaseAPIClient *)client;

/**
 *  发送POST请求
 *
 *  @param URLString  请求路径
 *  @param parameters 请求参数
 *  @param success    成功回调
 *  @param failure    失败回调
 *
 *  @return TCSerialRequestOperation
 */
- (TCSerialRequestOperation *)POST:(NSString *)URLString
                        parameters:(NSDictionary *)parameters
                           success:(TCRequestSuccessBlock)success
                           failure:(TCRequestFailureBlock)failure;

/**
 *  发送GET请求
 *
 *  @param URLString  请求路径
 *  @param parameters 请求参数
 *  @param success    成功回调
 *  @param failure    失败回调
 *
 *  @return TCSerialRequestOperation
 */
- (TCSerialRequestOperation *)GET:(NSString *)URLString
                       parameters:(NSDictionary *)parameters
                          success:(TCRequestSuccessBlock)success
                          failure:(TCRequestFailureBlock)failure;

/**
 *  取消所有请求
 */
- (void)cancelAllRequest;

@end
