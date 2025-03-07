#import <UIKit/UIKit.h>
#import "Global.h"
#import "ASIFormDataRequest.h"
#import "MBProgressHUD.h"
#import "LPLabel.h"

@interface Settings_PasswdViewController : UIViewController <UITextFieldDelegate, MBProgressHUDDelegate> {
    Global *global;
    __block ASIFormDataRequest *dataRequest;
    NSDictionary *responseData;
    
    MBProgressHUD *HUD;
    UIBarButtonItem *saveButton;
    UIView *errorStrip;
    UILabel *errorLabel;
    UIImageView *profileOwnerCard;
    UIView *profileOwnerCardBg;
    UIView *separator_1;
    UIView *separator_2;
    LPLabel *label_oldPasswd;
    LPLabel *label_changedPasswd;
    LPLabel *label_confirmedPasswd;
    UITextField *field_oldPasswd;
    UITextField *field_changedPasswd;
    UITextField *field_confirmedPasswd;
}

@property (nonatomic, retain) UITextField *field_oldPasswd;
@property (nonatomic, retain) UITextField *field_changedPasswd;
@property (nonatomic, retain) UITextField *field_confirmedPasswd;

- (void)respondToTextInFields;
- (void)saveNewPasswd;
- (void)showErrorStripWithError:(NSString *)error;

@end
