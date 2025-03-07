#import <UIKit/UIKit.h>
#import "Global.h"
#import "EGOImageView.h"
#import "LPLabel.h"

@interface IdCardCell : UITableViewCell {
    Global *global;
    
    NSInteger rowNumber;
    UIImageView *card;
    CALayer *cardBgTexture;
    CALayer *detailsSeparator;
    int userid;
	NSString *fullname;
	NSString *username;
	NSString *bio;
    NSString *userPicHash;
    int peopleHelped;
    LPLabel *currentUserIndicator;
	UILabel *nameLabel;
    LPLabel *usernameLabel;
    LPLabel *bioLabel;
    UILabel *peopleHelpedLabel;
    UILabel *peopleHelpedTextLabel;
    CALayer *peopleHelpedStrip;
    UIImageView *userThmbnlOverlayView;
	UIImage *userThmbnlOverlay;
    EGOImageView *userThmbnl;
    BOOL isCurrentUser;
}

@property (nonatomic) NSInteger rowNumber;
@property (nonatomic) int userid;
@property (nonatomic, retain) NSString *fullname;
@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) NSString *bio;
@property (nonatomic, retain) NSString *userPicHash;
@property (nonatomic, retain) UILabel *nameLabel;
@property (nonatomic, retain) UILabel *usernameLabel;
@property (nonatomic, retain) UILabel *bioLabel;
@property (nonatomic, retain) EGOImageView *userThmbnl;
@property (nonatomic) BOOL isCurrentUser;

- (void)populateCellWithContent:(NSMutableDictionary *)userInfo;
- (UIImage *)imageFilledWith:(UIColor *)color using:(UIImage *)startImage;

@end
