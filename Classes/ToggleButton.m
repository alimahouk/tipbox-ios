#import "ToggleButton.h"

@implementation ToggleButton

@synthesize menuController, activated;

- (id)init
{
    self = [super init];
    if (self) {
        menuController = [UIMenuController sharedMenuController];
        
        self.activated = NO;
    }
    
    return self;
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

@end
