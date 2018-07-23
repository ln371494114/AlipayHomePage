//
//  HomeUsusalFunctionView.m
//  AlipayHome
//
//  Created by 李楠 on 2018/7/20.
//  Copyright © 2018年 李楠. All rights reserved.
//

#import "HomeUsusalFunctionView.h"
#import "HomeCollectionViewCell.h"

static NSString *const collectionViewIdentify = @"collectionViewCell";

@interface HomeUsusalFunctionView () <UICollectionViewDelegate, UICollectionViewDataSource>
@property (nonatomic, strong) UICollectionView *collectionView;
@end

@implementation HomeUsusalFunctionView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initView];
    }
    return self;
}

- (void)initView {
    [self addSubview:self.collectionView];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 10;
}

- (HomeCollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    HomeCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:collectionViewIdentify forIndexPath:indexPath];
    cell.title.text = @"余额宝";
    cell.imgView.image = [UIImage imageNamed:@"transferMoney"];
    return cell;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        double itemWidth = (ScreenWidth - 180) / 4.0;
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.itemSize = CGSizeMake(itemWidth, itemWidth);
        layout.minimumLineSpacing = 20;
        layout.minimumInteritemSpacing = 20;
        layout.sectionInset = UIEdgeInsetsMake(10, 30, 10, 30);
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, self.height) collectionViewLayout:layout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = [UIColor whiteColor];
        [_collectionView registerClass:[HomeCollectionViewCell class] forCellWithReuseIdentifier:collectionViewIdentify];
    }
    return _collectionView;
}

@end
