//
//  TCSerialRequestOperation.m
//  TCNetworking
//
//  Created by 陈 胜 on 16/5/25.
//  Copyright © 2016年 陈胜. All rights reserved.
//

#import "TCSerialRequestOperation.h"
#import "TCCommoAPIClient.h"
#import "TCNetworkingHelper.h"

static NSString * const kTCRequestLockName = @"com.ichensheng.networking.request.operation.lock";

@interface TCSerialRequestOperation()

@property (nonatomic, copy) NSString *URLString;
@property (nonatomic, copy) NSDictionary *parameters;
@property (nonatomic, copy) TCRequestSuccessBlock successBlock;
@property (nonatomic, copy) TCRequestFailureBlock failureBlock;
@property (nonatomic, copy) TCRequestCancelBlock cancelBlock;
@property (nonatomic, strong) NSRecursiveLock *lock;
@property (nonatomic, strong) NSURLSessionDataTask *requestTask;
@property (nonatomic, assign) TCRequestAction action;

@property (assign, nonatomic, getter = isExecuting) BOOL executing;
@property (assign, nonatomic, getter = isFinished) BOOL finished;

@end

@implementation TCSerialRequestOperation

@synthesize executing = _executing;
@synthesize finished = _finished;

/**
 *  创建一个请求Operation
 *
 *  @param URLString  文件路径
 *  @param parameters 请求参数
 *  @param success    成功回调
 *  @param failure    失败回调
 *  @param cancel     取消回调
 *
 *  @return TCSerialRequestOperation
 */
- (instancetype)initWithURL:(NSString *)URLString
                 parameters:(NSDictionary *)parameters
                    success:(TCRequestSuccessBlock)success
                    failure:(TCRequestFailureBlock)failure
                     cancel:(TCRequestCancelBlock)cancel {
    
    if (self = [super init]) {
        _URLString = URLString;
        _parameters = parameters;
        _lock = [[NSRecursiveLock alloc] init];
        _lock.name = kTCRequestLockName;
        _successBlock = [success copy];
        _failureBlock = [failure copy];
        _cancelBlock = [cancel copy];
    }
    return self;
}

/**
 *  创建一个请求Operation
 *
 *  @param URLString  文件路径
 *  @param parameters 请求参数
 *  @param success    成功回调
 *  @param failure    失败回调
 *  @param cancel     取消回调
 *
 *  @return TCSerialRequestOperation
 */
+ (instancetype)GET:(NSString *)URLString
         parameters:(NSDictionary *)parameters
            success:(TCRequestSuccessBlock)success
            failure:(TCRequestFailureBlock)failure
             cancel:(TCRequestCancelBlock)cancel {
    
    TCSerialRequestOperation *operation =
    [[TCSerialRequestOperation alloc] initWithURL:URLString
                                       parameters:parameters
                                          success:success
                                          failure:failure
                                           cancel:cancel];
    operation.action = GET;
    return operation;
}

/**
 *  创建一个请求Operation
 *
 *  @param URLString  文件路径
 *  @param parameters 请求参数
 *  @param success    成功回调
 *  @param failure    失败回调
 *  @param cancel     取消回调
 *
 *  @return TCSerialRequestOperation
 */
+ (instancetype)POST:(NSString *)URLString
          parameters:(NSDictionary *)parameters
             success:(TCRequestSuccessBlock)success
             failure:(TCRequestFailureBlock)failure
              cancel:(TCRequestCancelBlock)cancel {
    
    TCSerialRequestOperation *operation =
    [[TCSerialRequestOperation alloc] initWithURL:URLString
                                       parameters:parameters
                                          success:success
                                          failure:failure
                                           cancel:cancel];
    operation.action = POST;
    return operation;
}

- (void)start {
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
    if (self.action == GET) {
        self.requestTask
        = [self.client GET:self.URLString parameters:self.parameters progress:nil
                 success:^(NSURLSessionDataTask * task, id responseObject) {
                     @strongify(self)
                     if (!self) {
                         return;
                     }
                     if (self.successBlock) {
                         self.successBlock(responseObject);
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
                         self.failureBlock(error);
                     }
                     [self done];
                     CFRunLoopStop(CFRunLoopGetCurrent());
                 }];
    } else {
        self.requestTask
        = [self.client POST:self.URLString parameters:self.parameters progress:nil
                  success:^(NSURLSessionDataTask * task, id responseObject) {
                      @strongify(self)
                      if (!self) {
                          return;
                      }
                      if (self.successBlock) {
                          self.successBlock(responseObject);
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
                          self.failureBlock(error);
                      }
                      [self done];
                      CFRunLoopStop(CFRunLoopGetCurrent());
                  }];
    }
    [self.lock unlock];
}

- (void)cancel {
    [self.lock lock];
    if (self.isFinished) {
        [self.lock unlock];
        return;
    }
    [super cancel];
    if (self.requestTask) {
        [self.requestTask cancel];
    }
    if (self.cancelBlock) {
        self.cancelBlock();
    }
    if (self.isExecuting) self.executing = NO;
    if (!self.isFinished) self.finished = YES;
    [self reset];
    CFRunLoopStop(CFRunLoopGetCurrent());
    [self.lock unlock];
}

- (void)done {
    self.finished = YES;
    self.executing = NO;
    [self reset];
}

- (void)reset {
    self.successBlock = nil;
    self.failureBlock = nil;
    self.cancelBlock = nil;
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
