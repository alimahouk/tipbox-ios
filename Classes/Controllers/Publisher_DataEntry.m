#import <QuartzCore/QuartzCore.h>
#import "Publisher_DataEntry.h"
#import "EGOImageView.h"
#import "TipboxAppDelegate.h"
#import "TopicViewController.h"

#define MAIN_FONT_SIZE 18
#define MIN_MAIN_FONT_SIZE 15
#define SECONDARY_FONT_SIZE 12
#define MIN_SECONDARY_FONT_SIZE 10

@implementation Publisher_DataEntry

@synthesize dataRequest, responseData, configuration;
@synthesize category, subcategory, topic, topicid;
@synthesize topics, tableContents, sortedKeys, subcategories_main;
@synthesize subcategories_thing, subcategories_place, subcategoriesDict;
@synthesize selectedSubcategoryIndexPath, selectedSubcategory;

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

- (void)showCategoryOverlay
{
    categorySelectionOverlay.hidden = NO;
    subcategoryTableView.scrollsToTop = YES; // So as not to conflict with the topic search results table scrolling.
}

- (void)dismissCategoryOverlay:(id)sender
{
    UIButton *categoryButton = (UIButton *)sender;
    
    if (categoryButton.tag == 0 || categoryButton.tag == 1) {
        subcategoryTableView.hidden = YES;
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3];
        
        if (categoryButton.tag == 0) {  // Thing
            categoryButton_place.alpha = 0.0;
            categoryButton_idea.alpha = 0.0;
        } else {                        // Place
            categoryButton_thing.alpha = 0.0;
            categoryButton_idea.alpha = 0.0;
        }
        
        categorySelectionOverlayDivider_1.alpha = 0.0;
        categorySelectionOverlayDivider_2.alpha = 0.0;
        categoryButton.frame = CGRectMake(0, 0, 320, 110);
        categoryButton.layer.shadowOffset = CGSizeMake(0, 2);
        categoryButton.layer.shadowRadius = 2;
        categoryButton.layer.shadowOpacity = 0.5;
        dottedDivider.frame = CGRectMake(0, 110, 320, 2);
        [UIView commitAnimations];
        
        if (categoryButton.tag == 0) {  // Thing
            pub.selectedCategoryButtonIcon.image = [UIImage imageNamed:@"pub_category_thing.png"];
            pub.selectedCategoryButtonTitle.text = @"Thing";
            
            if (subcategory == -1) {
                pub.selectedCategoryButtonSubtitle.text = @"Other";
            }
            
            if (!didDownloadSubcategories_thing) {
                activityIndicator_subcategories.hidden = NO;
                [activityIndicator_subcategories startAnimating];
                [self fetchSubcategoriesOfType:@"thing"];
            } else {
                subcategoryTableView.hidden = NO;
                activityIndicator_subcategories.hidden = YES;
                [activityIndicator_subcategories stopAnimating];
                
                self.subcategories_main = [[NSArray alloc] initWithArray:self.subcategories_thing];
                self.subcategoriesDict =[[[NSDictionary alloc]
                                         initWithObjectsAndKeys:self.subcategories_main, @"1", nil] autorelease];
                
                self.tableContents = self.subcategoriesDict;
                self.sortedKeys =[[self.tableContents allKeys]
                                  sortedArrayUsingSelector:@selector(compare:)];
                [subcategoryTableView reloadData];
                [subcategoryTableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
            }
            
            category = 0;
            subcategory = -1; // Reset the subcategory.
        } else {                        // Place
            pub.selectedCategoryButtonIcon.image = [UIImage imageNamed:@"pub_category_place.png"];
            pub.selectedCategoryButtonTitle.text = @"Place";
            
            if (subcategory == -1) {
                pub.selectedCategoryButtonSubtitle.text = @"Other";
            }
            
            if (!didDownloadSubcategories_place) {
                activityIndicator_subcategories.hidden = NO;
                [activityIndicator_subcategories startAnimating];
                [self fetchSubcategoriesOfType:@"place"];
            } else {
                subcategoryTableView.hidden = NO;
                activityIndicator_subcategories.hidden = YES;
                [activityIndicator_subcategories stopAnimating];
                
                self.subcategories_main = [[NSArray alloc] initWithArray:self.subcategories_place];
                self.subcategoriesDict = [[[NSDictionary alloc]
                                         initWithObjectsAndKeys:self.subcategories_main, @"1", nil] autorelease];
                
                self.tableContents = self.subcategoriesDict;
                self.sortedKeys = [[self.tableContents allKeys]
                                  sortedArrayUsingSelector:@selector(compare:)];
                [subcategoryTableView reloadData];
                [subcategoryTableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
            }
            
            category = 1;
        }
        
        categoryButton.enabled = NO;
        cancelCategoryButton.hidden = NO;
        
        pub.category = category;
        subcategory = -1; // Reset the subcategory.
    } else if (categoryButton.tag == 2) {// Idea
        category = 2;
        subcategory = 40;
        pub.category = category;
        pub.subcategory = subcategory;
        pub.selectedSubcategory = subcategory;
        pub.selectedCategoryButtonIcon.image = [UIImage imageNamed:@"pub_category_idea.png"];
        pub.selectedCategoryButtonTitle.text = @"Idea";
        pub.selectedCategoryButtonSubtitle.text = @"This category doesn't need a subcategory.";
        
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)resetCategories
{
    CGRect screenBound = [[UIScreen mainScreen] bounds];
    CGFloat screenHeight = screenBound.size.height;
    
    // Extra padding needed for the iPhone 5.
    int paddingHeight;
    
    if (screenHeight - 480 > 0) {
        paddingHeight = 29;
    } else {
        paddingHeight = 0;
    }
    
    [dataRequest cancel]; // Cancel any pending request.
    
    // Reset everything.
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    
    categoryButton_thing.frame = CGRectMake(0, 88, 320, 110 + paddingHeight);
    categoryButton_thing.layer.shadowOffset = CGSizeMake(0, 0);
    categoryButton_thing.layer.shadowRadius = 0;
    categoryButton_place.frame = CGRectMake(0, 89 + categoryButton_thing.bounds.size.height, 320, 110 + paddingHeight);
    categoryButton_place.layer.shadowOffset = CGSizeMake(0, 0);
    categoryButton_place.layer.shadowRadius = 0;
    dottedDivider.frame = CGRectMake(0, 86, 320, 2);

    categoryButton_thing.alpha = 1.0;
    categoryButton_place.alpha = 1.0;
    categoryButton_idea.alpha = 1.0;
    
    categorySelectionOverlayDivider_1.alpha = 1.0;
    categorySelectionOverlayDivider_2.alpha = 1.0;
    
    [UIView commitAnimations];
    
    categoryButton_thing.enabled = YES;
    categoryButton_place.enabled = YES;
    cancelCategoryButton.hidden = YES;
    subcategoryTableView.hidden = YES;
    subcategory = -1;
    selectedSubcategory = -1;   // Default selected row (out of the first table index).
    pub.selectedSubcategory = selectedSubcategory;
}

- (void)fetchSubcategoriesOfType:(NSString *)type
{
    TipboxAppDelegate *appDelegate = (TipboxAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/tipbox/api/getcats", SH_DOMAIN]];
    dataRequest = [[ASIFormDataRequest requestWithURL:url] retain];
    [dataRequest setPostValue:appDelegate.SHToken forKey:@"token"];
    [dataRequest setPostValue:type forKey:@"type"];
    [dataRequest setDelegate:self];
    
    if ([type isEqualToString:@"thing"]) {
        activeConnectionIdentifier = @"subcats_thing";
    } else {
        activeConnectionIdentifier = @"subcats_place";
    }
    
    [appDelegate.strobeLight activateStrobeLight];
    [dataRequest startAsynchronous];
}

- (void)showTopicSearchOverlay
{
    TipboxAppDelegate *appDelegate = (TipboxAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate navbarShadowMode_searchbar];
    
    topicTableView.scrollsToTop = YES;
    
    topicSelectionOverlay.hidden = NO;
    topicSelectionTip.hidden = NO;
    activityIndicator_topics.hidden = YES;
    
    if ([self.topics count] == 0) {
        [topicSearchBox becomeFirstResponder];
    }
    
    if (![topicSearchBox isFirstResponder]) {
        topicSelectionTip.frame = CGRectMake(0, 199, 320, 18);
        activityIndicator_topics.frame = CGRectMake(100, 217, 20, 20);
        topicSelectionTipSubtitle.frame = CGRectMake(0, 220, 320, 16);
    }
    
    topicSearchBox.text = self.topic;
    
    if (category == 0) {
        topicSelectionTipSubtitle.text = @"E.g. iPhone, Portal 2, ...";
    } else if (category == 1) {
        topicSelectionTipSubtitle.text = @"E.g. Starbucks, Disneyland, ...";
    } else {
        topicSelectionTipSubtitle.text = @"E.g. Cooking, Gaming, ...";
    }
    
    // If there's a previously selected topic, initiate search to save time.
    if (self.topic.length > 0) {
        query = self.topic;
        batchNo = 0;
        [self searchTopicsforQuery:query batch:batchNo];
    }
}

- (void)hideKeyboardPad
{
    keyboardTouchpad.hidden = YES;
}

- (void)dismissTopicSearchOverlay
{
    TipboxAppDelegate *appDelegate = (TipboxAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate navbarShadowMode_navbar];
    
    topicSelectionOverlay.hidden = YES;
    
    topicTableView.scrollsToTop = NO;
    [topicSearchBox resignFirstResponder];
}

- (void)searchTopicsforQuery:(NSString *)searchQuery batch:(int)batch
{
    TipboxAppDelegate *appDelegate = (TipboxAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [loadMoreCell.button setTitle:@"Loading..." forState:UIControlStateDisabled];
    loadMoreCell.buttonTxtShadow.text = @"Loading...";
    loadMoreCell.userInteractionEnabled = NO;
    loadMoreCell.button.enabled = NO; // Don't forget to disable the button!
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/tipbox/api/topicsearch", SH_DOMAIN]];
    
    dataRequest = [[ASIFormDataRequest requestWithURL:url] retain];
    [dataRequest setPostValue:appDelegate.SHToken forKey:@"token"];
    [dataRequest setPostValue:searchQuery forKey:@"term"];
    [dataRequest setPostValue:[NSNumber numberWithInt:batchNo] forKey:@"batch"];
    [dataRequest setDelegate:self];
    [appDelegate.strobeLight activateStrobeLight];
    activeConnectionIdentifier = @"topicSearch";
    [dataRequest startAsynchronous];
}

#pragma mark UISearchBarDelegate methods
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    CGRect screenBound = [[UIScreen mainScreen] bounds];
    CGFloat screenHeight = screenBound.size.height;
    
    if (!topicTableView.hidden) {
        keyboardTouchpad.hidden = NO;
    }
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView setAnimationDuration:0.2];
    
    if (!topicTableView.hidden) {
        keyboardTouchpad.alpha = 0.4;
    }
    
    topicSelectionTip.frame = CGRectMake(0, (screenHeight / 2) - 114, 320, 18);
    activityIndicator_topics.frame = CGRectMake(100, (screenHeight / 2) - 132, 20, 20);
    topicSelectionTipSubtitle.frame = CGRectMake(0, (screenHeight / 2) - 135, 320, 16);
    [UIView commitAnimations];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    CGRect screenBound = [[UIScreen mainScreen] bounds];
    CGFloat screenHeight = screenBound.size.height;
    query = searchBar.text;
    batchNo = 0;
    
    [searchBar resignFirstResponder];
    
    [self searchTopicsforQuery:query batch:batchNo];
    topicSelectionTip.hidden = YES;
    activityIndicator_topics.hidden = NO;
    topicSelectionTipSubtitle.hidden = NO;
    [activityIndicator_topics startAnimating];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView setAnimationDuration:0.2];
    keyboardTouchpad.alpha = 0.0;
    activityIndicator_topics.frame = CGRectMake(100, (screenHeight / 2) - 7, 20, 20);
    topicSelectionTipSubtitle.frame = CGRectMake(0, (screenHeight / 2) - 4, 320, 16);
    [UIView commitAnimations];
    
    [NSTimer scheduledTimerWithTimeInterval:0.2
                                     target:self
                                   selector:@selector(hideKeyboardPad)
                                   userInfo:nil
                                    repeats:NO];
    topicSelectionTipSubtitle.text = @"Loading...";
}

// Hide the keyboard when the user touches the view.
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch * touch = [touches anyObject];
    CGRect screenBound = [[UIScreen mainScreen] bounds];
    CGFloat screenHeight = screenBound.size.height;
    
    if (touch.phase == UITouchPhaseBegan) {
        [topicSearchBox resignFirstResponder];
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        [UIView setAnimationDuration:0.2];
        keyboardTouchpad.alpha = 0.0;
        topicSelectionTip.frame = CGRectMake(0, (screenHeight / 2) - 25, 320, 18);
        activityIndicator_topics.frame = CGRectMake(100, (screenHeight / 2) - 7, 20, 20);
        topicSelectionTipSubtitle.frame = CGRectMake(0, (screenHeight / 2) - 4, 320, 16);
        [UIView commitAnimations];
        
        [NSTimer scheduledTimerWithTimeInterval:0.2
                                         target:self
                                       selector:@selector(hideKeyboardPad)
                                       userInfo:nil
                                        repeats:NO];
    }
}

- (void)viewDidLoad
{
    didDownloadSubcategories_thing = NO;
    didDownloadSubcategories_place = NO;
    didDownloadTopics = NO;
    
    TipboxAppDelegate *appDelegate = (TipboxAppDelegate *)[[UIApplication sharedApplication] delegate];
    global = appDelegate.global;
    CGRect screenBound = [[UIScreen mainScreen] bounds];
    CGFloat screenHeight = screenBound.size.height;
    
    pub = (Publisher *)[self.navigationController.viewControllers objectAtIndex:0];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_paper_texture.png"]];
    
    categorySelectionOverlay = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    categorySelectionOverlay.backgroundColor = [UIColor colorWithRed:238/255.0 green:238/255.0 blue:238/255.0 alpha:1.0];
    categorySelectionOverlay.hidden = YES;
    
    LPLabel *categorySelectionTip = [[LPLabel alloc] initWithFrame:CGRectMake(20, 20, 280, 18)];
    categorySelectionTip.backgroundColor = [UIColor clearColor];
	categorySelectionTip.textColor = [UIColor colorWithRed:132.0/255.0 green:160.0/255.0 blue:181.0/255.0 alpha:1.0];
	categorySelectionTip.font = [UIFont boldSystemFontOfSize:16];
    categorySelectionTip.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.5];
    categorySelectionTip.shadowOffset = CGSizeMake(0, 1);
    categorySelectionTip.text = @"Choose a category";
    
    LPLabel *categorySelectionTipSubtitle = [[LPLabel alloc] initWithFrame:CGRectMake(20, 42, 280, 36)];
    categorySelectionTipSubtitle.backgroundColor = [UIColor clearColor];
	categorySelectionTipSubtitle.textColor = [UIColor colorWithRed:106.0/255.0 green:106.0/255.0 blue:106.0/255.0 alpha:1.0];
	categorySelectionTipSubtitle.font = [UIFont fontWithName:@"Georgia-Italic" size:14];
    categorySelectionTipSubtitle.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.5];
    categorySelectionTipSubtitle.shadowOffset = CGSizeMake(0, 1);
    categorySelectionTipSubtitle.numberOfLines = 0;
    categorySelectionTipSubtitle.lineBreakMode = UILineBreakModeWordWrap;
    categorySelectionTipSubtitle.text = @"A category tells people a bit more about what your tip is related to.";
    
    dottedDivider = [CALayer layer];
    dottedDivider.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"dotted_line_grey.png"]].CGColor;
    dottedDivider.frame = CGRectMake(0, 86, 320, 2);
    dottedDivider.opaque = YES;
    [dottedDivider setTransform:CATransform3DMakeScale(1.0, -1.0, 1.0)];
    
    // Extra padding needed for the iPhone 5.
    int paddingHeight;
    
    if (screenHeight - 480 > 0) {
        paddingHeight = 29;
    } else {
        paddingHeight = 0;
    }
    
    categoryButton_thing = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    categoryButton_thing.backgroundColor = [UIColor colorWithRed:238/255.0 green:238/255.0 blue:238/255.0 alpha:1.0];
    [categoryButton_thing addTarget:self action:@selector(dismissCategoryOverlay:) forControlEvents:UIControlEventTouchUpInside];
    [categoryButton_thing setBackgroundImage:[[UIImage imageNamed:@"feed_button_grey_bg.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0] forState:UIControlStateHighlighted];
    categoryButton_thing.frame = CGRectMake(0, 88, 320, 110 + paddingHeight);
    categoryButton_thing.tag = 0;
    
    categoryButton_place = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    categoryButton_place.backgroundColor = [UIColor colorWithRed:250.0/255.0 green:250.0/255.0 blue:250.0/255.0 alpha:1.0];
    [categoryButton_place addTarget:self action:@selector(dismissCategoryOverlay:) forControlEvents:UIControlEventTouchUpInside];
    [categoryButton_place setBackgroundImage:[[UIImage imageNamed:@"feed_button_grey_bg.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0] forState:UIControlStateHighlighted];
    categoryButton_place.frame = CGRectMake(0, 89 + categoryButton_thing.bounds.size.height, 320, 110 + paddingHeight);
    categoryButton_place.tag = 1;
    
    categoryButton_idea = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    categoryButton_idea.backgroundColor = [UIColor colorWithRed:238/255.0 green:238/255.0 blue:238/255.0 alpha:1.0];
    [categoryButton_idea addTarget:self action:@selector(dismissCategoryOverlay:) forControlEvents:UIControlEventTouchUpInside];
    [categoryButton_idea setBackgroundImage:[[UIImage imageNamed:@"feed_button_grey_bg.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0] forState:UIControlStateHighlighted];
    categoryButton_idea.frame = CGRectMake(0, 90 + categoryButton_thing.bounds.size.height * 2, 320, 110 + paddingHeight);
    categoryButton_idea.tag = 2;
    
    cancelCategoryButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    [cancelCategoryButton addTarget:self action:@selector(resetCategories) forControlEvents:UIControlEventTouchUpInside];
    cancelCategoryButton.showsTouchWhenHighlighted = YES;
    cancelCategoryButton.frame = CGRectMake(274, 10, 29, 29);
    cancelCategoryButton.tag = 3;
    cancelCategoryButton.hidden = YES;
    
    UIImageView *cancelCategoryButtonBG = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pub_cancel_category.png"]];
    cancelCategoryButtonBG.frame = CGRectMake(6, 6, 17, 17);
    
    categorySelectionOverlayDivider_1 = [[UIView alloc] initWithFrame:CGRectMake(0, 88 + categoryButton_thing.bounds.size.height, 320, 1)];
    categorySelectionOverlayDivider_1.backgroundColor = [UIColor colorWithRed:199/255.0 green:199/255.0 blue:199/255.0 alpha:1.0];
    
    categorySelectionOverlayDivider_2 = [[UIView alloc] initWithFrame:CGRectMake(0, 89 + categoryButton_thing.bounds.size.height * 2, 320, 1)];
    categorySelectionOverlayDivider_2.backgroundColor = [UIColor colorWithRed:199/255.0 green:199/255.0 blue:199/255.0 alpha:1.0];
    
    UIImageView *categoryButton_thing_icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pub_category_thing.png"]];
    categoryButton_thing_icon.frame = CGRectMake(20, (categoryButton_thing.bounds.size.height / 2) - 10, 30, 30);
    
    LPLabel *categoryButton_thing_title = [[LPLabel alloc] initWithFrame:CGRectMake(70, (categoryButton_thing.bounds.size.height / 2) - 40, 230, 20)];
    categoryButton_thing_title.backgroundColor = [UIColor clearColor];
	categoryButton_thing_title.textColor = [UIColor colorWithRed:54.0/255.0 green:54.0/255.0 blue:54.0/255.0 alpha:1.0];
	categoryButton_thing_title.font = [UIFont boldSystemFontOfSize:16];
    categoryButton_thing_title.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.5];
    categoryButton_thing_title.shadowOffset = CGSizeMake(0, 1);
    categoryButton_thing_title.text = @"Thing";
    
    LPLabel *categoryButton_thing_desc = [[LPLabel alloc] initWithFrame:CGRectMake(70, (categoryButton_thing.bounds.size.height / 2) - 20, 230, 70)];
    categoryButton_thing_desc .backgroundColor = [UIColor clearColor];
	categoryButton_thing_desc .textColor = [UIColor colorWithRed:106.0/255.0 green:106.0/255.0 blue:106.0/255.0 alpha:1.0];
	categoryButton_thing_desc .font = [UIFont systemFontOfSize:13];
    categoryButton_thing_desc .shadowColor = [UIColor colorWithWhite:1.0 alpha:0.5];
    categoryButton_thing_desc .shadowOffset = CGSizeMake(0, 1);
    categoryButton_thing_desc .numberOfLines = 0;
    categoryButton_thing_desc .lineBreakMode = UILineBreakModeWordWrap;
    categoryButton_thing_desc .text = @"For tips on physical and virtual objects, like a website, a game, or an electronic device.";
    
    UIImageView *categoryButton_place_icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pub_category_place.png"]];
    categoryButton_place_icon.frame = CGRectMake(20, (categoryButton_place.bounds.size.height / 2) - 10, 30, 30);
    
    LPLabel *categoryButton_place_title = [[LPLabel alloc] initWithFrame:CGRectMake(70, (categoryButton_place.bounds.size.height / 2) - 40, 230, 20)];
    categoryButton_place_title.backgroundColor = [UIColor clearColor];
	categoryButton_place_title.textColor = [UIColor colorWithRed:54.0/255.0 green:54.0/255.0 blue:54.0/255.0 alpha:1.0];
	categoryButton_place_title.font = [UIFont boldSystemFontOfSize:16];
    categoryButton_place_title.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.5];
    categoryButton_place_title.shadowOffset = CGSizeMake(0, 1);
    categoryButton_place_title.text = @"Place";
    
    LPLabel *categoryButton_place_desc = [[LPLabel alloc] initWithFrame:CGRectMake(70, (categoryButton_place.bounds.size.height / 2) - 20, 230, 70)];
    categoryButton_place_desc .backgroundColor = [UIColor clearColor];
	categoryButton_place_desc .textColor = [UIColor colorWithRed:106.0/255.0 green:106.0/255.0 blue:106.0/255.0 alpha:1.0];
	categoryButton_place_desc .font = [UIFont systemFontOfSize:13];
    categoryButton_place_desc .shadowColor = [UIColor colorWithWhite:1.0 alpha:0.5];
    categoryButton_place_desc .shadowOffset = CGSizeMake(0, 1);
    categoryButton_place_desc .numberOfLines = 0;
    categoryButton_place_desc .lineBreakMode = UILineBreakModeWordWrap;
    categoryButton_place_desc .text = @"For tips on places and locations, like a restaurant, a bookstore, or a city.";
    
    UIImageView *categoryButton_idea_icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pub_category_idea.png"]];
    categoryButton_idea_icon.frame = CGRectMake(20, (categoryButton_idea.bounds.size.height / 2) - 10, 30, 30);
    
    LPLabel *categoryButton_idea_title = [[LPLabel alloc] initWithFrame:CGRectMake(70, (categoryButton_idea.bounds.size.height / 2) - 40, 230, 20)];
    categoryButton_idea_title.backgroundColor = [UIColor clearColor];
	categoryButton_idea_title.textColor = [UIColor colorWithRed:54.0/255.0 green:54.0/255.0 blue:54.0/255.0 alpha:1.0];
	categoryButton_idea_title.font = [UIFont boldSystemFontOfSize:16];
    categoryButton_idea_title.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.5];
    categoryButton_idea_title.shadowOffset = CGSizeMake(0, 1);
    categoryButton_idea_title.text = @"Idea";
    
    LPLabel *categoryButton_idea_desc = [[LPLabel alloc] initWithFrame:CGRectMake(70, (categoryButton_idea.bounds.size.height / 2) - 20, 230, 70)];
    categoryButton_idea_desc .backgroundColor = [UIColor clearColor];
	categoryButton_idea_desc .textColor = [UIColor colorWithRed:106.0/255.0 green:106.0/255.0 blue:106.0/255.0 alpha:1.0];
	categoryButton_idea_desc .font = [UIFont systemFontOfSize:13];
    categoryButton_idea_desc .shadowColor = [UIColor colorWithWhite:1.0 alpha:0.5];
    categoryButton_idea_desc .shadowOffset = CGSizeMake(0, 1);
    categoryButton_idea_desc .numberOfLines = 0;
    categoryButton_idea_desc .lineBreakMode = UILineBreakModeWordWrap;
    categoryButton_idea_desc .text = @"For general tips on ideas and concepts, like cooking, basketball, or business.";
    
    self.subcategories_thing = [[[NSMutableArray alloc] init] autorelease];
    self.subcategories_place = [[[NSMutableArray alloc] init] autorelease];
    self.topics = [[[NSMutableArray alloc] init] autorelease];
    
    subcategoryTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 111, 320, screenHeight - 175) style:UITableViewStyleGrouped];
    subcategoryTableView.tag = 0;
    subcategoryTableView.delegate = self;
    subcategoryTableView.dataSource = self;
    subcategoryTableView.backgroundView = nil; // Fix for iOS 6+.
    subcategoryTableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_paper_texture.png"]];
    subcategoryTableView.hidden = YES;
    subcategoryTableView.scrollsToTop = NO;
    
    activityIndicator_subcategories = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(150, 250, 20, 20)];
    activityIndicator_subcategories.hidden = YES;
    activityIndicator_subcategories.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    
    topicSelectionOverlay = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, screenHeight)];
    topicSelectionOverlay.backgroundColor = [UIColor colorWithRed:238/255.0 green:238/255.0 blue:238/255.0 alpha:1.0];
    topicSelectionOverlay.userInteractionEnabled = YES;
    topicSelectionOverlay.hidden = YES;
    
    keyboardTouchpad = [[UIView alloc] initWithFrame:CGRectMake(0, 44, 320, screenHeight)];
    keyboardTouchpad.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    keyboardTouchpad.userInteractionEnabled = YES;
    keyboardTouchpad.hidden = YES;
    
    topicSearchBox = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    topicSearchBox.tintColor = [UIColor colorWithRed:112/255.0 green:58/255.0 blue:0/255.0 alpha:1.0];
    topicSearchBox.placeholder = @"Search for a topic";
    topicSearchBox.text = self.topic;
    topicSearchBox.delegate = self;
    
    activityIndicator_topics = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(100, 122, 20, 20)];
    activityIndicator_topics.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    activityIndicator_topics.hidden = YES;
    
    topicSelectionTip = [[LPLabel alloc] initWithFrame:CGRectMake(0, screenHeight / 2, 320, 18)];
    topicSelectionTip.backgroundColor = [UIColor clearColor];
	topicSelectionTip.textColor = [UIColor colorWithRed:132.0/255.0 green:160.0/255.0 blue:181.0/255.0 alpha:1.0];
	topicSelectionTip.font = [UIFont boldSystemFontOfSize:16];
    topicSelectionTip.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.5];
    topicSelectionTip.shadowOffset = CGSizeMake(0, 1);
    topicSelectionTip.textAlignment = UITextAlignmentCenter;
    
    topicSelectionTipSubtitle = [[LPLabel alloc] initWithFrame:CGRectMake(0, 21 + screenHeight / 2, 320, 16)];
    topicSelectionTipSubtitle.backgroundColor = [UIColor clearColor];
	topicSelectionTipSubtitle.textColor = [UIColor colorWithRed:106.0/255.0 green:106.0/255.0 blue:106.0/255.0 alpha:1.0];
	topicSelectionTipSubtitle.font = [UIFont fontWithName:@"Georgia-Italic" size:14];
    topicSelectionTipSubtitle.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.5];
    topicSelectionTipSubtitle.shadowOffset = CGSizeMake(0, 1);
    topicSelectionTipSubtitle.textAlignment = UITextAlignmentCenter;
    
    topicSelectionTip.text = @"What's your tip about?";
    
    topicTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 44, 320, screenHeight - 108) style:UITableViewStylePlain];
    topicTableView.tag = 1;
    topicTableView.delegate = self;
    topicTableView.dataSource = self;
    topicTableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_paper_texture.png"]];
    topicTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    topicTableView.hidden = YES;
    topicTableView.scrollsToTop = NO;
    
    [self.view addSubview:topicSelectionOverlay];
    [topicSelectionOverlay addSubview:topicSearchBox];
    [topicSelectionOverlay addSubview:topicSelectionTip];
    [topicSelectionOverlay addSubview:topicSelectionTipSubtitle];
    [topicSelectionOverlay addSubview:activityIndicator_topics];
    [topicSelectionOverlay addSubview:topicTableView];
    [topicSelectionOverlay addSubview:keyboardTouchpad];
    [self.view addSubview:categorySelectionOverlay];
    [categorySelectionOverlay addSubview:categorySelectionTip];
    [categorySelectionOverlay addSubview:categorySelectionTipSubtitle];
    [categorySelectionOverlay addSubview:subcategoryTableView];
    [categorySelectionOverlay addSubview:activityIndicator_subcategories];
    [categorySelectionOverlay.layer addSublayer:dottedDivider];
    [categorySelectionOverlay addSubview:categorySelectionOverlayDivider_1];
    [categorySelectionOverlay addSubview:categorySelectionOverlayDivider_2];
    [categorySelectionOverlay addSubview:categoryButton_thing];
    [categorySelectionOverlay addSubview:categoryButton_place];
    [categorySelectionOverlay addSubview:categoryButton_idea];
    [categorySelectionOverlay addSubview:cancelCategoryButton];
    [cancelCategoryButton addSubview:cancelCategoryButtonBG];
    [categoryButton_thing addSubview:categoryButton_thing_icon];
    [categoryButton_thing addSubview:categoryButton_thing_title];
    [categoryButton_thing addSubview:categoryButton_thing_desc];
    [categoryButton_place addSubview:categoryButton_place_icon];
    [categoryButton_place addSubview:categoryButton_place_title];
    [categoryButton_place addSubview:categoryButton_place_desc];
    [categoryButton_idea addSubview:categoryButton_idea_icon];
    [categoryButton_idea addSubview:categoryButton_idea_title];
    [categoryButton_idea addSubview:categoryButton_idea_desc];
    
    if ([configuration isEqualToString:@"cat"]) {
        [self setTitle:@"Categories"];
        [self showCategoryOverlay];
        
        if (category == 0) {
            [self dismissCategoryOverlay:categoryButton_thing];
        } else if (category == 1) {
            [self dismissCategoryOverlay:categoryButton_place];
        }
    } else {
        [self setTitle:@"Topics"];
        [self showTopicSearchOverlay];
    }
    
    [categorySelectionTip release];
    [categorySelectionTipSubtitle release];
    [categoryButton_thing_icon release];
    [categoryButton_thing_title release];
    [categoryButton_thing_desc release];
    [categoryButton_place_icon release];
    [categoryButton_place_title release];
    [categoryButton_place_desc release];
    [categoryButton_idea_icon release];
    [categoryButton_idea_title release];
    [categoryButton_idea_desc release];
    [cancelCategoryButtonBG release];
    [super viewDidLoad];
}

#pragma mark Customizations when the view appears/disappears
- (void)viewWillAppear:(BOOL)animated
{
    TipboxAppDelegate *appDelegate = (TipboxAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if ([configuration isEqualToString:@"cat"]) {
        [appDelegate navbarShadowMode_navbar];
    } else {
        [appDelegate navbarShadowMode_searchbar];
    }
    
    [appDelegate tabbarShadowMode_nobar];
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
        [dataRequest cancel];
        HUD.delegate = nil;
        dataRequest.delegate = nil;
        [appDelegate.strobeLight deactivateStrobeLight];
        
        if ([configuration isEqualToString:@"cat"]) {
            // If the subcategory is blank, but the category is selected, we automatically select "Other".
            if ((category == 0 || category == 1) && subcategory == -1) {
                if (category == 0) {
                    subcategory = 44;
                } else {
                    subcategory = 45;
                }
                
                pub.subcategory = subcategory;
                pub.selectedCategoryButtonSubtitle.text = @"Other";
            }
            
            if (category != -1 && pub.editor.text.length == 0) {
                [pub.editor becomeFirstResponder];
            }
        }
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
    if (tableView.tag == 0) {
        return [self.sortedKeys count];
    } else {
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section
{
    if (table.tag == 0) {
        NSArray *listData =[self.tableContents objectForKey:
                            [self.sortedKeys objectAtIndex:section]];
        return [listData count];
    } else {
        if ([self.topics count] == 0) {
            return 2;
        } else {
            return [self.topics count] + 2;  
        }
    }
}

- (CGFloat)tableView:(UITableView *)table heightForHeaderInSection:(NSInteger)section
{
    if (table.tag == 0) {
        return 50.0;
    } else {
        return 0.0;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (tableView.tag == 0) {
        if (section == 0) {
            CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
            UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenRect.size.width, 40.0)];
            
            // Add the label
            UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 300, 40)];
            headerLabel.backgroundColor = [UIColor clearColor];
            headerLabel.textColor = [UIColor colorWithRed:76.0/255.0 green:86.0/255.0 blue:108.0/255.0 alpha:1.0];
            headerLabel.font = [UIFont boldSystemFontOfSize:16];
            headerLabel.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.5];
            headerLabel.shadowOffset = CGSizeMake(0, 1);
            headerLabel.numberOfLines = 0;
            headerLabel.opaque = NO;
            headerLabel.text = @"Subcategories";
            [headerView addSubview:headerLabel];
            
            [headerLabel release];  
            
            return [headerView autorelease];
        } else {
           return nil;
        }
    } else {
        return nil;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    static NSString *CellIdentifier;
    int lastIndex = [self.topics count] - 1;
    int tailIndex = [self.topics count] + 1;
    
    if (tableView.tag == 0) {
        
        CellIdentifier = @"SubcategoryTableIdentifier";
        
        NSArray *listData =[self.tableContents objectForKey:
                            [self.sortedKeys objectAtIndex:[indexPath section]]];
        
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        }
        
        self.selectedSubcategoryIndexPath = indexPath;
        cell.tag = indexPath.row;
        cell.textLabel.text = [[listData objectAtIndex:indexPath.row] objectForKey:@"subcat"];
        
        if (cell.tag == selectedSubcategory) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    } else {
        if (indexPath.row == [self.topics count]) {	// Create topic cell.
            CellIdentifier = @"CreateTopicCell";
            createTopicCell = (TopicCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            if (createTopicCell == nil) {
                createTopicCell = [[[TopicCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
                createTopicCell.configuration = @"create";
            }
            
            createTopicCell.rowNumber = -1;
            NSMutableDictionary *topicData = [[[NSMutableDictionary alloc] 
                                              initWithObjectsAndKeys:@"-1", @"id",
                                                                    @"-1", @"topicid",
                                                                    @"-1", @"tipCount",
                                                                    @"-1", @"followCount",
                                                                    [NSString stringWithFormat:@"Create topic \"%@\"", topicSearchBox.text], @"content",
                                                                    @"-1", @"followsTopic", nil] autorelease];
            
            [createTopicCell populateCellWithContent:topicData];
            cell = createTopicCell;
        } else if (indexPath.row == tailIndex) {	// Load more cell.
            CellIdentifier = @"LoadMoreCell";
            loadMoreCell = (LoadMoreCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            if (loadMoreCell == nil) {
                loadMoreCell = [[[LoadMoreCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
                loadMoreCell.selectionStyle = UITableViewCellSelectionStyleNone;
                loadMoreCell.frame = CGRectMake(0, 0, 320, loadMoreCell.frame.size.height);
                [loadMoreCell.button addTarget:self action:@selector(loadMoreTopics) forControlEvents:UIControlEventTouchUpInside];
            }
            
            if (endOfFeed) {
                [loadMoreCell showEndMarker];
            } else {
                [loadMoreCell hideEndMarker];
                [loadMoreCell.button setTitle:@"Load more" forState:UIControlStateNormal];
                loadMoreCell.buttonTxtShadow.text = @"Load more";
                loadMoreCell.userInteractionEnabled = YES;
                loadMoreCell.button.enabled = YES; // Then don't forget to re-enable it!
            }
            
            cell = loadMoreCell;
        } else if (indexPath.row <= lastIndex) { // Topic cell.
            CellIdentifier = @"TopicCell";
            topicCell = (TopicCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            if (topicCell == nil) {
                topicCell = [[[TopicCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
                topicCell.showsFollowButton = NO;
                topicCell.showsDisclosureIndicator = YES;
                topicCell.configuration = @"regular";
                
                [topicCell.disclosureButton addTarget:self action:@selector(gotoTopic:) forControlEvents:UIControlEventTouchUpInside];
            }
            
            NSMutableDictionary *topicData = [self.topics objectAtIndex:indexPath.row];
            topicCell.rowNumber = indexPath.row;
            
            [topicCell populateCellWithContent:topicData];
            cell = topicCell;
        }
    }
    
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int lastIndex = [self.topics count] - 1;
    
    if (tableView.tag == 0) {
        return 44;
    } else {
        if ([self.topics count] > 0 && indexPath.row <= lastIndex && didDownloadTopics) {
            return 100 + (CELL_CONTENT_MARGIN * 2);
        } else {
            return 50 + (CELL_CONTENT_MARGIN * 2);
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag == 0) {
        int newRow = [indexPath row];
        int oldRow = [self.selectedSubcategoryIndexPath row];
        
        if (newRow != oldRow) {
            UITableViewCell *newCell = [tableView cellForRowAtIndexPath:indexPath];
            newCell.accessoryType = UITableViewCellAccessoryCheckmark;
            
            UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:selectedSubcategoryIndexPath]; 
            oldCell.accessoryType = UITableViewCellAccessoryNone;   
        } else {
            UITableViewCell *newCell = [tableView cellForRowAtIndexPath:indexPath];
            newCell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        
        NSArray *listData =[self.tableContents objectForKey:
                            [self.sortedKeys objectAtIndex:[indexPath section]]];
        
        subcategory = [[[listData objectAtIndex:[indexPath row]] objectForKey:@"id"] intValue];
        
        self.selectedSubcategoryIndexPath = indexPath;
        selectedSubcategory = self.selectedSubcategoryIndexPath.row;
        pub.subcategory = subcategory;
        pub.selectedSubcategory = selectedSubcategory;
        pub.selectedCategoryButtonSubtitle.text = [[subcategories_main objectAtIndex:selectedSubcategory] objectForKey:@"subcat"];
        [subcategoryTableView deselectRowAtIndexPath:indexPath animated:YES];
        
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
        int lastIndex = [self.topics count] - 1;
        
        if (selectedCell.tag == -1) {
            
            if (query.length > 32) { // Topic's too long.
                UIAlertView *alert = [[UIAlertView alloc]
                                      initWithTitle:@"Topic is too long!"
                                      message:@"Your topic exceeds 32 characters! Make it shorter?" delegate:self
                                      cancelButtonTitle:@"Back"
                                      otherButtonTitles:@"Continue", nil];
                alert.tag = 0;
                [alert show];
                [alert release];
                return;
            } else {
                topicid = 0;
                self.topic = query;
                
                pub.topicid = topicid;
                pub.topic = self.topic;
                
                [self.navigationController popViewControllerAnimated:YES];
            }
        } else if (indexPath.row <= lastIndex) {
            TopicCell *selectedTopicCell = (TopicCell *)selectedCell;
            topicid = selectedTopicCell.topicid;
            self.topic = selectedTopicCell.content;
            
            pub.topicid = topicid;
            pub.topic = self.topic;
            
            [self.navigationController popViewControllerAnimated:YES];
        }
        
        pub.topicButtonLabel.text = self.topic;
        [topicTableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

- (void)gotoTopic:(id)sender
{
    UIButton *gotoTopicButton = (UIButton *)sender;
    TopicCell *targetCell = (TopicCell *)[[[gotoTopicButton superview] superview] superview];
    
    TopicViewController *topicView = [[TopicViewController alloc] 
                                      initWithNibName:@"TopicView" 
                                      bundle:[NSBundle mainBundle]];
    
    topicView.topicName = targetCell.content;
    topicView.viewTopicid = targetCell.topicid;
    self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"New Tip" style:UIBarButtonItemStylePlain target:nil action:nil] autorelease];
    [self.navigationController pushViewController:topicView animated:YES];
    [topicView release];
    topicView = nil;
}

- (void)loadMoreTopics
{
    [loadMoreCell.button setTitle:@"Loading..." forState:UIControlStateDisabled];
    loadMoreCell.buttonTxtShadow.text = @"Loading...";
    loadMoreCell.userInteractionEnabled = NO;
    loadMoreCell.button.enabled = NO; // Don't forget to disable the button!
    
    [self searchTopicsforQuery:query batch:++batchNo];
}

#pragma ASIFormDataRequestDelegate methods
- (void)requestFinished:(ASIFormDataRequest *)request
{
    TipboxAppDelegate *appDelegate = (TipboxAppDelegate *)[[UIApplication sharedApplication] delegate];
    UIButton *dummyButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    
    NSError *jsonError;
    self.responseData = [NSJSONSerialization JSONObjectWithData:[request.responseString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:&jsonError];
    
    if ([activeConnectionIdentifier isEqualToString:@"subcats_thing"] || [activeConnectionIdentifier isEqualToString:@"subcats_place"]) { // Get subcategories.
        if ([[self.responseData objectForKey:@"error"] intValue] == 0) {
            
            for (NSDictionary *dictionary in [self.responseData objectForKey:@"responce"]) {
                if ([activeConnectionIdentifier isEqualToString:@"subcats_thing"]) {
                    [self.subcategories_thing addObject:dictionary];
                } else {
                    [self.subcategories_place addObject:dictionary];
                }
            }
            
            if ([activeConnectionIdentifier isEqualToString:@"subcats_thing"]) {
                didDownloadSubcategories_thing = YES;
                dummyButton.tag = 0;
            } else {
                didDownloadSubcategories_place = YES;
                dummyButton.tag = 1;
            }
            
            [self dismissCategoryOverlay:dummyButton];
        } else {
            HUD = [[MBProgressHUD alloc] initWithView:self.view];
            [self.view addSubview:HUD];
            
            HUD.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cross_white.png"]] autorelease];
            
            // Set custom view mode.
            HUD.mode = MBProgressHUDModeCustomView;
            HUD.dimBackground = YES;
            HUD.delegate = self;
            
            TipboxAppDelegate *appDelegate = (TipboxAppDelegate *)[[UIApplication sharedApplication] delegate];
            [appDelegate.strobeLight negativeStrobeLight];
            
            [HUD show:YES];
            [HUD hide:YES afterDelay:3];
            
            if ([[responseData objectForKey:@"errormsg"] isEqualToString:@"authFail"]) {
                [self.navigationController popToRootViewControllerAnimated:YES];
                [appDelegate logoutWithMessage:@"Sorry, but you need to log in again!"];
            }
        }
    } else if ([activeConnectionIdentifier isEqualToString:@"topicSearch"]) { // Topic search.
        if ([[self.responseData objectForKey:@"error"] intValue] == 0 && ![[NSNull null] isEqual:[self.responseData objectForKey:@"responce"]]) {
            NSDictionary *responce = [responseData objectForKey:@"responce"];
            
            if (batchNo == 0) {
                [self.topics removeAllObjects];
            }
            
            for (NSDictionary *topicObj in responce) {
                [self.topics addObject:[topicObj mutableCopy]];
            }
            
            if ([[self.responseData objectForKey:@"responce"] count] < BATCH_SIZE) {
                endOfFeed = YES;
            }
        } else {
            if (batchNo == 0) {
                [self.topics removeAllObjects];
            }
            
            // Handle error.
            NSLog(@"\nERROR!\n======\n%@", self.responseData);
            endOfFeed = YES; // Null marks end of feed.
            
            if ([[responseData objectForKey:@"errormsg"] isEqualToString:@"authFail"]) {
                [self.navigationController popToRootViewControllerAnimated:YES];
                [appDelegate logoutWithMessage:@"Sorry, but you need to log in again!"];
            }
        }
        
        didDownloadTopics = YES;
        [topicTableView reloadData];
        topicTableView.hidden = NO;
    }
    
    [dummyButton release];
    [appDelegate.strobeLight deactivateStrobeLight];
    activeConnectionIdentifier = @""; // Clear this out.
}

- (void)requestFailed:(ASIHTTPRequest *)request
{	
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
    
    [HUD show:YES];
    [HUD hide:YES afterDelay:3];
    
    if ([activeConnectionIdentifier isEqualToString:@"subcats_thing"]) {
        didDownloadSubcategories_thing = NO;
    } else {
        didDownloadSubcategories_place = NO;
    }
    
    // Reset the category overlay interface.
    activityIndicator_subcategories.hidden = YES;
    
    // Reset the topic overlay interface.
    topicSelectionTip.hidden = NO;
    activityIndicator_topics.hidden = YES;
    
    if (![topicSearchBox isFirstResponder]) {
        topicSelectionTip.frame = CGRectMake(0, 199, 320, 18);
        activityIndicator_topics.frame = CGRectMake(100, 217, 20, 20);
        topicSelectionTipSubtitle.frame = CGRectMake(0, 220, 320, 16);
    }
    
    if (category == 0) {
        topicSelectionTipSubtitle.text = @"E.g. iPhone, Portal 2, ...";
    } else if (category == 1) {
        topicSelectionTipSubtitle.text = @"E.g. Starbucks, Disneyland, ...";
    } else {
        topicSelectionTipSubtitle.text = @"E.g. Cooking, Gaming, ...";
    }
    
    [loadMoreCell hideEndMarker];
    [loadMoreCell.button setTitle:@"Could not connect!" forState:UIControlStateDisabled];
    loadMoreCell.buttonTxtShadow.text = @"Could not connect!";
    loadMoreCell.userInteractionEnabled = NO;
    loadMoreCell.button.enabled = NO; // Don't forget to disable the button!
    
    activeConnectionIdentifier = @""; // Clear this out.
}

#pragma UIAlertViewDelegate methods
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 0) { // Topic is too long
        if (buttonIndex == 1) {
            topicid = 0;
            self.topic = query;
            
            pub.topicid = topicid;
            pub.topic = self.topic;
            pub.topicButtonLabel.text = self.topic;
            
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    tableContents = nil;
    
    [topicSelectionOverlay release];
    [keyboardTouchpad release];
    [topicSearchBox release];
    [activityIndicator_topics release];
    [topicSelectionTip release];
    [topicSelectionTipSubtitle release];
    [topicTableView release];
    [categoryButton_thing release];
    [categoryButton_place release];
    [categoryButton_idea release];
    [cancelCategoryButton release];
    [categorySelectionOverlayDivider_1 release];
    [categorySelectionOverlayDivider_2 release];
    [subcategoryTableView release];
    [activityIndicator_subcategories release];
	[sortedKeys release];
    [subcategories_main release];
    [subcategories_thing release];
    [subcategories_place release];
    [super dealloc];
}


@end
