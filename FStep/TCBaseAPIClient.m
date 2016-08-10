//
//  TCBaseAPIClient.m
//  FStep
//
//  Created by mike on 8/4/16.
//  Copyright © 2016 mike. All rights reserved.
//

#import "TCBaseAPIClient.h"

@implementation TCBaseAPIClient

/**
 *  通过base url创建网络访问对象
 *
 *  @param url api基路径
 *
 *  @return TCBaseAPIClient
 */
+ (instancetype)clientWithBaseURL:(NSURL *)url {
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    //setting cache
    NSURLCache *cache = [[NSURLCache alloc] initWithMemoryCapacity:50 diskCapacity:100 diskPath:nil];
    [config setURLCache:cache];
    
    TCBaseAPIClient *manager = nil;
    if (url) {
        manager = [[self alloc] initWithBaseURL:url sessionConfiguration:config];
    }else {
        manager = [[self alloc] initWithSessionConfiguration:config];
    }
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy defaultPolicy];
    [manager setSecurityPolicy:securityPolicy];
    securityPolicy.allowInvalidCertificates = YES;
    
    // 以JSON格式解析参数
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    // 以HTTP格式返回
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];

    // 超时时间
    manager.requestSerializer.timeoutInterval = 15.0f;
    
    dispatch_queue_t workQueue = dispatch_queue_create("com.Tomike.networking", DISPATCH_QUEUE_CONCURRENT);
    
    manager.completionQueue = workQueue;
    
    return manager;
}

- (void)cancelAllRequest {


    [self.operationQueue cancelAllOperations];
    [self.tasks enumerateObjectsUsingBlock:^(NSURLSessionTask * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj cancel];
    }];

}


- (void)cancelRequestWithPath:(NSString *)path {
    if (!path || path.length<1) {
        return;
    }
    
    NSString *absolutePath = path;
    if (self.baseURL) {
        absolutePath = [[NSURL URLWithString:path relativeToURL:self.baseURL] absoluteString];
    }
    
    [self.tasks enumerateObjectsUsingBlock:^(NSURLSessionTask * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if([obj.currentRequest.URL.absoluteString isEqualToString:absolutePath]) {
            [obj cancel];
        }
    }];
}

@end
