#import <UIKit/UIKit.h>
#import "Global.h"
#import "ASIFormDataRequest.h"
#import "MBProgressHUD.h"
#import "LPLabel.h"

@interface Settings_ProfileEditorViewController : UIViewController <MBProgressHUDDelegate, UITextFieldDelegate, UIAlertViewDelegate> {
    Global *global;
    __block ASIFormDataRequest *dataRequest;
    NSDictionary *responseData;
    
    MBProgressHUD *HUD;
    UIBarButtonItem *saveButton;
    IBOutlet UIScrollView *scrollView;
    int userid;
    NSString *name;
    NSString *username;
    NSString *email;
    NSString *location;
    NSString *bio;
    NSString *url;
    LPLabel *label_name;
    LPLabel *label_username;
    LPLabel *label_email;
    LPLabel *label_location;
    LPLabel *label_url;
    LPLabel *label_bio;
    LPLabel *label_bioNotice;
    LPLabel *label_usernameMarker;
    UITextField *field_name;
    UITextField *field_username;
    UITextField *field_email;
    UITextField *field_location;
    UITextField *field_url;
    UITextField *field_bio;
    UITextField *activeTextField;
    UIImageView *profileOwnerCard;
    UIView *profileOwnerCardBg;
    UIView *separator_1;
    UIView *separator_2;
    UIView *separator_3;
    UIView *separator_4;
    UIView *separator_5;
    UIView *errorStrip;
    UILabel *errorLabel;
}

@property (nonatomic) int userid;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) NSString *email;
@property (nonatomic, retain) NSString *location;
@property (nonatomic, retain) NSString *bio;
@property (nonatomic, retain) NSString *url;

- (void)keyboardWasShown:(NSNotification *)aNotification;
- (void)keyboardWillBeHidden:(NSNotification *)aNotification;
- (void)enableFields;
- (void)disableFields;
- (void)updateProfile;
- (void)showErrorStripWithError:(NSString *)error;

@end
