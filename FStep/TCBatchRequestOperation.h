//
//  TCBatchRequestOperation.h
//  FStep
//
//  Created by mike on 8/4/16.
//  Copyright © 2016 mike. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TCBaseAPIClient.h"
#import "TCBatchRequest.h"

typedef void (^TCBatchRequestSuccessBlock)(id responseObject, TCBatchRequest  *batchRequest);

typedef void (^TCBatchRequestFailureBlock)(TCBatchRequest *  batchRequest, NSError *error);

@interface TCBatchRequestOperation : NSOperation

@property (nonatomic, strong) TCBaseAPIClient *client;

/**
 *  创建一个批量请求Operation
 *
 *  @param batchRequest 请求对象
 *  @param success      成功回调
 *  @param failure      失败回调
 *
 *  @return TCBatchRequestOperation
 */
- (instancetype)initWithBatchRequst:(TCBatchRequest *)request
                            success:(TCBatchRequestSuccessBlock)success
                            failure:(TCBatchRequestFailureBlock)failure;

@end
