//
//  TCDownLoadManager.m
//  FStep
//
//  Created by mike on 8/4/16.
//  Copyright © 2016 mike. All rights reserved.
//

#import "TCDownLoadManager.h"
static NSString * const kProgressCallbackKey = @"progressCallback";
static NSString * const kDestinationCallbackKey = @"destinationCallback";
static NSString * const kSuccessCallbackKey = @"successCallback";
static NSString * const kFailureCallbackKey = @"failureCallback";
static NSString * const kProgressKey = @"progress";

@interface TCDownLoadManager ()

@property (nonatomic, strong) NSOperationQueue *downloadQueue;
@property (nonatomic, strong) dispatch_queue_t barrierQueue;
@property (nonatomic, strong) NSMutableDictionary *URLCallbacks;
@property (nonatomic, strong) NSMutableDictionary *URLProgresses;

@end

@implementation TCDownLoadManager

- (instancetype)init {
    if (self = [super init]) {
        _downloadQueue = [[NSOperationQueue alloc] init];
        [_downloadQueue setMaxConcurrentOperationCount:2];
        _URLCallbacks = [[NSMutableDictionary alloc] init];
        _URLProgresses = [[NSMutableDictionary alloc] init];
        _barrierQueue = dispatch_queue_create("com.ichensheng.network.download.TCBarrierQueue", DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}

/**
 *  设置下载的最大并发数
 *
 *  @param maxConcurrentDownloads 下载最大并发数
 */
- (void)setMaxConcurrentDownloads:(NSInteger)maxConcurrentDownloads {
    self.downloadQueue.maxConcurrentOperationCount = maxConcurrentDownloads;
}

/**
 *  当前的下载数
 *
 *  @return 下载数
 */
- (NSUInteger)currentDownloadCount {
    return self.downloadQueue.operationCount;
}

/**
 *  获取当前最大的下载并发数
 *
 *  @return 最大的下载并发数
 */
- (NSInteger)maxConcurrentDownloads {
    return self.downloadQueue.maxConcurrentOperationCount;
}

/**
 *  取消所有下载任务
 */
- (void)cancelAllDownload {
    [self.downloadQueue cancelAllOperations];
}
/**
 *  下载文件
 *
 *  @param URLString   下载路径
 *  @param progress    进度回调
 *  @param destination 存储路径
 *  @param success     成功回调
 *  @param failure     失败回调
 *
 *  @return TCDownloadOperation对象
 */
- (TCDownloadOperation *)downloadFile:(NSString *)URLString
                             progress:(TCDownloadProgressBlock)progress
                          destination:(TCDownloadDestinationBlock)destination
                              success:(TCDownloadSuccessBlock)success
                              failure:(TCDownloadFailureBlock)failure {
    
    __block TCDownloadOperation *operation;
    NSURL *url = [NSURL URLWithString:URLString];
    @weakify(self)
    [self addProgressCallback:progress destination:destination success:success failure:failure forURL:url create:^{
        @strongify(self)
        operation = [[TCDownloadOperation alloc] initWithURL:URLString progress:^(NSUInteger total, NSUInteger completed) {
            @strongify(self)
            if (!self) {
                return;
            }
            NSArray *callbacksForURL = [self.URLCallbacks[url] copy];
            NSMutableArray *progressesArray = self.URLProgresses[url];
            for (NSDictionary *callbacks in callbacksForURL) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    TCDownloadProgressBlock callback = callbacks[kProgressCallbackKey];
                    if (callback) {
                        callback(total, completed);
                    }
                });
            }
            
            // 记住下载进度
            progressesArray[0] = @(total);
            progressesArray[1] = @(completed);
        } destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
            @strongify(self)
            if (!self) {
                return nil;
            }
            __block NSArray *callbacksForURL = [self.URLCallbacks[url] copy];
            NSURL *destinationURL = nil;
            for (NSDictionary *callbacks in callbacksForURL) {
                TCDownloadDestinationBlock callback = callbacks[kDestinationCallbackKey];
                if (callback) { // 只调用一次
                    destinationURL = callback(targetPath, response);
                    break;
                }
            }
            return destinationURL;
        } success:^(NSURLResponse *response, NSURL *filePath) {
            @strongify(self)
            if (!self) {
                return;
            }
            NSArray *callbacksForURL = [self.URLCallbacks[url] copy];
            for (NSDictionary *callbacks in callbacksForURL) {
                TCDownloadSuccessBlock callback = callbacks[kSuccessCallbackKey];
                if (callback) {
                    callback(response, filePath);
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
                TCDownloadFailureBlock callback = callbacks[kFailureCallbackKey];
                if (callback) {
                    callback(response, error);
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
        [self.downloadQueue addOperation:operation];
    }];
    return operation;
}

- (void)addProgressCallback:(TCDownloadProgressBlock)progress
                destination:(TCDownloadDestinationBlock)destination
                    success:(TCDownloadSuccessBlock)success
                    failure:(TCDownloadFailureBlock)failure
                     forURL:(NSURL *)url
                     create:(void(^)())create {
    
    // 下载的URL如果为空则直接返回
    if (url == nil) {
        if (success != nil) {
            success(nil, nil);
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
        
        // 一个URL只有一个下载，对应多个回调响应
        NSMutableArray *callbacksForURL = self.URLCallbacks[url];
        NSMutableDictionary *callbacks = [[NSMutableDictionary alloc] init];
        if (progress) { // 进度回调
            if (!first) { // 后面启动的下载立即获取最新进度
                NSMutableArray *progressesArray = self.URLProgresses[url];
                progress([progressesArray[0] integerValue], [progressesArray[1] integerValue]);
            }
            callbacks[kProgressCallbackKey] = [progress copy];
        }
        if (destination) { // 保存目录回调
            callbacks[kDestinationCallbackKey] = [destination copy];
        }
        if (success) { // 下载成功回调
            callbacks[kSuccessCallbackKey] = [success copy];
        }
        if (failure) { // 下载失败回调
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
    dispatch_barrier_sync(self.barrierQueue, ^{
        [self.URLCallbacks removeObjectForKey:URL];
        [self.URLProgresses removeObjectForKey:URL];
    });
}


@end
