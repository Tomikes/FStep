//
//  TCBatchRequestManager.h
//  FStep
//
//  Created by mike on 8/4/16.
//  Copyright © 2016 mike. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TCBaseAPIClient.h"
#import "TCBatchRequest.h"

@interface TCBatchRequestManager : NSObject

/**
 *  批量网络请求类
 *
 *  @param success 全部成功回调
 *  @param failure 只要有一个失败就回调该block
 *  @param serial  是否串行请求，串行请求时只有一个线程否则有多个线程
 *  @param client  API客户端
 *
 *  @return TCBatchRequestManager
 */
- (instancetype)initWithSuccessBlock:(void(^)(NSDictionary *successResponses))success
                             failure:(void(^)(NSDictionary *errorResponses))failure
                              serial:(BOOL)serial
                           useClient:(TCBaseAPIClient *)client;

/**
 * 添加批量请求
 *
 *@parma requests 批量请求数组
 */
- (void)addBatchRequests:(NSArray<TCBatchRequest *> *)array;

/**
 *  添加请求
 *
 *  @param request 请求对象
 */
- (void)addBatchRequest:(TCBatchRequest *)request;
/**
 *  启动批量请求
 */
- (void)startRequest;

/**
 *  取消所有请求
 */
- (void)cancelAllRequest;



@end
