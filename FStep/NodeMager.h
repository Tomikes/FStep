//
//  NodeMager.h
//  FStep
//
//  Created by mike on 8/9/16.
//  Copyright © 2016 mike. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NodeMager;

@protocol NodeDelegate <NSObject>

- (void)nodeFor;

@end

@interface NodeMager : NSObject

@end
