#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "MBProgressHUD.h"

@interface WebViewController : UIViewController <UIWebViewDelegate, MBProgressHUDDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate> {
    IBOutlet UIToolbar *lowerToolbar;
    IBOutlet UIWebView *browser;
    IBOutlet UIBarItem *backButton;
    IBOutlet UIBarItem *forwardButton;
    IBOutlet UIBarItem *refreshButton;
    MBProgressHUD *HUD;
    UIActionSheet *browserOptions;
    NSString *url;
    BOOL loading;
}

@property (nonatomic, retain) IBOutlet UIToolbar *lowerToolbar;
@property (nonatomic, retain) IBOutlet UIWebView *browser;
@property (nonatomic, retain) IBOutlet UIBarItem *backButton;
@property (nonatomic, retain) IBOutlet UIBarItem *forwardButton;
@property (nonatomic, retain) IBOutlet UIBarItem *refreshButton;
@property (nonatomic, retain) NSString *url;

- (IBAction)goBack:(id)sender;
- (IBAction)goForward:(id)sender;
- (IBAction)reloadPage:(id)sender;
- (IBAction)showBrowserOptions:(id)sender;
- (void)newTipUsingSelection;

@end
