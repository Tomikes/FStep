//
//  TCUploadManager.m
//  FStep
//
//  Created by mike on 8/4/16.
//  Copyright © 2016 mike. All rights reserved.
//
#import "TCUploadManager.h"

typedef void (^TCDoUploadProgressBlock)(NSUInteger total, NSUInteger completed, NSString *fileURL);
typedef void (^TCDoUploadSuccessBlock)(NSURLResponse *response, NSString *responseString, NSString *fileURL);
typedef void (^TCDoUploadFailureBlock)(NSURLResponse *response, NSError *error, NSString *fileURL);

static NSString * const kProgressCallbackKey = @"progressCallback";
static NSString * const kSuccessCallbackKey = @"successCallback";
static NSString * const kFailureCallbackKey = @"failureCallback";
static NSString * const kProgressKey = @"progress";

@interface TCUploadManager()

@property (nonatomic, strong) NSOperationQueue *uploadQueue;
@property (nonatomic, strong) dispatch_queue_t barrierQueue;
@property (nonatomic, strong) NSMutableDictionary *URLCallbacks;
@property (nonatomic, strong) NSMutableDictionary *URLProgresses;

@end

@implementation TCUploadManager

- (instancetype)init {
    if (self = [super init]) {
        _uploadQueue = [[NSOperationQueue alloc] init];
        [_uploadQueue setMaxConcurrentOperationCount:2];
        _URLCallbacks = [[NSMutableDictionary alloc] init];
        _URLProgresses = [[NSMutableDictionary alloc] init];
        _barrierQueue = dispatch_queue_create("com.ichensheng.network.upload.TCBarrierQueue", DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}

/**
 *  设置上传的最大并发数
 *
 *  @param maxConcurrentUploads 上传最大并发数
 */
- (void)setMaxConcurrentUploads:(NSInteger)maxConcurrentUploads {
    self.uploadQueue.maxConcurrentOperationCount = maxConcurrentUploads;
}

/**
 *  当前的上传数
 *
 *  @return 上传数
 */
- (NSUInteger)currentUploadCount {
    return self.uploadQueue.operationCount;
}

/**
 *  获取当前最大的上传并发数
 *
 *  @return 最大的上传并发数
 */
- (NSInteger)maxConcurrentUploads {
    return self.uploadQueue.maxConcurrentOperationCount;
}

/**
 *  取消所有上传任务
 */
- (void)cancelAllUpload {
    [self.uploadQueue cancelAllOperations];
}

/**
 *  上传文件
 *
 *  @param fileURL   文件路径
 *  @param serverURL 上传地址
 *  @param progress  进度回调
 *  @param success   成功回调
 *  @param failure   失败回调
 *
 *  @return TCUploadOperation对象
 */
- (TCUploadOperation *)uploadFile:(NSString *)fileURL
                        serverURL:(NSString *)serverURL
                         progress:(TCUploadProgressBlock)progress
                          success:(TCUploadSuccessBlock)success
                          failure:(TCUploadFailureBlock)failure {
    
    return [self doUploadFile:fileURL serverURL:serverURL progress:^(NSUInteger total, NSUInteger completed, NSString *fileURL) {
        progress(total, completed);
    } success:^(NSURLResponse *response, NSString *responseString, NSString *fileURL) {
        success(response, responseString);
    } failure:^(NSURLResponse *response, NSError *error, NSString *fileURL) {
        failure(response, error);
    }];
}

/**
 *  上传文件
 *
 *  @param fileURL   文件路径
 *  @param serverURL 上传地址
 *  @param progress  进度回调
 *  @param success   成功回调
 *  @param failure   失败回调
 *
 *  @return TCUploadOperation对象
 */
- (TCUploadOperation *)doUploadFile:(NSString *)fileURL
                          serverURL:(NSString *)serverURL
                           progress:(TCDoUploadProgressBlock)progress
                            success:(TCDoUploadSuccessBlock)success
                            failure:(TCDoUploadFailureBlock)failure {
    
    __block TCUploadOperation *operation;
    fileURL = [fileURL copy];
    NSURL *url = [NSURL fileURLWithPath:fileURL];
    @weakify(self)
    [self addProgressCallback:progress success:success failure:failure forURL:url create:^{
        @strongify(self)
        operation = [[TCUploadOperation alloc] initWithURL:fileURL serverURL:serverURL progress:^(NSUInteger total, NSUInteger completed) {
            @strongify(self)
            if (!self) {
                return;
            }
            NSArray *callbacksForURL = [self.URLCallbacks[url] copy];
            NSMutableArray *progressesArray = self.URLProgresses[url];
            for (NSDictionary *callbacks in callbacksForURL) {
                TCDoUploadProgressBlock callback = callbacks[kProgressCallbackKey];
                if (callback) {
                    callback(total, completed, fileURL);
                }
            }
            // 记住下载进度
            progressesArray[0] = @(total);
            progressesArray[1] = @(completed);
        } success:^(NSURLResponse *response, id responseObject) {
            @strongify(self)
            if (!self) {
                return;
            }
            NSArray *callbacksForURL = [self.URLCallbacks[url] copy];
            for (NSDictionary *callbacks in callbacksForURL) {
                TCDoUploadSuccessBlock callback = callbacks[kSuccessCallbackKey];
                if (callback) {
                    callback(response, responseObject, fileURL);
                }
            }
            [self doneForURL:url];
        } failure:^(NSURLResponse *response, NSError *error) {
            @strongify(self)
            if (!self) {
                return;
            }
            NSArray *callbacksForURL = [self.URLCallbacks[url] copy];
            for (NSDictionary *callbacks in callbacksForURL) {
                TCDoUploadFailureBlock callback = callbacks[kFailureCallbackKey];
                if (callback) {
                    callback(response, error, fileURL);
                }
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
        [self.uploadQueue addOperation:operation];
    }];
    return operation;
}

/**
 *  判断某个文件是否正在上传
 *
 *  @param fileURL 文件路径
 *
 *  @return BOOL
 */
- (BOOL)isUploading:(NSString *)fileURL {
    NSURL *url = [NSURL fileURLWithPath:fileURL];
    return !!self.URLCallbacks[url];
}

- (void)addProgressCallback:(TCDoUploadProgressBlock)progress
                    success:(TCDoUploadSuccessBlock)success
                    failure:(TCDoUploadFailureBlock)failure
                     forURL:(NSURL *)url
                     create:(void(^)())create {
    
    // 上传的文件路径如果为空则直接返回
    if (url == nil) {
        if (success != nil) {
            success(nil, nil, nil);
        }
        return;
    }
    
    dispatch_barrier_sync(self.barrierQueue, ^{
        BOOL first = NO;
        if (!self.URLCallbacks[url]) {
            self.URLCallbacks[url] = [[NSMutableArray alloc] init];
            
            NSMutableArray *progressesArray = [[NSMutableArray alloc] init];
            [progressesArray addObject:@(0)]; // total
            [progressesArray addObject:@(0)]; // completed
            self.URLProgresses[url] = progressesArray;
            
            first = YES;
        }
        
        // 一个URL只有一个上传，对应多个回调响应
        NSMutableArray *callbacksForURL = self.URLCallbacks[url];
        NSMutableDictionary *callbacks = [[NSMutableDictionary alloc] init];
        if (progress) { // 进度回调
            if (!first) { // 后面启动的下载立即获取最新进度
                NSMutableArray *progressesArray = self.URLProgresses[url];
                progress([progressesArray[0] integerValue], [progressesArray[1] integerValue], [url absoluteString]);
            }
            callbacks[kProgressCallbackKey] = [progress copy];
        }
        if (success) { // 上传成功回调
            callbacks[kSuccessCallbackKey] = [success copy];
        }
        if (failure) { // 上传失败回调
            callbacks[kFailureCallbackKey] = [failure copy];
        }
        [callbacksForURL addObject:callbacks];
        self.URLCallbacks[url] = callbacksForURL;
        
        if (first) {
            create();
        }
    });
}

/**
 *  下载完成
 *
 *  @param URL 下载地址
 */
- (void)doneForURL:(NSURL *)URL {
    [self.URLCallbacks removeObjectForKey:URL];
    [self.URLProgresses removeObjectForKey:URL];
}

/**
 *  批量上传文件
 *
 *  @param fileURLs  文件路径数组
 *  @param serverURL 上传地址
 *  @param progress  进度回调，每一个文件都会有一个回调
 *  @param complete  上传完成，回调里会给出成功和失败的结果
 *
 *  @return key为fileURL，值为TCUploadOperation
 */
- (NSDictionary *)uploadFiles:(NSArray *)fileURLs
                    serverURL:(NSString *)serverURL
                     progress:(TCBatchUploadProgressBlock)progress
                     complete:(TCBatchUploadCompleteBlock)complete {
    
    NSUInteger count = fileURLs.count;
    NSMutableDictionary *operations = [NSMutableDictionary dictionary];
    NSMutableArray *successes = [NSMutableArray array];
    NSMutableArray *failures = [NSMutableArray array];
    for (NSString *fileURL in fileURLs) {
        TCUploadOperation *operation =
        [self doUploadFile:fileURL serverURL:serverURL progress:progress success:^(NSURLResponse *response, NSString *responseString, NSString *fileURL) {
            NSMutableDictionary *successResult = [NSMutableDictionary dictionary];
            if (response) {
                successResult[@"response"] = response;
            }
            if (responseString) {
                successResult[@"responseString"] = responseString;
            }
            successResult[@"fileURL"] = fileURL;
            [successes addObject:successResult];
            if (successes.count + failures.count == count) {
                complete(successes, failures);
            }
        } failure:^(NSURLResponse *response, NSError *error, NSString *fileURL) {
            NSMutableDictionary *errorResult = [NSMutableDictionary dictionary];
            if (response) {
                errorResult[@"response"] = response;
            }
            if (error) {
                errorResult[@"error"] = error;
            }
            errorResult[@"fileURL"] = fileURL;
            [failures addObject:errorResult];
            if (successes.count + failures.count == count) {
                complete(successes, failures);
            }
        }];
        if (operation) {
            operations[fileURL] = operation;
        }
    }
    return operations;
}

@end
