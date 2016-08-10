//
//  TCBaseAPIClient.m
//  FStep
//
//  Created by mike on 8/4/16.
//  Copyright © 2016 mike. All rights reserved.
//

#import "TCFileUploader.h"
#import "TCCommoAPIClient.h"
#import "TCNetworkingHelper.h"

@implementation TCFileUploader

/**
 *  一次上传多个文件
 *
 *  @param fileURLs  文件路径数组
 *  @param serverURL 上传地址
 *  @param progress  上传进度
 *  @param success   成功回调
 *  @param failure   失败会掉
 *  @param client    TCBaseAPIClient
 *
 *  @return NSURLSessionUploadTask
 */
+ (NSURLSessionUploadTask *)uploadFiles:(NSArray *)fileURLs
                              serverURL:(NSString *)serverURL
                               progress:(TCUploadProgressBlock)progress
                                success:(TCUploadSuccessBlock)success
                                failure:(TCUploadFailureBlock)failure
                              useClient:(TCBaseAPIClient *)client{
    
    if (!serverURL) {
        NSLog(@"上传路径没提供");
        return nil;
    }
    if (fileURLs.count == 0) {
        NSLog(@"没有上传文件");
        return nil;
    }
    
    NSURLSessionUploadTask *uploadTask = nil;
    NSError *requestError = nil;
    NSMutableURLRequest *request =
    [client.requestSerializer multipartFormRequestWithMethod:@"POST"
                                                   URLString:serverURL
                                                  parameters:nil
                                   constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                                       [self appendUploadFormData:formData fileURLs:fileURLs];
                                   } error:&requestError];
    if (requestError) {
        NSLog(@"上传文件失败：%@", requestError);
        return nil;
    }
    uploadTask = [client uploadTaskWithStreamedRequest:request progress:^(NSProgress *uploadProgress) {
        progress((NSUInteger)uploadProgress.totalUnitCount, (NSUInteger)uploadProgress.completedUnitCount);
    } completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            failure(response, error);
        } else {
            success(response, [TCNetworkingHelper parseResponse:responseObject]);
        }
    }];
    [uploadTask resume];
    return uploadTask;
}

/**
 *  上传文件
 *
 *  @param fileURL   文件路径
 *  @param serverURL 上传地址
 *  @param progress  上传进度
 *  @param success   成功回调
 *  @param failure   失败会掉
 *  @param client    TCBaseAPIClient
 *
 *  @return NSURLSessionUploadTask
 */
+ (NSURLSessionUploadTask *)uploadFile:(NSString *)fileURL
                             serverURL:(NSString *)serverURL
                              progress:(TCUploadProgressBlock)progress
                               success:(TCUploadSuccessBlock)success
                               failure:(TCUploadFailureBlock)failure
                             useClient:(TCBaseAPIClient *)client {
    
    return [self uploadFiles:@[fileURL]
                   serverURL:serverURL
                    progress:progress
                     success:success
                     failure:failure
                   useClient:client];
}

#pragma mark - Private Methods

+ (void)appendUploadFormData:(id<AFMultipartFormData>)formData
                    fileURLs:(NSArray *)fileURLs {
    
    for (NSString *fileURL in fileURLs) {
        NSInputStream *input = [NSInputStream inputStreamWithFileAtPath:fileURL];
        NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:fileURL error:nil];
        NSNumber *contentLength = (NSNumber *)[fileAttributes objectForKey:NSFileSize];
        [formData appendPartWithInputStream:input
                                       name:@"file"
                                   fileName:[fileURL lastPathComponent]
                                     length:[contentLength integerValue]
                                   mimeType:[self MIMEType:fileURL]];
    }
}

+ (NSString *)MIMEType:(NSString *)fileURL {
    NSString *extension = [fileURL pathExtension];
    CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)extension, NULL);
    return (__bridge NSString *)UTTypeCopyPreferredTagWithClass (UTI, kUTTagClassMIMEType);
}

@end
