//
//  TCDownloadOperation.m
//  FStep
//
//  Created by mike on 8/4/16.
//  Copyright © 2016 mike. All rights reserved.
//

#import "TCDownloadOperation.h"

static NSString * const kTCDownloadLockName = @"com.Tomikes.networking.download.operation.lock";

@interface TCDownloadOperation ()

@property (nonatomic, copy) NSString *downloadURL;
@property (nonatomic, copy) TCDownloadProgressBlock progressBlock;
@property (nonatomic, copy) TCDownloadDestinationBlock destinationBlock;
@property (nonatomic, copy) TCDownloadSuccessBlock successBlock;
@property (nonatomic, copy) TCDownloadFailureBlock failureBlock;
@property (nonatomic, copy) TCDownloadCancelBlock cancelBlock;
@property (nonatomic, strong) NSRecursiveLock *lock;
@property (nonatomic, strong) NSURLSessionDownloadTask *downloadTask;

@property (assign, nonatomic, getter = isExecuting) BOOL executing;
@property (assign, nonatomic, getter = isFinished) BOOL finished;

@end

@implementation TCDownloadOperation

@synthesize executing = _executing;
@synthesize finished = _finished;

/**
 *  创建一个下载Operation
 *
 *  @param URLString   下载路径
 *  @param progress    进度回调
 *  @param destination 存储路径回调
 *  @param success     成功回调
 *  @param failure     失败回调
 *  @param cancel      取消回调
 *
 *  @return TCDownloadOperation对象
 */
- (instancetype)initWithURL:(NSString *)URLString
                   progress:(TCDownloadProgressBlock)progress
                destination:(TCDownloadDestinationBlock)destination
                    success:(TCDownloadSuccessBlock)success
                    failure:(TCDownloadFailureBlock)failure
                     cancel:(TCDownloadCancelBlock)cancel {
    
    if (self = [super init]) {
        _downloadURL = URLString;
        _lock = [[NSRecursiveLock alloc] init];
        _lock.name = kTCDownloadLockName;
        _progressBlock = [progress copy];
        _destinationBlock = [destination copy];
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
    self.downloadTask =
    [TCFileDownLoadTool downloadFile:self.downloadURL progress:^(NSUInteger total, NSUInteger completed) {
        @strongify(self)
        if (!self) {
            return;
        }
        if (self.progressBlock) {
            self.progressBlock(total, completed);
        }
    } destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        @strongify(self)
        if (!self) {
            return nil;
        }
        if (self.destinationBlock) {
            return self.destinationBlock(targetPath, response);
        }
        return nil;
    } success:^(NSURLResponse *response, NSURL *filePath) {
        @strongify(self)
        if (!self) {
            return;
        }
        if (self.successBlock) {
            self.successBlock(response, filePath);
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
    if (self.downloadTask) {
        [self.downloadTask cancel];
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
    self.destinationBlock = nil;
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
