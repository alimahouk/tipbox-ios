#import <UIKit/UIKit.h>
#import "Global.h"
#import "EGOImageView.h"
#import "ToggleButton.h"
#import "LPLabel.h"

@interface TipCard : UIView {
    Global *global;
    
    NSMutableArray *timelineData;
    UIImageView *card;
    UIView *cardBgTexture;
    CALayer *detailsSeparator;
    int cardIndex;
    int tipid;
    int tipUserid;
	NSString *fullname;
	NSString *username;
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
	UIImageView *userThmbnlOverlayView;
	UIImage *userThmbnlOverlay;
	EGOImageView *userThmbnl;
    BOOL showsMarkUsefulButton;
    BOOL genius;
    BOOL marked;
    float location_lat;
    float location_long;
	UILabel *tipTxtLabel;
	UILabel *storyActor;
    LPLabel *usernameLabel;
    ToggleButton *markUsefulButton;
    CALayer *topicStrip;
    UIImageView *topicStripIcon;
    UILabel *topicLabel;
    UIImageView *catIcon;
    UIImageView *geniusIcon;
    UIImageView *clockIcon;
	LPLabel *timestampLabel;
}

@property (nonatomic, retain) NSMutableArray *timelineData;
@property (nonatomic) int cardIndex;
@property (nonatomic) int tipid;
@property (nonatomic) int tipUserid;
@property (nonatomic, retain) NSString *fullname;
@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) NSString *content;
@property (nonatomic) int catid;
@property (nonatomic, retain) NSString *subcat;
@property (nonatomic, retain) NSString *parentCat;
@property (nonatomic) int topicid;
@property (nonatomic, retain) NSString *topicContent;
@property (nonatomic, retain) NSString *timestamp;
@property (nonatomic, retain) UILabel *tipTxtLabel;
@property (nonatomic, retain) UILabel *storyActor;
@property (nonatomic, retain) UILabel *usernameLabel;
@property (nonatomic, retain) EGOImageView *userThmbnl;
@property (nonatomic, retain) UILabel *topicLabel;
@property (nonatomic, retain) UILabel *timestampLabel;
@property (nonatomic) BOOL showsMarkUsefulButton;
@property (nonatomic) BOOL genius;

- (void)populateCellWithContent:(NSMutableDictionary *)tip;
- (void)markUseful;

@end
