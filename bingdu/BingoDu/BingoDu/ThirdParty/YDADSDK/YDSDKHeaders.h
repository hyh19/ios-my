//
//  YDSDKHeaders.h
//  testSDK
//
//  Created by lizai on 15/2/3.
//  Copyright (c) 2015年 lizai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class YDNativeAd;
@class YDNativeAdRequest;
@class YDNativeAdRequestTargeting;
@class YDAdConfiguration;
@class CLLocation;
typedef void(^YDNativeAdRequestHandler)(YDNativeAdRequest *request,
                                        YDNativeAd *response,
                                        NSError *error) ;

@protocol YDNativeAdAdapter;
@protocol YDNativeAdDelegate;
@protocol YDNativeAdDelegate <NSObject>
@required
- (UIViewController *)viewControllerForPresentingModalView;
@end
@protocol YDNativeAdRendering <NSObject>
- (void)layoutAdAssets:(YDNativeAd *)adObject;
@optional
+ (CGSize)sizeWithMaximumWidth:(CGFloat)maximumWidth;
+ (UINib *)nibForAd;
@end

@interface YDAdPositioning : NSObject <NSCopying>
@property (nonatomic, assign) NSUInteger repeatingInterval;
@property (nonatomic, strong, readonly) NSMutableOrderedSet *fixedPositions;
@end

@interface YDNativeAdRequest : NSObject
@property (nonatomic, strong) YDNativeAdRequestTargeting *targeting;
+ (YDNativeAdRequest *)requestWithAdUnitIdentifier:(NSString *)identifier;
- (void)startWithCompletionHandler:(YDNativeAdRequestHandler)handler;
@end

@interface YDNativeAd : NSObject
@property (nonatomic, weak) id<YDNativeAdDelegate> delegate;
@property (nonatomic, readonly) NSDictionary *properties;
@property (nonatomic, readonly) NSURL *defaultActionURL;
@property (nonatomic, readonly) NSNumber *starRating;
- (instancetype)initWithAdAdapter:(id<YDNativeAdAdapter>)adAdapter;
- (void)prepareForDisplayInView:(UIView *)view;
- (void)trackImpression;
- (void)trackClick;
- (void)displayContentFromRootViewController:(UIViewController *)controller completion:(void (^)(BOOL success, NSError *error))completionBlock __deprecated;
- (void)displayContentForURL:(NSURL *)URL rootViewController:(UIViewController *)controller
                  completion:(void (^)(BOOL success, NSError *error))completionBlock __deprecated;
- (void)displayContentWithCompletion:(void (^)(BOOL success, NSError *error))completionBlock;
- (void)displayContentForURL:(NSURL *)URL completion:(void (^)(BOOL success, NSError *error))completionBlock;
- (void)trackMetricForURL:(NSURL *)URL;
- (void)loadIconIntoImageView:(UIImageView *)imageView;
- (void)loadImageIntoImageView:(UIImageView *)imageView;
- (void)loadImageIntoImageView:(UIImageView *)imageView forKey:(NSString *)key;
- (void)loadTitleIntoLabel:(UILabel *)label;
- (void)loadTextIntoLabel:(UILabel *)label;
- (void)loadTextIntoLabel:(UILabel *)label forKey:(NSString *) key;
- (void)loadCallToActionTextIntoLabel:(UILabel *)label;
- (void)loadCallToActionTextIntoButton:(UIButton *)button;
- (void)loadImageForURL:(NSURL *)imageURL intoImageView:(UIImageView *)imageView;
@end

@interface YDNativeAdRequestTargeting : NSObject
+ (YDNativeAdRequestTargeting *)targeting;
@property (nonatomic, copy) NSString *keywords;
@property (nonatomic, copy) CLLocation *location;
@property (nonatomic, strong) NSSet *desiredAssets;
@end

@interface YDClientAdPositioning : YDAdPositioning
+ (instancetype)positioning;
- (void)addFixedIndexPath:(NSIndexPath *)indexPath;
- (void)enableRepeatingPositionsWithInterval:(NSUInteger)interval;
@end

@interface YDTableViewAdManager : NSObject
- (id)initWithTableView:(UITableView *)tableView __attribute__((deprecated));
- (UITableViewCell *)adCellForAd:(YDNativeAd *)adObject cellClass:(Class)cellClass __attribute__((deprecated));
@end

@interface YDTableViewAdPlacer : NSObject
+ (instancetype)placerWithTableView:(UITableView *)tableView viewController:(UIViewController *)controller defaultAdRenderingClass:(Class)defaultAdRenderingClass;
+ (instancetype)placerWithTableView:(UITableView *)tableView viewController:(UIViewController *)controller adPositioning:(YDAdPositioning *)positioning defaultAdRenderingClass:(Class)defaultAdRenderingClass;
- (void)loadAdsForAdUnitID:(NSString *)adUnitID;
- (void)loadAdsForAdUnitID:(NSString *)adUnitID targeting:(YDNativeAdRequestTargeting *)targeting;
@end

@interface UITableView (YDTableViewAdPlacer)
- (void)yd_setAdPlacer:(YDTableViewAdPlacer *)placer;
- (YDTableViewAdPlacer *)yd_adPlacer;
- (void)yd_setDataSource:(id<UITableViewDataSource>)dataSource;
- (id<UITableViewDataSource>)yd_dataSource;
- (void)yd_setDelegate:(id<UITableViewDelegate>)delegate;
- (id<UITableViewDelegate>)yd_delegate;
- (void)yd_beginUpdates;
- (void)yd_endUpdates;
- (void)yd_reloadData;
- (void)yd_insertRowsAtIndexPaths:(NSArray *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation;
- (void)yd_deleteRowsAtIndexPaths:(NSArray *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation;
- (void)yd_reloadRowsAtIndexPaths:(NSArray *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation;
- (void)yd_moveRowAtIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)newIndexPath;
- (void)yd_insertSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation;
- (void)yd_deleteSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation;
- (void)yd_reloadSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation;
- (void)yd_moveSection:(NSInteger)section toSection:(NSInteger)newSection;
- (UITableViewCell *)yd_cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (id)yd_dequeueReusableCellWithIdentifier:(NSString *)identifier forIndexPath:(NSIndexPath *)indexPath;
- (void)yd_deselectRowAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated;
- (NSIndexPath *)yd_indexPathForCell:(UITableViewCell *)cell;
- (NSIndexPath *)yd_indexPathForRowAtPoint:(CGPoint)point;
- (NSIndexPath *)yd_indexPathForSelectedRow;
- (NSArray *)yd_indexPathsForRowsInRect:(CGRect)rect;
- (NSArray *)yd_indexPathsForSelectedRows;
- (NSArray *)yd_indexPathsForVisibleRows;
- (CGRect)yd_rectForRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)yd_scrollToRowAtIndexPath:(NSIndexPath *)indexPath atScrollPosition:(UITableViewScrollPosition)scrollPosition animated:(BOOL)animated;
- (void)yd_selectRowAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated scrollPosition:(UITableViewScrollPosition)scrollPosition;
- (NSArray *)yd_visibleCells;
@end

