#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface Settings_CorporateWebViewController : UIViewController <UIWebViewDelegate, MBProgressHUDDelegate> {
    IBOutlet UIWebView *browser;
    MBProgressHUD *HUD;
    NSString *url;
}

@property (nonatomic, retain) IBOutlet UIWebView *browser;
@property (nonatomic, retain) NSString *url;

@end
