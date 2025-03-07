#import "FollowerListViewController.h"
#import "TipboxAppDelegate.h"
#import "MeViewController.h"

#define MAIN_FONT_SIZE 18
#define MIN_MAIN_FONT_SIZE 15
#define SECONDARY_FONT_SIZE 12
#define MIN_SECONDARY_FONT_SIZE 10

@implementation FollowerListViewController

@synthesize topicid;

#pragma mark setTitle override
- (void)setTitle:(NSString *)title
{
    UILabel *titleView = (UILabel *)self.navigationItem.titleView;
    if (!titleView) {
        titleView = [[UILabel alloc] initWithFrame:CGRectZero];
        titleView.backgroundColor = [UIColor clearColor];
        titleView.font = [UIFont boldSystemFontOfSize:20.0];
        titleView.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
        titleView.shadowOffset = CGSizeMake(0, -1);
        
        titleView.textColor = [UIColor colorWithWhite:1.0 alpha:0.85]; // Change to desired color.
        
        self.navigationItem.titleView = titleView;
        [titleView release];
    }
    titleView.text = title;
    [titleView sizeToFit];
}

- (void)hudWasHidden:(MBProgressHUD *)hud
{
	// Remove HUD from screen when the HUD was hidden.
	[HUD removeFromSuperview];
	[HUD release];
	HUD = nil;
}

- (void)getFollowersForBatch:(int)batch
{
    TipboxAppDelegate *appDelegate = (TipboxAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.strobeLight activateStrobeLight];
    
    NSURL *apiurl = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/tipbox/api/getfollowers", SH_DOMAIN]];
    
    dataRequest_child = [[ASIFormDataRequest requestWithURL:apiurl] retain];
    [dataRequest_child setPostValue:[NSNumber numberWithInt:topicid] forKey:@"topicid"];
    [dataRequest_child setPostValue:[NSNumber numberWithInt:batch] forKey:@"batch"];
    [dataRequest_child setCompletionBlock:^{
        NSError *jsonError;
        responseData_child = [NSJSONSerialization JSONObjectWithData:[dataRequest_child.responseString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:&jsonError];
        
        if ([[responseData_child objectForKey:@"error"] intValue] == 0) {
            for (NSMutableDictionary *user in [responseData_child objectForKey:@"responce"]) {
                [self.feedEntries addObject:[user mutableCopy]];
            }
            
            if ([[responseData_child objectForKey:@"responce"] count] < BATCH_SIZE) {
                endOfFeed = YES;
            } else {
                endOfFeed = NO;
            }
            
            timelineDidDownload = YES;
            [timelineFeed reloadData];
            [appDelegate.strobeLight deactivateStrobeLight];
        } else {
            NSLog(@"Follow error!");
            
            if ([[responseData_child objectForKey:@"errormsg"] isEqualToString:@"authFail"]) {
                [self.navigationController popToRootViewControllerAnimated:YES];
                [appDelegate logoutWithMessage:@"Sorry, but you need to log in again!"];
            }
        }
        
    }];
    [dataRequest_child setFailedBlock:^{
        HUD = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:HUD];
        
        HUD.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cross_white.png"]] autorelease];
        
        // Set custom view mode.
        HUD.mode = MBProgressHUDModeCustomView;
        HUD.dimBackground = YES;
        HUD.delegate = self;
        HUD.labelText = @"Could not connect!";
        
        TipboxAppDelegate *appDelegate = (TipboxAppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate.strobeLight negativeStrobeLight];
        
        [loadMoreCell hideEndMarker];
        [loadMoreCell.button setTitle:@"Could not connect!" forState:UIControlStateDisabled];
        loadMoreCell.buttonTxtShadow.text = @"Could not connect!";
        loadMoreCell.userInteractionEnabled = NO;
        loadMoreCell.button.enabled = NO; // Don't forget to disable the button!
        
        [HUD show:YES];
        [HUD hide:YES afterDelay:3];
        
        NSError *error = [dataRequest_child error];
        NSLog(@"%@", error);
    }];
    [dataRequest_child startAsynchronous];
}

- (void)viewDidLoad
{
    TipboxAppDelegate *appDelegate = (TipboxAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate showNavbarShadowAnimated:YES];
    
    global = appDelegate.global;
    feedEntries = [[NSMutableArray alloc] init];
    
    [self setTitle:@"Followers"];
    
    [self getFollowersForBatch:0];
    [super viewDidLoad];
}

#pragma mark UITableViewDataSource
#define CELL_CONTENT_WIDTH 320.0f
#define CELL_CONTENT_MARGIN 5.0f
#define CELL_COLLAPSED_HEIGHT 87
#define MAIN_FONT_SIZE 18
#define MIN_MAIN_FONT_SIZE 15
#define SECONDARY_FONT_SIZE 12
#define MIN_SECONDARY_FONT_SIZE 10

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Add an object to the end of the array for the "Load more..." table cell.
    return [self.feedEntries count] + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Special cases:
	// 1: if search results count == 0, display a giant blank UITableViewCell, and disable user interaction.
	// 2: if last cell, display the "Load more" search results UITableViewCell.
    
    UITableViewCell *assembledCell;
    
    if (indexPath.row == [self.feedEntries count]) { // Special Case 2		
        static NSString *CellIdentifier = @"LoadMoreCell";
        loadMoreCell = (LoadMoreCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (loadMoreCell == nil) {
            loadMoreCell = [[[LoadMoreCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            loadMoreCell.selectionStyle = UITableViewCellSelectionStyleNone;
            loadMoreCell.frame = CGRectMake(0, 0, 320, loadMoreCell.frame.size.height);
            [loadMoreCell.button addTarget:self action:@selector(loadMoreFeedEntries) forControlEvents:UIControlEventTouchUpInside];
        }
        
        if (!timelineDidDownload) {
            [loadMoreCell hideEndMarker];
            [loadMoreCell.button setTitle:@"Loading..." forState:UIControlStateNormal];
            loadMoreCell.buttonTxtShadow.text = @"Loading...";
            loadMoreCell.userInteractionEnabled = NO;
            loadMoreCell.button.enabled = NO; // Don't forget to disable the button!
        } else {
            if ([self.feedEntries count] < BATCH_SIZE) {
                [loadMoreCell showEndMarker];
            } else {
                [loadMoreCell hideEndMarker];
                [loadMoreCell.button setTitle:@"Load more" forState:UIControlStateNormal];
                loadMoreCell.buttonTxtShadow.text = @"Load more";
                loadMoreCell.userInteractionEnabled = YES;
                loadMoreCell.button.enabled = YES; // Then don't forget to re-enable it!
            }
        }
        
        assembledCell = loadMoreCell;
        
    } else if (indexPath.row <= ([self.feedEntries count] - 1)) {
        
        if (timelineDidDownload) {
            static NSString *CellIdentifier = @"idCardCell";
            idCardCell = (IdCardCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            NSMutableDictionary *user = [self.feedEntries objectAtIndex:indexPath.row];
            
            if (idCardCell == nil) {
                idCardCell = [[[IdCardCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
                idCardCell.frame = CGRectMake(0, 0, 320, idCardCell.frame.size.height);
            }
            
            idCardCell.rowNumber = indexPath.row;
            [idCardCell populateCellWithContent:user];
            
            assembledCell = idCardCell;
        }
    }
    
    return assembledCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{	
    CGFloat height;
    
    if ([self.feedEntries count] > 0 && indexPath.row <= ([self.feedEntries count] - 1)) {
        NSMutableDictionary *user = [self.feedEntries objectAtIndex:indexPath.row];
        NSString *bio = [user objectForKey:@"bio"];
        
        if ([[NSNull null] isEqual:bio]) {
            bio = @"";
        }
        
        CGSize bioSize = [bio sizeWithFont:[UIFont fontWithName:@"HelveticaNeue" size:MIN_MAIN_FONT_SIZE] constrainedToSize:CGSizeMake(287, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];
        
        height = MAX(bioSize.height + 116, 60);
    } else {
        height = 50;
    }
    
    return height += (CELL_CONTENT_MARGIN * 2);
}

// Override to support row selection in the table view.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    IdCardCell *targetCell = (IdCardCell *)[tableView cellForRowAtIndexPath:indexPath];
        
    MeViewController *profileView = [[MeViewController alloc] 
                                     initWithNibName:@"MeView" 
                                     bundle:[NSBundle mainBundle]];
    
    profileView.profileOwnerUsername = targetCell.username;
    self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Followers" style:UIBarButtonItemStylePlain target:nil action:nil] autorelease];
    [self.navigationController pushViewController:profileView animated:YES];
    [profileView release];
    profileView = nil;
}

- (void)loadMoreFeedEntries
{
    [loadMoreCell.button setTitle:@"Loading..." forState:UIControlStateDisabled];
    loadMoreCell.buttonTxtShadow.text = @"Loading...";
    loadMoreCell.userInteractionEnabled = NO;
    loadMoreCell.button.enabled = NO; // Don't forget to disable the button!
    
    [self getFollowersForBatch:++batchNo];
}

#pragma mark Customizations when the view appears/disappears
- (void)viewWillAppear:(BOOL)animated
{
    TipboxAppDelegate *appDelegate = (TipboxAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (appDelegate.mainTabBarController.tabBar.hidden) {
        [appDelegate tabbarShadowMode_nobar];
    } else {
        [appDelegate tabbarShadowMode_tabbar];
    }
    
    [appDelegate navbarShadowMode_navbar];
    [appDelegate showNavbarShadowAnimated:YES];
    [appDelegate showTabbarShadowAnimated:YES];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    TipboxAppDelegate *appDelegate = (TipboxAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSArray *viewControllers = self.navigationController.viewControllers;
    
    if (viewControllers.count > 1 && [viewControllers objectAtIndex:viewControllers.count - 2] == self) { // View is disappearing because a new view controller was pushed onto the stack
        
        
    } else if ([viewControllers indexOfObject:self] == NSNotFound) { // View is disappearing because it was popped from the stack
        HUD.delegate = nil;
        [appDelegate.strobeLight deactivateStrobeLight];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


- (void)dealloc
{
    [feedEntries release];
    [super dealloc];
}

@end
