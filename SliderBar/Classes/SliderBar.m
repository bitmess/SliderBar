//
//  SliderBar.m
//  SliderBar
//
//  Created by jv on 2017/7/27.
//  Copyright © 2017年 jv. All rights reserved.
//

#import "SliderBar.h"
#import <KVOController/KVOController.h>

static CGFloat const kSliderPlusWidth = 2;
static NSUInteger const kStartTag = 10086;

@interface SliderBar ()
{
    
    NSMutableArray *_buttons;
    NSMutableArray *_widthes;
    
    __weak UIScrollView *_scrollView;
    
    NSArray *_titles;
    NSUInteger _count;
    UIView *_bar;
    
    CGFloat _divideWidth;
    
    BOOL _actionClicked;
}


@end


@implementation SliderBar

- (void)dealloc {
    
#if DEBUG
    NSLog(@"%s",__FUNCTION__);
#endif
    
}

- (instancetype)initWithTitles:(NSArray *)titles scrollView:(UIScrollView *)scrollView {
    
    NSParameterAssert(titles.count);
    NSParameterAssert(scrollView);
    
    self = [super init];
    if (self) {
        
        _scrollView = scrollView;
        
        _titles = titles;
        
        _count = _titles.count;
    
        [self setup];
        
    }
    return self;
    
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setup];
}

- (void)setup {
    
    _buttons = [NSMutableArray array];
    _widthes = [NSMutableArray array];
    
    _divideWidth = NSNotFound;
    NSInteger count = _count;
    
    UIButton *lastButton;
    for (NSInteger i=0; i<count; i++) {
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn addTarget:self action:@selector(_clickAction:) forControlEvents:UIControlEventTouchUpInside];
        btn.tag = i + kStartTag;
        btn.titleLabel.font = [UIFont systemFontOfSize:14];
        [btn setTitle:_titles[i] forState:UIControlStateNormal];
        [btn setTitle:_titles[i] forState:UIControlStateHighlighted];
        
        UIColor *textColor = [UIColor colorWithRed:0.600000F green:0.035294F blue:0.380392F alpha:1.0F];
        [btn setTitleColor:textColor forState:UIControlStateNormal];
        [btn setTitleColor:textColor forState:UIControlStateHighlighted];
        [self addSubview:btn];
        
        
        [btn mas_makeConstraints:^(MASConstraintMaker *make){
            
            if (lastButton) {
                make.left.equalTo(lastButton.mas_right);
                make.centerY.equalTo(lastButton);
                make.size.equalTo(lastButton);
            }else{
                make.centerY.left.equalTo(@0);
                make.height.equalTo(self);
            }
            
            if (i+1 == count) {
                
                make.right.equalTo(@0);
                
            }
            
        }];
        
        [_buttons addObject:btn];
        
        lastButton = btn;
        
    }
    
    _bar = [UIView new];
    _bar.backgroundColor = [UIColor redColor];
    _bar.height = 3;
    _bar.left = 0;
    [self addSubview:_bar];
    
    [self.KVOController observe:_scrollView keyPath:@"contentOffset" options:NSKeyValueObservingOptionNew action:@selector(_kvoWatch:)];
    
}


#pragma mark - override

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (_divideWidth == NSNotFound && _count > 0) {
        _divideWidth = self.width / _count;
        _bar.top = self.height - _bar.height;
        for (UIButton *btn in _buttons) {
            
            UILabel *label = btn.titleLabel;
            NSDictionary *attribute = @{NSFontAttributeName: label.font};
            
            NSStringDrawingOptions options = NSStringDrawingTruncatesLastVisibleLine |
            NSStringDrawingUsesLineFragmentOrigin |
            NSStringDrawingUsesFontLeading;
            
            float fontWidth = [label.text boundingRectWithSize:label.size options:options attributes:attribute context:nil].size.width;
            
            [_widthes addObject:@(fontWidth)];
        }
        
        _scrollView.contentOffset = CGPointZero;
    }

}

#pragma mark - kvo

- (void)_kvoWatch:(NSDictionary *)info {
    
    if (_actionClicked) {
        _actionClicked = NO;
        return;
    }
    
    if (_widthes.count == 0) {
        return;
    }
    
    float x = [info[NSKeyValueChangeNewKey] CGPointValue].x;
    
    [self _offsetBarByX:x];
}

#pragma mark - method

- (void)_offsetBarByX:(float)x {
    NSInteger smallPage = x / _scrollView.width;
    
    NSInteger bigPage = smallPage + 1;
    
    smallPage = smallPage < 0 ? 0 : smallPage;
    bigPage = bigPage < 0 ? 0 : bigPage;
    
    smallPage = smallPage >= _count ? _count - 1 : smallPage;
    bigPage = bigPage >= _count ? _count - 1 : bigPage;
    
    float smallWidth = [_widthes[smallPage] floatValue];
    float bigWidth = [_widthes[bigPage] floatValue];
    
    float smallLeft = smallPage * _divideWidth + (_divideWidth - kSliderPlusWidth * 2 - smallWidth) / 2;
    float bigLeft =  bigPage * _divideWidth + (_divideWidth - kSliderPlusWidth * 2 - bigWidth) / 2;
    
    
    float ratio = (x - smallPage * _scrollView.width) / _scrollView.width;
    
    ratio = ratio < 0 ? 0 : ratio;
    ratio = ratio > 1 ? 1 : ratio;
    
    _bar.left = smallLeft + (bigLeft - smallLeft) * ratio + 2;//add 2 margin to fit
    _bar.width = smallWidth + (bigWidth - smallWidth) * ratio;
}

#pragma mark - action

- (void)_clickAction:(UIButton *)button {
    
    NSUInteger page = button.tag - kStartTag;
    
    float x = page * _scrollView.width;
    
    _actionClicked = YES;
    [_scrollView setContentOffset:(CGPoint){x,0}];
    
    [UIView animateWithDuration:.25 animations:^{
       
        [self _offsetBarByX:x];
        
    }];
    
}


@end
