//
//  HomePageViewController.m
//  AlipayHome
//
//  Created by 李楠 on 2018/7/20.
//  Copyright © 2018年 李楠. All rights reserved.
//

#import "HomePageViewController.h"
#import "HomeFunctionView.h"
#import "HomeUsusalFunctionView.h"
#import "HomeCollectionViewCell.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <ReactiveCocoa/RACEXTScope.h>
#import <ReactiveCocoa/RACReturnSignal.h>
#import "NSObject+kvo.h"

static NSString *const collectionViewIdentify = @"collectionViewCell";
static NSString *const collectionViewHeaderIdentify = @"collectionViewCellHeader";


@interface HomePageViewController () <UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UITextField *searchTextField;
@property (nonatomic, strong) NSArray *itemsArr;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) HomeFunctionView *headerView;
@property (nonatomic, assign) double collectionViewHeight;
@end

@implementation HomePageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupNavigationItem];
    [self initView];
    [self.tableView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)initView {
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.backgroundColor = [UIColor orangeColor];
    [self.view addSubview:self.scrollView];
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    //tableView
    [self.scrollView addSubview:self.tableView];
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.scrollView);
    }];
    
    //collectionView
    [self.scrollView addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(self.scrollView);
        make.height.mas_equalTo(self.collectionViewHeight);
        make.top.mas_equalTo(0);
    }];
    
    //禁止中间的collectionView滚动
    self.collectionView.scrollEnabled = NO;
    
    //移除scrollView所有的手势
//    for (UIGestureRecognizer *gesture in self.scrollView.gestureRecognizers) {
//        [self.scrollView removeGestureRecognizer:gesture];
//    }
    
//    // 将tableView的手势添加到父scrollView上
//    for (UIGestureRecognizer *gesture in self.tableView.gestureRecognizers) {
//        [self.scrollView addGestureRecognizer:gesture];
//    }
}

- (void)setupNavigationItem {
    UIImage *adressBook = [[UIImage imageNamed:@"adressBook"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIImage *addMore = [[UIImage imageNamed:@"addMore"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    UIBarButtonItem *itemAdressBook = [[UIBarButtonItem alloc] initWithImage:adressBook style:UIBarButtonItemStylePlain target:self action:@selector(adressBookAction)];
    UIBarButtonItem *itemMore = [[UIBarButtonItem alloc] initWithImage:addMore style:UIBarButtonItemStylePlain target:self action:@selector(moreAction)];
    self.navigationItem.rightBarButtonItems = @[itemMore, itemAdressBook];
    self.navigationItem.titleView = self.searchTextField;
    [self updateNavigationItem:NO];
}


- (UIColor *)getNewColorWith:(UIColor *)color alpha:(CGFloat)alpha{
    CGFloat red = 0.0;
    CGFloat green = 0.0;
    CGFloat blue = 0.0;
    CGFloat alp = 0.0;
    [color getRed:&red green:&green blue:&blue alpha:&alp];
    UIColor *newColor = [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
    return newColor;
}



- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"contentOffset"]) {
        double originY = self.tableView.contentOffset.y + self.collectionViewHeight;
        NSLog(@"%f", originY);
        if (originY > 0) {
            self.collectionView.y = -originY;
            //导航栏渐变
            double height = _headerView.height / 2.0;
            self.headerView.contentView.alpha = 1 - originY / self.headerView.height;
            if (originY < height) {
                CGFloat alpha = originY / height;
                self.searchTextField.alpha = 1 - alpha;
                [self updateNavigationItem:NO];
                for (UIBarButtonItem *item in self.itemsArr) {
                    UIButton *btn = item.customView;
                    btn.alpha = 1 - alpha;
                }
            } else {
                [self updateNavigationItem:YES];

                CGFloat alpha = (originY - height) / height;
                for (UIBarButtonItem *item in self.navigationItem.leftBarButtonItems) {
                    UIButton *btn = item.customView;
                    btn.alpha = alpha;
                }
            }
            
        } else {
            self.collectionView.y = 0;
            self.headerView.contentView.alpha = 1;
            self.searchTextField.alpha = 1;
        }
    }
}

- (void)updateNavigationItem:(BOOL)flag {
    if (flag) {
        self.navigationItem.leftBarButtonItems = self.itemsArr;
        self.navigationItem.titleView = nil;
    } else {
        self.navigationItem.leftBarButtonItems = @[];
        self.navigationItem.titleView = self.searchTextField;
    }
}

- (void)adressBookAction {
    
}

- (void)moreAction {
    
}

- (void)disableAdjustsScrollViewInsets:(UIScrollView *)scrollView {
    if (@available(iOS 11.0, *)) {
        scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - tableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"tableCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"tableCell"];
        cell.textLabel.font = [UIFont systemFontOfSize:14];
    }
    cell.textLabel.text = @"嘿嘿嘿";
    return cell;
}

#pragma mark - collectionView
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

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:collectionViewHeaderIdentify forIndexPath:indexPath];
    [header addSubview:self.headerView];
    return header;
}


#pragma mark - 懒加载
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - self.navigationController.navigationBar.frame.origin.y) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.contentInset = UIEdgeInsetsMake(self.collectionViewHeight, 0, 0, 0);
        _tableView.scrollIndicatorInsets = UIEdgeInsetsMake(self.collectionViewHeight + 80, 0, 0, 0);
        @weakify(self);
        _tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                @strongify(self);
                [self.tableView.mj_header endRefreshing];
            });
        }];
    }
    return _tableView;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        double width = (ScreenWidth - 180) / 4.0;
        layout.itemSize = CGSizeMake(width, width);
        layout.minimumLineSpacing = 20;
        layout.minimumInteritemSpacing = 20;
        layout.sectionInset = UIEdgeInsetsMake(10, 30, 10, 30);
        layout.headerReferenceSize =CGSizeMake(ScreenWidth, 80);
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, self.collectionViewHeight) collectionViewLayout:layout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = [UIColor whiteColor];
        [_collectionView registerClass:[HomeCollectionViewCell class] forCellWithReuseIdentifier:collectionViewIdentify];
        [_collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:collectionViewHeaderIdentify];
    }
    return _collectionView;
}

- (HomeFunctionView *)headerView {
    if (!_headerView) {
        _headerView = [[HomeFunctionView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 84)];
    }
    return _headerView;
}

- (double)collectionViewHeight {
    double width = (ScreenWidth - 180) / 4.0;
    double height = (width + 20) * 3 + 84 + 0.5;
    return height;
}

- (NSArray *)itemsArr {
    NSMutableArray *arr = [NSMutableArray array];
    UIImage *littleCollectMoney = [[UIImage imageNamed:@"littleCollectMoney"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIImage *littleScan = [[UIImage imageNamed:@"littleScan"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIImage *littleSearch = [[UIImage imageNamed:@"littleSearch"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    NSArray *imgName = @[littleCollectMoney, littleScan, littleSearch];

    if (!_itemsArr) {
        for (int i = 0;i < imgName.count; i ++) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button setImage:imgName[i] forState:UIControlStateNormal];
            button.frame = CGRectMake(0, 0, 44, 44);
            UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:button];
            [arr addObject:item];
        }
        _itemsArr = [NSArray arrayWithArray:arr];
    }
    return _itemsArr;
}

- (UITextField *)searchTextField {
    if (!_searchTextField) {
        _searchTextField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 28)];
        _searchTextField.backgroundColor = [self getNewColorWith:[UIColor blackColor] alpha:0.2];
        _searchTextField.font = [UIFont systemFontOfSize:14];
        _searchTextField.textColor = [UIColor whiteColor];
        _searchTextField.text = @"附近美食";
        _searchTextField.borderStyle = UITextBorderStyleRoundedRect;
        _searchTextField.enabled = NO;
    }
    return _searchTextField;
}

@end
