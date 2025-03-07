#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "Global.h"
#import "MBProgressHUD.h"
#import "FBConnect.h"
#import "EGORefreshTableHeaderView.h"
#import "UITableViewActionSheet.h"
#import "Timeline.h"

@interface SearchViewController : Timeline <UISearchDisplayDelegate, UISearchBarDelegate, UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource, MBProgressHUDDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate, FBDialogDelegate> {
    Global *global;
    __block ASIFormDataRequest *dataRequest_child;
    NSDictionary *responseData_child;
    
    UITableView *searchResultsTableView;
    NSString *searchType;
    NSString *query;
    MBProgressHUD *HUD;
    UITableViewActionSheet *genericOptions;
    UITableViewActionSheet *sharingOptions;
    UITableViewActionSheet *deletionOptions;
    NSDictionary *quotesDict;
    UILabel *noResultsLabel;
    UIImageView *shRoof;
    UIImageView *beOriginal;
    UIImageView *potato;
    UIImageView *lemon;
    UIImageView *heart;
    UILabel *quote;
    UILabel *quoter;
    UILabel *funnyLine;
}

@property (nonatomic, retain) UITableView *searchResultsTableView;

- (void)searchResultsForBatch:(int)batch;
- (void)fetchTopics;
- (void)fetchTips;
- (void)fetchUsers;
- (void)followTopic:(id)sender;

@end