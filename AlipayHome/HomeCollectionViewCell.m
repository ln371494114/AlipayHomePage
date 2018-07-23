//
//  HomeCollectionViewCell.m
//  AlipayHome
//
//  Created by 李楠 on 2018/7/20.
//  Copyright © 2018年 李楠. All rights reserved.
//

#import "HomeCollectionViewCell.h"

@implementation HomeCollectionViewCell



- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initView];
    }
    return self;
}

- (void)initView {
    self.imgView = [[UIImageView alloc] init];
    [self.contentView addSubview:self.imgView];
    
    self.title = [[UILabel alloc] init];
    self.title.font = [UIFont systemFontOfSize:13];
    self.title.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:self.title];

}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.imgView.frame = CGRectMake(0, 0, 20, 20);
    self.imgView.center = self.contentView.center;
    
    self.title.frame = CGRectMake(self.contentView.left, self.imgView.bottom, self.contentView.width, 28);
}

@end
