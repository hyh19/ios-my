#import "ZWAdvertiseSkipManager.h"
#import "ZWGoodsDetailViewController.h"
#import "ZWPrizeDetailViewController.h"
#import "ZWADWebViewController.h"
#import "ZWActivityViewController.h"
#import "ZWStoreViewController.h"
#import "ZWPrizeListViewController.h"

@implementation ZWAdvertiseSkipManager

+ (void)pushViewController:(UIViewController *)controller
    withAdvertiseDataModel:(ZWArticleAdvertiseModel *)model
{
    switch (model.redirectType) {
        case AdvertiseType://广告详情
        {
            if(model.adversizeDetailUrl && model.adversizeDetailUrl.length > 0)
            {
                ZWADWebViewController *adWebView = [[ZWADWebViewController alloc] initWithModel:model];
                [controller.navigationController pushViewController:adWebView animated:YES];
            }
        }
            break;
        case GoodsDetailType://商品详情
        {
            ZWGoodsDetailViewController *goodsDetailView = [[ZWGoodsDetailViewController alloc] init];
            [goodsDetailView setGoodsID:@([model.redirectTargetId integerValue])];
            [controller.navigationController pushViewController:goodsDetailView animated:YES];
        }
            break;
        case LotteryDetailType://抽奖详情
        {
            
            ZWPrizeDetailViewController *priceDetailView = [[UIStoryboard storyboardWithName:@"LuckDraw" bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([ZWPrizeDetailViewController class])];

            [priceDetailView setPrizeID:model.redirectTargetId];
            [controller.navigationController pushViewController:priceDetailView animated:YES];
        }
            break;
        case ActivityDetailType://活动详情
        {
            ZWActivityViewController *activityView = [[ZWActivityViewController alloc] initWithURLString:model.adversizeDetailUrl];
            activityView.title = model.adversizeTitle;
            [controller.navigationController pushViewController:activityView animated:YES];
        }
            
            break;
        case GoodsListType://商城首页
        {
            ZWStoreViewController *nextViewController = [[ZWStoreViewController alloc] init];
            [controller.navigationController pushViewController:nextViewController animated:YES];
        }
            
            break;
        case LotteryListType://抽奖首页
        {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"LuckDraw" bundle:nil];
            ZWPrizeListViewController *pickUpVC = [storyboard instantiateViewControllerWithIdentifier:
                                                   NSStringFromClass([ZWPrizeListViewController class])];
            [controller.navigationController pushViewController:pickUpVC animated:YES];
        }
            
            break;
        default:
        {
            if(model.adversizeDetailUrl && model.adversizeDetailUrl.length > 0)
            {
                ZWADWebViewController *adWebView = [[ZWADWebViewController alloc] initWithModel:model];
                
                [controller.navigationController pushViewController:adWebView animated:YES];
            }
        }
        break;
    }
}

@end
