//
//  THSerialRequestManager.m
//  TCNetworking
//
//  Created by 陈 胜 on 16/5/25.
//  Copyright © 2016年 陈胜. All rights reserved.
//

#import "TCSerialRequestManager.h"

@interface TCSerialRequestManager()

@property (nonatomic, strong) TCBaseAPIClient *client;
@property (nonatomic, strong) NSOperationQueue *requestQueue;
@property (nonatomic, strong) NSMutableDictionary *URLRequests;

@end

@implementation TCSerialRequestManager

/**
 *  以TCBaseAPIClient构造网络串行请求队列
 *
 *  @param client TCBaseAPIClient
 *
 *  @return THNetworkingSerialQueue
 */
+ (instancetype)instanceWithClient:(TCBaseAPIClient *)client {
    return [[self alloc] initWithClient:client];
}

- (instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (instancetype)initWithClient:(TCBaseAPIClient *)client {
    if (self = [super init]) {
        _client = client;
        _requestQueue = [[NSOperationQueue alloc] init];
        [_requestQueue setMaxConcurrentOperationCount:1];
        _URLRequests = [[NSMutableDictionary alloc] init];
    }
    return self;
}

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
                           failure:(TCRequestFailureBlock)failure {
    
    NSURL *url = [NSURL fileURLWithPath:URLString];
    if (self.URLRequests[url]) {
        NSLog(@"正在请求进行：%@", [url absoluteString]);
        return nil;
    }
    
    @weakify(self)
    TCSerialRequestOperation *operation =
    [TCSerialRequestOperation POST:URLString parameters:parameters success:^(NSString *responseString) {
        @strongify(self)
        if (!self) {
            return;
        }
        if (success) {
            success(responseString);
        }
        [self doneForURL:url];
    } failure:^(NSError *error) {
        @strongify(self)
        if (!self) {
            return;
        }
        if (error) {
            failure(error);
        }
        [self doneForURL:url];
    } cancel:^{
        @strongify(self)
        if (!self) {
            return;
        }
        [self doneForURL:url];
    }];
    operation.client = self.client;
    [self.requestQueue addOperation:operation];
    
    return operation;
}

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
                          failure:(TCRequestFailureBlock)failure {
    
    NSURL *url = [NSURL fileURLWithPath:URLString];
    if (self.URLRequests[url]) {
        NSLog(@"正在请求进行：%@", [url absoluteString]);
        return nil;
    }
    
    @weakify(self)
    TCSerialRequestOperation *operation =
    [TCSerialRequestOperation GET:URLString parameters:parameters success:^(NSString *responseString) {
        @strongify(self)
        if (!self) {
            return;
        }
        if (success) {
            success(responseString);
        }
        [self doneForURL:url];
    } failure:^(NSError *error) {
        @strongify(self)
        if (!self) {
            return;
        }
        if (error) {
            failure(error);
        }
        [self doneForURL:url];
    } cancel:^{
        @strongify(self)
        if (!self) {
            return;
        }
        [self doneForURL:url];
    }];
    operation.client = self.client;
    [self.requestQueue addOperation:operation];
    
    return operation;
}

/**
 *  取消所有请求
 */
- (void)cancelAllRequest {
    [self.requestQueue cancelAllOperations];
}

#pragma mark - Private Methods

/**
 *  请求完成
 *
 *  @param URL 请求地址
 */
- (void)doneForURL:(NSURL *)URL {
    [self.URLRequests removeObjectForKey:URL];
}

@end
