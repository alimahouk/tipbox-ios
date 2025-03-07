#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "MBProgressHUD.h"
#import "Facebook.h"
#import "ASIFormDataRequest.h"
#import "Global.h"

@protocol SettingsPanelViewDelegate <NSObject>

- (void)panelDidGetDismissed;

@end

@interface SettingsPanelViewController : UIViewController <UINavigationControllerDelegate, MBProgressHUDDelegate, UIActionSheetDelegate, UIAlertViewDelegate, UIImagePickerControllerDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate, FBDialogDelegate> {
    Global *global;
    __block ASIFormDataRequest *dataRequest;
    NSDictionary *responseData;
    
    MBProgressHUD *HUD;
    id <SettingsPanelViewDelegate> delegate;
    IBOutlet UITableView *settingsTableView;
    UIBarButtonItem *doneButton;
    NSDictionary *tableContents;
	NSArray *sortedKeys;
    UIImagePickerController *dpPicker;
    UIImage *selectedDPImage;
}

@property (nonatomic, retain) __block ASIFormDataRequest *dataRequest;
@property (nonatomic, retain) NSDictionary *responseData;
@property (nonatomic, assign) id <SettingsPanelViewDelegate> delegate;
@property (nonatomic, retain) IBOutlet UITableView *settingsTableView;
@property (nonatomic, retain) NSDictionary *tableContents;
@property (nonatomic, retain) NSArray *sortedKeys;
@property (nonatomic, retain) UIImage *selectedDPImage;

- (void)dismissSettingsPanel;
- (void)showUserPicOptions;
- (void)importFBDP;
- (void)importTWTDP;
- (void)initiateTwitterDPImportForAccount:(ACAccount *)account;

@end