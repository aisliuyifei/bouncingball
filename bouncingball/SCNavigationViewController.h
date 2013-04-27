//
//  SCNavigationViewController.h
//  是男人就点一百下
//
//  Created by wupeng on 12-11-13.
//
//

#import <UIKit/UIKit.h>
#import "GADBannerView.h"

@interface SCNavigationViewController : UINavigationController{
    GADBannerView *gAdBannerView;
}
- (void)layoutAnimated:(BOOL)animated;

@end
