#import <QuartzCore/QuartzCore.h>
#import "TipCard.h"
#import "TipboxAppDelegate.h"

#define CELL_CONTENT_WIDTH 320
#define CELL_CONTENT_MARGIN 5
#define CELL_COLLAPSED_HEIGHT 87
#define MAIN_FONT_SIZE 18
#define MIN_MAIN_FONT_SIZE 15
#define SECONDARY_FONT_SIZE 12
#define MIN_SECONDARY_FONT_SIZE 10

@implementation TipCard

@synthesize timelineData, cardIndex, tipid, tipUserid, fullname, username;
@synthesize content, catid, subcat, parentCat, topicid, topicContent, timestamp, tipTxtLabel;
@synthesize storyActor, usernameLabel, timestampLabel;
@synthesize userThmbnl, genius, showsMarkUsefulButton;
@synthesize topicLabel;

- (id)init
{
    self = [super init];
    if (self) {
        card = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"card_shadow_bg.png"] stretchableImageWithLeftCapWidth:7.0 topCapHeight:7.0]];
        card.userInteractionEnabled = YES;
        
        cardBgTexture = [[UIView alloc] init];
        cardBgTexture.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"paper_noise.png"]];
        cardBgTexture.opaque = YES;
        
        detailsSeparator = [CALayer layer];
        detailsSeparator.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"solid_line_red.png"]].CGColor;
        detailsSeparator.frame = CGRectMake(10, 53, 288, 2);
        detailsSeparator.opaque = YES;
        [detailsSeparator setTransform:CATransform3DMakeScale(1.0, -1.0, 1.0)];
        
		userThmbnlOverlay = [[UIImage imageNamed:@"photo_frame.png"] stretchableImageWithLeftCapWidth:4.0 topCapHeight:3.0];
		userThmbnlOverlayView = [[UIImageView alloc] initWithImage:userThmbnlOverlay];
        userThmbnlOverlayView.frame = CGRectMake(9, 10, 36, 36);
		
		userThmbnl = [[EGOImageView alloc] initWithFrame:CGRectMake(12, 12, 30, 30)];
		userThmbnl.placeholderImage = [UIImage imageNamed:@"user_placeholder_default.png"];
        userThmbnl.opaque = YES;
        
		storyActor = [[UILabel alloc] init];
		storyActor.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"paper_noise.png"]];
		storyActor.textColor = [UIColor colorWithRed:54.0/255.0 green:54.0/255.0 blue:54.0/255.0 alpha:1.0];
		storyActor.numberOfLines = 1;
		storyActor.minimumFontSize = 8.;
        storyActor.adjustsFontSizeToFitWidth = YES;
		storyActor.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:MIN_MAIN_FONT_SIZE];
        
        usernameLabel = [[LPLabel alloc] init];
		usernameLabel.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"paper_noise.png"]];
		usernameLabel.textColor = [UIColor colorWithRed:157.0/255.0 green:157.0/255.0 blue:157.0/255.0 alpha:1.0];
		usernameLabel.shadowColor = [UIColor colorWithWhite:1.0 alpha:1.0];
		usernameLabel.numberOfLines = 1;
		usernameLabel.minimumFontSize = 8.;
        usernameLabel.adjustsFontSizeToFitWidth = YES;
		usernameLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:MIN_MAIN_FONT_SIZE];
		
		tipTxtLabel = [[UILabel alloc] init];
		tipTxtLabel.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"paper_noise.png"]];
		tipTxtLabel.textColor = [UIColor colorWithRed:54.0/255.0 green:54.0/255.0 blue:54.0/255.0 alpha:1.0];
		tipTxtLabel.numberOfLines = 0;
		tipTxtLabel.lineBreakMode = UILineBreakModeWordWrap;
        tipTxtLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:MIN_MAIN_FONT_SIZE];
        
        geniusIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"genius_star.png"]];
        geniusIcon.hidden = YES;
        genius = NO;
        
        clockIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"clock_grey.png"]];
        clockIcon.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"paper_noise.png"]];
		
		timestampLabel = [[LPLabel alloc] initWithFrame:CGRectMake(198, 18, 100, 20)];
		timestampLabel.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"paper_noise.png"]];
		timestampLabel.textColor = [UIColor colorWithRed:157.0/255.0 green:157.0/255.0 blue:157.0/255.0 alpha:1.0];
		timestampLabel.shadowColor = [UIColor colorWithWhite:1.0 alpha:1.0];
		timestampLabel.numberOfLines = 1;
		timestampLabel.lineBreakMode = UILineBreakModeWordWrap;
		timestampLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:MIN_MAIN_FONT_SIZE];
        timestampLabel.textAlignment = UITextAlignmentRight;
        
        markUsefulButton = [[ToggleButton alloc] init];
        [markUsefulButton setBackgroundImage:[UIImage imageNamed:@"feed_useful_button.png"] forState:UIControlStateNormal];
        [markUsefulButton setBackgroundImage:[UIImage imageNamed:@"feed_useful_button_pressed.png"] forState:UIControlStateHighlighted];
        [markUsefulButton addTarget:self action:@selector(markUseful) forControlEvents:UIControlEventTouchUpInside];
        markUsefulButton.showsTouchWhenHighlighted = YES;
        markUsefulButton.opaque = YES;
        markUsefulButton.hidden = YES;
        marked = NO;
        
        showsMarkUsefulButton = NO;
        
        topicStrip = [CALayer layer];
        topicStrip.backgroundColor = [UIColor colorWithRed:205.0/255.0 green:205.0/255.0 blue:201.0/255.0 alpha:1.0].CGColor;
        topicStrip.borderWidth = 0.7;
        topicStrip.borderColor = [UIColor colorWithRed:199.0/255.0 green:199.0/255.0 blue:199.0/255.0 alpha:1.0].CGColor;
        topicStrip.opaque = YES;
        
        topicStripIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tab_bar_topics.png"]];
        topicStripIcon.backgroundColor = [UIColor colorWithRed:205.0/255.0 green:205.0/255.0 blue:201.0/255.0 alpha:1.0];
        topicStripIcon.frame = CGRectMake(7, 1, 30, 30);
        topicStripIcon.opaque = YES;
        
        topicLabel = [[UILabel alloc] initWithFrame:CGRectMake(43, 7, 200, 19)];
		topicLabel.backgroundColor = [UIColor colorWithRed:205.0/255.0 green:205.0/255.0 blue:201.0/255.0 alpha:1.0];
		topicLabel.textColor = [UIColor colorWithRed:54.0/255.0 green:54.0/255.0 blue:54.0/255.0 alpha:1.0];
		topicLabel.shadowColor = [UIColor colorWithWhite:1.0 alpha:1.0];
        topicLabel.shadowOffset = CGSizeMake(0, 1);
		topicLabel.numberOfLines = 1;
		topicLabel.lineBreakMode = UILineBreakModeWordWrap;
		topicLabel.font = [UIFont fontWithName:@"Georgia" size:MIN_MAIN_FONT_SIZE];
        topicLabel.opaque = YES;
        
        catIcon = [[UIImageView alloc] initWithFrame:CGRectMake(275, 8, 20, 20)];
        catIcon.backgroundColor = [UIColor colorWithRed:205.0/255.0 green:205.0/255.0 blue:201.0/255.0 alpha:1.0];
        catIcon.opaque = YES;
        
        [card addSubview:cardBgTexture];
		[card addSubview:userThmbnlOverlayView];
		[card addSubview:userThmbnl];
		[card addSubview:storyActor];
        [card addSubview:usernameLabel];
        [card addSubview:geniusIcon];
        [card addSubview:timestampLabel];
        [card addSubview:clockIcon];
        [card.layer addSublayer:detailsSeparator];
        [card addSubview:tipTxtLabel];
        [card addSubview:markUsefulButton];
        [card.layer addSublayer:topicStrip];
        [topicStrip addSublayer:topicStripIcon.layer];
        [topicStrip addSublayer:topicLabel.layer];
        [topicStrip addSublayer:catIcon.layer];
        
		[self addSubview:card];
    }
    
    return self;
}

- (void)populateCellWithContent:(NSMutableDictionary *)tip
{
    TipboxAppDelegate *appDelegate = (TipboxAppDelegate *)[[UIApplication sharedApplication] delegate];
    global = appDelegate.global;
    
    tipid = [[tip objectForKey:@"id"] intValue];
    tipUserid = [[tip objectForKey:@"userid"] intValue];
    fullname = [tip objectForKey:@"fullname"];
	username = [tip objectForKey:@"username"];
    catid = [[tip objectForKey:@"catid"] intValue];
    subcat = [tip objectForKey:@"subcat"];
    parentCat = [tip objectForKey:@"parentcat"];
	content = [tip objectForKey:@"content"];
    topicid = [[tip objectForKey:@"topicid"] intValue];
    topicContent = [tip objectForKey:@"topicContent"];
	timestamp = [tip objectForKey:@"relativeTime"];
    timestamp_short = [tip objectForKey:@"relativeTimeShort"];
    actualTime = [tip objectForKey:@"time"];
    NSString *profilePicPath = [NSString stringWithFormat:@"http://%@/userphotos/%d/profile/m_%@.jpg", SH_DOMAIN, tipUserid, [tip objectForKey:@"pichash"]];
	userThmbnl.imageURL = [NSURL URLWithString:profilePicPath];
    
    if (genius) {
        geniusIcon.hidden = NO;
    } else {
        geniusIcon.hidden = YES;
    }
    
    if ([parentCat isEqualToString:@"thing"]) {
        catIcon.image = [UIImage imageNamed:@"feed_category_thing.png"];
    } else if ([parentCat isEqualToString:@"place"]) {
        catIcon.image = [UIImage imageNamed:@"feed_category_place.png"];
    } else {
        catIcon.image = [UIImage imageNamed:@"feed_category_idea.png"];
    }
    
    storyActor.text = fullname;
    usernameLabel.text = [NSString stringWithFormat:@"@%@", username];
	timestampLabel.text = timestamp_short;
    topicLabel.text = topicContent;
    tipTxtLabel.text = content;
	
    CGSize actorSize = [fullname sizeWithFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:MIN_MAIN_FONT_SIZE] constrainedToSize:CGSizeMake(258, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];
    CGSize usernameSize = [usernameLabel.text sizeWithFont:[UIFont fontWithName:@"HelveticaNeue" size:MIN_MAIN_FONT_SIZE] constrainedToSize:CGSizeMake(258, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];
	CGSize timestampSize = [timestamp_short sizeWithFont:[UIFont fontWithName:@"HelveticaNeue" size:MIN_MAIN_FONT_SIZE] constrainedToSize:CGSizeMake(100, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];
	CGSize tipTxtSize;
    
    if (showsMarkUsefulButton) {
        markUsefulButton.hidden = NO;
        
        tipTxtSize = [tipTxtLabel.text sizeWithFont:[UIFont fontWithName:@"HelveticaNeue" size:MIN_MAIN_FONT_SIZE] constrainedToSize:CGSizeMake(253, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];
    } else {
        markUsefulButton.hidden = YES;
        
        // Since the mark button is hidden, we might as well use up that otherwise wasted space. ;)
        tipTxtSize = [tipTxtLabel.text sizeWithFont:[UIFont fontWithName:@"HelveticaNeue" size:MIN_MAIN_FONT_SIZE] constrainedToSize:CGSizeMake(288, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];
    }
    
    // Disable implicit animations.
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    
	storyActor.frame = CGRectMake(51, 10, actorSize.width, 18);
    usernameLabel.frame = CGRectMake(51, 30, usernameSize.width, 17);
    geniusIcon.frame = CGRectMake(actorSize.width + 53, 11, 16, 16);
    clockIcon.frame = CGRectMake(279 - timestampSize.width, 19, 16, 16); // The clock icon should be exactly before the time + a bit of padding.
    markUsefulButton.frame = CGRectMake(258, 41 + (tipTxtSize.height / 2), 50, 50); // We use half of the height of the icon (32px in this case) 'cuz we wanna center the button with respect to the height of the tip text.
    tipTxtLabel.frame = CGRectMake(11, 65, tipTxtSize.width, tipTxtSize.height);
    cardBgTexture.frame = CGRectMake(4, 4, 300, tipTxtSize.height + 106);
    topicStrip.frame = CGRectMake(4, tipTxtSize.height + 164 - CELL_COLLAPSED_HEIGHT, 300, 33); // -0.7 on the x-axis to account for the 0.7px border.
    card.frame = CGRectMake(6, 10, 308, tipTxtSize.height + 201 - CELL_COLLAPSED_HEIGHT);
    self.frame = CGRectMake(0, 0, 320, card.frame.size.height + 10);
    
    [CATransaction commit];
}

- (void)markUseful
{
    if (marked) {
        [markUsefulButton setBackgroundImage:[UIImage imageNamed:@"feed_useful_button.png"] forState:UIControlStateNormal];
        markUsefulButton.activated = NO;
        marked = NO;
    } else {
        [markUsefulButton setBackgroundImage:[UIImage imageNamed:@"feed_useful_button_activated.png"] forState:UIControlStateNormal];
        markUsefulButton.activated = YES;
        marked = YES;
    }
}

- (void)dealloc
{
    [timelineData release];
    [card release];
    [cardBgTexture release];
	[userThmbnlOverlayView release];
	[storyActor release];
    [usernameLabel release];
	[tipTxtLabel release];
    [geniusIcon release];
    [clockIcon release];
	[timestampLabel release];
	[userThmbnl release];
    [topicStripIcon release];
    [catIcon release];
    [super dealloc];
}

@end
