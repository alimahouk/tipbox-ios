#import <UIKit/UIKit.h>

@interface TopicCell : UITableViewCell {
	CALayer *entryBody;
    UIImageView *card;
    CALayer *cardBgTexture;
    int rowNumber;
    int _id;
    int topicid;
    int tipCount;
    int followCount;
    BOOL showsFollowButton;
    BOOL showsDisclosureIndicator;
    BOOL followsTopic;
    NSString *configuration;
	NSString *content;
    CALayer *statsSeparator;
    UILabel *tipCountLabel;
    UILabel *followerCountLabel;
    UILabel *tipCountTextLabel;
    UILabel *followerCountTextLabel;
    UILabel *followButtonLabel;
    CALayer *topicStrip;
    UILabel *topicLabel;
    UIButton *followButton;
    UIButton *disclosureButton;
    UIImageView *disclosureAdd; // This one's not tappable.
    CALayer *dottedDivider;
}

@property (nonatomic) int rowNumber;
@property (nonatomic) int _id;
@property (nonatomic) int topicid;
@property (nonatomic) int tipCount;
@property (nonatomic) int followCount;
@property (nonatomic) BOOL showsFollowButton;
@property (nonatomic) BOOL showsDisclosureIndicator;
@property (nonatomic) BOOL followsTopic;
@property (nonatomic, retain) NSString *configuration;
@property (nonatomic, retain) NSString *content;
@property (nonatomic, retain) UILabel *followerCountLabel;
@property (nonatomic, retain) UILabel *followerCountTextLabel;
@property (nonatomic, retain) UILabel *topicLabel;
@property (nonatomic, retain) UILabel *followButtonLabel;
@property (nonatomic, retain) UIButton *followButton;
@property (nonatomic, retain) UIButton *disclosureButton;
@property (nonatomic, retain) UIImageView *disclosureAdd;

- (void)populateCellWithContent:(NSMutableDictionary *)topic;
- (void)toggleFollowStatus;

@end
