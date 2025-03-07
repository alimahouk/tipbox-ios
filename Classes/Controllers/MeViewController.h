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
#import "TTTAttributedLabel.h"
#import "TipCard.h"

@interface MeViewController : Timeline <SettingsPanelViewDelegate, EGORefreshTableHeaderDelegate, UITableViewDelegate, UITableViewDataSource, MBProgressHUDDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate, FBDialogDelegate, TTTAttributedLabelDelegate> {
    Global *global;
    __block ASIFormDataRequest *dataRequest_child;
    NSDictionary *responseData_child;
    BOOL isCurrentUser;
    BOOL fbConnected;
    BOOL twitterConnected;
    MBProgressHUD *HUD;
    UIBarButtonItem *settingsButtonItem;
    SettingsPanelViewController *settings;
	EGORefreshTableHeaderView *refreshHeaderView;
    UITableViewActionSheet *genericOptions;
    UITableViewActionSheet *sharingOptions;
    UITableViewActionSheet *deletionOptions;
    int profileOwnerUserid;
    NSString *profileOwnerName;
    NSString *profileOwnerUsername;
    NSString *profileOwnerEmail;
    NSString *profileOwnerHash;
    NSString *profileOwnerLocation;
    NSString *profileOwnerBio;
    NSString *profileOwnerURL;
    NSString *fbID;
    NSString *twitterID;
    int tipCount;
    int topicCount;
    int geniusCount;
    int peopleHelped;
    int foundUsefulCount;
    EGOImageView *userThmbnl;
    UILabel *profileOwnerNameLabel;
    LPLabel *profileOwnerUsernameLabel;
    LPLabel *currentUserIndicator;
    CALayer *detailsSeparator;
    UIImageView *locationMarkerIconView;
    CALayer *locationSeparator;
    LPLabel *profileOwnerLocationLabel;
    TTTAttributedLabel *profileOwnerBioLabel;
    TTTAttributedLabel *profileOwnerBioLabelShadow;
    LPLabel *profileOwnerURLLabel;
    UIButton *profileOwnerURLButton;
    CALayer *statsTopSeparator;
    CALayer *statsSideSeparator_1;
    CALayer *statsSideSeparator_2;
    UIView *tipCountButton;
    LPLabel *tipCountLabel;
    LPLabel *topicCountLabel;
    LPLabel *geniusCountLabel;
    UILabel *tipCountTextLabel;
    UIButton *topicCountButton;
    UILabel *topicCountTextLabel;
    UILabel *geniusCountTextLabel;
    UIButton *geniusCountButton;
    UIView *peopleHelpedStrip;
    UILabel *peopleHelpedLabel;
    UILabel *peopleHelpedTextLabel;
    UIButton *externIdentityButton_fb;
    UIButton *externIdentityButton_twitter;
    UIImageView *profileOwnerCard;
    UIView *profileOwnerCardBg;
    UIImageView *foundUsefulButtonIconView;
    UILabel *foundUsefulButtonTitle;
    UIButton *foundUsefulButton;
    UIImageView *foundUsefulButtonBg;
    UILabel *foundUsefulLabel;
    UIImageView *foundUsefulStripChevron;
    UILabel *feedTitle;
    UIView *tableHeader;
    BOOL freshTip;
    TipCard *phantomCard;
}

@property (nonatomic, retain) ASIFormDataRequest *dataRequest_child;
@property (nonatomic) BOOL isCurrentUser;
@property (nonatomic, retain) NSString *profileOwnerName;
@property (nonatomic, retain) NSString *profileOwnerUsername;
@property (nonatomic, retain) NSString *profileOwnerEmail;
@property (nonatomic, retain) NSString *profileOwnerHash;
@property (nonatomic, retain) NSString *profileOwnerLocation;
@property (nonatomic, retain) NSString *profileOwnerBio;
@property (nonatomic, retain) NSString *profileOwnerURL;
@property (nonatomic) BOOL freshTip;

- (void)getUserInfoForUsername:(NSString *)username;
- (void)userNotFound;
- (void)redrawContents;
- (void)layoutProfileCard;
- (void)showSettingsPanel;
- (void)gotoProfilePicOptions:(id)sender;
- (void)reportUser;
- (void)showTopicsFollowed:(id)sender;
- (void)gotoUserURL:(id)sender;
- (void)gotoUserIdentity:(id)sender;
- (void)gotoUsefulList;

@end