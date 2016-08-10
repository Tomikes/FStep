//
//  TCFileDownLoadTool.m
//  FStep
//
//  Created by mike on 8/4/16.
//  Copyright © 2016 mike. All rights reserved.
//

#import "TCFileDownLoadTool.h"

@implementation TCFileDownLoadTool

/**
 *  文件下载
 *
 *  @param URLString   文件路径，全路径
 *  @param progress    下载进度
 *  @param destination 存储路径
 *  @param success     成功回调
 *  @param failure     失败回调
 *  @param client      TCBaseAPIClient
 *
 *  @return NSURLSessionDownloadTask
 */
+ (NSURLSessionDownloadTask *)downloadFile:(NSString *)URLString
                                  progress:(TCDownloadProgressBlock)progress
                               destination:(TCDownloadDestinationBlock)destination
                                   success:(TCDownloadSuccessBlock)success
                                   failure:(TCDownloadFailureBlock)failure
                                 useClient:(TCBaseAPIClient *)client {
    
    NSURLSessionDownloadTask *downloadTask = nil;
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:URLString]];
    downloadTask = [client downloadTaskWithRequest:request progress:^(NSProgress *downloadProgress) {
        progress((NSUInteger)downloadProgress.totalUnitCount, (NSUInteger)downloadProgress.completedUnitCount);
    } destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        NSURL *destinationURL = destination(targetPath, response);
        return [destinationURL URLByAppendingPathComponent:[response suggestedFilename]];
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        if (error) {
            failure(response, error);
        } else {
            success(response, filePath);
        }
    }];
    [downloadTask resume];
    return downloadTask;
}

/**
 *  文件下载
 *
 *  @param URLString   文件路径，全路径
 *  @param progress    下载进度
 *  @param success     成功回调
 *  @param failure     失败回调
 *  @param client      TCBaseAPIClient
 *
 *  @return NSURLSessionDownloadTask
 */
+ (NSURLSessionDownloadTask *)downloadFile:(NSString *)URLString
                                  progress:(TCDownloadProgressBlock)progress
                                   success:(TCDownloadSuccessBlock)success
                                   failure:(TCDownloadFailureBlock)failure
                                 useClient:(TCBaseAPIClient *)client {
    
    return [self downloadFile:URLString
                     progress:progress
                  destination:nil
                      success:success
                      failure:failure
                    useClient:client];
}


@end
