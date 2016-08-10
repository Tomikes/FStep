//
//  TCDownloadOperation.h
//  FStep
//
//  Created by mike on 8/4/16.
//  Copyright © 2016 mike. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TCFileDownLoadTool.h"
#import "TCBaseAPIClient.h"
@interface TCDownloadOperation : NSOperation

@property (nonatomic, strong) TCBaseAPIClient *client;

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
                     cancel:(TCDownloadCancelBlock)cancel;

@end
