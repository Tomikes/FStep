//
//  TCSerialRequestOperation.h
//  TCNetworking
//
//  Created by 陈 胜 on 16/5/25.
//  Copyright © 2016年 陈胜. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TCBaseAPIClient.h"

typedef void (^TCRequestSuccessBlock)(id resposeObject);
typedef void (^TCRequestFailureBlock)(NSError *error);
typedef void (^TCRequestCancelBlock)();

@interface TCSerialRequestOperation : NSOperation

@property (nonatomic, strong) TCBaseAPIClient *client;

/**
 *  创建一个请求Operation
 *
 *  @param URLString  文件路径
 *  @param parameters 请求参数
 *  @param success    成功回调
 *  @param failure    失败回调
 *  @param cancel     取消回调
 *
 *  @return TCSerialRequestOperation
 */
+ (instancetype)GET:(NSString *)URLString
         parameters:(NSDictionary *)parameters
            success:(TCRequestSuccessBlock)success
            failure:(TCRequestFailureBlock)failure
             cancel:(TCRequestCancelBlock)cancel;

/**
 *  创建一个请求Operation
 *
 *  @param URLString  文件路径
 *  @param parameters 请求参数
 *  @param success    成功回调
 *  @param failure    失败回调
 *  @param cancel     取消回调
 *
 *  @return TCSerialRequestOperation
 */
+ (instancetype)POST:(NSString *)URLString
          parameters:(NSDictionary *)parameters
             success:(TCRequestSuccessBlock)success
             failure:(TCRequestFailureBlock)failure
              cancel:(TCRequestCancelBlock)cancel;

@end
