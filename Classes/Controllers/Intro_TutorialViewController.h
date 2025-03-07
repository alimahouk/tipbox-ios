#import <UIKit/UIKit.h>
#import "Global.h"
#import "TipCard.h"

@interface Intro_TutorialViewController : UIViewController {
    Global *global;
    
    UIBarButtonItem *skipButton;
    UIButton *replayButton;
    TipCard *card;
    UIImageView *geniusIcon;
    UILabel *usefulnessMeter;
    NSInteger usefulCount;
    UILabel *welcomeLabel_1;
    UILabel *welcomeLabel_2;
    UILabel *finalWord;
    UIImageView *popover_1;
    UIImageView *popover_2;
    UIImageView *popover_3;
    UIImageView *popover_4;
    UIImageView *popover_5;
}

- (void)skipTutorial;
- (void)play;
- (void)triggerMarkUseful;
- (void)updateUsefulCount;

@end
