#import <UIKit/UIKit.h>
#import "Global.h"
#import "ASIFormDataRequest.h"
#import "MBProgressHUD.h"
#import "LPLabel.h"

@interface Settings_ContactViewController : UIViewController <MBProgressHUDDelegate, UITextViewDelegate> {
    Global *global;
    __block ASIFormDataRequest *dataRequest;
    NSDictionary *responseData;
    
    int targetIdentity;
    MBProgressHUD *HUD;
    UIImageView *envelope;
    UIImageView *envelope_back;
    UIImageView *card;
    CALayer *cardBgTexture;
    UIButton *backButton;
    UIButton *sendButton;
    UITextView *editor;
    UIImageView *pubUpperShadow;
    UIImageView *pubLowerShadow;
    CALayer *topicStrip;
    UIButton *externIdentityButton_fb;
    UIButton *externIdentityButton_twitter;
    UILabel *welcomeLabel;
    UIButton *gratitude_keyboardTouchpad;
    UIImageView *gratitude_overlay;
    UIImageView *gratitude_1;
    UIImageView *gratitude_2;
}

- (void)goBack:(id)sender;
- (void)send:(id)sender;
- (void)gotoIdentity:(id)sender;
- (void)respondToTextInPub;

@end
