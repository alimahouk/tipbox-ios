#import "Timeline.h"
#import "TipboxAppDelegate.h"
#import "FeedViewController.h"

@implementation Timeline

@synthesize dataRequest, responseData, feedEntries, timelineFeed;
@synthesize selectedIndexes, tapCount, tappedRow, lastTappedRow, feed_targetid;
@synthesize batchNo, endOfFeed;

- (void)downloadTimeline:(NSString *)type batch:(int)batch
{
    TipboxAppDelegate *appDelegate = (TipboxAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.strobeLight activateStrobeLight];
    
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/tipbox/api/%@", SH_DOMAIN, type]];
	dataRequest = [[ASIFormDataRequest requestWithURL:url] retain];
	[dataRequest setPostValue:appDelegate.SHToken forKey:@"token"];
    [dataRequest setPostValue:[NSNumber numberWithInt:batch] forKey:@"batch"];
    
    if ([type isEqualToString:@"gettipsbyuser"] || [type isEqualToString:@"gettipslikedbyuser"]) {
        [dataRequest setPostValue:[NSNumber numberWithInt:feed_targetid] forKey:@"userid"];
    }
    
    if ([type isEqualToString:@"gettipsbytopicid"]) {
        [dataRequest setPostValue:[NSNumber numberWithInt:feed_targetid] forKey:@"topicid"];
    }
    
    [dataRequest setCompletionBlock:^{
        if (dataRequest.responseString.length > 0 && ![[NSNull null] isEqual:dataRequest.responseString]) {
            NSError *jsonError;
            responseData = [[NSJSONSerialization JSONObjectWithData:[dataRequest.responseString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:&jsonError] retain];
            
            if ([[responseData objectForKey:@"error"] intValue] == 0 && ![[NSNull null] isEqual:[responseData objectForKey:@"responce"]]) {
                
                if (batchNo == 0) {
                    [self.feedEntries removeAllObjects];
                }
                
                for (NSMutableDictionary *tip in [self.responseData objectForKey:@"responce"]) {
                    [self.feedEntries addObject:[tip mutableCopy]];  // IMPORTANT: MAKE A MUTABLE COPY!!! Spent an hour trying to figure this shit out. :@
                }
                
                if ([[responseData objectForKey:@"responce"] count] < BATCH_SIZE) {
                    endOfFeed = YES;
                } else {
                    endOfFeed = NO;
                }
            } else {
                if (batchNo == 0) {
                    [self.feedEntries removeAllObjects];
                }
                
                if ([[responseData objectForKey:@"errormsg"] isEqualToString:@"authFail"] && ![appDelegate.SHToken isEqualToString:@""]) {
                    NSLog(@"%@", appDelegate.SHToken);
                    [self.navigationController popToRootViewControllerAnimated:YES];
                    [appDelegate logoutWithMessage:@"Sorry, but you need to log in again!"];
                }
                
                endOfFeed = YES; // Null marks end of feed.
                NSLog(@"\nERROR!\n======\n%@", self.responseData); // Handle error.
            }
            
            [self timelineDidFinishDownloading];
        }
    }];
    [dataRequest setFailedBlock:^{
        [self timelineFailedToDownload];
        
        NSError *error = [dataRequest error];
        NSLog(@"%@", error);
    }];
	[dataRequest startAsynchronous];
}

- (void)timelineDidFinishDownloading
{
    
}

- (void)timelineFailedToDownload
{

}

- (void)viewDidLoad
{
    lastTappedRow = -1; // Initialize this.
    batchNo = 0;
    endOfFeed = NO;
    
    timelineFeed.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_paper_texture.png"]];
	timelineFeed.separatorStyle = UITableViewCellSeparatorStyleNone;
    timelineFeed.showsVerticalScrollIndicator = NO; // Personally, I think it's just useless clutter.
    
    // I added a lil' nugget here: Swipe to the left to go to the tip.
    UISwipeGestureRecognizer *swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didSwipeTableViewCell:)];
    swipeGesture.direction = UISwipeGestureRecognizerDirectionLeft;
    [timelineFeed addGestureRecognizer:swipeGesture];
    
    [swipeGesture release];
    [super viewDidLoad];
}

- (BOOL)cellIsSelected:(NSIndexPath *)indexPath
{
    // Return whether the cell at the specified index path is selected or not.
	NSNumber *selectedIndex = [selectedIndexes objectForKey:indexPath];
	return selectedIndex == nil ? FALSE : [selectedIndex boolValue];
}

- (void)reloadTableViewDataSource
{
    
}

- (void)doneLoadingTableViewData
{
    
}

- (void)tapTimerFired:(NSTimer *)aTimer
{
    
}

- (void)loadMoreFeedEntries
{
    
}

- (void)didSwipeTableViewCell:(UIGestureRecognizer *)gestureRecognizer
{
    
}

- (void)markUseful:(id)sender
{
    
}

- (void)gotoTip:(id)sender
{
    
}

- (void)followTopicAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (void)handleTipSharingAtIndexPath:(NSIndexPath *)indexPath forButtonAtIndex:(int)buttonIndex
{
    
}

- (void)handleTipDeletionAtIndexPath:(NSIndexPath *)indexPath
{

}

- (void)handleTipCreationAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (void)handleTipReportingAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (void)gotoUser:(id)sender
{
    
}

- (void)showMoreTipOptions:(id)sender
{
    
}

- (void)showTipSharingOptions:(id)sender
{
    
}

- (void)showTipDeletionOptions:(id)sender
{
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc 
{
    [super dealloc];
}

@end
