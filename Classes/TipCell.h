#import <UIKit/UIKit.h>
#import "Global.h"
#import "TipCardView.h"
#import "EGOImageView.h"
#import "ToggleButton.h"
#import "LPLabel.h"
#import "FacemashPhoto.h"

@interface TipCell : UITableViewCell {
    Global *global;
    
    TipCardView *tipCardView;
}

@property (nonatomic, retain) TipCardView *tipCardView;;

- (void)collapseCell;

@end
