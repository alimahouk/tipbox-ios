#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "Global.h"
#import "ASIFormDataRequest.h"
#import "MBProgressHUD.h"
#import "FBConnect.h"
#import "EGOImageView.h"
#import "FacemashPhoto.h"
#import "LPLabel.h"
#import "ToggleButton.h"

@interface TipViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, MBProgressHUDDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate, FBDialogDelegate, UIWebViewDelegate> {
    __block ASIFormDataRequest *dataRequest;
    NSDictionary *responseData;
    Global *global;
    
	IBOutlet UIScrollView *scrollView;
    MBProgressHUD *HUD;
    int genius;
    BOOL marked;
    BOOL userFollowsTopic;
    BOOL deleted;
    BOOL fetchesOwnData;
    NSIndexPath *motherCellIndexPath;
    UIActionSheet *sharingOptions;
    UIActionSheet *deletionOptions;
    UIActionSheet *genericOptions;
    NSMutableArray *participantData;
	NSString *subcat;
    NSString *parentCat;
    int topicid;
    NSString *topicContent;
    int catid;
	int tipid;
	int tipUserid;
    NSString *tipFullName;
	NSString *tipUsername;
	NSString *tipUserPicHash;
	NSString *content;
	NSString *tipTimestamp;
    NSString *tipTimestamp_short;
    NSString *tipActualTime;
    int usefulCount;
    float location_lat;
    float location_long;
    UIImageView *card;
    CALayer *cardBgTexture;
    UIButton *tipAuthorButton;
    UIImageView *userThmbnlOverlayView;
	UIImage *userThmbnlOverlay;
	EGOImageView *userThmbnl;
    CALayer *detailsSeparator;
    UILabel *tipTxtLabelShadowCopy;
	UIWebView *tipTxtLabel;
	LPLabel *nameLabel;
    LPLabel *usernameLabel;
    UIButton *topicButton;
    UILabel *topicLabel;
    UIImageView *geniusIcon;
    UIImageView *clockIcon;
	LPLabel *timestampLabel;
    CALayer *timestampSeparator;
    UIImageView *tipOptionsLinen;
    ToggleButton *pane_markUsefulButton;
    UIButton *pane_shareButton;
    UIButton *pane_tipOptionsButton;
    UIButton *pane_deleteButton;
    UILabel *usefulnessMeter;
    UIImageView *usefulnessMeterIconView;
    UIImageView *facemashStripBg;
    FacemashPhoto *facemash_1;
    FacemashPhoto *facemash_2;
    FacemashPhoto *facemash_3;
    FacemashPhoto *facemash_4;
    FacemashPhoto *facemash_5;
    FacemashPhoto *facemash_6;
    FacemashPhoto *facemash_7;
    FacemashPhoto *facemash_8;
    FacemashPhoto *facemash_9;
    CALayer *dottedDivider;
    UIImageView *catIcon;
    UILabel *categoryLabel;
}

@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic) int genius;
@property (nonatomic) BOOL marked;
@property (nonatomic) BOOL userFollowsTopic;
@property (nonatomic) BOOL fetchesOwnData;
@property (nonatomic, retain) NSIndexPath *motherCellIndexPath;
@property (nonatomic, retain) NSMutableArray *participantData;
@property (nonatomic, retain) NSString *subcat;
@property (nonatomic, retain) NSString *parentCat;
@property (nonatomic) int topicid;
@property (nonatomic, retain) NSString *topicContent;
@property (nonatomic) int catid;
@property (nonatomic) int tipid;
@property (nonatomic) int tipUserid;
@property (nonatomic, retain) NSString *tipFullName;
@property (nonatomic, retain) NSString *tipUsername;
@property (nonatomic, retain) NSString *tipUserPicHash;
@property (nonatomic, retain) NSString *content;
@property (nonatomic, retain) NSString *tipTimestamp;
@property (nonatomic, retain) NSString *tipTimestamp_short;
@property (nonatomic, retain) NSString *tipActualTime;
@property (nonatomic) int usefulCount;

- (void)fetchTipData;
- (void)redrawView;
- (void)showTipSharingOptions:(id)sender;
- (void)showTipDeletionOptions:(id)sender;
- (void)showMoreTipOptions:(id)sender;
- (void)markUseful:(id)sender;
- (void)deleteTip;
- (void)createTipOnTopic;
- (void)followTopic;
- (void)reportTip;
- (void)redisplayUsefulnessData;
- (void)setUpFacemash;
- (void)didSwipeView;
- (void)gotoTipAuthor:(id)sender;
- (void)gotoUser:(id)sender;
- (void)gotoTopic:(id)sender;

@end
