#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <Accounts/Accounts.h>
#import "ASIFormDataRequest.h"
#import "MBProgressHUD.h"
#import "FBConnect.h"

@protocol SignupViewControllerDelegate <NSObject>

- (void)signupPanelDidGetDismissed;

@end

@interface SignupViewController : UIViewController <MBProgressHUDDelegate, UIActionSheetDelegate, UIAlertViewDelegate, FBRequestDelegate, FBSessionDelegate> {
    id <SignupViewControllerDelegate> delegate;
    __block ASIFormDataRequest *dataRequest;
    NSDictionary *responseData;
    
    UIBarButtonItem *cancelButton;
    MBProgressHUD *HUD;
    UILabel *descLabel;
    UIButton *fbButton;
    UIButton *twitterButton;
    UIButton *emailButton; 
    NSString *fbid;
    NSString *twitterid;
    NSString *TWTokenSecret;
    NSString *picHash;
    NSString *name;
    NSString *email;
    NSString *username;
    NSString *location;
    NSString *bio;
    NSString *websiteURL;
    NSString *userTimezone;
    NSArray *fbUserPermissions;
}

@property (nonatomic, assign) id <SignupViewControllerDelegate> delegate;
@property (nonatomic, retain) UIBarButtonItem *cancelButton;
@property (nonatomic, retain) NSArray *fbUserPermissions;

- (void)dismissSettingsPanel;
- (void)initiateSignup:(id)sender;
- (void)initiateTwitterSignupForAccount:(ACAccount *)account;
- (BOOL)openSessionWithAllowLoginUI:(BOOL)allowLoginUI;
- (void)showConnectionError;

@end