#import <QuartzCore/QuartzCore.h>
#import "IdCardCell.h"
#import "TipboxAppDelegate.h"

#define CELL_CONTENT_WIDTH 320
#define CELL_CONTENT_MARGIN 5
#define MAIN_FONT_SIZE 18
#define MIN_MAIN_FONT_SIZE 15
#define SECONDARY_FONT_SIZE 12
#define MIN_SECONDARY_FONT_SIZE 10

@implementation IdCardCell

@synthesize rowNumber, userid, fullname, username, userPicHash;
@synthesize bio, nameLabel, usernameLabel, bioLabel;
@synthesize userThmbnl, isCurrentUser;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	
	if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]) {
        self.opaque = YES;
        self.contentView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_paper_texture.png"]];
        
        card = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"card_shadow_bg.png"] stretchableImageWithLeftCapWidth:7.0 topCapHeight:7.0]];
        card.opaque = YES;
        card.userInteractionEnabled = YES;
        
        cardBgTexture = [CALayer layer];
        cardBgTexture.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"paper_noise.png"]].CGColor;
        cardBgTexture.opaque = YES;
        [cardBgTexture setTransform:CATransform3DMakeScale(1.0, -1.0, 1.0)]; // Sets the co-ordinates right.
        
        detailsSeparator = [CALayer layer];
        detailsSeparator.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"solid_line_red.png"]].CGColor;
        detailsSeparator.frame = CGRectMake(7, 50, 288, 2);
        detailsSeparator.opaque = YES;
        [detailsSeparator setTransform:CATransform3DMakeScale(1.0, -1.0, 1.0)];
        
		userThmbnlOverlay = [[UIImage imageNamed:@"photo_frame.png"] stretchableImageWithLeftCapWidth:4.0 topCapHeight:3.0];
		userThmbnlOverlayView = [[UIImageView alloc] initWithImage:userThmbnlOverlay];
        userThmbnlOverlayView.frame = CGRectMake(9, 10, 36, 36);
		
		userThmbnl = [[EGOImageView alloc] initWithFrame:CGRectMake(12, 12, 30, 30)];
		userThmbnl.placeholderImage = [UIImage imageNamed:@"user_placeholder_default.png"];
        userThmbnl.opaque = YES;
        
        currentUserIndicator = [[LPLabel alloc] initWithFrame:CGRectMake(195, 19, 100, 20)];
		currentUserIndicator.backgroundColor = [UIColor clearColor];
		currentUserIndicator.textColor = [UIColor colorWithRed:157.0/255.0 green:157.0/255.0 blue:157.0/255.0 alpha:1.0];
		currentUserIndicator.shadowColor = [UIColor colorWithWhite:1.0 alpha:1.0];
		currentUserIndicator.numberOfLines = 1;
		currentUserIndicator.font = [UIFont fontWithName:@"HelveticaNeue" size:MIN_SECONDARY_FONT_SIZE];
        currentUserIndicator.textAlignment = UITextAlignmentRight;
        currentUserIndicator.text = @"← That's you!";
        currentUserIndicator.hidden = YES;
        
		nameLabel = [[UILabel alloc] init];
		nameLabel.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"paper_noise.png"]];
		nameLabel.textColor = [UIColor colorWithRed:54.0/255.0 green:54.0/255.0 blue:54.0/255.0 alpha:1.0];
		nameLabel.numberOfLines = 1;
		nameLabel.minimumFontSize = 8.;
        nameLabel.adjustsFontSizeToFitWidth = YES;
		nameLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:MIN_MAIN_FONT_SIZE];
        
        usernameLabel = [[LPLabel alloc] init];
		usernameLabel.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"paper_noise.png"]];
		usernameLabel.textColor = [UIColor colorWithRed:157.0/255.0 green:157.0/255.0 blue:157.0/255.0 alpha:1.0];
		usernameLabel.shadowColor = [UIColor colorWithWhite:1.0 alpha:1.0];
		usernameLabel.numberOfLines = 1;
		usernameLabel.minimumFontSize = 8.;
        usernameLabel.adjustsFontSizeToFitWidth = YES;
		usernameLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:MIN_MAIN_FONT_SIZE];
		
		bioLabel = [[LPLabel alloc] init];
		bioLabel.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"paper_noise.png"]];
		bioLabel.textColor = [UIColor colorWithRed:157.0/255.0 green:157.0/255.0 blue:157.0/255.0 alpha:1.0];
        bioLabel.shadowColor = [UIColor colorWithWhite:1.0 alpha:1.0];
		bioLabel.numberOfLines = 0;
		bioLabel.lineBreakMode = UILineBreakModeWordWrap;
        bioLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:MIN_MAIN_FONT_SIZE];
        
        peopleHelpedLabel = [[UILabel alloc] initWithFrame:CGRectMake(7, 9, 280, 20)];
        peopleHelpedLabel.backgroundColor = [UIColor colorWithRed:205.0/255.0 green:205.0/255.0 blue:201.0/255.0 alpha:1.0];
        peopleHelpedLabel.textColor = [UIColor colorWithRed:54.0/255.0 green:54.0/255.0 blue:54.0/255.0 alpha:1.0];
        peopleHelpedLabel.shadowColor = [UIColor colorWithWhite:1.0 alpha:1.0];
        peopleHelpedLabel.shadowOffset = CGSizeMake(0, 1);
        peopleHelpedLabel.numberOfLines = 1;
        peopleHelpedLabel.lineBreakMode = UILineBreakModeWordWrap;
        peopleHelpedLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:MIN_MAIN_FONT_SIZE];
        peopleHelpedLabel.opaque = YES;
        
        peopleHelpedTextLabel = [[UILabel alloc] init];
        peopleHelpedTextLabel.backgroundColor = [UIColor colorWithRed:205.0/255.0 green:205.0/255.0 blue:201.0/255.0 alpha:1.0];
        peopleHelpedTextLabel.textColor = [UIColor colorWithRed:54.0/255.0 green:54.0/255.0 blue:54.0/255.0 alpha:1.0];
        peopleHelpedTextLabel.shadowColor = [UIColor colorWithWhite:1.0 alpha:1.0];
        peopleHelpedTextLabel.shadowOffset = CGSizeMake(0, 1);
        peopleHelpedTextLabel.numberOfLines = 1;
        peopleHelpedTextLabel.lineBreakMode = UILineBreakModeWordWrap;
        peopleHelpedTextLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:SECONDARY_FONT_SIZE];
        peopleHelpedTextLabel.opaque = YES;
        
        peopleHelpedStrip = [CALayer layer];
        peopleHelpedStrip.backgroundColor = [UIColor colorWithRed:205.0/255.0 green:205.0/255.0 blue:201.0/255.0 alpha:1.0].CGColor;
        peopleHelpedStrip.masksToBounds = YES;
        peopleHelpedStrip.borderWidth = 0.7;
        peopleHelpedStrip.borderColor = [UIColor colorWithRed:199.0/255.0 green:199.0/255.0 blue:199.0/255.0 alpha:1.0].CGColor;
        peopleHelpedStrip.opaque = YES;
        
        isCurrentUser = NO;
		
        [card.layer addSublayer:cardBgTexture];
		[card addSubview:userThmbnlOverlayView];
		[card addSubview:userThmbnl];
        [card addSubview:currentUserIndicator];
		[card addSubview:nameLabel];
        [card addSubview:usernameLabel];
        [card.layer addSublayer:detailsSeparator];
        [card addSubview:bioLabel];
        [card.layer addSublayer:peopleHelpedStrip];
        [peopleHelpedStrip addSublayer:peopleHelpedLabel.layer];
        [peopleHelpedStrip addSublayer:peopleHelpedTextLabel.layer];
        
        self.userInteractionEnabled = YES;
		[self.contentView addSubview:card];
	}
	
	return self;
}

- (void)populateCellWithContent:(NSMutableDictionary *)userInfo
{
    TipboxAppDelegate *appDelegate = (TipboxAppDelegate *)[[UIApplication sharedApplication] delegate];    
    global = appDelegate.global;
    self.tag = rowNumber; // Special identifier.
	
    userid = [[userInfo objectForKey:@"id"] intValue];
    fullname = [userInfo objectForKey:@"fullname"];
	username = [userInfo objectForKey:@"username"];
    bio = [userInfo objectForKey:@"bio"];
	userPicHash = [userInfo objectForKey:@"pichash"];
    peopleHelped = [[userInfo objectForKey:@"helpCount"] intValue];
    NSString *profilePicPath = [NSString stringWithFormat:@"http://%@/userphotos/%d/profile/m_%@.jpg", SH_DOMAIN, userid, [userInfo objectForKey:@"pichash"]];
	userThmbnl.imageURL = [NSURL URLWithString:profilePicPath];
    
    if ([[NSNull null] isEqual:bio] || bio.length == 0) {
        bio = @"";
        detailsSeparator.hidden = YES; // Hide the red separator.
    } else {
        detailsSeparator.hidden = NO;
    }
    
    nameLabel.text = fullname;
    usernameLabel.text = [NSString stringWithFormat:@"@%@", username];
    bioLabel.text = bio;
    peopleHelpedLabel.text = [NSString stringWithFormat:@"%d", peopleHelped];
    peopleHelpedTextLabel.text = [NSString stringWithFormat:@"%@ helped", peopleHelped == 1 ? @"person" : @"people"];
	
	CGSize nameSize = [fullname sizeWithFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:MIN_MAIN_FONT_SIZE] constrainedToSize:CGSizeMake(230, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];
    CGSize usernameSize = [usernameLabel.text sizeWithFont:[UIFont fontWithName:@"HelveticaNeue" size:MIN_MAIN_FONT_SIZE] constrainedToSize:CGSizeMake(230, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];
    CGSize bioSize = [bio sizeWithFont:[UIFont fontWithName:@"HelveticaNeue" size:MIN_MAIN_FONT_SIZE] constrainedToSize:CGSizeMake(287, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];
    CGSize peopleHelpedSize = [peopleHelpedLabel.text sizeWithFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:MIN_MAIN_FONT_SIZE] constrainedToSize:CGSizeMake(248, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];
	
    // Customizations if the current user owns the current tip.
    if ([[global readProperty:@"userid"] intValue] == userid) {
        isCurrentUser = YES;
        currentUserIndicator.hidden = NO;
    } else {
        isCurrentUser = NO;
        currentUserIndicator.hidden = YES;
    }
	
	nameLabel.frame = CGRectMake(51, 10, nameSize.width, 18);
    usernameLabel.frame = CGRectMake(51, 28, usernameSize.width, 17);
    bioLabel.frame = CGRectMake(11, 65, bioSize.width, bioSize.height);
    peopleHelpedStrip.frame = CGRectMake(4, bioSize.height + 77, 300, 33);
    peopleHelpedTextLabel.frame = CGRectMake(peopleHelpedSize.width + 11, 9, 280, 20);
    cardBgTexture.frame = CGRectMake(4, 4, 300, bioSize.height + 106);
    card.frame = CGRectMake(6, 10, 308, bioSize.height + 114);
    self.frame = CGRectMake(0, 0, 320, card.frame.size.height + 10);
}

#pragma mark Generate images with given fill color
// Convert the image's fill color to the passed in color
- (UIImage *)imageFilledWith:(UIColor *)color using:(UIImage *)startImage
{
    // Create the proper sized rect
    CGRect imageRect = CGRectMake(0, 0, CGImageGetWidth(startImage.CGImage), CGImageGetHeight(startImage.CGImage));
    
    // Create a new bitmap context
    CGContextRef context = CGBitmapContextCreate(NULL, imageRect.size.width, imageRect.size.height, 8, 0, CGImageGetColorSpace(startImage.CGImage), kCGImageAlphaPremultipliedLast);
    
    // Use the passed in image as a clipping mask
    CGContextClipToMask(context, imageRect, startImage.CGImage);
    // Set the fill color
    CGContextSetFillColorWithColor(context, color.CGColor);
    // Fill with color
    CGContextFillRect(context, imageRect);
    
    // Generate a new image
    CGImageRef newCGImage = CGBitmapContextCreateImage(context);
    UIImage* newImage = [UIImage imageWithCGImage:newCGImage scale:startImage.scale orientation:startImage.imageOrientation];
    
    // Cleanup
    CGContextRelease(context);
    CGImageRelease(newCGImage);
    
    return newImage;
}
 
// Override these methods to customize cell highlighting.
- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    // Disable implicit animations. Make sure to wrap the affected code
    // in a block, otherwise it messes up pushViewController animations!
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    
    if (highlighted) {
        cardBgTexture.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"feed_button_grey_bg.png"]].CGColor;
        nameLabel.backgroundColor = [UIColor clearColor];
        usernameLabel.backgroundColor = [UIColor clearColor];
        bioLabel.backgroundColor = [UIColor clearColor];
    } else {
        cardBgTexture.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"paper_noise.png"]].CGColor;
        nameLabel.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"paper_noise.png"]];
        usernameLabel.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"paper_noise.png"]];
        bioLabel.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"paper_noise.png"]];
    }
    
    [CATransaction commit];
    
    [super setHighlighted:NO animated:animated];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:NO animated:animated];
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
	[super willMoveToSuperview:newSuperview];
	
	if (!newSuperview) {
		[userThmbnl cancelImageLoad];
	}
}

- (void)dealloc
{
	[userThmbnlOverlayView release];
    [currentUserIndicator release];
	[nameLabel release];
    [usernameLabel release];
	[bioLabel release];
    [peopleHelpedLabel release];
    [peopleHelpedTextLabel release];
    [userThmbnl release];
    [super dealloc];
}

@end
