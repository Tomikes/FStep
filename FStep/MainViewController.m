//
//  MainViewController.m
//  FStep
//
//  Created by mike on 8/2/16.
//  Copyright © 2016 mike. All rights reserved.
//

#import "MainViewController.h"
#import "CNPGridMenu.h"
#import <POP.h>
#import <Masonry.h>
#import <YYCategories/UIImage+YYAdd.h>
#import "UIView+Extension.h"
#import "UserViewController.h"

#import "TCSerialRequestManager.h"
#import "TCBaseAPIClient.h"

@interface MainViewController ()<POPAnimationDelegate>
@property (nonatomic, strong) UIButton    *gridButton;
@property (nonatomic, strong) UIButton    *userButton;
@property (nonatomic, strong) CNPGridMenu *cnGridView;

@property (nonatomic, strong) TCSerialRequestManager *SerialRequestManager;

@end

@implementation MainViewController

#pragma mark - View Cycle

- (void)loadView{
    [super loadView];

    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.gridButton];
    [self.view addSubview:self.userButton];
    [self.view bringSubviewToFront:self.gridButton];
    [self layoutTwoButton];
//    [self setNaviAlpha];
    __block  NSString *title;
    TCBaseAPIClient *ct = [[TCBaseAPIClient alloc] initWithBaseURL:[NSURL URLWithString:@"https://www.v2ex.com"]];
    self.SerialRequestManager =  [TCSerialRequestManager instanceWithClient:ct];
    
    [self.SerialRequestManager GET:@"/api/topics/hot.json" parameters:nil success:^(id responseObject) {
        NSData *data = [NSJSONSerialization dataWithJSONObject:responseObject options:NSJSONWritingPrettyPrinted error:nil];
        NSError *err;
        NSArray *arr = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&err];
        
        if ([arr[1] isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dic = arr[1];
            
            title = dic[@"content"];
            self.title = title;
   
         
            
        }

    } failure:^(NSError *error) {
        NSLog(@"请求QQ失败");
    }];

    
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (self.cnGridView) {
        [self.cnGridView dismissGridMenuAnimated:YES completion:nil];
        self.cnGridView = nil;
    }
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self popTwoButton];

}
#pragma mark - Private Methods
/**
 *  Description
 *  1.设置nav透明
 */
- (void)setNaviAlpha{
     [[[self.navigationController.navigationBar subviews] objectAtIndex:0] setAlpha:0];
}
/**
 *  Description
 *  按钮动画
 */
- (void)popTwoButton{
    


    dispatch_after(dispatch_time(DISPATCH_TIME_NOW,(int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        CGPoint velocity = CGPointMake(1, 1);
        POPSpringAnimation *positionAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerPosition];
        positionAnimation.velocity = [NSValue valueWithCGPoint:velocity];
        positionAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(self.view.centerX-60, self.view.centerY)];
        [self.gridButton.layer pop_addAnimation:positionAnimation forKey:@"1layerPositionAnimation"];
        
        
        CGPoint velocity1 = CGPointMake(1, 1);
        POPSpringAnimation *positionAnimation2 = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerPosition];
        positionAnimation2.velocity = [NSValue valueWithCGPoint:velocity1];
        positionAnimation2.toValue = [NSValue valueWithCGPoint:CGPointMake(self.view.centerX+10, self.view.centerY)];
        [self.userButton.layer pop_addAnimation:positionAnimation2 forKey:@"2layerPositionAnimation"];
        positionAnimation2.delegate = self;
        
    });
    

}
/**
 *  Description
 *  显示网格视图
 */
- (void)showGridView{

}
/**
 *  Description
 *  显示用户视图
 */
- (void)showUserView{
    UserViewController *user= [[UserViewController alloc] init];
    [self.navigationController pushViewController:user animated:YES];
}
#pragma mark - Event Action
/**
 *  Description
 *  点击网格按钮
 */
- (void)touchGridButton:(id)sender{
    NSLog(@"222333");
    [self showGridView];
    
}
/**
 *  Description
 *  点击用户按钮
 */
- (void)touchUserButton:(id)sender{
    [self showUserView];
    
}
/**
 *  Description
 *  layout
 */
- (void)layoutTwoButton{
    __weak typeof(self) weakSelf = self;
    
    [self.gridButton  mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.view.mas_centerX).with.offset(-60);
        make.bottom.mas_equalTo(weakSelf.view.mas_top);
        make.size.mas_equalTo(CGSizeMake(50, 50));
    }];
    [self.userButton  mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.view.mas_centerX).with.offset(10);
        make.bottom.mas_equalTo(weakSelf.view.mas_top);
        make.size.mas_equalTo(CGSizeMake(50, 50));
    }];
}

- (void) addBubbleAnimation:(UIButton *)bt {
    
    // create an animation to follow a circular path
    CAKeyframeAnimation *pathAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    
    pathAnimation.calculationMode = kCAAnimationPaced;
    // apply transformation at the end of animation
    pathAnimation.fillMode = kCAFillModeForwards;
    pathAnimation.removedOnCompletion = NO;
    
    // run forever
    pathAnimation.repeatCount = INFINITY;
    
    // no ease in/out to have the same speed along the path
    pathAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    pathAnimation.duration = 5.0f;
    
    //The circle to follow will be inside the circleContainer frame.
    //it should be a frame around the center of your view to animate.
    //do not make it to large, a width/height of 3-4 will be enough.
    CGMutablePathRef curvedPath = CGPathCreateMutable();
    CGRect circleContainer = CGRectInset(bt.frame, bt.frame.size.width/3, bt.frame.size.height/3);
    CGPathAddEllipseInRect(curvedPath, NULL, circleContainer);
    
    // add the path to the animation
    pathAnimation.path = curvedPath;
    // release path
    CGPathRelease(curvedPath);
    // add animation to the view's layer
    [bt.layer addAnimation:pathAnimation forKey:@"myCircleAnimation"];
    
    CAKeyframeAnimation *scaleX = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale.x"];
    // set the duration
    scaleX.duration = 1;
    //it starts from scale factor 1, scales to 1.05 and back to 1
    scaleX.values = @[@1.0f, @1.05f, @1.0];
    //time percentage when the values above will be reached.
    //i.e. 1.05 will be reached just as half the duration has passed.
    scaleX.keyTimes = @[@0.0f, @0.5f, @1.0f];
    //keep repeating
    scaleX.repeatCount = INFINITY;
    //play animation backwards on repeat (not really needed since it scales back to 1)
    scaleX.autoreverses = YES;
    // ease in/out animation for more natural look
    scaleX.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    // add the animation to the view's layer
    [bt.layer addAnimation:scaleX forKey:@"scaleXAnimation"];
}
#pragma mark - Getters And Setters

- (UIButton *)gridButton{
    if (!_gridButton) {
        _gridButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_gridButton setImage:[[[UIImage imageNamed:@"ImgSource.bundle/GridImg.png"] imageByResizeToSize:CGSizeMake(50, 50)] imageByRoundCornerRadius:6 borderWidth:1 borderColor:[UIColor greenColor]]  forState:UIControlStateNormal];
        [_gridButton addTarget:self action:@selector(touchGridButton:) forControlEvents:UIControlEventTouchUpInside];
  
        
        
    }
    return _gridButton;
}

- (UIButton *)userButton{
    if (!_userButton) {
        _userButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_userButton setImage:[[[UIImage imageNamed:@"ImgSource.bundle/img.png"] imageByResizeToSize:CGSizeMake(50, 50)] imageByRoundCornerRadius:6 borderWidth:1 borderColor:[UIColor greenColor]]  forState:UIControlStateNormal];
        [_userButton addTarget:self action:@selector(touchGridButton:) forControlEvents:UIControlEventTouchUpInside];
        

        
        
    }
    return _userButton;

}

#pragma mark - GridDelegate

#pragma mark - popdelegate
- (void)pop_animationDidStop:(POPAnimation *)anim finished:(BOOL)finished{

    if (finished) {
        [self addBubbleAnimation:self.gridButton];
        [self addBubbleAnimation:self.userButton];
    }
}

@end
