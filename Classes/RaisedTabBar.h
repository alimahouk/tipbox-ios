#import <UIKit/UIKit.h>
#import "SignupViewController.h"
#import "TipExplorerViewController.h"

@interface RaisedTabBar : UITabBarController {
    SignupViewController *signupView;
    TipExplorerViewController *tipExplorerView;
	UILabel *notifCount;
	UILabel *notifCountShadow;
}

@property (nonatomic, retain) SignupViewController *signupView;
@property (nonatomic, retain) TipExplorerViewController *tipExplorerView;
@property (nonatomic, retain) UILabel *notifCount;
@property (nonatomic, retain) UILabel *notifCountShadow;

//- (UIView *)setupNavBar;
// Create a custom UIButton and add it to the center of our tab bar.
- (void)addCenterButtonWithImage:(UIImage*)buttonImage;

@end
