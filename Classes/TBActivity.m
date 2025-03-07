#import "TBActivity.h"
#import "TipboxAppDelegate.h"

@implementation TBActivity

@synthesize TBActivityType, TBActivityTitle, TBActivityImage, data;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (NSString *)activityType
{
    return TBActivityType;
}

- (NSString *)activityTitle
{
    return TBActivityTitle;
}

- (UIImage *)activityImage
{
    return TBActivityImage;
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems
{
    return YES;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems
{
    for (id item in activityItems) {
        if ([item isKindOfClass:[NSString class]]) {
            
        } else if ([item isKindOfClass:[NSURL class]]) {
            
        } else {
            NSLog(@"Unknown item type %@", item);
        }
    }
}

- (void)performActivity
{
    if ([TBActivityType isEqualToString:@"TBActivityTypeCopyLinkToTip"]) {
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = data;
        
        [self activityDidFinish:YES]; // Cave Johnson here, we're done.
    }
}

- (void)dealloc
{
    [super dealloc];
}

@end
