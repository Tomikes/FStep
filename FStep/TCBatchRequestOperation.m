//
//  TCBatchRequestOperation.m
//  FStep
//
//  Created by mike on 8/4/16.
//  Copyright © 2016 mike. All rights reserved.
//

#import "TCBatchRequestOperation.h"

static NSString * const kTCBatchRequestLockName = @"com.Tomikes.networking.batchrequest.operation.lock";

@interface TCBatchRequestOperation ()

@property (nonatomic, strong) TCBatchRequest *batchRequest;
@property (nonatomic, copy) TCBatchRequestSuccessBlock successBlock;
@property (nonatomic, copy) TCBatchRequestFailureBlock failureBlock;
@property (nonatomic, strong) NSRecursiveLock *lock;
@property (nonatomic, strong) NSURLSessionDataTask *requestTask;
@property (nonatomic, assign, getter=isExecuting) BOOL executing;
@property (nonatomic, assign, getter=isFinished) BOOL finished;

@end

@implementation TCBatchRequestOperation
@synthesize executing = _executing;
@synthesize finished = _finished;

/**
 *  创建一个批量请求Operation
 *
 *  @param batchRequest 请求对象
 *  @param success      成功回调
 *  @param failure      失败回调
 *
 *  @return TCBatchRequestOperation
 */
- (instancetype)initWithBatchRequst:(TCBatchRequest *)batchRequest
                            success:(TCBatchRequestSuccessBlock)success
                            failure:(TCBatchRequestFailureBlock)failure {
    
    if (self = [super init]) {
        _batchRequest = batchRequest;
        _lock = [[NSRecursiveLock alloc] init];
        _lock.name = kTCBatchRequestLockName;
        _successBlock = [success copy];
        _failureBlock = [failure copy];
    }
    return self;
}


#pragma mark -override func
- (void)start{
    
    [self.lock lock];
    if ([self isCancelled]) {
        self.finished = YES;
        [self reset];
        [self.lock unlock];
        return;
    }
    
    CFRunLoopRun();
    self.executing = YES;
    @weakify(self)
    self.requestTask = nil;
    if (self.batchRequest.action == GET) {
        [self.client GET:self.batchRequest.URLString
              parameters:self.batchRequest.parameters
                progress:nil
                 success:^(NSURLSessionDataTask *task, id responseObject) {
             @strongify(self)
                     if (!self) {
                         return;
                     }
                     if (self.successBlock) {
                         self.successBlock(responseObject,self.batchRequest);
                     }
                     [self done];
                     CFRunLoopStop(CFRunLoopGetCurrent());
            
        }
                 failure:^(NSURLSessionDataTask *task, NSError *error){
            
                     @strongify(self)
                     if (!self) {
                         return;
                     }
                     if (self.failureBlock) {
                         self.failureBlock(self.batchRequest,error);
                     }
                     [self done];
                     CFRunLoopStop(CFRunLoopGetCurrent());
        }];
    }else{
        [self.client POST:self.batchRequest.URLString parameters:self.batchRequest.parameters progress:nil
                  success:^(NSURLSessionDataTask *task, id responseObject) {
                      @strongify(self)
                      if (!self) {
                          return;
                      }
                      if (self.successBlock) {
                          self.successBlock(responseObject, self.batchRequest);
                      }
                      [self done];
                      CFRunLoopStop(CFRunLoopGetCurrent());
                  }
                  failure:^(NSURLSessionDataTask *task, NSError *error) {
                      @strongify(self)
                      if (!self) {
                          return;
                      }
                      if (self.failureBlock) {
                          self.failureBlock(self.batchRequest,error);
                      }
                      [self done];
                      CFRunLoopStop(CFRunLoopGetCurrent());
                  }];

    }
    
    //事务完成，解锁
    [self.lock unlock];
    
}


- (void)reset{
    self.successBlock = nil;
    self.failureBlock = nil;
}


- (void)done{
    self.finished = YES;
    self.executing = NO;
    [self reset];
}

//-----------------over
- (void)cancel{
    [self.lock lock];
    if (self.isFinished) {
        [self.lock unlock];
        return;
    }
    [super cancel];
    if (self.requestTask) {
        [self.requestTask cancel];
    }
    if (self.isExecuting) self.executing = NO;
    if (!self.isFinished) self.finished = YES;
    [self reset];
    CFRunLoopStop(CFRunLoopGetCurrent());
    [self.lock unlock];


}

- (void)setFinished:(BOOL)finished {
    [self willChangeValueForKey:@"isFinished"];
    _finished = finished;
    [self didChangeValueForKey:@"isFinished"];
}

- (void)setExecuting:(BOOL)executing {
    [self willChangeValueForKey:@"isExecuting"];
    _executing = executing;
    [self didChangeValueForKey:@"isExecuting"];
}
// 返回YES表示异步调用，否则为同步调用
- (BOOL)isAsynchronous {
    return YES;
}

@end
