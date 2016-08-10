//
//  TCBatchRequestManager.m
//  FStep
//
//  Created by mike on 8/4/16.
//  Copyright © 2016 mike. All rights reserved.
//

#import "TCBatchRequestManager.h"
#import "TCBatchRequestOperation.h"

@interface TCBatchRequestManager()

@property (nonatomic, copy) void(^success)(NSDictionary *responses);
@property (nonatomic, copy) void(^failure)(NSDictionary *responses);
@property (nonatomic, strong) NSOperationQueue *requestQueue;
@property (nonatomic, strong) TCBaseAPIClient *client;
@property (nonatomic, strong) NSMutableArray *batchRequests;
@property (nonatomic, assign) BOOL canAddTask;

@property (nonatomic, strong) __block NSMutableDictionary *successResponses;
@property (nonatomic, strong) __block NSMutableDictionary *failureResponses;

@end

@implementation TCBatchRequestManager

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
                           useClient:(TCBaseAPIClient *)client {

    if (self = [super init]) {
        self.canAddTask = YES;
        self.success = success;
        self.failure = failure;
        self.client = client;
        self.batchRequests = [NSMutableArray array];
        self.successResponses = [NSMutableDictionary dictionary];
        self.failureResponses = [NSMutableDictionary dictionary];
        
        /**
         * 请求队列 后期更改，需要监听网络变化，如果wifi则5，
         */
        _requestQueue = [[NSOperationQueue alloc] init];
        [_requestQueue setMaxConcurrentOperationCount:(serial ? 1 : 3)];

    }
    
    return self;

}

/**
 *  添加批量请求
 *
 *  @param requests 批量请求数组
 */
- (void)addBatchRequests:(NSArray<TCBatchRequest *> *)requests {
    if (self.canAddTask) {
        [self.batchRequests addObjectsFromArray:requests];
    }
}

/**
 *  添加请求
 *
 *  @param request 请求对象
 */
- (void)addBatchRequest:(TCBatchRequest *)request {
    if (self.canAddTask) {
        [self.batchRequests addObject:request];
    }
}

/**
 *  启动批量请求
 */
- (void)startRequest{
    NSLog(@"开始批量请求...");
    self.canAddTask = NO;// 开始请求之后禁止添加任务
    @weakify(self)
    for (TCBatchRequest *batchRequest in self.batchRequests) {
        TCBatchRequestOperation *operation = [[TCBatchRequestOperation alloc] initWithBatchRequst:batchRequest success:^(id responseObject, TCBatchRequest  *batchRequest){
            @strongify(self)
            self.successResponses[[batchRequest description]] = responseObject;
            [self handleResponse];
        }failure:^(TCBatchRequest *  batchRequest, NSError *error){
            @strongify(self)
            self.failureResponses[[batchRequest description]] = error;
            [self handleResponse];
        }];
        
        operation.client = self.client;
         [self.requestQueue addOperation:operation];
    }
}


- (void)handleResponse {
    if (self.successResponses.count + self.failureResponses.count == self.batchRequests.count) {
        if (self.successResponses.count > 0) {
            self.success(self.successResponses);
        }
        if (self.failureResponses.count > 0) {
            self.failure(self.failureResponses);
        }
        self.canAddTask = YES;
        NSLog(@"完成批量请求...");
    }
}

/**
 *  取消所有请求
 */
- (void)cancelAllRequest {
    [self.requestQueue cancelAllOperations];
}

@end
