//
//  TopicModel.h
//  FStep
//
//  Created by mike on 8/9/16.
//  Copyright © 2016 mike. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TopicModel : NSObject

@property (nonatomic, copy) NSString *memberName;
@property (nonatomic, copy) NSString *memberImageUrl;
@property (nonatomic, copy) NSString *replayURL;//  /t/12345
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *time;

@property (nonatomic, assign) BOOL readDeteail;

@end
