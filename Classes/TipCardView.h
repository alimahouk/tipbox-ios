#import <UIKit/UIKit.h>
#import "Global.h"
#import "EGOImageView.h"
#import "ToggleButton.h"
#import "LPLabel.h"
#import "FacemashPhoto.h"

@interface TipCardView : UIView {
    Global *global;
    
    NSMutableArray *participantData;
    int rowNumber;
    int tipid;
    int tipUserid;
	NSString *fullname;
	NSString *username;
    NSString *userPicHash;
	NSString *content;
    int catid;
    NSString *subcat;
    NSString *parentCat;
    int topicid;
    NSString *topicContent;
	NSString *timestamp;
    NSString *timestamp_short;
    NSString *actualTime;
    int usefulCount;
    int genius;
    BOOL marked;
    BOOL followsTopic;
    BOOL isSelected;
    float location_lat;
    float location_long;
    UIImageView *card;
    CALayer *cardBgTexture;
    CALayer *detailsSeparator;
    UIImageView *userThmbnlOverlayView;
	UIImage *userThmbnlOverlay;
	EGOImageView *userThmbnl;
    ToggleButton *markUsefulButton;
    UIImageView *stretchyMarkUsefulButton;
    UIImageView *stretchyMarkUsefulButtonBulb;
    UILabel *stretchyMarkUsefulButtonLabel;
	UILabel *tipTxtLabel;
	UILabel *nameLabel;
    LPLabel *usernameLabel;
    CALayer *topicStrip;
    UIImageView *topicStripIcon;
    UILabel *topicLabel;
    UIImageView *catIcon;
    UIImageView *geniusIcon;
    UIImageView *clockIcon;
	LPLabel *timestampLabel;
    UIView *tipOptionsPane;
    UIImageView *tipOptionsStripFrame;
    CALayer *tipOptionsStripBg;
    UIImageView *tipOptionsLinen;
    UIImageView *usefulnessMeterIconView;
    LPLabel *usefulnessMeter;
    CALayer *tipOptionsSeparator;
    FacemashPhoto *facemash_1;
    FacemashPhoto *facemash_2;
    FacemashPhoto *facemash_3;
    FacemashPhoto *facemash_4;
    FacemashPhoto *facemash_5;
    FacemashPhoto *facemash_6;
    FacemashPhoto *facemash_7;
    UIButton *pane_gotoTipButton;
    UIButton *pane_gotoUserButton;
    UIButton *pane_shareButton;
    UIButton *pane_tipOptionsButton;
    UIButton *pane_deleteButton;
}

@property (nonatomic, retain) NSMutableArray *participantData;
@property (nonatomic) int rowNumber;
@property (nonatomic) int tipid;
@property (nonatomic) int tipUserid;
@property (nonatomic, retain) NSString *fullname;
@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) NSString *userPicHash;
@property (nonatomic, retain) NSString *content;
@property (nonatomic) int catid;
@property (nonatomic, retain) NSString *subcat;
@property (nonatomic, retain) NSString *parentCat;
@property (nonatomic) int topicid;
@property (nonatomic, retain) NSString *topicContent;
@property (nonatomic, retain) NSString *timestamp;
@property (nonatomic, retain) NSString *timestamp_short;
@property (nonatomic, retain) NSString *actualTime;
@property (nonatomic, retain) UIImageView *card;
@property (nonatomic, retain) CALayer *cardBgTexture;
@property (nonatomic, retain) UILabel *tipTxtLabel;
@property (nonatomic, retain) UILabel *nameLabel;
@property (nonatomic, retain) LPLabel *usernameLabel;
@property (nonatomic, retain) EGOImageView *userThmbnl;
@property (nonatomic) int usefulCount;
@property (nonatomic, retain) ToggleButton *markUsefulButton;
@property (nonatomic) int genius;
@property (nonatomic) BOOL marked;
@property (nonatomic) BOOL followsTopic;
@property (nonatomic) BOOL isSelected;
@property (nonatomic, retain) UILabel *topicLabel;
@property (nonatomic, retain) CALayer *topicStrip;
@property (nonatomic, retain) UILabel *timestampLabel;
@property (nonatomic, retain) UIView *tipOptionsPane;
@property (nonatomic, retain) LPLabel *usefulnessMeter;
@property (nonatomic, retain) FacemashPhoto *facemash_1;
@property (nonatomic, retain) FacemashPhoto *facemash_2;
@property (nonatomic, retain) FacemashPhoto *facemash_3;
@property (nonatomic, retain) FacemashPhoto *facemash_4;
@property (nonatomic, retain) FacemashPhoto *facemash_5;
@property (nonatomic, retain) FacemashPhoto *facemash_6;
@property (nonatomic, retain) FacemashPhoto *facemash_7;
@property (nonatomic, retain) UIButton *pane_gotoTipButton;
@property (nonatomic, retain) UIButton *pane_gotoUserButton;
@property (nonatomic, retain) UIButton *pane_shareButton;
@property (nonatomic, retain) UIButton *pane_tipOptionsButton;
@property (nonatomic, retain) UIButton *pane_deleteButton;

- (void)populateViewWithContent:(NSMutableDictionary *)tip;
- (void)redisplayUsefulnessData;
- (void)setUpFacemash;
- (void)playMarkingAnimation;

@end
