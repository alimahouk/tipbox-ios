#import <QuartzCore/QuartzCore.h>
#import <Twitter/Twitter.h>
#import "SearchViewController.h"
#import "TipboxAppDelegate.h"
#import "TopicViewController.h"
#import "TipViewController.h"
#import "WebViewController.h"
#import "MeViewController.h"
#import "Publisher.h"
#import "ReportViewController.h"

#define MAIN_FONT_SIZE 18
#define MIN_MAIN_FONT_SIZE 15
#define SECONDARY_FONT_SIZE 12
#define MIN_SECONDARY_FONT_SIZE 10

@implementation SearchViewController

@synthesize searchResultsTableView;

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

- (void)viewDidLoad
{
    //[self setTitle:@"Tipbox"];
    UIImageView *tbLogo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tb_nav_bar_logo.png"]];
    tbLogo.frame = CGRectMake(0, 0, 86, 40);
    
    self.navigationController.navigationBar.topItem.titleView = tbLogo;
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:192.0/255.0 green:133.0/255.0 blue:87.0/255.0 alpha:1.0];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_paper_texture.png"]];
    
    // The defaults.
    searchType = @"topicsearch";
     
	// Set up the nav bar.
	TipboxAppDelegate *appDelegate = (TipboxAppDelegate *)[[UIApplication sharedApplication] delegate];
    global = appDelegate.global;
    CGRect screenBound = [[UIScreen mainScreen] bounds];
    CGFloat screenHeight = screenBound.size.height;
    
    selectedIndexes = [[NSMutableDictionary alloc] init];
    feedEntries = [[NSMutableArray alloc] init];
    
    timelineFeed.scrollEnabled = NO;
    timelineFeed.tag = 0;
    
    noResultsLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 140, 280, 20)];
    noResultsLabel.backgroundColor = [UIColor clearColor];
    noResultsLabel.textColor = [UIColor colorWithRed:145.0/255.0 green:145.0/255.0 blue:145.0/255.0 alpha:1.0];
    noResultsLabel.shadowColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    noResultsLabel.numberOfLines = 0;
    noResultsLabel.textAlignment = UITextAlignmentCenter;
    noResultsLabel.font = [UIFont fontWithName:@"Georgia" size:MAIN_FONT_SIZE];
    noResultsLabel.text = @"Oops! No Results.";
    
    quotesDict = [[NSDictionary alloc] 
                                initWithObjectsAndKeys:@"“Simplicity is the ultimate sophistication.”", @"— Leonardo da Vinci",
                                @"“Good artists copy. Great artists steal.”", @"— Pablo Picasso",
                                @"“Perfection is achieved, not when there is nothing more to add, but when there is nothing left to take away.”", @"— Antoine de Saint-Exupéry",
                                @"“Work like you don’t need money, love like you’ve never been hurt, and dance like no one’s watching.”", @"",
                                @"“An inventor is simply a fellow who doesn’t take his education too seriously.”", @"— Charles F. Kettering",
                                @"“Think different.”", @"— Apple slogan (1997–2002)",
                                @"“Just do it.”", @"— Nike slogan",
                                @"“The people who are crazy enough to think that they can change the world are the ones who do.”", @"— Steve Jobs",
                                @"“Everything should be as simple as it is, but not simpler.”", @"— Albert Einstein",
                                @"“The best way to predict the future is to create it.”", @"— Abraham Lincoln",
                                @"“Nothing is true, everything is permitted.”", @"",
                                @"“Fortune favors the bold.”", @"— Virgil",
                                @"“For every minute you are angry you lose sixty seconds of happiness.”", @"— Ralph Waldo Emerson",
                                @"“You know you are getting old when the candles cost more than the cake.”", @"— Bob Hope",
                                @"“A house divided against itself cannot stand.”", @"— Abraham Lincoln",
                                @"“He who angers you conquers you.”", @"— Elizabeth Kenny",
                                @"“It is not beauty that endears; it’s love that makes us see beauty.”", @"— Leo Tolstoy",
                                @"“If you cannot work with love but only with distaste, it is better that you should leave your work.”", @"— Kahlil Gibran",
                                @"“We worry about what a child will be tomorrow, yet we forget that he is someone today.”", @"— Stacia Tauscher",
                                @"“The only true wisdom is knowing that you know nothing.”", @"— Socrates",
                                @"“You don’t choose your family. They are God’s gift to you, as you are to them.”", @"— Desmond Tutu",
                                @"“Your friend is the man who knows all about you and still likes you.”", @"— Elbert Hubbard",
                                @"“The best way to cheer yourself up is to cheer somebody else up.”", @"— Mark Twain",
                                @"“Music in the soul can be heard by the universe.”", @"— Lao Tzu",
                                @"“Time is money.”", @"— Benjamin Franklin",
                                @"“Fighting for peace is like screwing for virginity.”", @"— George Carlin",
                                @"“Sports do not build character. They reveal it.”", @"— Heywood Broun",
                                @"“We didn’t lose the game; we just ran out of time.”", @"— Vince Lombardi",
                                @"“You can’t win unless you learn how to lose.”", @"— Kareem Abdul-Jabbar",
                                @"“Winners never quit and quitters never win.”", @"— Vince Lombardi",
                                @"“Failure is simply the opportunity to begin again, this time more intelligently.”", @"— Henry Ford",
                                @"“I don’t know the key to success, but the key to failure is trying to please everybody.”", @"— Bill Cosby",
                                @"“That which doesn’t kill us makes us stronger.”", @"— Friedrich Nietzche",
                                @"“We must learn to live together as brothers or perish together as fools.”", @"— Martin Luther King, Jr.",
                                @"“Genius is one percent inspiration and ninety-nine percent perspiration.”", @"— Thomas Edison",
                                @"“You can fool some of the people all of the time, and all of the people some of the time. But you cannot fool all of the people all of the time.”", @"— Abraham Lincoln",
                                @"“Screw it, Let’s do it!”", @"— Richard Branson",
                                @"“Better late than never!”", @"",
                                @"“Innovation distinguishes between a leader and a follower.”", @"— Steve Jobs",
                                @"“The only place where success comes before work is in the dictionary.”", @"— Vidal Sassoon",
                                @"“A friendship founded on business is a good deal better than a business founded on friendship.”", @"— John D. Rockefeller",
                                @"“Logic will get you from A to B. Imagination will take you everywhere.”", @"— Albert Einstein",
                                @"“When you see a person who has been given more than you in money and beauty, look to those who have been given less.”", @"— Muhammed (PBUH)",
                                @"“Conduct yourself in this world as if you are here to stay forever, and yet prepare for eternity as if you are to die tomorrow.”", @"— Muhammed (PBUH)",
                                @"“The best richness is the richness of the soul.”", @"— Muhammed (PBUH)",
                                @"“Veni, vidi, vici (I came, I saw, I conquered)”", @"— Julius Caesar",
                                @"“He who knows when he can fight and when he cannot will be victorious.”", @"— Sun Tzu",
                                @"“You can do anything, but not everything.”", @"— David Allen", nil];
    
    shRoof = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sh_roof_big_white.png"]];
    shRoof.frame = CGRectMake(0, screenHeight - 366, 320, 153);
    
    beOriginal = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"be_original.png"]];
    beOriginal.frame = CGRectMake(0, screenHeight - 356, 320, 100);
    
    potato = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"potato.png"]];
    potato.frame = CGRectMake(0, screenHeight - 366, 320, 153);
    
    lemon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lemon.png"]];
    lemon.frame = CGRectMake(0, screenHeight - 366, 320, 153);
    
    heart = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"love.png"]];
    heart.frame = CGRectMake(0, screenHeight - 366, 320, 153);
    
    quote = [[UILabel alloc] init];
    quote.backgroundColor = [UIColor clearColor];
    quote.textColor = [UIColor colorWithRed:191.0/255.0 green:191.0/255.0 blue:191.0/255.0 alpha:1.0];
    quote.shadowColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    quote.shadowOffset = CGSizeMake(0, 1);
    quote.numberOfLines = 0;
    quote.lineBreakMode = UILineBreakModeWordWrap;
    quote.font = [UIFont fontWithName:@"Georgia" size:22];
    quote.text = @"“Simplicity is the ultimate sophistication.”";
    
    quoter = [[UILabel alloc] init];
    quoter.backgroundColor = [UIColor clearColor];
    quoter.textColor = [UIColor colorWithRed:145.0/255.0 green:145.0/255.0 blue:145.0/255.0 alpha:1.0];
    quoter.shadowColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    quoter.shadowOffset = CGSizeMake(0, 1);
    quoter.numberOfLines = 0;
    quoter.lineBreakMode = UILineBreakModeWordWrap;
    quoter.textAlignment = UITextAlignmentRight;
    quoter.font = [UIFont fontWithName:@"Georgia" size:MIN_MAIN_FONT_SIZE];
    
    
    funnyLine = [[UILabel alloc] initWithFrame:CGRectMake(20, screenHeight - 220, 280, 34)];
    funnyLine.backgroundColor = [UIColor clearColor];
    funnyLine.textColor = [UIColor colorWithRed:145.0/255.0 green:145.0/255.0 blue:145.0/255.0 alpha:1.0];
    funnyLine.shadowColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    funnyLine.shadowOffset = CGSizeMake(0, 1);
    funnyLine.numberOfLines = 0;
    funnyLine.lineBreakMode = UILineBreakModeWordWrap;
    funnyLine.textAlignment = UITextAlignmentCenter;
    funnyLine.font = [UIFont fontWithName:@"Georgia" size:MIN_MAIN_FONT_SIZE];
    
    [super viewDidLoad];
}

#pragma mark Customizations when the view appears/disappears
- (void)viewWillAppear:(BOOL)animated
{
    TipboxAppDelegate *appDelegate = (TipboxAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate navbarShadowMode_searchbar];
    [appDelegate tabbarShadowMode_tabbar];
    [appDelegate showNavbarShadowAnimated:YES];
    [appDelegate showTabbarShadowAnimated:YES];
    
    if (self.searchDisplayController.searchBar.text.length == 0) {
        NSInteger randomDisplayChoice = arc4random_uniform(6);
        
        switch (randomDisplayChoice) {
            case 0:
            {
                NSInteger keyCount = [[quotesDict allKeys] count];
                NSInteger randomKeyIndex = arc4random_uniform(keyCount + 1);
                NSString *randomKey = [[quotesDict allKeys] objectAtIndex:randomKeyIndex];
                
                quote.text = [quotesDict objectForKey:randomKey];
                quoter.text = randomKey;
                
                CGSize quoteSize = [quote.text sizeWithFont:[UIFont fontWithName:@"Georgia" size:22] constrainedToSize:CGSizeMake(280, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];
                
                quote.frame = CGRectMake(20, 104, 280, quoteSize.height);
                quoter.frame = CGRectMake(20, quoteSize.height + 114, 280, 17);
                
                [beOriginal removeFromSuperview];
                [shRoof removeFromSuperview];
                [potato removeFromSuperview];
                [lemon removeFromSuperview];
                [heart removeFromSuperview];
                [funnyLine removeFromSuperview];
                [self.view addSubview:quote];
                [self.view addSubview:quoter];
                break;
            }
                
            case 1:
            {
                [quote removeFromSuperview];
                [quoter removeFromSuperview];
                [shRoof removeFromSuperview];
                [potato removeFromSuperview];
                [lemon removeFromSuperview];
                [heart removeFromSuperview];
                [funnyLine removeFromSuperview];
                [self.view addSubview:beOriginal];
                break;
            }
                
            case 2:
            {
                [quote removeFromSuperview];
                [quoter removeFromSuperview];
                [beOriginal removeFromSuperview];
                [potato removeFromSuperview];
                [lemon removeFromSuperview];
                [heart removeFromSuperview];
                [funnyLine removeFromSuperview];
                [self.view addSubview:shRoof];
                break;
            }
                
            case 3:
            {
                NSInteger randomDisplayChoice_funnyLine = arc4random_uniform(3);
                
                switch (randomDisplayChoice_funnyLine) {
                    case 0:
                        funnyLine.text = @"“Here's a potato for you.”";
                        break;
                        
                    case 1:
                        funnyLine.text = @"“Potato.”";
                        break;
                        
                    case 2:
                        funnyLine.text = @"“Hey! There's a potato here!”";
                        break;
                        
                    default:
                        break;
                }
                
                [quote removeFromSuperview];
                [quoter removeFromSuperview];
                [beOriginal removeFromSuperview];
                [shRoof removeFromSuperview];
                [lemon removeFromSuperview];
                [heart removeFromSuperview];
                [self.view addSubview:potato];
                [self.view addSubview:funnyLine];
                break;
            }
                
            case 4:
            {
                NSInteger randomDisplayChoice_funnyLine = arc4random_uniform(3);
                
                switch (randomDisplayChoice_funnyLine) {
                    case 0:
                        funnyLine.text = @"“Would you like a lemon?”";
                        break;
                        
                    case 1:
                        funnyLine.text = @"“When life gives you lemons, make lemonade.”";
                        break;
                        
                    case 2:
                        funnyLine.text = @"“We're in the mood for some lemon tart here!”";
                        break;
                        
                    default:
                        break;
                }
                
                [quote removeFromSuperview];
                [quoter removeFromSuperview];
                [beOriginal removeFromSuperview];
                [shRoof removeFromSuperview];
                [potato removeFromSuperview];
                [heart removeFromSuperview];
                [self.view addSubview:lemon];
                [self.view addSubview:funnyLine];
                break;
            }
                
            case 5:
            {
                [quote removeFromSuperview];
                [quoter removeFromSuperview];
                [beOriginal removeFromSuperview];
                [shRoof removeFromSuperview];
                [potato removeFromSuperview];
                [lemon removeFromSuperview];
                [funnyLine removeFromSuperview];
                [self.view addSubview:heart];
                break;
            }
                
            default:
                break;
        }
        
        // Give the search bar focus.
        [self.searchDisplayController setActive:YES animated:YES];
        [self.searchDisplayController.searchBar becomeFirstResponder];
    }
    
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
    
    [self.searchDisplayController.searchBar resignFirstResponder]; // The focus on the search bar fucks up tab state-saving, therefore, we defuck it.
}

#pragma mark -
#pragma mark UISearchBarDelegate methods

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    [self.searchDisplayController.searchBar setShowsCancelButton:YES animated:YES];
    self.searchDisplayController.searchBar.showsScopeBar = YES;
    return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    batchNo = 0;
    [self searchResultsForBatch:batchNo];
}

- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope
{
    [searchBar resignFirstResponder];
    
    switch (selectedScope) {
        case 0:
            searchType = @"topicsearch";
            searchBar.placeholder = @"Search for tip topics";
            searchBar.autocapitalizationType = UITextAutocapitalizationTypeSentences;
            searchBar.keyboardType = UIKeyboardTypeDefault;
            [searchBar becomeFirstResponder];
            break;
            
        case 1:
            searchType = @"tipsearch";
            searchBar.placeholder = @"Search for tips";
            searchBar.autocapitalizationType = UITextAutocapitalizationTypeSentences;
            searchBar.keyboardType = UIKeyboardTypeDefault;
            [searchBar becomeFirstResponder];
            break;
            
        case 2:
            searchType = @"usersearch";
            searchBar.placeholder = @"Search for people";
            searchBar.autocapitalizationType = UITextAutocapitalizationTypeWords;
            searchBar.keyboardType = UIKeyboardTypeEmailAddress;
            [searchBar becomeFirstResponder];
            break;
            
        default:
            break;
    }
    
}

- (void)searchResultsForBatch:(int)batch
{
    TipboxAppDelegate *appDelegate = (TipboxAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.strobeLight activateStrobeLight];
    
    NSURL *apiurl = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/tipbox/api/%@", SH_DOMAIN, searchType]];
    
    dataRequest_child = [[ASIFormDataRequest requestWithURL:apiurl] retain];
    [dataRequest_child setPostValue:appDelegate.SHToken forKey:@"token"];
    [dataRequest_child setPostValue:self.searchDisplayController.searchBar.text forKey:@"term"];
    [dataRequest_child setPostValue:[NSNumber numberWithInt:batch] forKey:@"batch"];
    [dataRequest_child setCompletionBlock:^{
        NSError *jsonError;
        responseData_child = [NSJSONSerialization JSONObjectWithData:[dataRequest_child.responseString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:&jsonError];
        
        if ([[responseData_child objectForKey:@"error"] intValue] == 0 && ![[NSNull null] isEqual:[responseData_child objectForKey:@"responce"]]) {
            [noResultsLabel removeFromSuperview];
            
            if (batchNo == 0) {
                [self.feedEntries removeAllObjects];
            }
            
            if ([searchType isEqualToString:@"topicsearch"]) {
                [self fetchTopics];
            } else if ([searchType isEqualToString:@"tipsearch"]) {
                [self fetchTips];
            } else {
                [self fetchUsers];
            }
            
            if ([[responseData_child objectForKey:@"responce"] count] < BATCH_SIZE) {
                endOfFeed = YES;
            } else {
                endOfFeed = NO;
            }
        } else {
            if (batchNo == 0) {
                [self.feedEntries removeAllObjects];
                [searchResultsTableView addSubview:noResultsLabel];
            }
            
            endOfFeed = YES; // Null marks end of feed.
            NSLog(@"\nERROR!\n======\n%@", responseData_child); // Handle error.
            
            if ([[responseData_child objectForKey:@"errormsg"] isEqualToString:@"authFail"]) {
                [self.navigationController popToRootViewControllerAnimated:YES];
                [appDelegate logoutWithMessage:@"Sorry, but you need to log in again!"];
            }
        }
        
        searchResultsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        searchResultsTableView.showsVerticalScrollIndicator = NO; // Personally, I think it's just useless clutter.
        
        UISwipeGestureRecognizer *gesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didSwipeTableViewCell:)];
        gesture.direction = UISwipeGestureRecognizerDirectionLeft;
        [searchResultsTableView addGestureRecognizer:gesture];
        [gesture release];
        
        timelineDidDownload = YES;
        [searchResultsTableView reloadData];
        searchResultsTableView.hidden = NO;
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
        
        TipboxAppDelegate *appDelegate = (TipboxAppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate.strobeLight negativeStrobeLight];
        [self performSelector:@selector(doneLoadingTableViewData)];
        
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

- (void)fetchTopics
{
    if (![[NSNull null] isEqual:[responseData_child objectForKey:@"responce"]]) {
        for (NSMutableDictionary *topic in [responseData_child objectForKey:@"responce"]) {
            [self.feedEntries addObject:[topic mutableCopy]];  // IMPORTANT: MAKE A MUTABLE COPY!!! Spent an hour trying to figure this shit out. :@
        }
    }
}

- (void)fetchTips
{
    if (![[NSNull null] isEqual:[responseData_child objectForKey:@"responce"]]) {
        for (NSMutableDictionary *tip in [responseData_child objectForKey:@"responce"]) {
            [self.feedEntries addObject:[tip mutableCopy]];
        }
    }
}

- (void)fetchUsers
{
    if (![[NSNull null] isEqual:[responseData_child objectForKey:@"responce"]]) {
        for (NSMutableDictionary *user in [responseData_child objectForKey:@"responce"]) {
            [self.feedEntries addObject:[user mutableCopy]];
        }
    }
}

#pragma mark -
#pragma mark UISearchDisplayDelegate methods

- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller
{
    if ([searchType isEqualToString:@"topicsearch"]) {
        self.searchDisplayController.searchBar.placeholder = @"Search for tip topics";
    } else if ([searchType isEqualToString:@"tipsearch"]) {
        self.searchDisplayController.searchBar.placeholder = @"Search for tips";
    } else {
        self.searchDisplayController.searchBar.placeholder = @"Search for people";
    }
}

- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller
{
    self.searchDisplayController.searchBar.placeholder = @"Search";
}

- (void)searchDisplayController:(UISearchDisplayController *)controller willShowSearchResultsTableView:(UITableView *)tableView
{
    searchResultsTableView = tableView;
    searchResultsTableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_paper_texture.png"]];
    searchResultsTableView.tag = 0110;
    searchResultsTableView.hidden = YES;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    return NO;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    return NO;
}

#pragma mark UIScrollViewDelegate methods
/*- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    TipboxAppDelegate *appDelegate = (TipboxAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (timelineFeed.contentOffset.y <= 0) {
        [appDelegate showNavbarShadowAnimated:YES];
    } else {
        [appDelegate hideNavbarShadowAnimated:YES];
    }
}*/

#pragma mark UITableViewDataSource
#define CELL_CONTENT_WIDTH 320.0f
#define CELL_CONTENT_MARGIN 5.0f
#define CELL_COLLAPSED_HEIGHT 87
#define MAIN_FONT_SIZE 18
#define MIN_MAIN_FONT_SIZE 15
#define SECONDARY_FONT_SIZE 12
#define MIN_SECONDARY_FONT_SIZE 10

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return 1 section which will be used to display the giant blank UITableViewCell as defined
	// in the tableView:cellForRowAtIndexPath: method below
    NSInteger total = 0;
    
    if (tableView.tag == 0110) {
        total = [self.feedEntries count] + 1; // Add an object to the end of the array for the "Load more..." table cell.
    }
    
    return total;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Special cases:
	// 1: if search results count == 0, display a giant blank UITableViewCell, and disable user interaction.
	// 2: if last cell, display the "Load more" search results UITableViewCell.
    
    UITableViewCell *assembledCell;
    int lastIndex = [feedEntries count] - 1;
    
    if (tableView.tag == 0110) {
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
        } else if (indexPath.row <= lastIndex) {
            
            if ([searchType isEqualToString:@"tipsearch"]  && timelineDidDownload == YES) {
                static NSString *CellIdentifier = @"TimelineCell";
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
            } else if ([searchType isEqualToString:@"topicsearch"]) {
                static NSString *CellIdentifier = @"topicCell";
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
            } else {
                static NSString *CellIdentifier = @"idCardCell";
                idCardCell = (IdCardCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                NSMutableDictionary *user = [self.feedEntries objectAtIndex:indexPath.row];
                
                if (idCardCell == nil) {
                    idCardCell = [[[IdCardCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
                }
                
                idCardCell.rowNumber = indexPath.row;
                [idCardCell populateCellWithContent:user];
                
                assembledCell = idCardCell;
            }
        }
    }
    
    return assembledCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{	
    CGFloat height;
    int lastIndex = [feedEntries count] - 1;
    
    if ([searchType isEqualToString:@"tipsearch"]) {
        if ([self.feedEntries count] > 0 && indexPath.row <= ([self.feedEntries count] - 1) && timelineDidDownload == YES) {
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
        
        height += (CELL_CONTENT_MARGIN * 2);
    } else if ([searchType isEqualToString:@"usersearch"]) {
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
        
        height += (CELL_CONTENT_MARGIN * 2);
    } else {
        if ([self.feedEntries count] > 0 && indexPath.row <= lastIndex) {
            return 100 + (CELL_CONTENT_MARGIN * 2);
        } else {
            return 50 + (CELL_CONTENT_MARGIN * 2);
        }
    }
    
    return height;
}

// Override to support row selection in the table view.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    int lastIndex = [feedEntries count] - 1;
    
    if ([searchType isEqualToString:@"tipsearch"] && [self.feedEntries count] > 0 && indexPath.row <= lastIndex) {
        // NIFTY SHORTCUT (BELOW): Double-tap a tip to directly go to the tip view without bringing up the action card.
        // checking for double taps here
        if (tapCount == 1 && tapTimer != nil && tappedRow == indexPath.row) {
            // Double tap - Put double tap code here.
            [tapTimer invalidate];
            tapTimer = nil;
            
            doubleTapRow = tappedRow;
            
            TipCell *targetCell = (TipCell *)[tableView cellForRowAtIndexPath:indexPath];
            [targetCell.tipCardView.pane_gotoTipButton sendActionsForControlEvents:UIControlEventTouchUpInside];
            
            tapCount = 0;
            tappedRow = -1;
        } else if (tapCount == 0) {
            // This is the first tap. If there is no tap till tapTimer is fired, it's a single tap.
            tapCount = 1;
            tappedRow = indexPath.row;
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
    } else if ([searchType isEqualToString:@"topicsearch"]) {
        if (indexPath.row != [self.feedEntries count]) {
            TopicCell *targetCell = (TopicCell *)[tableView cellForRowAtIndexPath:indexPath];
            
            TopicViewController *topicView = [[TopicViewController alloc] 
                                              initWithNibName:@"TopicView" 
                                              bundle:[NSBundle mainBundle]];
            
            topicView.topicName = targetCell.content;
            topicView.viewTopicid = targetCell.topicid;
            self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Search" style:UIBarButtonItemStylePlain target:nil action:nil] autorelease];
            [self.navigationController pushViewController:topicView animated:YES];
            [topicView release];
            topicView = nil;
        }
    } else if ([searchType isEqualToString:@"usersearch"]) {
        IdCardCell *targetCell = (IdCardCell *)[tableView cellForRowAtIndexPath:indexPath];
        
        MeViewController *profileView = [[MeViewController alloc] 
                                          initWithNibName:@"MeView" 
                                          bundle:[NSBundle mainBundle]];
        
        profileView.profileOwnerUsername = targetCell.username;
        self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Search" style:UIBarButtonItemStylePlain target:nil action:nil] autorelease];
        [self.navigationController pushViewController:profileView animated:YES];
        [profileView release];
        profileView = nil;
    }
}

- (void)tapTimerFired:(NSTimer *)aTimer
{
    // Timer fired! There was a single tap on indexPath.row = tappedRow.
    // Do something here with tappedRow.
    if (tapTimer != nil) {
        NSIndexPath *indexPath_tappedRow = [NSIndexPath indexPathForRow:tappedRow inSection:0];
        NSIndexPath *indexPath_lastTappedRow = [NSIndexPath indexPathForRow:lastTappedRow inSection:0];
        
        TipCell *cell = (TipCell *)[searchResultsTableView cellForRowAtIndexPath:indexPath_tappedRow];
        [cell collapseCell];
        
        // Toggle 'selected' state
        BOOL isSelected = ![self cellIsSelected:[NSIndexPath indexPathForRow:tappedRow inSection:0]];
        
        // Store cell 'selected' state keyed on indexPath
        NSNumber *selectedIndex = [NSNumber numberWithBool:isSelected];
        [selectedIndexes setObject:selectedIndex forKey:[NSIndexPath indexPathForRow:tappedRow inSection:0]];
		cell.tipCardView.isSelected = isSelected;
        
        if (lastTappedRow != tappedRow) { // Collapse any other cell (unless if it's the same one, this will cause fuckage).
            TipCell *oldCell = (TipCell *)[searchResultsTableView cellForRowAtIndexPath:indexPath_lastTappedRow];
            
            NSNumber *oldIndex = [NSNumber numberWithBool:FALSE];
            [selectedIndexes setObject:oldIndex forKey:indexPath_lastTappedRow];
            
            if (indexPath_lastTappedRow.row != [feedEntries count]) { // We don't want it sending wrong messages to the "Load more" cell.
                [oldCell collapseCell];
                oldCell.tipCardView.isSelected = FALSE;
            }
        }
        
        // This is where the magic happens...
        [searchResultsTableView beginUpdates];
        [searchResultsTableView endUpdates];
        
        if (lastTappedRow == tappedRow) {
            lastTappedRow = -1;
        } else {
            lastTappedRow = tappedRow;
        }
        
        tapCount = 0;
        tappedRow = -1;
    }
}

- (void)didSwipeTableViewCell:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded && [searchType isEqualToString:@"tipsearch"]) {
        CGPoint swipeLocation = [gestureRecognizer locationInView:searchResultsTableView];
        NSIndexPath *swipedIndexPath = [searchResultsTableView indexPathForRowAtPoint:swipeLocation];
        int lastIndex = [feedEntries count] - 1;
        
        if ([feedEntries count] > 0 && swipedIndexPath.row <= lastIndex && timelineDidDownload == YES) {
            TipCell *targetCell = (TipCell *)[searchResultsTableView cellForRowAtIndexPath:swipedIndexPath];
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
    
    [self searchResultsForBatch:++batchNo];
}

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
	
    self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Search" style:UIBarButtonItemStylePlain target:nil action:nil] autorelease];
	[self.navigationController pushViewController:tipView animated:YES];
	[tipView release];
	tipView = nil;
}

#pragma mark Follow/Unfollow a topic (topicCell)
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
    TipCell *targetCell = (TipCell *)[searchResultsTableView cellForRowAtIndexPath:indexPath];
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
    TipCell *targetCell = (TipCell *)[searchResultsTableView cellForRowAtIndexPath:indexPath];
    
    tapCount = 1;
    tappedRow = indexPath.row;
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
                [searchResultsTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                [searchResultsTableView reloadData];
                
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
    TipCell *targetCell = (TipCell *)[searchResultsTableView cellForRowAtIndexPath:indexPath];
    
    tapCount = 1;
    tappedRow = indexPath.row;
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
    
    TipCell *targetCell = (TipCell *)[searchResultsTableView cellForRowAtIndexPath:indexPath];
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
    self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Search" style:UIBarButtonItemStylePlain target:nil action:nil] autorelease];
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
    [selectedIndexes release];
    [feedEntries release];
    [genericOptions release];
    [sharingOptions release];
    [deletionOptions release];
    [quotesDict release];
    [noResultsLabel release];
    [beOriginal release];
    [potato release];
    [lemon release];
    [heart release];
    [quote release];
    [quoter release];
    [funnyLine release];
    [super dealloc];
}

@end
