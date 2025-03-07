#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "Global.h"
#import "MBProgressHUD.h"
#import "FBConnect.h"
#import "EGORefreshTableHeaderView.h"
#import "UITableViewActionSheet.h"
#import "Timeline.h"

@interface FeedViewController : Timeline <EGORefreshTableHeaderDelegate, UITableViewDelegate, UITableViewDataSource, MBProgressHUDDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate, FBDialogDelegate> {
    Global *global;
    __block ASIFormDataRequest *dataRequest_child;
    NSDictionary *responseData_child;
    
    EGORefreshTableHeaderView *refreshHeaderView;
    MBProgressHUD *HUD;
    UITableViewActionSheet *genericOptions;
    UITableViewActionSheet *sharingOptions;
    UITableViewActionSheet *deletionOptions;
    CALayer *dottedDivider;
    UILabel *qsgIntroLabel;
    UIImageView *qsgIcon;
    UIImageView *qsgButtonCard;
}

@property (nonatomic, retain) EGORefreshTableHeaderView *refreshHeaderView; // We only use this a property here because the QSG needs it.

- (void)showQuickStartGuide;

@end