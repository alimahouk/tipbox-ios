#import <UIKit/UIKit.h>
#import "Global.h"
#import "ASIFormDataRequest.h"
#import "LPLabel.h"

@interface Intro_InterestsViewController : UIViewController {
    Global *global;
    __block ASIFormDataRequest *dataRequest;
    NSDictionary *responseData;
    
    UIBarButtonItem *saveButton;
    UIBarButtonItem *skipButton;
    NSString *configuration;
    NSMutableArray *selectedInterests;
    UIView *cardPile;
    UIView *card_1;
    UIView *card_2;
    UIView *card_3;
    UIImageView *cardPile_bg;
    UIImageView *cardPile_bottom;
    UIImageView *card_1_bg;
    UIImageView *card_2_bg;
    UIImageView *card_3_bg;
    UIButton *nextPageButton;
    UIButton *previousPageButton;
    LPLabel *pageCounter;
    int activePage;
}

@property (nonatomic, retain) NSString *configuration;

- (void)getTopicsForInterests;
- (void)skipIntro;
- (void)gotoNextPage;
- (void)gotoPreviousPage;
- (void)hidePaperBottoms;
- (void)showPaperBottoms;
- (void)toggleInterest:(id)sender;

@end
