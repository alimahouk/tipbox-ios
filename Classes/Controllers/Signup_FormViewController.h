#import <UIKit/UIKit.h>
#import "ASIFormDataRequest.h"
#import "MBProgressHUD.h"
#import "Global.h"
#import "LPLabel.h"

@interface Signup_FormViewController : UIViewController <MBProgressHUDDelegate, UITextFieldDelegate> {
    Global *global;
    __block ASIFormDataRequest *dataRequest;
    NSDictionary *responseData;
    
    UIBarButtonItem *nextButton;
    MBProgressHUD *HUD;
    UIImageView *profileOwnerCard;
    UIView *profileOwnerCardBg;
    UIView *errorStrip;
    UILabel *errorLabel;
    UIView *separator_1;
    UIView *separator_2;
    UIView *separator_3;
    UIView *separator_4;
    LPLabel *label_notice;
    LPLabel *label_name;
    LPLabel *label_email;
    LPLabel *label_username;
    LPLabel *label_passwd;
    LPLabel *label_confirmedPasswd;
    LPLabel *label_usernameMarker;
    UITextField *field_name;
    UITextField *field_email;
    UITextField *field_username;
    UITextField *field_passwd;
    UITextField *field_confirmedPasswd;
    UILabel *underKeyboardLoadingLabel;
    UIActivityIndicatorView *underKeyboardLoadingIndicator;
    NSString *formConfiguration;
    NSString *fbid;
    NSString *twitterid;
    NSString *twitterUsername;
    NSString *TWTokenSecret;
    NSString *name;
    NSString *email;
    NSString *username;
    NSString *picHash;
    NSString *passwd;
    NSString *passwdConfirmed;
    NSString *location;
    NSString *bio;
    NSString *websiteURL;
    NSString *userTimezone;
}

@property (nonatomic, retain) ASIFormDataRequest *dataRequest;
@property (nonatomic, retain) NSDictionary *responseData;
@property (nonatomic, retain) UITextField *field_name;
@property (nonatomic, retain) UITextField *field_email;
@property (nonatomic, retain) UITextField *field_username;
@property (nonatomic, retain) UITextField *field_passwd;
@property (nonatomic, retain) UITextField *field_confirmedPasswd;
@property (nonatomic, retain) NSString *fbid;
@property (nonatomic, retain) NSString *twitterid;
@property (nonatomic, retain) NSString *twitterUsername;
@property (nonatomic, retain) NSString *TWTokenSecret;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *email;
@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) NSString *picHash;
@property (nonatomic, retain) NSString *passwd;
@property (nonatomic, retain) NSString *passwdConfirmed;
@property (nonatomic, retain) NSString *location;
@property (nonatomic, retain) NSString *bio;
@property (nonatomic, retain) NSString *websiteURL;
@property (nonatomic, retain) NSString *userTimezone;

- (void)respondToTextInFields;
- (void)showFieldsForConfiguration:(NSString *)configuration;
- (void)enableFields;
- (void)disableFields;
- (void)createAccount;
- (void)showErrorStripWithError:(NSString *)error;

@end
