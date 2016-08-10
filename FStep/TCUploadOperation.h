//
//  TCUploadOperation.h
//  FStep
//
//  Created by mike on 8/4/16.
//  Copyright © 2016 mike. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "TCFileUploader.h"

@interface TCUploadOperation : NSOperation

@property (nonatomic, strong) TCBaseAPIClient *client;

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
                     cancel:(TCUploadCancelBlock)cancel;

@end
