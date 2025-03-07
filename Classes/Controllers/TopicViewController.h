#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "Global.h"
#import "MBProgressHUD.h"
#import "FBConnect.h"
#import "SettingsPanelViewController.h"
#import "EGORefreshTableHeaderView.h"
#import "UITableViewActionSheet.h"
#import "Timeline.h"
#import "LPLabel.h"

@interface TopicViewController : Timeline <EGORefreshTableHeaderDelegate, UITableViewDelegate, UITableViewDataSource, MBProgressHUDDelegate, UIActionSheetDelegate, UIAlertViewDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate, FBDialogDelegate> {
    Global *global;
    __block ASIFormDataRequest *dataRequest_child;
    NSDictionary *responseData_child;
    
    UIBarButtonItem *followTopicButton;
	NSString *topicName;
    int viewTopicid;
    NSString *topicCreationDate_relative;
    NSString *topicCreationDate_actual;
    NSString *topicCreatorUsername;
    int topicCreatorUserid;
    NSMutableArray *followers;
    int followerCount;
    NSString *geniusName;
    NSString *geniusUsername;
    NSString *geniusPicHash;
    int geniusUserid;
    int tipCount;
    BOOL userFollowsTopic;
    EGORefreshTableHeaderView *refreshHeaderView;
    MBProgressHUD *HUD;
    UITableViewActionSheet *genericOptions;
    UITableViewActionSheet *sharingOptions;
    UITableViewActionSheet *deletionOptions;
    UIImageView *followCountButtonIconView;
    UILabel *topicCreationDateLabel;
    UILabel *topicCreatorLabel;
    UIButton *topicCreatorButton;
    UIView *dottedDivider;
    UILabel *followCountButtonTitle;
    UIButton *followCountButton;
    UIImageView *followCountButtonBg;
    NSMutableArray *followerData;
    UIImageView *facemashFrame_1;
    UIImageView *facemashFrame_2;
    UIImageView *facemashFrame_3;
    UIImageView *facemashFrame_4;
    UIImageView *facemashFrame_5;
    UIImageView *facemashFrame_6;
    UIImageView *facemashFrame_7;
    UIImageView *facemashFrame_8;
    UIImageView *facemashFrame_9;
    EGOImageView *facemash_1;
    EGOImageView *facemash_2;
    EGOImageView *facemash_3;
    EGOImageView *facemash_4;
    EGOImageView *facemash_5;
    EGOImageView *facemash_6;
    EGOImageView *facemash_7;
    EGOImageView *facemash_8;
    EGOImageView *facemash_9;
    UIImageView *followCountStripChevron;
    UIImageView *geniusButtonIconView;
    UILabel *geniusButtonTitle;
    UIButton *geniusButton;
    UIImageView *geniusButtonBg;
    UIImageView *userThmbnlOverlayView;
    EGOImageView *userThmbnl;
    UILabel *geniusNameLabel;
    LPLabel *geniusUsernameLabel;
    LPLabel *emptyGeniusLabel;
    UIImageView *geniusStripChevron;
    UIImageView *feedTitleIconView;
    UILabel *feedTitle;
    UIView *tableHeader;
}

@property (nonatomic, retain) NSString *topicName;
@property (nonatomic) int viewTopicid;
@property (nonatomic) BOOL userFollowsTopic;

- (void)followTopic;
- (void)getTopicInfo;
- (void)setUpFacemash;
- (void)gotoFollowerList;
- (void)gotoGenius;
- (void)gotoTopicCreator;
- (void)createTipOnTopic_noCat;

@end