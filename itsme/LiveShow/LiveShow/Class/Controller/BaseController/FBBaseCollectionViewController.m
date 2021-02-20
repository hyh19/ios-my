#import "FBBaseCollectionViewController.h"

@interface FBBaseCollectionViewController ()

@end

@implementation FBBaseCollectionViewController

- (void)dealloc {
    self.collectionView.delegate = nil;
}

@end
