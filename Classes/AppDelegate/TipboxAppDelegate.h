#import <UIKit/UIKit.h>
#import <sys/utsname.h>
#import "ASIFormDataRequest.h"
#import "Global.h"
#import "RaisedTabBar.h"
#import "UIStrobeLight.h"
#import "MBProgressHUD.h"
#import "SignupViewController.h"
#import "TipExplorerViewController.h"
#import "FBConnect.h"

// 192.168.1.200 << akay64's IP address.

#define SH_DOMAIN @"scapehouse.com" // For use in URLs. Alternate between actual domain and localhost for testing purposes.
#define APP_NAME @"Tipbox"
#define APP_TARGET_PLATFORM @"iOS"
#define APP_TARGET_PLATFORM_MINVER @"5.0"
#define APP_VERSION @"1.1.0"
#define BATCH_SIZE 15
#define AUTOREFRESH_THRESHOLD 5

static NSString *FB_APP_ID = @"278585982224213"; // FB App ID.
extern NSString *const FBSessionStateChangedNotification;

@interface TipboxAppDelegate : NSObject <UIApplicationDelegate, UINavigationControllerDelegate, UITabBarControllerDelegate, MBProgressHUDDelegate, UIAlertViewDelegate, UITextFieldDelegate, SignupViewControllerDelegate, TipExplorerViewControllerDelegate> {
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;
    
    ASIFormDataRequest *dataRequest;
    NSString *activeConnectionIdentifier;
    NSDictionary *responseData;
    Global *global;
    NSString *currentDeviceModel;
    UIWindow *window;
    RaisedTabBar *mainTabBarController;
    UINavigationController *publisherNavigationController;
    UINavigationController *signupViewNavigationController;
    UINavigationController *tipExplorerNavigationController;
    UIStrobeLight *strobeLight;
    MBProgressHUD *HUD;
    NSTimer *boxAnimationTimer;
    UIImageView *navbarShadow;
    UIImageView *tabbarShadow;
    UIImageView *boxCoverUpper;
    UIImageView *boxCoverLower;
    UIImageView *loginBoxShadow;
    UIView *loginBox;
    UIView *loginBoxBack;
    UIButton *joinButton;
    UIButton *loginButton;
    UIButton *forgotPasswdButton;
    UIButton *cancelPasswdResetButton;
    UIButton *passwdResetButton;
    UILabel *label_loginButton;
    UILabel *label_cancelPasswdResetButton;
    UILabel *label_passwdResetButton;
    UITextField *field_username;
    UITextField *field_passwd;
    UITextField *field_passwdReset;
    UITextField *field_usernameShadowCopy;
    UITextField *field_passwdShadowCopy;
    UIImageView *usernameFieldBGImageView;
    UIImageView *usernameFieldCover;
    UIImageView *passwdFieldBGImageView;
    UIImageView *passwdFieldCover;
    UIImageView *passwdResetFieldBGImageView;
    UILabel *passwdResetDescLabel;
    UILabel *logoutMessage;
    NSString *deviceToken;
    NSString *SHToken;
    NSString *FBToken;
    NSString *TWToken;
    NSString *SHAppid;
    NSDate *lastRefreshedDate;
    Facebook *facebook;
    NSArray *fbUserPermissions;
    BOOL keyboardIsShown;
}

@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic, readonly) NSString *applicationDocumentsDirectory;
@property (nonatomic, retain) ASIFormDataRequest *dataRequest;
@property (nonatomic, retain) NSDictionary *responseData;
@property (nonatomic, retain) Global *global;
@property (nonatomic, retain) NSString *currentDeviceModel;
@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet RaisedTabBar *mainTabBarController;
@property (nonatomic, retain) UINavigationController *publisherNavigationController;
@property (nonatomic, retain) UINavigationController *signupViewNavigationController;
@property (nonatomic, retain) UIStrobeLight *strobeLight;
@property (nonatomic, retain) UIImageView *boxCoverUpper;
@property (nonatomic, retain) UIImageView *boxCoverLower;
@property (nonatomic, retain) NSString *device_token;
@property (nonatomic, retain) NSString *SHToken;
@property (nonatomic, retain) NSString *FBToken;
@property (nonatomic, retain) NSString *TWToken;
@property (nonatomic, retain) NSString *SHAppid;
@property (nonatomic, retain) Facebook *facebook;
@property (nonatomic, retain) NSArray *fbUserPermissions;

- (void)getDeviceModel;
- (void)saveAction;
- (void)openBoxWithConfiguration:(NSString *)configuration;
- (void)closeBoxWithConfiguration:(NSString *)configuration;
- (void)hideBoxCovers;
- (void)showLoginFields;
- (void)hideLoginFields;
- (void)flipBackLoginBox;
- (void)reverseCoverLayerOrder;
- (void)flipFrontLoginBox;
- (void)restoreCoverLayerOrder;
- (void)hideKeyboardForFlip:(NSString *)flipDirection;
- (void)hideLoginBox;
- (void)setViewMovedUp:(BOOL)movedUp;
- (void)SHPopupPublisher;
- (void)hideNavbarShadowAnimated:(BOOL)animated;
- (void)showNavbarShadowAnimated:(BOOL)animated;
- (void)navbarShadowMode_navbar;
- (void)navbarShadowMode_searchbar;
- (void)hideTabbarShadowAnimated:(BOOL)animated;
- (void)showTabbarShadowAnimated:(BOOL)animated;
- (void)tabbarShadowMode_toolbar;
- (void)tabbarShadowMode_tabbar;
- (void)tabbarShadowMode_nobar;
- (void)signup;
- (void)hideSignupView;
- (void)explore;
- (void)hideTipExplorer;
- (void)goHome;
- (void)login;
- (void)logout;
- (void)logoutWithMessage:(NSString *)message;
- (void)resetPasswd;
- (void)postTip:(NSMutableDictionary *)tip;

@end
