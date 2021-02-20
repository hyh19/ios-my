//
//  FBGuideView.m
//  LiveShow
//
//  Created by chenfanshun on 09/11/16.
//  Copyright © 2016年 FB. All rights reserved.
//

#import "FBLaunchGuideView.h"
#import "FBLaunchGuideCollectionViewCell.h"

#define kFBGuideViewBounds  [UIScreen mainScreen].bounds

static NSString *kCellIdentifier = @"FBGuideViewCell";

@interface FBLaunchGuideView()<UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSArray *images;
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, copy  ) NSString *buttonTitle;

@end

@implementation FBLaunchGuideView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(void)showGuideViewWithImages:(NSArray*)images
                andButtonTitle:(NSString*)title
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *key = [self getKey];
    BOOL hasShow = [userDefaults boolForKey:key];
    if(!hasShow) {
        self.images = images;
        self.buttonTitle = title;
        self.pageControl.numberOfPages = [images count];
        
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        
        [window addSubview:self.collectionView];
        [window addSubview:self.pageControl];
    }
}

#pragma mark - Setter & Getter -
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        
        UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
        
        layout.minimumInteritemSpacing = 0;
        layout.minimumLineSpacing = 0;
        layout.itemSize = kFBGuideViewBounds.size;
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
        _collectionView = [[UICollectionView alloc] initWithFrame:kFBGuideViewBounds collectionViewLayout:layout];
        _collectionView.bounces = NO;
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.pagingEnabled = YES;
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        
        [_collectionView registerClass:[FBLaunchGuideCollectionViewCell class] forCellWithReuseIdentifier:kCellIdentifier];
    }
    return _collectionView;
}

- (UIPageControl *)pageControl {
    if (_pageControl == nil) {
        _pageControl = [[UIPageControl alloc] init];
        _pageControl.frame = CGRectMake(0, 0, kFBGuideViewBounds.size.width, 44.0f);
        _pageControl.center = CGPointMake(kFBGuideViewBounds.size.width / 2, kFBGuideViewBounds.size.height - 60);
    }
    return _pageControl;
}


#pragma mark - collectionview datasource & delegate -
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.images count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    FBLaunchGuideCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCellIdentifier forIndexPath:indexPath];
    
    UIImage *img = [self.images objectAtIndex:indexPath.row];
    CGSize size = [self adapterSizeImageSize:img.size compareSize:kFBGuideViewBounds.size];
    
    //自适应图片位置,图片可以是任意尺寸,会自动缩放.
    cell.imageView.frame = CGRectMake(0, 0, size.width, size.height);
    cell.imageView.image = img;
    cell.imageView.center = CGPointMake(kFBGuideViewBounds.size.width / 2, kFBGuideViewBounds.size.height / 2);
    
    if (indexPath.row == self.images.count - 1) {
        [cell.button setHidden:NO];
        [cell.button addTarget:self action:@selector(onButtonOK:) forControlEvents:UIControlEventTouchUpInside];
        [cell.button setTitle:self.buttonTitle forState:UIControlStateNormal];
    } else {
        [cell.button setHidden:YES];
    }
    
    return cell;
}

/**
 *  计算自适应的图片
 *
 *  @param is 需要适应的尺寸
 *  @param cs 适应到的尺寸
 *
 *  @return 适应后的尺寸
 */
- (CGSize)adapterSizeImageSize:(CGSize)is compareSize:(CGSize)cs
{
    CGFloat w = cs.width;
    CGFloat h = cs.width / is.width * is.height;
    
    if (h < cs.height) {
        w = cs.height / h * w;
        h = cs.height;
    }
    return CGSizeMake(w, h);
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    self.pageControl.currentPage = (scrollView.contentOffset.x / kFBGuideViewBounds.size.width);
}

- (void)onButtonOK:(id)sender {
    
    [self.pageControl removeFromSuperview];
    [self.collectionView removeFromSuperview];
    [self setCollectionView:nil];
    [self setPageControl:nil];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *key = [self getKey];
    [userDefaults setBool:YES forKey:key];
    [userDefaults synchronize];
}


-(NSString*)getKey
{
    NSString *version = [[NSBundle mainBundle].infoDictionary objectForKey:@"CFBundleShortVersionString"];
    NSString *key = [NSString stringWithFormat:@"LaunchGuide_version_%@", version];
    return key;
}

@end
