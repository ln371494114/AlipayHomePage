//
//  HomeFunctionView.m
//  AlipayHome
//
//  Created by 李楠 on 2018/7/20.
//  Copyright © 2018年 李楠. All rights reserved.
//

#import "HomeFunctionView.h"

@implementation HomeFunctionView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initView];
    }
    return self;
}

- (void)initView {
    self.backgroundColor = kColor;
    self.contentView = [[UIView alloc]  initWithFrame:self.bounds];
    self.contentView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.contentView];
    NSArray *imgName = @[@"scanIcon", @"payIcon", @"mmmmmmmm", @"cardsIcon"];
    NSArray *titleName = @[@"扫一扫", @"付钱", @"收钱", @"卡包"];
    double itemWidth = ScreenWidth / 4.0;
    for (int i = 0; i < imgName.count; i++) {
        UIImageView *imgView = [[UIImageView alloc] init];
        imgView.frame = CGRectMake(36 + i * itemWidth, 12, 28, 28);
        imgView.image = [UIImage imageNamed:imgName[i]];
        [self.contentView addSubview:imgView];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(itemWidth * i, imgView.bottom + 4, itemWidth, 28)];
        label.font = [UIFont systemFontOfSize:14];
        label.text = titleName[i];
        label.textAlignment = NSTextAlignmentCenter;;
        label.textColor = [UIColor whiteColor];
        [self.contentView addSubview:label];
    }
}



@end
