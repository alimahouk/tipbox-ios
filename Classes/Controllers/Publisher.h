#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "MBProgressHUD.h"
#import "Global.h"
#import "LPLabel.h"
#import "ToggleButton.h"

@interface Publisher : UIViewController <UINavigationControllerDelegate, UIScrollViewDelegate, CLLocationManagerDelegate, MBProgressHUDDelegate, UIAlertViewDelegate, UITextViewDelegate> {
    Global *global;
    
    UIBarButtonItem *cancelButton;
    UIBarButtonItem *postButton;
    UIScrollView *pubScrollView;
    MBProgressHUD *HUD;
    CALayer *dottedDivider;
    ToggleButton *fbShareButton;
    ToggleButton *twitterShareButton;
    UIImageView *card;
    CALayer *cardBgTexture;
    LPLabel *charChounter;
    UITextView *editor;
    LPLabel *editorPlaceholder;
    UIImageView *pubUpperShadow;
    UIImageView *pubLowerShadow;
    CALayer *topicStrip;
    UIButton *topicButton;
	UIImageView *topicButtonIconView;
    UILabel *topicButtonLabel;
    UIButton *selectedCategoryButton;
    UIImageView *selectedCategoryButtonIcon;
    LPLabel *selectedCategoryButtonTitle;
    LPLabel *selectedCategoryButtonSubtitle;
    CLLocationManager *locationManager;
    CLLocationCoordinate2D currentLocation;
    int charsLeft;
    NSMutableDictionary *tip;
    UIImageView *todoList_title;
    UIImageView *todoList_1;
    UIImageView *todoList_2;
    UIImageView *todoList_3;
    UIImageView *todoList_4;
    UIImageView *todoList_5;
    
    /**********************************/
    /* Category/Subcategory Selection */
    /**********************************/
    int selectedSubcategory;
    int category;
    int subcategory;
    
    /*******************/
    /* Topic Selection */
    /*******************/
    NSString *topic;
    int topicid;
}

@property (nonatomic, retain) ToggleButton *fbShareButton;
@property (nonatomic, retain) ToggleButton *twitterShareButton;
@property (nonatomic, retain) UITextView *editor;
@property (nonatomic, retain) UILabel *topicButtonLabel;
@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic) int category;
@property (nonatomic) int subcategory;
@property (nonatomic) int selectedSubcategory;
@property (nonatomic, retain) UIImageView *selectedCategoryButtonIcon;
@property (nonatomic, retain) UILabel *selectedCategoryButtonTitle;
@property (nonatomic, retain) UILabel *selectedCategoryButtonSubtitle;
@property (nonatomic, retain) NSString *topic;
@property (nonatomic) int topicid;

- (void)showCategoryView;
- (void)showTopicSearchView;
- (void)todoListTapped;
- (void)respondToTextInPub;
- (void)postTip:(id)sender;
- (void)dismissPublisher:(id)sender;
- (void)activateFb;
- (void)activateTwitter;

@end