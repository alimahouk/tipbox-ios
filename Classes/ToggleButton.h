#import <UIKit/UIKit.h>

@interface ToggleButton : UIButton {
    UIMenuController *menuController;
    BOOL activated;
}

@property (nonatomic, retain) UIMenuController *menuController;
@property (nonatomic) BOOL activated;

@end
