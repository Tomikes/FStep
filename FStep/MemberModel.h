//
//  MemberModel.h
//  FStep
//
//  Created by mike on 8/9/16.
//  Copyright © 2016 mike. All rights reserved.
//
//http://www.v2ex.com/member/wangxinyue
#import <Foundation/Foundation.h>

@interface MemberModel : NSObject

@property (nonatomic, copy) NSString *memberxxID;
@property (nonatomic, copy) NSString *memberxURL;
@property (nonatomic, copy) NSString *memberName;
@property (nonatomic, copy) NSString *memberxweb;
@property (nonatomic, copy) NSString *githubxURL;
//img url
@property (nonatomic, copy) NSString *memberxxAvatarMini;
@property (nonatomic, copy) NSString *memberAvatarNormal;
@property (nonatomic, copy) NSString *memberxAvatarLarge;

@property (nonatomic, copy) NSString *memberTagline;


@end
