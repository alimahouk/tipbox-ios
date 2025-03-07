#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "Global.h"
#import "MBProgressHUD.h"
#import "FBConnect.h"
#import "EGORefreshTableHeaderView.h"
#import "UITableViewActionSheet.h"
#import "Timeline.h"

@protocol TipExplorerViewControllerDelegate <NSObject>

- (void)tipExplorerDidGetDismissed;

@end

@interface TipExplorerViewController  : Timeline <EGORefreshTableHeaderDelegate, UITableViewDelegate, UITableViewDataSource, MBProgressHUDDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate, FBDialogDelegate> {
    id <TipExplorerViewControllerDelegate> delegate;
    Global *global;
    __block ASIFormDataRequest *dataRequest_child;
    NSDictionary *responseData_child;
    
    NSMutableArray *feedEntries_hot;
    NSMutableArray *feedEntries_recent;
    EGORefreshTableHeaderView *refreshHeaderView;
    MBProgressHUD *HUD;
    UISegmentedControl *segmentedControl;
    IBOutlet UIToolbar *lowerToolbar;
    UIBarButtonItem *loginButton;
    UIBarButtonItem *joinButton;
    UITableViewActionSheet *genericOptions;
    UITableViewActionSheet *sharingOptions;
    UITableViewActionSheet *deletionOptions;
    int activeSegmentIndex;
    BOOL didDownloadTimeline_hot;
    BOOL didDownloadTimeline_trending;
    BOOL didDownloadTimeline_recent;
    BOOL endOfFeed_hot;
    BOOL endOfFeed_recent;
    NSMutableDictionary *selectedIndexes_hot;
    NSMutableDictionary *selectedIndexes_recent;
    int tappedRow_hot;
    int tappedRow_recent;
    int lastTappedRow_hot;
    int lastTappedRow_recent;
}

@property (nonatomic, assign) id <TipExplorerViewControllerDelegate> delegate;
@property (nonatomic, retain) IBOutlet UIToolbar *lowerToolbar;
@property (nonatomic, retain) NSMutableArray *feedEntries_hot;
@property (nonatomic, retain) NSMutableArray *feedEntries_recent;
@property (nonatomic, retain) NSMutableDictionary *selectedIndexes_hot;
@property (nonatomic, retain) NSMutableDictionary *selectedIndexes_recent;

- (void)dismissTipExplorer;
- (void)dismissTipExplorerForLogin;
- (void)dismissTipExplorerForSignup;
- (void)signup;
- (void)toggleFeedType:(id)sender;

@end