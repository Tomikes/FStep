//
//  TopicsTableViewCell.h
//  FStep
//
//  Created by mike on 8/9/16.
//  Copyright © 2016 mike. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TopicModel.h"
@interface TopicsTableViewCell : UITableViewCell

- (void)configCellWithTopic:(TopicModel *)topic;

@end
