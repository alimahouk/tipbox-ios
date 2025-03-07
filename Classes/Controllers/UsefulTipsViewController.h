#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "Global.h"
#import "MBProgressHUD.h"
#import "FBConnect.h"
#import "EGORefreshTableHeaderView.h"
#import "UITableViewActionSheet.h"
#import "Timeline.h"

@interface UsefulTipsViewController : Timeline <UITableViewDelegate, UITableViewDataSource, MBProgressHUDDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate, FBDialogDelegate> {
    Global *global;
    __block ASIFormDataRequest *dataRequest_child;
    NSDictionary *responseData_child;
    
    MBProgressHUD *HUD;
    UITableViewActionSheet *genericOptions;
    UITableViewActionSheet *sharingOptions;
    UITableViewActionSheet *deletionOptions;
}

@end
