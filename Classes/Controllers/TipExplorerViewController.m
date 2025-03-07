#import <QuartzCore/QuartzCore.h>
#import <Twitter/Twitter.h>
#import "TipExplorerViewController.h"
#import "TipboxAppDelegate.h"
#import "SCAppUtils.h"
#import "TipViewController.h"
#import "WebViewController.h"
#import "MeViewController.h"
#import "Publisher.h"
#import "ReportViewController.h"

#define MAIN_FONT_SIZE 18
#define MIN_MAIN_FONT_SIZE 15
#define SECONDARY_FONT_SIZE 12
#define MIN_SECONDARY_FONT_SIZE 10

@implementation TipExplorerViewController

@synthesize delegate, lowerToolbar, feedEntries_hot, feedEntries_recent, selectedIndexes_hot, selectedIndexes_recent;

- (void)dismissTipExplorer
{
    TipboxAppDelegate *appDelegate = (TipboxAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.strobeLight deactivateStrobeLight];
    [appDelegate hideTabbarShadowAnimated:NO];
    [appDelegate closeBoxWithConfiguration:@"explorer"];
    
    if (delegate && [delegate respondsToSelector:@selector(tipExplorerDidGetDismissed)]) {
        [delegate tipExplorerDidGetDismissed];
    } else {
        NSLog(@"Not Delegating. I don't know why. :/");
    }
}

- (void)dismissTipExplorerForLogin
{
    [self dismissTipExplorer];
}

- (void)dismissTipExplorerForSignup
{
    TipboxAppDelegate *appDelegate = (TipboxAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [self dismissTipExplorer];
    [appDelegate hideLoginFields];
    
    [NSTimer scheduledTimerWithTimeInterval:0.4
                                     target:self
                                   selector:@selector(signup)
                                   userInfo:nil
                                    repeats:NO];
}

- (void)signup
{
    TipboxAppDelegate *appDelegate = (TipboxAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate signup];
}

- (void)toggleFeedType:(id)sender
{
    UISegmentedControl *selectedSegment = (UISegmentedControl *)sender;
    
    if (selectedSegment.selectedSegmentIndex == 0) {
        if (!didDownloadTimeline_hot) {
            [self downloadTimeline:@"gethottips" batch:0];
        }
        
        activeSegmentIndex = 0;
        self.feedEntries = feedEntries_hot;
    } else if (selectedSegment.selectedSegmentIndex == 1) {
        if (!didDownloadTimeline_recent) {
            [self downloadTimeline:@"getrecenttips" batch:0];
        }
        
        activeSegmentIndex = 1;
        self.feedEntries = feedEntries_recent;
    }
    
    [timelineFeed reloadData];
    [timelineFeed scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO]; // Scroll back to top.
}

// Override this method. This view controller uses a different approach.
- (void)downloadTimeline:(NSString *)type batch:(int)batch
{
    TipboxAppDelegate *appDelegate = (TipboxAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.strobeLight activateStrobeLight];
    
    [loadMoreCell.button setTitle:@"Loading..." forState:UIControlStateNormal];
    loadMoreCell.buttonTxtShadow.text = @"Loading...";
    loadMoreCell.userInteractionEnabled = NO;
    loadMoreCell.button.enabled = NO; // Don't forget to disable the button!
    
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/tipbox/api/%@", SH_DOMAIN, type]];
	dataRequest = [[ASIFormDataRequest requestWithURL:url] retain];
    [dataRequest setPostValue:appDelegate.SHToken forKey:@"token"];
    [dataRequest setPostValue:[NSNumber numberWithInt:batch] forKey:@"batch"];
    [dataRequest setCompletionBlock:^{
        NSError *jsonError;
        self.responseData = [[NSJSONSerialization JSONObjectWithData:[dataRequest.responseString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:&jsonError] retain];
        
        if ([[self.responseData objectForKey:@"error"] intValue] == 0 && ![[NSNull null] isEqual:[self.responseData objectForKey:@"responce"]]) {
            
            if (batchNo == 0) {
                if (activeSegmentIndex == 0) {
                    [feedEntries_hot removeAllObjects];
                } else if (activeSegmentIndex == 1) {
                    [feedEntries_recent removeAllObjects];
                }
            }
            
            for (NSMutableDictionary *tip in [self.responseData objectForKey:@"responce"]) {
                if (activeSegmentIndex == 0) {
                    [feedEntries_hot addObject:[tip mutableCopy]];
                } else if (activeSegmentIndex == 1) {
                    [feedEntries_recent addObject:[tip mutableCopy]];
                }
            }
            
            if ([[self.responseData objectForKey:@"responce"] count] < BATCH_SIZE) {
                if (activeSegmentIndex == 0) {
                    endOfFeed_hot = YES; 
                } else if (activeSegmentIndex == 1) {
                    endOfFeed_recent = YES; 
                }
            } else {
                if (activeSegmentIndex == 0) {
                    endOfFeed_hot = NO; 
                } else if (activeSegmentIndex == 1) {
                    endOfFeed_recent = NO; 
                }
            }
        } else {
            if (batchNo == 0) {
                [self.feedEntries removeAllObjects];
            }
            
            // Null marks end of feed.
            if (activeSegmentIndex == 0) {
                endOfFeed_hot = YES; 
            } else if (activeSegmentIndex == 1) {
                endOfFeed_recent = YES;
            }
            
            NSLog(@"\nERROR!\n======\n%@", self.responseData); // Handle error.
            
            if ([[responseData_child objectForKey:@"errormsg"] isEqualToString:@"authFail"]) {
                [self.navigationController popToRootViewControllerAnimated:YES];
                [appDelegate logoutWithMessage:@"Sorry, but you need to log in again!"];
            }
        }
        
        if (activeSegmentIndex == 0) {
            didDownloadTimeline_hot = YES;
            
            // Saving an offline copy of the feed.
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
            NSString *libraryDirectory = [paths objectAtIndex:0];
            NSString *folderPath =  [libraryDirectory stringByAppendingPathComponent:@"TBFeedData"];
            NSString *filePath =  [folderPath stringByAppendingPathComponent:@"tips.txt"];
            BOOL isDir;
            
            if (batchNo <= 5) { // Only cache the 1st 5 batches.
                if (![fileManager fileExistsAtPath:folderPath isDirectory:&isDir]) {
                    NSError *dirWriteError = nil;
                    
                    if(![fileManager createDirectoryAtPath:folderPath withIntermediateDirectories:YES attributes:nil error:&dirWriteError])
                        NSLog(@"Error: failed to create folder!");
                }
                
                if ([NSKeyedArchiver archiveRootObject:self.feedEntries toFile:filePath]) {
                    NSLog(@"Successfully wrote feed to disk!");
                } else {
                    NSLog(@"Failed to write feed to disk!");
                }
            }
        } else if (activeSegmentIndex == 1) {
            didDownloadTimeline_recent = YES;
        }
        
        timelineDidDownload = YES;
        [timelineFeed reloadData];
        [self performSelector:@selector(doneLoadingTableViewData)];
        [appDelegate.strobeLight deactivateStrobeLight];
    }];
    [dataRequest setFailedBlock:^{
        HUD = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:HUD];
        
        HUD.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cross_white.png"]] autorelease];
        
        // Set custom view mode.
        HUD.mode = MBProgressHUDModeCustomView;
        HUD.dimBackground = YES;
        HUD.delegate = self;
        HUD.labelText = @"Could not connect!";
        
        [HUD show:YES];
        [HUD hide:YES afterDelay:3];
        
        [appDelegate.strobeLight negativeStrobeLight];
        [self performSelector:@selector(doneLoadingTableViewData)];
        
        [loadMoreCell hideEndMarker];
        [loadMoreCell.button setTitle:@"Could not connect!" forState:UIControlStateDisabled];
        loadMoreCell.buttonTxtShadow.text = @"Could not connect!";
        loadMoreCell.userInteractionEnabled = NO;
        loadMoreCell.button.enabled = NO; // Don't forget to disable the button!
        
        NSError *error = [dataRequest error];
        NSLog(@"%@", error);
    }];
	[dataRequest startAsynchronous];
}

- (void)hudWasHidden:(MBProgressHUD *)hud
{
	// Remove HUD from screen when the HUD was hidden.
	[HUD removeFromSuperview];
	[HUD release];
	HUD = nil;
}

- (void)viewDidLoad {
    // THIS FEED IS CACHED!
    
    TipboxAppDelegate *appDelegate = (TipboxAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate showNavbarShadowAnimated:YES];
    
    [SCAppUtils customizeNavigationController:self.navigationController];
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:192.0/255.0 green:133.0/255.0 blue:87.0/255.0 alpha:1.0];
    
    CGRect screenBound = [[UIScreen mainScreen] bounds];
    CGFloat screenHeight = screenBound.size.height;
    
    NSArray *segItemsArray = [NSArray arrayWithObjects:@"Hot", @"Recent", nil];
    segmentedControl = [[UISegmentedControl alloc] initWithItems:segItemsArray];
    segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
    [segmentedControl setWidth:100 forSegmentAtIndex:0];
    [segmentedControl setWidth:100 forSegmentAtIndex:1];
    activeSegmentIndex = 0;
    segmentedControl.selectedSegmentIndex = activeSegmentIndex;
    [segmentedControl addTarget:self action:@selector(toggleFeedType:) forControlEvents:UIControlEventValueChanged];
    
    self.navigationItem.titleView = (UIView *)segmentedControl;
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_paper_texture.png"]];
    
    loginButton = [[UIBarButtonItem alloc] initWithTitle:@"Login" style:UIBarButtonItemStyleBordered target:self action:@selector(dismissTipExplorerForLogin)];
    joinButton = [[UIBarButtonItem alloc] initWithTitle:@"Join" style:UIBarButtonItemStyleDone target:self action:@selector(dismissTipExplorerForSignup)];
    
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    UILabel *welcomeLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 0, 200, 44)];
    welcomeLabel.backgroundColor = [UIColor clearColor];
    welcomeLabel.textColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    welcomeLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:1.0];
    welcomeLabel.numberOfLines = 0;
    welcomeLabel.textAlignment = UITextAlignmentCenter;
    welcomeLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:SECONDARY_FONT_SIZE];
    welcomeLabel.text = @"Find, share, & leave your own tips.";
    
    lowerToolbar.items = @[joinButton, flexibleSpace, loginButton];
    
    // Public explorer.
    if (!appDelegate.SHToken || [appDelegate.SHToken isEqualToString:@""]) {
        timelineFeed.frame = CGRectMake(0, 0, 320, screenHeight - 110);
        timelineFeed.contentSize = CGSizeMake(320, screenHeight - 110);
    } else {
        lowerToolbar.hidden = YES;
    }
    
    selectedIndexes_hot = [[NSMutableDictionary alloc] init];
    selectedIndexes_recent = [[NSMutableDictionary alloc] init];
    feedEntries = [[NSMutableArray alloc] init];
    feedEntries_recent = [[NSMutableArray alloc] init];
    
    global = appDelegate.global;
    lastTappedRow_hot = -1;
    lastTappedRow_recent = -1;
    didDownloadTimeline_trending = NO;
    didDownloadTimeline_recent = NO;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *libraryDirectory = [paths objectAtIndex:0];
    NSString *filePath =  [libraryDirectory stringByAppendingPathComponent:@"TBFeedData/tips.txt"];
    
    NSMutableArray *savedFeed = [[NSKeyedUnarchiver unarchiveObjectWithFile:filePath] mutableCopy];
    
    if (savedFeed != nil) {
        feedEntries_hot = [[NSMutableArray alloc] initWithArray:savedFeed];
    } else {
        feedEntries_hot = [[NSMutableArray alloc] init];
    }
    
    self.feedEntries = feedEntries_hot;
    
    if ([feedEntries count] > 0) {
        timelineDidDownload = YES;
    } else {
        timelineDidDownload = NO;
    }
    
    if (refreshHeaderView == nil) {
		refreshHeaderView = [[EGORefreshTableHeaderView alloc] 
                             initWithFrame:CGRectMake(0, 0 - timelineFeed.bounds.size.height, self.view.frame.size.width, timelineFeed.bounds.size.height)];
		refreshHeaderView.delegate = self;
		[timelineFeed addSubview:refreshHeaderView];
	}
    
    [refreshHeaderView egoRefreshScrollViewDataSourceStartManualLoading:timelineFeed];
    
    [lowerToolbar addSubview:welcomeLabel];
    
    [flexibleSpace release];
    [welcomeLabel release];
    [super viewDidLoad];
}

#pragma mark Customizations when the view appears/disappears
- (void)viewWillAppear:(BOOL)animated
{
    TipboxAppDelegate *appDelegate = (TipboxAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate navbarShadowMode_navbar];
    
    if (!appDelegate.SHToken || [appDelegate.SHToken isEqualToString:@""]) {
        [appDelegate tabbarShadowMode_toolbar];
    } else {
        [appDelegate tabbarShadowMode_tabbar];
    }
    
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
    if (activeSegmentIndex == 0) {
        return [feedEntries_hot count] + 1;
    } else {
        return [feedEntries_recent count] + 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Special cases:
	// 1: if search results count == 0, display a giant blank UITableViewCell, and disable user interaction.
	// 2: if last cell, display the "Load more" search results UITableViewCell.
    
    UITableViewCell *assembledCell;
    static NSString *CellIdentifier;
    int lastIndex = [feedEntries count] - 1;
    
    if (indexPath.row == [self.feedEntries count]) { // Special Case 2		
		CellIdentifier = @"LoadMoreCell";
		loadMoreCell = (LoadMoreCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
		if (loadMoreCell == nil) {
            loadMoreCell = [[[LoadMoreCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            loadMoreCell.selectionStyle = UITableViewCellSelectionStyleNone;
            loadMoreCell.frame = CGRectMake(0, 0, 320, loadMoreCell.frame.size.height);
            [loadMoreCell.button addTarget:self action:@selector(loadMoreFeedEntries) forControlEvents:UIControlEventTouchUpInside];
		}
		
        if ((!didDownloadTimeline_hot && activeSegmentIndex == 0) || (!didDownloadTimeline_recent && activeSegmentIndex == 1)) {
            [loadMoreCell hideEndMarker];
            [loadMoreCell.button setTitle:@"Loading..." forState:UIControlStateDisabled];
            loadMoreCell.buttonTxtShadow.text = @"Loading...";
            loadMoreCell.userInteractionEnabled = NO;
            loadMoreCell.button.enabled = NO; // Don't forget to disable the button!
        } else {
            BOOL targetEndOfFeed = YES;
            
            if (activeSegmentIndex == 0) {
                targetEndOfFeed = endOfFeed_hot; 
            } else if (activeSegmentIndex == 1) {
                targetEndOfFeed = endOfFeed_recent; 
            }
            
            if (targetEndOfFeed) {
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
		
	} else {
        if (indexPath.row <= lastIndex && timelineDidDownload == YES) {
            CellIdentifier = @"TimelineCell";
            timelineCell = (TipCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            BOOL isSelected = [self cellIsSelected:indexPath];
            
            if (timelineCell == nil) {
                timelineCell = [[[TipCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
                timelineCell.frame = CGRectMake(0, 0, 320, timelineCell.frame.size.height);
                isSelected = NO;
                
                [timelineCell.tipCardView.facemash_1 addTarget:self action:@selector(gotoUser:) forControlEvents:UIControlEventTouchUpInside];
                [timelineCell.tipCardView.facemash_2 addTarget:self action:@selector(gotoUser:) forControlEvents:UIControlEventTouchUpInside];
                [timelineCell.tipCardView.facemash_3 addTarget:self action:@selector(gotoUser:) forControlEvents:UIControlEventTouchUpInside];
                [timelineCell.tipCardView.facemash_4 addTarget:self action:@selector(gotoUser:) forControlEvents:UIControlEventTouchUpInside];
                [timelineCell.tipCardView.facemash_5 addTarget:self action:@selector(gotoUser:) forControlEvents:UIControlEventTouchUpInside];
                [timelineCell.tipCardView.facemash_6 addTarget:self action:@selector(gotoUser:) forControlEvents:UIControlEventTouchUpInside];
                [timelineCell.tipCardView.facemash_7 addTarget:self action:@selector(gotoUser:) forControlEvents:UIControlEventTouchUpInside];
                [timelineCell.tipCardView.markUsefulButton addTarget:self action:@selector(markUseful:) forControlEvents:UIControlEventTouchUpInside];
                [timelineCell.tipCardView.pane_gotoTipButton addTarget:self action:@selector(gotoTip:) forControlEvents:UIControlEventTouchUpInside];
                [timelineCell.tipCardView.pane_gotoUserButton addTarget:self action:@selector(gotoUser:) forControlEvents:UIControlEventTouchUpInside];
                [timelineCell.tipCardView.pane_tipOptionsButton addTarget:self action:@selector(showMoreTipOptions:) forControlEvents:UIControlEventTouchUpInside];
                [timelineCell.tipCardView.pane_shareButton addTarget:self action:@selector(showTipSharingOptions:) forControlEvents:UIControlEventTouchUpInside];
                [timelineCell.tipCardView.pane_deleteButton addTarget:self action:@selector(showTipDeletionOptions:) forControlEvents:UIControlEventTouchUpInside];
            }
            
            timelineCell.tipCardView.isSelected = isSelected;
            timelineCell.tipCardView.rowNumber = indexPath.row;
            [timelineCell.tipCardView populateViewWithContent:[self.feedEntries objectAtIndex:indexPath.row]];
            
            assembledCell = timelineCell;
        }
    }
    
    return assembledCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{	
    CGFloat height;
    int lastIndex = [feedEntries count] - 1;
    
    if ([self.feedEntries count] > 0 && indexPath.row <= lastIndex && timelineDidDownload == YES) {
        NSMutableDictionary *tip = [self.feedEntries objectAtIndex:indexPath.row];
        int tipUserid = [[tip objectForKey:@"userid"] intValue];
        NSString *content = [tip objectForKey:@"content"];
        
        CGSize tipTxtSize;
        
        // Since the mark button is hidden, we might as well use up that otherwise wasted space. ;)
        if ([[global readProperty:@"userid"] intValue] == tipUserid) {
            tipTxtSize = [content sizeWithFont:[UIFont fontWithName:@"HelveticaNeue" size:MIN_MAIN_FONT_SIZE] constrainedToSize:CGSizeMake(288, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];
        } else {
            tipTxtSize = [content sizeWithFont:[UIFont fontWithName:@"HelveticaNeue" size:MIN_MAIN_FONT_SIZE] constrainedToSize:CGSizeMake(253, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];
        }
        
        if ([self cellIsSelected:indexPath]) {
            height = MAX(tipTxtSize.height + 255, 60);
        } else {
            height = MAX(tipTxtSize.height + 203 - CELL_COLLAPSED_HEIGHT, 60);
        }
    } else {
        height = 50;
    }
	
	return height + (CELL_CONTENT_MARGIN * 2);
}

// Override to support row selection in the table view.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:NO];
    int lastIndex = [feedEntries count] - 1;
    
    if ([feedEntries count] > 0 && indexPath.row <= lastIndex) {
        // NIFTY SHORTCUT (BELOW): Double-tap a tip to directly go to the tip view without bringing up the action card.
        // checking for double taps here
        if (activeSegmentIndex == 0) {
            tappedRow = tappedRow_hot;
        } else {
            tappedRow = tappedRow_recent;
        }
        
        if (tapCount == 1 && tapTimer != nil && tappedRow == indexPath.row) {
            // Double tap - Put double tap code here.
            [tapTimer invalidate];
            tapTimer = nil;
            
            if (activeSegmentIndex == 0) {
                doubleTapRow = tappedRow_hot;
            } else {
                doubleTapRow = tappedRow_recent;
            }
            
            TipCell *targetCell = (TipCell *)[tableView cellForRowAtIndexPath:indexPath];
            [targetCell.tipCardView.pane_gotoTipButton sendActionsForControlEvents:UIControlEventTouchUpInside];
            
            tapCount = 0;
            tappedRow_hot = -1;
            tappedRow_recent = -1;
        } else if (tapCount == 0) {
            // This is the first tap. If there is no tap till tapTimer is fired, it's a single tap.
            tapCount = 1;
            
            if (activeSegmentIndex == 0) {
                tappedRow_hot = indexPath.row;
            } else {
                tappedRow_recent = indexPath.row;
            }
            
            tapTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self 
                                                      selector:@selector(tapTimerFired:) 
                                                      userInfo:nil repeats:NO];
        } else if (tappedRow != indexPath.row) {
            // tap on new row
            tapCount = 0;
            if (tapTimer != nil) {
                [tapTimer invalidate];
                tapTimer = nil;
            }
        }
    }
}

// This method needs overriding in thie view controller.
- (BOOL)cellIsSelected:(NSIndexPath *)indexPath
{
    // Return whether the cell at the specified index path is selected or not.
    NSNumber *selectedIndex;
    
    if (activeSegmentIndex == 0) {
        selectedIndex = [selectedIndexes_hot objectForKey:indexPath];
    } else {
        selectedIndex = [selectedIndexes_recent objectForKey:indexPath];
    }
	
	return selectedIndex == nil ? FALSE : [selectedIndex boolValue];
}

- (void)tapTimerFired:(NSTimer *)aTimer
{
    // Timer fired! There was a single tap on indexPath.row = tappedRow.
    // Do something here with tappedRow.
    if (tapTimer != nil) {
        if (activeSegmentIndex == 0) { // Hot
            NSIndexPath *indexPath_tappedRow = [NSIndexPath indexPathForRow:tappedRow_hot inSection:0];
            NSIndexPath *indexPath_lastTappedRow = [NSIndexPath indexPathForRow:lastTappedRow_hot inSection:0];
            
            TipCell *cell = (TipCell *)[timelineFeed cellForRowAtIndexPath:indexPath_tappedRow];
            [cell collapseCell];
            
            // Toggle 'selected' state
            BOOL isSelected = ![self cellIsSelected:[NSIndexPath indexPathForRow:tappedRow_hot inSection:0]];
            
            // Store cell 'selected' state keyed on indexPath
            NSNumber *selectedIndex = [NSNumber numberWithBool:isSelected];
            [selectedIndexes_hot setObject:selectedIndex forKey:[NSIndexPath indexPathForRow:tappedRow_hot inSection:0]];
            cell.tipCardView.isSelected = isSelected;
            
            if (lastTappedRow_hot != tappedRow_hot) { // Collapse any other cell (unless if it's the same one, this will cause fuckage).
                TipCell *oldCell = (TipCell *)[timelineFeed cellForRowAtIndexPath:indexPath_lastTappedRow];
                
                NSNumber *oldIndex = [NSNumber numberWithBool:FALSE];
                [selectedIndexes_hot setObject:oldIndex forKey:indexPath_lastTappedRow];
                
                if (indexPath_lastTappedRow.row != [feedEntries count]) { // We don't want it sending wrong messages to the "Load more" cell.
                    [oldCell collapseCell];
                    oldCell.tipCardView.isSelected = FALSE;
                }
            }
            
            if (lastTappedRow_hot == tappedRow_hot) {
                lastTappedRow_hot = -1;
            } else {
                lastTappedRow_hot = tappedRow_hot;
            }
            
            tapCount = 0;
            tappedRow_hot = -1;
        } else { // Recent
            NSIndexPath *indexPath_tappedRow = [NSIndexPath indexPathForRow:tappedRow_recent inSection:0];
            NSIndexPath *indexPath_lastTappedRow = [NSIndexPath indexPathForRow:lastTappedRow_recent inSection:0];
            
            TipCell *cell = (TipCell *)[timelineFeed cellForRowAtIndexPath:indexPath_tappedRow];
            [cell collapseCell];
            
            // Toggle 'selected' state
            BOOL isSelected = ![self cellIsSelected:[NSIndexPath indexPathForRow:tappedRow_recent inSection:0]];
            
            // Store cell 'selected' state keyed on indexPath
            NSNumber *selectedIndex = [NSNumber numberWithBool:isSelected];
            [selectedIndexes_recent setObject:selectedIndex forKey:[NSIndexPath indexPathForRow:tappedRow_recent inSection:0]];
            cell.tipCardView.isSelected = isSelected;
            
            if (lastTappedRow_recent != tappedRow_recent) { // Collapse any other cell (unless if it's the same one, this will cause fuckage).
                TipCell *oldCell = (TipCell *)[timelineFeed cellForRowAtIndexPath:indexPath_lastTappedRow];
                
                NSNumber *oldIndex = [NSNumber numberWithBool:FALSE];
                [selectedIndexes_recent setObject:oldIndex forKey:indexPath_lastTappedRow];
                
                if (indexPath_lastTappedRow.row != [feedEntries count]) { // We don't want it sending wrong messages to the "Load more" cell.
                    [oldCell collapseCell];
                    oldCell.tipCardView.isSelected = FALSE;
                }
            }
            
            if (lastTappedRow_recent == tappedRow_recent) {
                lastTappedRow_recent = -1;
            } else {
                lastTappedRow_recent = tappedRow_recent;
            }
            
            tapCount = 0;
            tappedRow_recent = -1;
        }
        
        [timelineFeed beginUpdates];
        [timelineFeed endUpdates];
    }
}

- (void)didSwipeTableViewCell:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        CGPoint swipeLocation = [gestureRecognizer locationInView:timelineFeed];
        NSIndexPath *swipedIndexPath = [timelineFeed indexPathForRowAtPoint:swipeLocation];
        int lastIndex = [feedEntries count] - 1;
        
        if ([self.feedEntries count] > 0 && swipedIndexPath.row <= lastIndex && timelineDidDownload == YES) {
            TipCell *targetCell = (TipCell *)[timelineFeed cellForRowAtIndexPath:swipedIndexPath];
            [targetCell.tipCardView.pane_gotoTipButton sendActionsForControlEvents:UIControlEventTouchUpInside];
        }
    }
}

- (void)loadMoreFeedEntries
{
    [loadMoreCell.button setTitle:@"Loading..." forState:UIControlStateDisabled];
    loadMoreCell.buttonTxtShadow.text = @"Loading...";
    loadMoreCell.userInteractionEnabled = NO;
    loadMoreCell.button.enabled = NO; // Don't forget to disable the button!
    
    if (activeSegmentIndex == 0) {
        [self downloadTimeline:@"gethottips" batch:++batchNo];
    } else {
        [self downloadTimeline:@"getrecenttips" batch:++batchNo];
    }
}

#pragma mark Data Source Loading / Reloading Methods
- (void)reloadTableViewDataSource
{
    NSIndexPath *indexPath_lastTappedRow;
    
    if (activeSegmentIndex == 0) {
        indexPath_lastTappedRow = [NSIndexPath indexPathForRow:lastTappedRow_hot inSection:0];
    } else {
        indexPath_lastTappedRow = [NSIndexPath indexPathForRow:lastTappedRow_recent inSection:0];
    }
    
    TipCell *cell = (TipCell *)[timelineFeed cellForRowAtIndexPath:indexPath_lastTappedRow];
    
    if (cell.tipCardView.isSelected) {
        tapCount = 1;
        
        if (activeSegmentIndex == 0) {
            tappedRow_hot = indexPath_lastTappedRow.row;
        } else {
            tappedRow_recent = indexPath_lastTappedRow.row;
        }
        
        tapTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self 
                                                  selector:@selector(tapTimerFired:) 
                                                  userInfo:nil repeats:NO];
    }
    
    batchNo = 0;
    
    if (activeSegmentIndex == 0) {
        [self downloadTimeline:@"gethottips" batch:batchNo];
    } else if (activeSegmentIndex == 1) {
        [self downloadTimeline:@"getrecenttips" batch:batchNo];
    } else if (activeSegmentIndex == 2) {
        [self downloadTimeline:@"getrecenttips" batch:batchNo];
    }
    
    [loadMoreCell hideEndMarker];
    [loadMoreCell.button setTitle:@"Loading..." forState:UIControlStateDisabled];
    loadMoreCell.buttonTxtShadow.text = @"Loading...";
    loadMoreCell.userInteractionEnabled = NO;
    loadMoreCell.button.enabled = NO; // Don't forget to disable the button!
    
	reloading = YES;	
}

- (void)doneLoadingTableViewData
{
	//  Model should call this when its done loading
	reloading = NO;
	[refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:timelineFeed];
}

#pragma mark UIScrollViewDelegate Methods
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{	
	[refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
	[refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];	
}

#pragma mark EGORefreshTableHeaderDelegate Methods
- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView *)view
{
	[self reloadTableViewDataSource];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView *)view
{
	return reloading; // should return if data source model is reloading	
}

/*
 - (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView *)view
 {
 return [NSDate date]; // should return date data source was last changed	
 }
 */

- (void)markUseful:(id)sender
{
    TipboxAppDelegate *appDelegate = (TipboxAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (!appDelegate.SHToken || [appDelegate.SHToken isEqualToString:@""]) {
        [appDelegate logoutWithMessage:@"You need to log in before you can do that!"];
        
        return;
    }
    
    ToggleButton *markUsefulButton = (ToggleButton *)sender;
    TipCell *targetCell = (TipCell *)[[[[markUsefulButton superview] superview] superview] superview];
    NSIndexPath *indexPath = [timelineFeed indexPathForCell:targetCell];
    
    if (targetCell.tipCardView.marked == YES) {
        [markUsefulButton setBackgroundImage:[UIImage imageNamed:@"feed_useful_button.png"] forState:UIControlStateNormal];
        markUsefulButton.activated = NO;
        targetCell.tipCardView.marked = NO;
        [[self.feedEntries objectAtIndex:indexPath.row] setObject:@"NO" forKey:@"marked"]; // Modify our copy of the data.
        
        targetCell.tipCardView.usefulCount--;
    } else if (targetCell.tipCardView.marked == NO) {
        [markUsefulButton setBackgroundImage:[UIImage imageNamed:@"feed_useful_button_activated.png"] forState:UIControlStateNormal];
        markUsefulButton.activated = YES;
        targetCell.tipCardView.marked = YES;
        [targetCell.tipCardView playMarkingAnimation];
        [[self.feedEntries objectAtIndex:indexPath.row] setObject:@"YES" forKey:@"marked"]; // Modify our copy of the data.
        
        targetCell.tipCardView.usefulCount++;
    }
    
    [targetCell.tipCardView redisplayUsefulnessData];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/tipbox/api/liketip", SH_DOMAIN]];
    
    dataRequest_child = [[ASIFormDataRequest requestWithURL:url] retain];
    [dataRequest_child setPostValue:appDelegate.SHToken forKey:@"token"];
    [dataRequest_child setPostValue:[NSNumber numberWithInt:targetCell.tipCardView.tipid] forKey:@"tipid"];
    [dataRequest_child setCompletionBlock:^{
        NSError *jsonError;
        responseData_child = [NSJSONSerialization JSONObjectWithData:[dataRequest_child.responseString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:&jsonError];
        
        if ([[responseData_child objectForKey:@"error"] intValue] == 0) {
            
        } else {
            // Revert the button's state.
            if (targetCell.tipCardView.marked == YES) {
                [markUsefulButton setBackgroundImage:[UIImage imageNamed:@"feed_useful_button.png"] forState:UIControlStateNormal];
                markUsefulButton.activated = NO;
                targetCell.tipCardView.marked = NO;
                [[self.feedEntries objectAtIndex:indexPath.row] setObject:@"NO" forKey:@"marked"]; // Modify our copy of the data.
                
                targetCell.tipCardView.usefulCount--;
            } else if (targetCell.tipCardView.marked == NO) {
                [markUsefulButton setBackgroundImage:[UIImage imageNamed:@"feed_useful_button_activated.png"] forState:UIControlStateNormal];
                markUsefulButton.activated = YES;
                targetCell.tipCardView.marked = YES;
                [[self.feedEntries objectAtIndex:indexPath.row] setObject:@"YES" forKey:@"marked"]; // Modify our copy of the data.
                
                targetCell.tipCardView.usefulCount++;
            }
            
            [targetCell.tipCardView redisplayUsefulnessData];
            
            NSLog(@"Could not mark/unmark tip!\nError:\n%@", dataRequest_child.responseString);
            [appDelegate.strobeLight negativeStrobeLight];
            
            if ([[responseData_child objectForKey:@"errormsg"] isEqualToString:@"authFail"]) {
                [self.navigationController popToRootViewControllerAnimated:YES];
                [appDelegate logoutWithMessage:@"Sorry, but you need to log in again!"];
            }
        }
    }];
    [dataRequest_child setFailedBlock:^{
        [appDelegate.strobeLight negativeStrobeLight];
        
        // Revert the button's state.
        if (targetCell.tipCardView.marked == YES) {
            [markUsefulButton setBackgroundImage:[UIImage imageNamed:@"feed_useful_button.png"] forState:UIControlStateNormal];
            markUsefulButton.activated = NO;
            targetCell.tipCardView.marked = NO;
            [[self.feedEntries objectAtIndex:indexPath.row] setObject:@"NO" forKey:@"marked"]; // Modify our copy of the data.
            
            targetCell.tipCardView.usefulCount--;
        } else if (targetCell.tipCardView.marked == NO) {
            [markUsefulButton setBackgroundImage:[UIImage imageNamed:@"feed_useful_button_activated.png"] forState:UIControlStateNormal];
            markUsefulButton.activated = YES;
            targetCell.tipCardView.marked = YES;
            [[self.feedEntries objectAtIndex:indexPath.row] setObject:@"YES" forKey:@"marked"]; // Modify our copy of the data.
            
            targetCell.tipCardView.usefulCount++;
        }
        
        [targetCell.tipCardView redisplayUsefulnessData];
        
        NSError *error = [dataRequest_child error];
        NSLog(@"%@", error);
    }];
    [dataRequest_child startAsynchronous];
}

- (void)gotoTip:(id)sender
{
    UIButton *gotoTipButton = (UIButton *)sender;
    TipCell *targetCell = (TipCell *)[[[[[[gotoTipButton superview] superview] superview] superview] superview] superview];
    NSIndexPath *indexPath = [timelineFeed indexPathForCell:targetCell];
    int tipid = targetCell.tipCardView.tipid;
    NSString *content = targetCell.tipCardView.content;
    NSString *name = targetCell.tipCardView.fullname;
    NSString *username = targetCell.tipCardView.username;
    int userid = targetCell.tipCardView.tipUserid;
    NSString *userPicHash = targetCell.tipCardView.userPicHash;
    NSString *timestamp = targetCell.tipCardView.timestamp;
    NSString *timestamp_short = targetCell.tipCardView.timestamp_short;
    NSString *actualTime = targetCell.tipCardView.actualTime;
    int usefulCount = targetCell.tipCardView.usefulCount;
    NSMutableArray *participantData = targetCell.tipCardView.participantData;
    int catid = targetCell.tipCardView.catid;
    NSString *subcat = targetCell.tipCardView.subcat;
    NSString *parentCat = targetCell.tipCardView.parentCat;
    int topicid = targetCell.tipCardView.topicid;
    NSString *topicContent = targetCell.tipCardView.topicContent;
    BOOL followsTopic = targetCell.tipCardView.followsTopic;
    int genius = targetCell.tipCardView.genius;
    
    // Initialize the detail view controller and display it.
    TipViewController *tipView = [[TipViewController alloc] 
                                  initWithNibName:@"TipView" 
                                  bundle:[NSBundle mainBundle]];
    
    tipView.motherCellIndexPath = indexPath;
    tipView.tipid = tipid;
    tipView.tipUserid = userid;
    tipView.subcat = subcat;
    tipView.parentCat = parentCat;
    tipView.catid = catid;
    tipView.topicid = topicid;
    tipView.topicContent = topicContent;
    tipView.userFollowsTopic = followsTopic;
    tipView.tipFullName = name;
    tipView.tipUsername = username;
    tipView.tipUserPicHash = userPicHash;
    tipView.content = content;
    tipView.tipTimestamp = timestamp;
    tipView.tipTimestamp_short = timestamp_short;
    tipView.tipActualTime = actualTime;
    tipView.usefulCount = usefulCount;
    tipView.participantData = participantData;
    tipView.marked = targetCell.tipCardView.marked;
    tipView.genius = genius;
	
    self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Tips" style:UIBarButtonItemStylePlain target:nil action:nil] autorelease];
	[self.navigationController pushViewController:tipView animated:YES];
	[tipView release];
	tipView = nil;
}

#pragma mark Follow/Unfollow the topic of the tip
- (void)followTopicAtIndexPath:(NSIndexPath *)indexPath
{
    TipboxAppDelegate *appDelegate = (TipboxAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (!appDelegate.SHToken || [appDelegate.SHToken isEqualToString:@""]) {
        [appDelegate logoutWithMessage:@"You need to log in before you can do that!"];
        
        return;
    }
    
    TipCell *targetCell = (TipCell *)[timelineFeed cellForRowAtIndexPath:indexPath];
    BOOL userFollowsTipTopic = targetCell.tipCardView.followsTopic;
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/tipbox/api/followtopic", SH_DOMAIN]];
    
    [appDelegate.strobeLight activateStrobeLight];
    dataRequest_child = [[ASIFormDataRequest requestWithURL:url] retain];
    [dataRequest_child setPostValue:appDelegate.SHToken forKey:@"token"];
    [dataRequest_child setPostValue:[NSNumber numberWithInt:targetCell.tipCardView.topicid] forKey:@"topicid"];
    [dataRequest_child setCompletionBlock:^{
        NSError *jsonError;
        responseData_child = [NSJSONSerialization JSONObjectWithData:[dataRequest_child.responseString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:&jsonError];
        
        if ([[responseData_child objectForKey:@"error"] intValue] == 0) {
            HUD = [[MBProgressHUD alloc] initWithView:self.view];
            [self.view addSubview:HUD];
            NSString *HUDImageName;
            
            if (userFollowsTipTopic) {
                targetCell.tipCardView.followsTopic = 0;
                
                HUDImageName = @"cross_white.png";
                HUD.labelText = @"Unfollowed";
            } else {
                targetCell.tipCardView.followsTopic = 1;
                
                HUDImageName = @"check_white.png";
                HUD.labelText = @"Following";
            }
            
            HUD.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:HUDImageName]] autorelease];
            HUD.mode = MBProgressHUDModeCustomView; // Set custom view mode.
            HUD.dimBackground = YES;
            HUD.delegate = self;
            
            [HUD show:YES];
            [HUD hide:YES afterDelay:2];
            [appDelegate.strobeLight deactivateStrobeLight];
        } else {
            NSLog(@"Could not follow/unfollow topic!\nError:\n%@", dataRequest_child.responseString);
            [appDelegate.strobeLight negativeStrobeLight];
            
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
        
        [appDelegate.strobeLight negativeStrobeLight];
        
        [HUD show:YES];
        [HUD hide:YES afterDelay:3];
        
        NSError *error = [dataRequest_child error];
        NSLog(@"%@", error);
    }];
    [dataRequest_child startAsynchronous];
}

#pragma mark Handle the tip sharing options
- (void)handleTipSharingAtIndexPath:(NSIndexPath *)indexPath forButtonAtIndex:(NSInteger)buttonIndex
{
    TipboxAppDelegate *appDelegate = (TipboxAppDelegate *)[[UIApplication sharedApplication] delegate];
    TipCell *targetCell = (TipCell *)[timelineFeed cellForRowAtIndexPath:indexPath];
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    NSString *content = targetCell.tipCardView.content;
    
    if (buttonIndex == 0) {         // Copy Tip
        pasteboard.string = content;
    } else if (buttonIndex == 1) {  // Copy Link to Tip
        pasteboard.string = [NSString stringWithFormat:@"http://%@/tipbox/tip/%d", SH_DOMAIN, targetCell.tipCardView.tipid];
    } else if (buttonIndex == 2) {  // Mail Tip
        MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
        picker.mailComposeDelegate = self;
        
        NSString *emailBody = [NSString stringWithFormat:
                               @"<strong>%@</strong> <span style='color:#777;'>(@%@)</span> shared this tip on <em>%@</em> with you!<br /><br />“%@”<br /><br /><em style='color:#777;'>(Source on Tipbox: <a href=\"http://%@/tipbox/tip/%d\" style='color:#0073b9;text-decoration:none;'>http://%@/tipbox/tip/%d</a>)</em>", 
                               targetCell.tipCardView.fullname,
                               targetCell.tipCardView.username,
                               targetCell.tipCardView.topicContent,
                               content, 
                               SH_DOMAIN, 
                               targetCell.tipCardView.tipid, 
                               SH_DOMAIN, 
                               targetCell.tipCardView.tipid]; // Fill out the email body text.
        [picker setSubject:[NSString stringWithFormat:@"A tip on %@ • Tipbox", targetCell.tipCardView.topicContent]];
        [picker setMessageBody:emailBody isHTML:YES]; // Depends. Mostly YES, unless you want to send it as plain text (boring).
        
        picker.navigationBar.tintColor = [UIColor colorWithRed:162/255.0 green:165/255.0 blue:152/255.0 alpha:1.0];
        
        [appDelegate navbarShadowMode_navbar];
        [appDelegate tabbarShadowMode_nobar];
        [self presentModalViewController:picker animated:YES];
        [picker release];
    } else if (buttonIndex == 3) {  // Facebook
        if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
            SLComposeViewController *fbController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
            NSString *previewTxt = targetCell.tipCardView.content;
            
            SLComposeViewControllerCompletionHandler __block completionHandler=^(SLComposeViewControllerResult result) {
                [fbController dismissViewControllerAnimated:YES completion:nil];
                
                switch(result) {
                    case SLComposeViewControllerResultCancelled:
                    default:
                    {
                        NSLog(@"Cancelled!");
                        
                    }
                        break;
                    case SLComposeViewControllerResultDone:
                    {
                        NSLog(@"Posted!");
                    }
                        break;
                }};
            
            [fbController setInitialText:[NSString stringWithFormat:@"%@ (via Tipbox)", previewTxt]];
            [fbController addURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@/tipbox/tip/%d", SH_DOMAIN, targetCell.tipCardView.tipid]]];
            [fbController setCompletionHandler:completionHandler];
            [self presentViewController:fbController animated:YES completion:nil];
        } else {
            FBSBJSON *jsonWriter = [[FBSBJSON new] autorelease];
            
            NSMutableDictionary *params;
            
            // Dialog parameters
            if (!appDelegate.SHToken || [appDelegate.SHToken isEqualToString:@""]) {
                params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                               @"A tip on Tipbox", @"name",
                                               @"Tipbox is tip sharing, reinvented for your iPhone.", @"caption",
                                               targetCell.tipCardView.content, @"description",
                                               [NSString stringWithFormat:@"http://%@/tipbox/tip/%d", SH_DOMAIN, targetCell.tipCardView.tipid], @"link",
                                               @"http://scapehouse.com/graphics/en/icons/tipbox_icon_medium.png", @"picture",
                                               nil];
            } else {
                NSArray* actionLinks = [NSArray arrayWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                  [NSString stringWithFormat:@"@%@ on Tipbox", [global readProperty:@"username"]], @"name", @"http://scapehouse.com/", @"link", nil], nil];
                NSString *actionLinksStr = [jsonWriter stringWithObject:actionLinks];
                
                params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                               [NSString stringWithFormat:@"%@ shared a tip on Tipbox",  [global readProperty:@"name"]], @"name",
                                               @"Tipbox is tip sharing, reinvented for your iPhone.", @"caption",
                                               targetCell.tipCardView.content, @"description",
                                               [NSString stringWithFormat:@"http://%@/tipbox/tip/%d", SH_DOMAIN, targetCell.tipCardView.tipid], @"link",
                                               @"http://scapehouse.com/graphics/en/icons/tipbox_icon_medium.png", @"picture",
                                               actionLinksStr, @"actions",
                                               nil];
            }
            
            [appDelegate.facebook dialog:@"feed"
                               andParams:params
                             andDelegate:self];
        }
    } else if (buttonIndex == 4) {  // Tweet
        TWTweetComposeViewController *tweetSheet = [[TWTweetComposeViewController alloc] init]; // Create the tweet sheet.
        NSString *previewTxt = targetCell.tipCardView.content;
        
        if (previewTxt.length > 69) {
            previewTxt = [NSString stringWithFormat:@"%@… #Tipbox (by @Scapehouse)", [previewTxt substringToIndex:68]];
        } else {
            previewTxt = [NSString stringWithFormat:@"%@ #Tipbox (by @Scapehouse)", previewTxt];
        }
        
        [tweetSheet setInitialText:previewTxt];
        [tweetSheet addURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@/tipbox/tip/%d", SH_DOMAIN, targetCell.tipCardView.tipid]]];
        
        tweetSheet.completionHandler = ^(TWTweetComposeViewControllerResult result) { // Set a blocking handler for the tweet sheet.
            dispatch_async(dispatch_get_main_queue(), ^{            
                [self dismissViewControllerAnimated:YES completion:^{
                    
                }];
            });
        };
        
        // Show the tweet sheet!
        [self presentModalViewController:tweetSheet animated:YES];
        [tweetSheet release];
    } else if (buttonIndex == 5) { // Message
        if ([MFMessageComposeViewController canSendText]) {
            MFMessageComposeViewController *picker = [[MFMessageComposeViewController alloc] init];
            picker.messageComposeDelegate = self;
            
            NSString *messageBody = [NSString stringWithFormat:@"%@ (Source on Tipbox: http://%@/tipbox/tip/%d)", content, SH_DOMAIN, targetCell.tipCardView.tipid]; // Fill out the body text.
            [picker setBody:messageBody];
            
            picker.navigationBar.tintColor = [UIColor colorWithRed:162/255.0 green:165/255.0 blue:152/255.0 alpha:1.0];
            
            [appDelegate navbarShadowMode_navbar];
            [appDelegate tabbarShadowMode_nobar];
            [self presentModalViewController:picker animated:YES];
            [picker release];
        }
    }
}

#pragma mark Dismiss message composer
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    switch (result)
    {
        case MessageComposeResultCancelled:
            break;
        case MessageComposeResultSent:
            break;
        case MessageComposeResultFailed:
            break;
            
        default:
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message Status" message:@"Sending Failed - Unknown Error"
                                                           delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
            [alert release];
        }
            
            break;
    }
    
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark Dismiss mail composer
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{ 
    // Notifies users about errors associated with the interface
    switch (result)
    {
        case MFMailComposeResultCancelled:
            break;
        case MFMailComposeResultSaved:
            break;
        case MFMailComposeResultSent:
            break;
        case MFMailComposeResultFailed:
            break;
            
        default:
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Email Status" message:@"Sending Failed - Unknown Error"
                                                           delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
            [alert release];
        }
            
            break;
    }
    
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark Handle tip deletion
- (void)handleTipDeletionAtIndexPath:(NSIndexPath *)indexPath
{
    // We have to deselct the cell before deleting it, otherwise the next cell opens up when this one's gone.
    // The code here's basically the same as the one handling a single tap on it to collapse it.
    TipCell *targetCell = (TipCell *)[timelineFeed cellForRowAtIndexPath:indexPath];
    
    tapCount = 1;
    
    if (activeSegmentIndex == 0) {
        tappedRow_hot = indexPath.row;
    } else {
        tappedRow_recent = indexPath.row;
    }
    
    tapTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self 
                                              selector:@selector(tapTimerFired:) 
                                              userInfo:nil repeats:NO];
    
    TipboxAppDelegate *appDelegate = (TipboxAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.strobeLight activateStrobeLight];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/tipbox/api/deletetip", SH_DOMAIN]];
    
    dataRequest_child = [[ASIFormDataRequest requestWithURL:url] retain];
    [dataRequest_child setPostValue:appDelegate.SHToken forKey:@"token"];
    [dataRequest_child setPostValue:[NSNumber numberWithInt:targetCell.tipCardView.tipid] forKey:@"tipid"];
    [dataRequest_child setCompletionBlock:^{
        NSError *jsonError;
        responseData_child = [NSJSONSerialization JSONObjectWithData:[dataRequest_child.responseString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:&jsonError];
        
        if ([[responseData_child objectForKey:@"error"] intValue] == 0) {
            [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                [targetCell.tipCardView.card setFrame:CGRectMake(targetCell.tipCardView.card.frame.origin.x - targetCell.tipCardView.card.frame.size.width, targetCell.tipCardView.card.frame.origin.y, targetCell.tipCardView.card.frame.size.width, targetCell.tipCardView.card.frame.size.height)];
                targetCell.tipCardView.card.alpha = 0;
            } completion:^(BOOL finished){
                [feedEntries removeObjectAtIndex:indexPath.row];
                [timelineFeed deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                [timelineFeed reloadData];
                
                // Reset other cards on this index path.
                [UIView animateWithDuration:0.5 delay:0.4 options:UIViewAnimationOptionCurveEaseIn animations:^{
                    [targetCell.tipCardView.card setFrame:CGRectMake(targetCell.tipCardView.card.frame.origin.x + targetCell.tipCardView.card.frame.size.width, targetCell.tipCardView.card.frame.origin.y, targetCell.tipCardView.card.frame.size.width, targetCell.tipCardView.card.frame.size.height)];
                    targetCell.tipCardView.card.alpha = 1;
                } completion:^(BOOL finished){
                    
                }];
            }];
            
            [appDelegate.strobeLight deactivateStrobeLight];
        } else {
            NSLog(@"Could not delete tip!\nError:\n%@", dataRequest_child.responseString);
            [appDelegate.strobeLight negativeStrobeLight];
            
            if ([[responseData_child objectForKey:@"errormsg"] isEqualToString:@"authFail"]) {
                [self.navigationController popToRootViewControllerAnimated:YES];
                [appDelegate logoutWithMessage:@"Sorry, but you need to log in again!"];
            }
        }
    }];
    [dataRequest_child setFailedBlock:^{
        NSError *error = [dataRequest_child error];
        NSLog(@"%@", error);
    }];
    [dataRequest_child startAsynchronous];
}

#pragma mark Handle creating a tip on the topic of the cell
- (void)handleTipCreationAtIndexPath:(NSIndexPath *)indexPath
{
    // Collapse the cell first.
    // The code here's basically the same as the one handling a single tap on it to collapse it.
    TipCell *targetCell = (TipCell *)[timelineFeed cellForRowAtIndexPath:indexPath];
    
    tapCount = 1;
    
    if (activeSegmentIndex == 0) {
        tappedRow_hot = indexPath.row;
    } else {
        tappedRow_recent = indexPath.row;
    }
    
    tapTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self 
                                              selector:@selector(tapTimerFired:) 
                                              userInfo:nil repeats:NO];
    
    TipboxAppDelegate *appDelegate = (TipboxAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (!appDelegate.SHToken || [appDelegate.SHToken isEqualToString:@""]) {
        [appDelegate logoutWithMessage:@"You need to log in before you can do that!"];
        
        return;
    }
    
    int topicid = targetCell.tipCardView.topicid;
    NSString *topicContent = targetCell.tipCardView.topicContent;
    NSString *subcat = targetCell.tipCardView.subcat;
    int catid = targetCell.tipCardView.catid;
    int category;
    
    if ([targetCell.tipCardView.parentCat isEqualToString:@"thing"]) {
        category = 0;
    } else if ([targetCell.tipCardView.parentCat isEqualToString:@"place"]) {
        category = 1;
    } else {
        category = 2;
    }
    
    if ([subcat isEqualToString:@"none"]) {
        subcat = @"This category doesn't need a subcategory.";
    }
    
    appDelegate.mainTabBarController.tabBar.hidden = YES;
    [appDelegate navbarShadowMode_navbar];
    [appDelegate tabbarShadowMode_nobar];
    [appDelegate showNavbarShadowAnimated:YES];
    [appDelegate showTabbarShadowAnimated:YES];
    
    Publisher *pub = [[Publisher alloc] init];
    UINavigationController *publisherNavigationController = [[UINavigationController alloc] initWithRootViewController:pub];
    pub.category = category;
    pub.topicid = topicid;
    pub.topic = topicContent;
    [appDelegate.mainTabBarController presentModalViewController:publisherNavigationController animated:true];
    pub.subcategory = catid;
    pub.selectedCategoryButtonSubtitle.text = subcat;
	[pub release];
    [publisherNavigationController release];
}

#pragma mark Handle tip reporting
- (void)handleTipReportingAtIndexPath:(NSIndexPath *)indexPath
{
    TipboxAppDelegate *appDelegate = (TipboxAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (!appDelegate.SHToken || [appDelegate.SHToken isEqualToString:@""]) {
        [appDelegate logoutWithMessage:@"You need to log in before you can do that!"];
        
        return;
    }
    
    TipCell *targetCell = (TipCell *)[timelineFeed cellForRowAtIndexPath:indexPath];
    int tipid = targetCell.tipCardView.tipid;
    
    ReportViewController *reportView = [[ReportViewController alloc] initWithNibName:@"ReportView" bundle:nil];
    reportView.reportType = @"tip";
    reportView.objectid = tipid;
    [self presentModalViewController:reportView animated:true];
    [reportView release];
}

/* * * * * * * * * * * * * * * * * * *
 * TAG REFERENCE
 * =============
 * 10: Tip details Pane: Facemash 1.
 * 20: Tip details Pane: Facemash 2.
 * 30: Tip details Pane: Facemash 3.
 * 40: Tip details Pane: Facemash 4.
 * 50: Tip details Pane: Facemash 5.
 * 60: Tip details Pane: Facemash 6.
 * 70: Tip details Pane: Facemash 7.
 * * * * * * * * * * * * * * * * * * */
- (void)gotoUser:(id)sender
{
    UIButton *gotoUserButton = (UIButton *)sender;
    FacemashPhoto *facemash = (FacemashPhoto *)sender;
    TipCell *targetCell = (TipCell *)[[[[[[gotoUserButton superview] superview] superview] superview] superview] superview];
    NSMutableArray *participantData = targetCell.tipCardView.participantData;
	NSString *username;
    
    // Facemash handlers.
    switch (gotoUserButton.tag) {
        case 10:
        {
            NSDictionary *data_facemash_1 = [participantData objectAtIndex:0];
            username = [data_facemash_1 objectForKey:@"username"];
            [facemash.menuController setMenuVisible:NO animated:YES];
            break;
        }
            
            
        case 20:
        {
            NSDictionary *data_facemash_2 = [participantData objectAtIndex:1];
            username = [data_facemash_2 objectForKey:@"username"];
            [facemash.menuController setMenuVisible:NO animated:YES];
            break;
        }
            
        case 30:
        {
            NSDictionary *data_facemash_3 = [participantData objectAtIndex:2];
            username = [data_facemash_3 objectForKey:@"username"];
            [facemash.menuController setMenuVisible:NO animated:YES];
            break;
        }
            
        case 40:
        {
            NSDictionary *data_facemash_4 = [participantData objectAtIndex:3];
            username = [data_facemash_4 objectForKey:@"username"];
            [facemash.menuController setMenuVisible:NO animated:YES];
            break;
        }
            
        case 50:
        {
            NSDictionary *data_facemash_5 = [participantData objectAtIndex:4];
            username = [data_facemash_5 objectForKey:@"username"];
            [facemash.menuController setMenuVisible:NO animated:YES];
            break;
        }
            
        case 60:
        {
            NSDictionary *data_facemash_6 = [participantData objectAtIndex:5];
            username = [data_facemash_6 objectForKey:@"username"];
            [facemash.menuController setMenuVisible:NO animated:YES];
            break;
        }
            
        case 70:
        {
            NSDictionary *data_facemash_7 = [participantData objectAtIndex:6];
            username = [data_facemash_7 objectForKey:@"username"];
            [facemash.menuController setMenuVisible:NO animated:YES];
            break;
        }
            
        default: // Non-facemash handler.
            username = targetCell.tipCardView.username;
            break;
    }
    
	// Initialize the detail view controller and display it.
	MeViewController *profileView = [[MeViewController alloc] 
                                     initWithNibName:@"MeView" 
                                     bundle:[NSBundle mainBundle]];		// Creating new detail view controller instance.
	
    profileView.isCurrentUser = NO;
    profileView.profileOwnerUsername = username;
    self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Tips" style:UIBarButtonItemStylePlain target:nil action:nil] autorelease];
	[self.navigationController pushViewController:profileView animated:YES];	// "Pushing the controller on the screen".
	[profileView release];                                                      // Releasing controller from the memory.
    profileView = nil;
    
}

- (void)showMoreTipOptions:(id)sender
{
    UIButton *button = (UIButton *)sender;
    TipCell *targetCell = (TipCell *)[[[[[[button superview] superview] superview] superview] superview] superview];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:targetCell.tipCardView.rowNumber inSection:0];
    BOOL userFollowsTipTopic = targetCell.tipCardView.followsTopic;
    
    if (userFollowsTipTopic) {
        if ([[global readProperty:@"userid"] intValue] == targetCell.tipCardView.tipUserid) {
            genericOptions = [[UITableViewActionSheet alloc] 
                              initWithTitle:@"More Options" 
                              delegate:self
                              cancelButtonTitle:@"Cancel" 
                              destructiveButtonTitle:@"Unfollow Topic" 
                              otherButtonTitles:@"New Tip On Topic", nil];
        } else {
            genericOptions = [[UITableViewActionSheet alloc] 
                              initWithTitle:@"More Options" 
                              delegate:self
                              cancelButtonTitle:@"Cancel" 
                              destructiveButtonTitle:@"Unfollow Topic" 
                              otherButtonTitles:@"New Tip On Topic", @"Report Tip", nil];
        }
    } else {
        if ([[global readProperty:@"userid"] intValue] == targetCell.tipCardView.tipUserid) {
            genericOptions = [[UITableViewActionSheet alloc] 
                              initWithTitle:@"More Options" 
                              delegate:self
                              cancelButtonTitle:@"Cancel" 
                              destructiveButtonTitle:nil 
                              otherButtonTitles:@"Follow Topic", @"New Tip On Topic", nil];
        } else {
            genericOptions = [[UITableViewActionSheet alloc] 
                              initWithTitle:@"More Options" 
                              delegate:self
                              cancelButtonTitle:@"Cancel" 
                              destructiveButtonTitle:nil 
                              otherButtonTitles:@"Follow Topic", @"New Tip On Topic", @"Report Tip", nil];
        }
        
    }
    
	genericOptions.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    genericOptions.tag = 102;
    genericOptions.indexPath = indexPath;
    
    TipboxAppDelegate *appDelegate = (TipboxAppDelegate *)[[UIApplication sharedApplication] delegate];
	[genericOptions showFromTabBar:appDelegate.mainTabBarController.tabBar];
}

- (void)showTipSharingOptions:(id)sender
{
    UIButton *button = (UIButton *)sender;
    TipCell *targetCell = (TipCell *)[[[[[[button superview] superview] superview] superview] superview] superview];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:targetCell.tipCardView.rowNumber inSection:0];
    
    sharingOptions = [[UITableViewActionSheet alloc] 
                      initWithTitle:@"Share this tip" 
                      delegate:self
                      cancelButtonTitle:@"Cancel" 
                      destructiveButtonTitle:nil 
                      otherButtonTitles:@"Copy Tip", @"Copy Link to Tip", @"Mail Tip", @"Facebook", @"Tweet", @"Message", nil];
	
	sharingOptions.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    sharingOptions.tag = 100;
    sharingOptions.indexPath = indexPath;
    
    TipboxAppDelegate *appDelegate = (TipboxAppDelegate *)[[UIApplication sharedApplication] delegate];
	[sharingOptions showFromTabBar:appDelegate.mainTabBarController.tabBar];
}

- (void)showTipDeletionOptions:(id)sender
{
    UIButton *button = (UIButton *)sender;
    TipCell *targetCell = (TipCell *)[[[[[[button superview] superview] superview] superview] superview] superview];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:targetCell.tipCardView.rowNumber inSection:0];
    
	deletionOptions = [[UITableViewActionSheet alloc] 
                       initWithTitle:@"Delete this tip?" 
                       delegate:self
                       cancelButtonTitle:@"Cancel" 
                       destructiveButtonTitle:@"Delete" 
                       otherButtonTitles:nil];
	deletionOptions.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    deletionOptions.tag = 101;
    deletionOptions.indexPath = indexPath;
    
    TipboxAppDelegate *appDelegate = (TipboxAppDelegate *)[[UIApplication sharedApplication] delegate];
	[deletionOptions showFromTabBar:appDelegate.mainTabBarController.tabBar];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    UITableViewActionSheet *targetActionSheet = (UITableViewActionSheet *)actionSheet;
    
    if (targetActionSheet.tag == 100) {        // Sharing options
        
        [self handleTipSharingAtIndexPath:targetActionSheet.indexPath forButtonAtIndex:buttonIndex];
        
    } else if (targetActionSheet.tag == 101) { // Deletion options
        
        if (buttonIndex == 0) {                                                 // Delete
            [self handleTipDeletionAtIndexPath:targetActionSheet.indexPath];
        }
        
    } else if (targetActionSheet.tag == 102) {  // Generic options
        
        if (buttonIndex == 0) {                                                 // Follow topic
            [self followTopicAtIndexPath:targetActionSheet.indexPath];
        } else if (buttonIndex == 1) {                                          // New Tip on Topic
            [self handleTipCreationAtIndexPath:targetActionSheet.indexPath];
        } else if (buttonIndex == 2 && actionSheet.numberOfButtons == 4) {      // Report Tip
            [self handleTipReportingAtIndexPath:targetActionSheet.indexPath];
        }
        
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


- (void)dealloc
{
    [selectedIndexes_hot release];
    [selectedIndexes_recent release];
    [feedEntries release];
    [feedEntries_hot release];
    [feedEntries_recent release];
    [refreshHeaderView release];
    [lowerToolbar release];
    [loginButton release];
    [joinButton release];
    [segmentedControl release];
    [genericOptions release];
    [sharingOptions release];
    [deletionOptions release];
    [super dealloc];
}

@end
