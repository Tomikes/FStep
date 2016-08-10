//
//  TCFileDownLoadTool.m
//  FStep
//
//  Created by mike on 8/4/16.
//  Copyright © 2016 mike. All rights reserved.
//

#import "TCUploadOperation.h"

static NSString * const kTCUploadLockName = @"com.ichensheng.networking.upload.operation.lock";

@interface TCUploadOperation()

@property (nonatomic, copy) NSString *fileURL;
@property (nonatomic, copy) NSString *serverURL;
@property (nonatomic, copy) TCUploadProgressBlock progressBlock;
@property (nonatomic, copy) TCUploadSuccessBlock successBlock;
@property (nonatomic, copy) TCUploadFailureBlock failureBlock;
@property (nonatomic, copy) TCUploadCancelBlock cancelBlock;
@property (nonatomic, strong) NSRecursiveLock *lock;
@property (nonatomic, strong) NSURLSessionUploadTask *uploadTask;

@property (assign, nonatomic, getter = isExecuting) BOOL executing;
@property (assign, nonatomic, getter = isFinished) BOOL finished;

@end

@implementation TCUploadOperation

@synthesize executing = _executing;
@synthesize finished = _finished;

/**
 *  创建一个上传Operation
 *
 *  @param fileURL   文件路径
 *  @param serverURL 上传地址
 *  @param progress  进度回调
 *  @param success   成功回调
 *  @param failure   失败回调
 *  @param cancel    取消回调
 *
 *  @return TCUploadOperation对象
 */
- (instancetype)initWithURL:(NSString *)fileURL
                  serverURL:(NSString *)serverURL
                   progress:(TCUploadProgressBlock)progress
                    success:(TCUploadSuccessBlock)success
                    failure:(TCUploadFailureBlock)failure
                     cancel:(TCUploadCancelBlock)cancel {
    
    if (self = [super init]) {
        _fileURL = [fileURL copy];
        _serverURL = [serverURL copy];
        _lock = [[NSRecursiveLock alloc] init];
        _lock.name = kTCUploadLockName;
        _progressBlock = [progress copy];
        _successBlock = [success copy];
        _failureBlock = [failure copy];
        _cancelBlock = [cancel copy];
    }
    return self;
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
    self.uploadTask =
    [TCFileUploader uploadFile:self.fileURL serverURL:self.serverURL progress:^(NSUInteger total, NSUInteger completed) {
        @strongify(self)
        if (!self) {
            return;
        }
        if (self.progressBlock) {
            self.progressBlock(total, completed);
        }
    } success:^(NSURLResponse *response, id responseObject) {
        @strongify(self)
        if (!self) {
            return;
        }
        if (self.successBlock) {
            self.successBlock(response, responseObject);
        }
        [self done];
        CFRunLoopStop(CFRunLoopGetCurrent());
    } failure:^(NSURLResponse *response, NSError *error) {
        @strongify(self)
        if (!self) {
            return;
        }
        if (self.failureBlock) {
            self.failureBlock(response, error);
        }
        [self done];
        CFRunLoopStop(CFRunLoopGetCurrent());
    } useClient:self.client];
    [self.lock unlock];
}

- (void)cancel {
    [self.lock lock];
    if (self.isFinished) {
        [self.lock unlock];
        return;
    }
    [super cancel];
    if (self.uploadTask) {
        [self.uploadTask cancel];
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
    self.progressBlock = nil;
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
