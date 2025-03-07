#import "UITableViewActionSheet.h"

@implementation UITableViewActionSheet

@synthesize indexPath;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)dealloc
{
    [indexPath release];
    [super dealloc];
}

@end
