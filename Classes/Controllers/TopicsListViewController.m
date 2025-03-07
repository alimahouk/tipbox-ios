#import "TopicsListViewController.h"
#import "TipboxAppDelegate.h"
#import "TopicViewController.h"

#define MAIN_FONT_SIZE 18
#define MIN_MAIN_FONT_SIZE 15
#define SECONDARY_FONT_SIZE 12
#define MIN_SECONDARY_FONT_SIZE 10

@implementation TopicsListViewController

@synthesize listOwner, listOwnerUserid, listType, topicCount;

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

- (void)fetchTopicsForBatch:(int)batch
{
    TipboxAppDelegate *appDelegate = (TipboxAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if ([listType isEqualToString:@"topics"]) {
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/tipbox/api/getfollowedtopics", SH_DOMAIN]];
        
        [appDelegate.strobeLight activateStrobeLight];
        dataRequest_child = [[ASIFormDataRequest requestWithURL:url] retain];
        [dataRequest_child setPostValue:listOwnerUserid forKey:@"userid"];
        [dataRequest_child setPostValue:[NSNumber numberWithInt:batch] forKey:@"batch"];
        [dataRequest_child setCompletionBlock:^{
            NSError *jsonError;
            responseData_child = [NSJSONSerialization JSONObjectWithData:[dataRequest_child.responseString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:&jsonError];
            
            if ([[responseData_child objectForKey:@"error"] intValue] == 0 && ![[NSNull null] isEqual:[responseData_child objectForKey:@"responce"]]) {
                for (NSMutableDictionary *user in [responseData_child objectForKey:@"responce"]) {
                    [self.feedEntries addObject:[user mutableCopy]];
                }
                
                if ([[responseData_child objectForKey:@"responce"] count] < BATCH_SIZE) {
                    endOfFeed = YES;
                } else {
                    endOfFeed = NO;
                }
            } else {
                // Handle error.
                NSLog(@"\nERROR!\n======\n%@", self.responseData);
                endOfFeed = YES; // Null marks end of feed.
                
                if ([[responseData_child objectForKey:@"errormsg"] isEqualToString:@"authFail"]) {
                    [self.navigationController popToRootViewControllerAnimated:YES];
                    [appDelegate logoutWithMessage:@"Sorry, but you need to log in again!"];
                }
            }
            
            timelineDidDownload = YES;
            [timelineFeed reloadData];
            [appDelegate.strobeLight deactivateStrobeLight];
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
    } else if ([listType isEqualToString:@"genius"]) {
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/tipbox/api/gettopicsbygenius", SH_DOMAIN]];
        
        [appDelegate.strobeLight activateStrobeLight];
        dataRequest_child = [[ASIFormDataRequest requestWithURL:url] retain];        [dataRequest_child setPostValue:listOwnerUserid forKey:@"userid"];
        [dataRequest_child setCompletionBlock:^{
            NSError *jsonError;
            responseData_child = [NSJSONSerialization JSONObjectWithData:[dataRequest_child.responseString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:&jsonError];
            
            if ([[responseData_child objectForKey:@"error"] intValue] == 0 && ![[NSNull null] isEqual:[responseData_child objectForKey:@"responce"]]) {
                for (NSMutableDictionary *topic in [responseData_child objectForKey:@"responce"]) {
                    [self.feedEntries addObject:[topic mutableCopy]];  // IMPORTANT: MAKE A MUTABLE COPY!!! Spent an hour trying to figure this shit out. :@
                }
                
                if ([[responseData_child objectForKey:@"responce"] count] < BATCH_SIZE) {
                    endOfFeed = YES;
                } else {
                    endOfFeed = NO;
                }
            } else {
                // Handle error.
                NSLog(@"\nERROR!\n======\n%@", self.responseData);
                endOfFeed = YES; // Null marks end of feed.
                
                if ([[responseData_child objectForKey:@"errormsg"] isEqualToString:@"authFail"]) {
                    [self.navigationController popToRootViewControllerAnimated:YES];
                    [appDelegate logoutWithMessage:@"Sorry, but you need to log in again!"];
                }
            }
            
            timelineDidDownload = YES;
            [timelineFeed reloadData];
            [appDelegate.strobeLight deactivateStrobeLight];
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
}

- (void)confirmFollowAll
{
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"Confirmation"
                          message:@"Just making sure you didn't accidentally hit that button!" delegate:self
                          cancelButtonTitle:@"Cancel"
                          otherButtonTitles:@"Follow All", nil];
    alert.tag = 0;
    [alert show];
    [alert release];
}

- (void)followAllTopics
{
    TipboxAppDelegate *appDelegate = (TipboxAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (!appDelegate.SHToken || [appDelegate.SHToken isEqualToString:@""]) {
        [appDelegate logoutWithMessage:@"You need to log in before you can do that!"];
        
        return;
    }
    
    [appDelegate.strobeLight activateStrobeLight];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/tipbox/api/followalltopics", SH_DOMAIN]];
    
    dataRequest_child = [[ASIFormDataRequest requestWithURL:url] retain];
    [dataRequest_child setPostValue:appDelegate.SHToken forKey:@"token"];
    [dataRequest_child setPostValue:listOwnerUserid forKey:@"userid"];
    [dataRequest_child setCompletionBlock:^{
        NSError *jsonError;
        responseData_child = [NSJSONSerialization JSONObjectWithData:[dataRequest_child.responseString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:&jsonError];
        
        if ([[responseData_child objectForKey:@"error"] intValue] == 0) {
            followAllButton.enabled = NO;
            followAllButtonLabel.text = @"FOLLOWING ALL";
            
            HUD = [[MBProgressHUD alloc] initWithView:self.view];
            [self.view addSubview:HUD];
            
            HUD.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"check_white.png"]] autorelease];
            HUD.mode = MBProgressHUDModeCustomView; // Set custom view mode.
            HUD.labelText = @"Following All";
            HUD.dimBackground = YES;
            HUD.delegate = self;
            
            [HUD show:YES];
            [HUD hide:YES afterDelay:2];
        } else {
            if ([[responseData_child objectForKey:@"errormsg"] isEqualToString:@"authFail"]) {
                [self.navigationController popToRootViewControllerAnimated:YES];
                [appDelegate logoutWithMessage:@"Sorry, but you need to log in again!"];
            }
        }
        
        [appDelegate.strobeLight deactivateStrobeLight];
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
        
        [appDelegate.strobeLight negativeStrobeLight];
        
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
    timelineDidDownload = NO;
    feedEntries = [[NSMutableArray alloc] init];
    
    [self fetchTopicsForBatch:batchNo];
    
    UIImageView *tableHeaderBG = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"topicListHeader.png"]];
    tableHeaderBG.frame = CGRectMake(0, 0, 320, 45);
    
    UIImageView *tableHeaderIconView;
    
    UILabel *listDesc = [[UILabel alloc] initWithFrame:CGRectMake(28, 11, 180, 20)];
    listDesc.backgroundColor = [UIColor clearColor];
    listDesc.textColor = [UIColor colorWithRed:54.0/255.0 green:54.0/255.0 blue:54.0/255.0 alpha:1.0];
    listDesc.shadowColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    listDesc.shadowOffset = CGSizeMake(0, 1);
    listDesc.numberOfLines = 1;
    listDesc.minimumFontSize = 8.;
    listDesc.adjustsFontSizeToFitWidth = YES;
    listDesc.font = [UIFont fontWithName:@"Georgia" size:SECONDARY_FONT_SIZE];
    
    if ([listType isEqualToString:@"topics"]) {
        tableHeaderIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"topic.png"]];
        listDesc.text = [NSString stringWithFormat:@"%@ follows %d topic%@", listOwner, topicCount, topicCount == 1 ? @"" : @"s"];
        tableHeaderIconView.frame = CGRectMake(8, 13, 16, 16);
    } else if ([listType isEqualToString:@"genius"]) {
        tableHeaderIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"genius_star.png"]];
        listDesc.text = [NSString stringWithFormat:@"%@ is a genius in %d topic%@", listOwner, topicCount, topicCount == 1 ? @"" : @"s"];
        tableHeaderIconView.frame = CGRectMake(8, 13, 16, 16);
    }
    
    followAllButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    [followAllButton setBackgroundImage:[[UIImage imageNamed:@"quickfollow.png"] stretchableImageWithLeftCapWidth:7.0 topCapHeight:7.0] forState:UIControlStateNormal];
    [followAllButton setBackgroundImage:[[UIImage imageNamed:@"quickfollow_highlighted.png"] stretchableImageWithLeftCapWidth:7.0 topCapHeight:7.0] forState:UIControlStateHighlighted];
    [followAllButton addTarget:self action:@selector(confirmFollowAll) forControlEvents:UIControlEventTouchUpInside];
    followAllButton.adjustsImageWhenHighlighted = NO;
    followAllButton.frame = CGRectMake(210, -1, 100, 44);
    
    if (topicCount == 0 || [[global readProperty:@"userid"] isEqualToString:listOwnerUserid]) {
        followAllButton.hidden = YES;
    }
    
    followAllButtonLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, 90, 44)];
    followAllButtonLabel.backgroundColor = [UIColor clearColor];
    followAllButtonLabel.textColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    followAllButtonLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.4];
    followAllButtonLabel.shadowOffset = CGSizeMake(0, -1);
    followAllButtonLabel.textAlignment = UITextAlignmentCenter;
    followAllButtonLabel.numberOfLines = 1;
    followAllButtonLabel.minimumFontSize = 8.;
    followAllButtonLabel.adjustsFontSizeToFitWidth = YES;
    followAllButtonLabel.font = [UIFont boldSystemFontOfSize:SECONDARY_FONT_SIZE];
    followAllButtonLabel.text = @"FOLLOW ALL";
    
    [self.view addSubview:tableHeaderBG];
    [tableHeaderBG addSubview:tableHeaderIconView];
    [tableHeaderBG addSubview:listDesc];
    [followAllButton addSubview:followAllButtonLabel];
    [self.view addSubview:followAllButton];
    
    [tableHeaderBG release];
    [tableHeaderIconView release];
    [listDesc release];
    [super viewDidLoad];
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
    static NSString *CellIdentifier;
    int lastIndex = [self.feedEntries count] - 1;
    
    if (indexPath.row == [self.feedEntries count]) { // Special Case 2		
        CellIdentifier = @"LoadMoreCell";
		loadMoreCell = (LoadMoreCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (loadMoreCell == nil) {
            loadMoreCell = [[[LoadMoreCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            loadMoreCell.selectionStyle = UITableViewCellSelectionStyleNone;
            loadMoreCell.frame = CGRectMake(0, 0, 320, loadMoreCell.frame.size.height);
            [loadMoreCell.button addTarget:self action:@selector(loadMoreFeedEntries) forControlEvents:UIControlEventTouchUpInside];
        }
        
        if (!timelineDidDownload) {
            [loadMoreCell hideEndMarker];
            [loadMoreCell.button setTitle:@"Loading..." forState:UIControlStateDisabled];
            loadMoreCell.buttonTxtShadow.text = @"Loading...";
            loadMoreCell.userInteractionEnabled = NO;
            loadMoreCell.button.enabled = NO; // Don't forget to disable the button!
        } else {
            if (endOfFeed) {
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
        
    } else if (indexPath.row <= lastIndex && timelineDidDownload == YES) {
        CellIdentifier = @"TopicCell";
        topicCell = (TopicCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (topicCell == nil) {
            topicCell = [[[TopicCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            [topicCell.followButton addTarget:self action:@selector(followTopic:) forControlEvents:UIControlEventTouchUpInside];
            topicCell.showsFollowButton = YES;
        }
        
        NSMutableDictionary *topicData = [self.feedEntries objectAtIndex:indexPath.row];
        topicCell.rowNumber = indexPath.row;
        
        [topicCell populateCellWithContent:topicData];
        assembledCell = topicCell;
    }
    
    return assembledCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{	
    CGFloat height;
    int lastIndex = [self.feedEntries count] - 1;
    
    if ([self.feedEntries count] > 0 && indexPath.row <= lastIndex) {
        height = 100 + (CELL_CONTENT_MARGIN * 2);
    } else {
        height = 50 + (CELL_CONTENT_MARGIN * 2);
    }
    
    return height;
}

// Override to support row selection in the table view.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if (indexPath.row != [self.feedEntries count]) {
        TopicCell *targetCell = (TopicCell *)[tableView cellForRowAtIndexPath:indexPath];
        
        TopicViewController *topicView = [[TopicViewController alloc] 
                                          initWithNibName:@"TopicView" 
                                          bundle:[NSBundle mainBundle]];
        
        topicView.topicName = targetCell.content;
        topicView.viewTopicid = targetCell.topicid;
        self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Topics" style:UIBarButtonItemStylePlain target:nil action:nil] autorelease];
        [self.navigationController pushViewController:topicView animated:YES];
        [topicView release];
        topicView = nil;
    }
}

- (void)loadMoreFeedEntries
{
    [loadMoreCell.button setTitle:@"Loading..." forState:UIControlStateDisabled];
    loadMoreCell.buttonTxtShadow.text = @"Loading...";
    loadMoreCell.userInteractionEnabled = NO;
    loadMoreCell.button.enabled = NO; // Don't forget to disable the button!
    
    [self fetchTopicsForBatch:++batchNo];
}

#pragma mark Follow/Unfollow a topic
- (void)followTopic:(id)sender
{
    TipboxAppDelegate *appDelegate = (TipboxAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (!appDelegate.SHToken || [appDelegate.SHToken isEqualToString:@""]) {
        [appDelegate logoutWithMessage:@"You need to log in before you can do that!"];
        
        return;
    }
    
    [appDelegate.strobeLight activateStrobeLight];
    
    UIButton *button = (UIButton *)sender;
    TopicCell *targetCell = (TopicCell *)[[[button superview] superview] superview];
    BOOL userFollowsTopic = targetCell.followsTopic;
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/tipbox/api/followtopic", SH_DOMAIN]];
    
    [appDelegate.strobeLight activateStrobeLight];
    dataRequest_child = [[ASIFormDataRequest requestWithURL:url] retain];
    [dataRequest_child setPostValue:appDelegate.SHToken forKey:@"token"];
    [dataRequest_child setPostValue:[NSNumber numberWithInt:targetCell.topicid] forKey:@"topicid"];
    [dataRequest_child setCompletionBlock:^{
        NSError *jsonError;
        responseData_child = [NSJSONSerialization JSONObjectWithData:[dataRequest_child.responseString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:&jsonError];
        
        if ([[responseData_child objectForKey:@"error"] intValue] == 0) {
            [targetCell toggleFollowStatus];
            
            HUD = [[MBProgressHUD alloc] initWithView:self.view];
            [self.view addSubview:HUD];
            NSString *HUDImageName;
            
            if (userFollowsTopic) {
                HUDImageName = @"cross_white.png";
                HUD.labelText = @"Unfollowed";
            } else {
                HUDImageName = @"check_white.png";
                HUD.labelText = @"Following";
            }
            
            HUD.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:HUDImageName]] autorelease];
            HUD.mode = MBProgressHUDModeCustomView; // Set custom view mode.
            HUD.dimBackground = YES;
            HUD.delegate = self;
            
            [HUD show:YES];
            [HUD hide:YES afterDelay:2];
            
        } else {
            if ([[responseData_child objectForKey:@"errormsg"] isEqualToString:@"authFail"]) {
                [self.navigationController popToRootViewControllerAnimated:YES];
                [appDelegate logoutWithMessage:@"Sorry, but you need to log in again!"];
            }
        }
        
        [appDelegate.strobeLight deactivateStrobeLight];
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
        
        [appDelegate.strobeLight negativeStrobeLight];
        
        [HUD show:YES];
        [HUD hide:YES afterDelay:3];
        
        NSError *error = [dataRequest_child error];
        NSLog(@"%@", error);
    }];
    [dataRequest_child startAsynchronous];
}

#pragma UIAlertViewDelegate methods
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 0) {
        if (buttonIndex == 1) { // Follow all topics.
            [self followAllTopics];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


- (void)dealloc
{
    [feedEntries release];
    [followAllButton release];
    [followAllButtonLabel release];
    [super dealloc];
}

@end
