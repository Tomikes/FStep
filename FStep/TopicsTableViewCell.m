//
//  TopicsTableViewCell.m
//  FStep
//
//  Created by mike on 8/9/16.
//  Copyright © 2016 mike. All rights reserved.
//

#import "TopicsTableViewCell.h"
#import <Masonry.h>

@interface TopicsTableViewCell()

@property (nonatomic, strong) UIImageView *avatarImage;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UILabel *readLabel;

@end

@implementation TopicsTableViewCell


- (void)configCellWithTopic:(TopicModel *)topic{
    
}


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {

        [self.contentView addSubview:self.avatarImage];
        [self.contentView addSubview:self.nameLabel];
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.timeLabel];
        [self.contentView addSubview:self.readLabel];

        [self setUILayout];
        
        self.backgroundColor = [UIColor whiteColor];
    }
    
    return  self;
}

- (void)setUILayout{
    __weak typeof(self) weakSelf = self;
    
    [self.avatarImage  mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.contentView.mas_left).with.offset(10);
        make.top.mas_equalTo(weakSelf.contentView.mas_top).with.offset(10);
        make.size.mas_equalTo(CGSizeMake(40*xA, 40*xA));
        
    }];
    
    [self.readLabel  mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.mas_equalTo(weakSelf.contentView.mas_top).with.offset(10);
        make.right.mas_equalTo(weakSelf.contentView.mas_right).with.offset(-10);
        make.size.mas_equalTo(CGSizeMake(30*xA, 30*xA));
        
    }];

    [self.nameLabel  mas_makeConstraints:^(MASConstraintMaker *make){
        make.left.mas_equalTo(weakSelf.avatarImage.mas_right).with.offset(10);
        make.top.mas_equalTo(weakSelf.contentView.mas_top).with.offset(10);
        make.right.mas_equalTo(weakSelf.readLabel.mas_left).with.offset(-10);
        make.height.mas_equalTo(30*xA);
        
    
    }];
    
    [self.titleLabel  mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.avatarImage.mas_right).with.offset(10);
        make.top.mas_equalTo(weakSelf.nameLabel.mas_bottom).with.offset(10);
        make.right.mas_equalTo(weakSelf.readLabel.mas_left).with.offset(10);

        
    }];
    
  
    
    [self.timeLabel  mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.avatarImage.mas_right).with.offset(10);
         make.top.mas_equalTo(weakSelf.titleLabel.mas_bottom).with.offset(10);
        make.right.mas_equalTo(weakSelf.readLabel.mas_left).with.offset(10);
        make.bottom.mas_equalTo(weakSelf.contentView.mas_bottom).with.offset(-10)
        ;    }];
    

    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    UIView *backView = [[UIView alloc] initWithFrame:self.frame];
    self.selectedBackgroundView = backView;
    self.selectedBackgroundView.backgroundColor = [UIColor clearColor];
    //取消边框线
    [self setBackgroundView:[[UIView alloc] init]];          //取消边框线
    self.backgroundColor = [UIColor clearColor];
 
}

@end
