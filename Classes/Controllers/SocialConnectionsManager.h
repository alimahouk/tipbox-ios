#import <UIKit/UIKit.h>
#import <Accounts/Accounts.h>
#import "FBConnect.h"
#import "ASIFormDataRequest.h"
#import "MBProgressHUD.h"
#import "Global.h"
#import "LPLabel.h"

@interface SocialConnectionsManager : UIViewController <MBProgressHUDDelegate, FBRequestDelegate, FBSessionDelegate, UIActionSheetDelegate> {
    __block ASIFormDataRequest *dataRequest;
    NSDictionary *responseData;
    Global *global;
    
    MBProgressHUD *HUD;
    UIView *card;
    UIView *cardBg;
    UIButton *fbButton;
    UIButton *twitterButton;
    UILabel *fbButtonLabel;
    UILabel *twitterButtonLabel;
    NSArray *fbUserPermissions;
    NSString *twitterUsername;
    NSString *twitterid;
    NSString *TWTokenSecret;
}

@property (nonatomic, retain) ASIFormDataRequest *dataRequest;
@property (nonatomic, retain) NSDictionary *responseData;

- (void)showConnectionError;
- (void)renewFBToken:(id)sender;
- (void)renewTWToken:(id)sender;
- (void)initiateTwitterSignupForAccount:(ACAccount *)account;
- (BOOL)openSessionWithAllowLoginUI:(BOOL)allowLoginUI;

@end