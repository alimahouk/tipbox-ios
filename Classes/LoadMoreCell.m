#import <QuartzCore/QuartzCore.h>
#import "LoadMoreCell.h"

#define CELL_CONTENT_WIDTH 320.0f
#define CELL_CONTENT_MARGIN 5.0f
#define MAIN_FONT_SIZE 18
#define MIN_MAIN_FONT_SIZE 15
#define SECONDARY_FONT_SIZE 12
#define MIN_SECONDARY_FONT_SIZE 10

@implementation LoadMoreCell

@synthesize button, buttonTxtShadow;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	
	if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]) {
        self.opaque = YES;
        self.contentView.opaque = YES;
        self.userInteractionEnabled = YES;
        self.frame = CGRectMake(0, 0, 320, 50);
        
        card = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"card_shadow_bg.png"] stretchableImageWithLeftCapWidth:7.0 topCapHeight:7.0]];
        card.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_paper_texture.png"]];
        card.opaque = YES;
        
        button = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
        button.adjustsImageWhenHighlighted = NO;
        button.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"paper_noise.png"]];
        [button setBackgroundImage:[[UIImage imageNamed:@"feed_button_grey_bg.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0] forState:UIControlStateHighlighted];
        [button setTitle:@"Load more" forState:UIControlStateNormal];
		[button setTitleColor:[UIColor colorWithRed:109.0/255.0 green:109.0/255.0 blue:109.0/255.0 alpha:1.0] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor colorWithRed:109.0/255.0 green:109.0/255.0 blue:109.0/255.0 alpha:1.0] forState:UIControlStateDisabled];
        [button setTitleShadowColor:[UIColor colorWithWhite:1.0 alpha:1.0] forState:UIControlStateNormal];
        [button setTitleShadowColor:[UIColor colorWithWhite:1.0 alpha:1.0] forState:UIControlStateDisabled];
        button.titleLabel.shadowOffset = CGSizeMake(0, 1);
		button.titleLabel.font = [UIFont fontWithName:@"Georgia" size:MIN_MAIN_FONT_SIZE];
        
        buttonTxtShadow = [[UILabel alloc] init];
		buttonTxtShadow.backgroundColor = [UIColor clearColor];
        buttonTxtShadow.textColor = [UIColor colorWithRed:109.0/255.0 green:109.0/255.0 blue:109.0/255.0 alpha:1.0];
		buttonTxtShadow.shadowColor = [UIColor colorWithRed:213.0/255.0 green:213.0/255.0 blue:213.0/255.0 alpha:0.8];
        buttonTxtShadow.shadowOffset = CGSizeMake(0, -1);
		buttonTxtShadow.font = [UIFont fontWithName:@"Georgia" size:MIN_MAIN_FONT_SIZE];
        buttonTxtShadow.textAlignment = UITextAlignmentCenter;
        buttonTxtShadow.text = @"Load more";
        buttonTxtShadow.opaque = YES;
        
        feedEndMarker = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"feed_end.png"]];
        feedEndMarker.opaque = YES;
        feedEndMarker.hidden = YES;
        
		card.frame = CGRectMake(8, 12, 303, 34);
        buttonTxtShadow.frame = CGRectMake(12, 16, 294, 26);
        button.frame = CGRectMake(12, 16, 295, 26);
        feedEndMarker.frame = CGRectMake(130, 14, 58, 24);
		
        [self.contentView addSubview:card];
        [self.contentView addSubview:button];
        [self.contentView addSubview:buttonTxtShadow];
        [self.contentView addSubview:feedEndMarker];
	}
	
	return self;
}

- (void)showEndMarker
{
    card.hidden = YES;
    button.hidden = YES;
    buttonTxtShadow.hidden = YES;
    feedEndMarker.hidden = NO;
}

- (void)hideEndMarker
{
    card.hidden = NO;
    button.hidden = NO;
    buttonTxtShadow.hidden = NO;
    feedEndMarker.hidden = YES;
}

- (void)dealloc
{
    [card release];
    [buttonTxtShadow release];
    [feedEndMarker release];
    [super dealloc];
}

@end
