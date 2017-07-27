//
//  ViewController.m
//  SliderBar
//
//  Created by jv on 2017/7/27.
//  Copyright © 2017年 jv. All rights reserved.
//

#import "ViewController.h"
#import "SliderBar.h"

@interface ViewController ()
{
    SliderBar *_bar;
    UIScrollView *_scrollView;
    NSArray *_data;
    
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    _scrollView = [UIScrollView new];
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.pagingEnabled = YES;
    [self.view addSubview:_scrollView];
    
    
    _data = @[@"个性推荐",@"歌单",@"主播电台",@"排行榜",@"赞"];
    
    UIView *lastView;
    for (NSInteger i=0; i<_data.count; i++) {
        
        UIView *v = [UIView new];
        UILabel *label = [UILabel new];
        label.font = [UIFont systemFontOfSize:20];
        label.textColor = [UIColor whiteColor];
        label.backgroundColor = [UIColor clearColor];
        label.text = [NSString stringWithFormat:@"%lu",i+1];
        [v addSubview:label];
        
        [label mas_makeConstraints:^(MASConstraintMaker *make){
            make.center.equalTo(@0);
        }];

        
        v.backgroundColor = [UIColor colorWithRed:arc4random_uniform(256) / 255. green:arc4random_uniform(256) / 255. blue:arc4random_uniform(256) / 255. alpha:1];
        [_scrollView addSubview:v];
        if (lastView) {
            
            [v mas_makeConstraints:^(MASConstraintMaker *make){
                make.left.equalTo(lastView.mas_right);
                make.size.centerY.equalTo(lastView);
            }];

            
        }else{
            
            [v mas_makeConstraints:^(MASConstraintMaker *make){
                make.left.equalTo(@0);
                make.centerY.equalTo(@0);
                make.size.equalTo(_scrollView);
            }];
            
        }
        
        
        lastView = v;
    }
    
    
    _bar = [[SliderBar alloc] initWithTitles:_data scrollView:_scrollView];
    [self.view addSubview:_bar];
    [self.view bringSubviewToFront:_bar];
    
    [_bar mas_makeConstraints:^(MASConstraintMaker *make){
        make.top.left.right.equalTo(@0);
        make.height.equalTo(@40);
    }];

    [_scrollView mas_makeConstraints:^(MASConstraintMaker *make){
        make.top.equalTo(_bar.mas_bottom);
        make.left.bottom.right.equalTo(@0);
    }];

    
    
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    
    _scrollView.contentSize = CGSizeMake(_data.count * _scrollView.width, _scrollView.height);
    
}



@end
