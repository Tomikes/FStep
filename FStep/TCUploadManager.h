//
//  TCUploadManager.h
//  FStep
//
//  Created by mike on 8/4/16.
//  Copyright © 2016 mike. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TCUploadOperation.h"

typedef void (^TCBatchUploadProgressBlock)(NSUInteger total, NSUInteger completed, NSString *fileURL);
typedef void (^TCBatchUploadCompleteBlock)(NSArray *successes, NSArray *failures);

@interface TCUploadManager : NSObject

@property (nonatomic, strong) TCBaseAPIClient *client;

/**
 *  设置上传的最大并发数
 *
 *  @param maxConcurrentUploads 上传最大并发数
 */
- (void)setMaxConcurrentUploads:(NSInteger)maxConcurrentUploads;

/**
 *  当前的上传数
 *
 *  @return 上传数
 */
- (NSUInteger)currentUploadCount;

/**
 *  获取当前最大的上传并发数
 *
 *  @return 最大的上传并发数
 */
- (NSInteger)maxConcurrentUploads;

/**
 *  取消所有上传任务
 */
- (void)cancelAllUpload;

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
                          failure:(TCUploadFailureBlock)failure;

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
                     complete:(TCBatchUploadCompleteBlock)complete;

/**
 *  判断某个文件是否正在上传
 *
 *  @param fileURL 文件路径
 *
 *  @return BOOL
 */
- (BOOL)isUploading:(NSString *)fileURL;

@end
