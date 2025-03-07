#import <QuartzCore/QuartzCore.h>
#import "Intro_InterestsViewController.h"
#import "TipboxAppDelegate.h"
#import "FeedViewController.h"

#define MAIN_FONT_SIZE 18
#define MIN_MAIN_FONT_SIZE 15
#define SECONDARY_FONT_SIZE 12
#define MIN_SECONDARY_FONT_SIZE 10
#define kOFFSET_FOR_KEYBOARD 60.0

@implementation Intro_InterestsViewController

@synthesize configuration;

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

- (void)getTopicsForInterests
{
    TipboxAppDelegate *appDelegate = (TipboxAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.strobeLight activateStrobeLight];
    saveButton.enabled = NO;
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/tipbox/api/quickguide", SH_DOMAIN]];
    NSString *joinedString = [selectedInterests componentsJoinedByString:@","];
    
    dataRequest = [[ASIFormDataRequest requestWithURL:url] retain];
    [dataRequest setPostValue:appDelegate.SHToken forKey:@"token"];
    [dataRequest setPostValue:joinedString forKey:@"ids"];
    [dataRequest setCompletionBlock:^{
        NSError *jsonError;
        responseData = [NSJSONSerialization JSONObjectWithData:[dataRequest.responseString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:&jsonError];
        
        [self skipIntro];
        [appDelegate.strobeLight deactivateStrobeLight];
    }];
    [dataRequest setFailedBlock:^{
        [appDelegate.strobeLight negativeStrobeLight];
        
        NSError *error = [dataRequest error];
        NSLog(@"%@", error);
    }];
    [dataRequest startAsynchronous];
}

- (void)skipIntro
{
    TipboxAppDelegate *appDelegate = (TipboxAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if ([configuration isEqualToString:@"feed"]) {
        NSArray *viewControllers = self.navigationController.viewControllers;
        FeedViewController *feed = (FeedViewController *)[viewControllers objectAtIndex:0];
        [feed.refreshHeaderView egoRefreshScrollViewDataSourceStartManualLoading:feed.timelineFeed];
    } else {
        [appDelegate closeBoxWithConfiguration:@"home"];
    }
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)gotoNextPage
{
    
    if (activePage < 3) {
        UIView *currentView;
        UIView *targetView;
        
        switch (activePage) {
            case 1:
                currentView = card_1;
                targetView = card_2;
                nextPageButton.enabled = YES;
                previousPageButton.enabled = YES;
                break;
                
            case 2:
                currentView = card_2;
                targetView = card_3;
                
                previousPageButton.enabled = YES;
                
                if ([selectedInterests count] > 0) {
                    nextPageButton.enabled = YES;
                } else {
                    nextPageButton.enabled = NO;
                }
                
                break;
                
            default:
                break;
        }
        
        [NSTimer scheduledTimerWithTimeInterval:0.0797
                                         target:self
                                       selector:@selector(hidePaperBottoms)
                                       userInfo:nil
                                        repeats:NO];
        
        [UIView transitionWithView:cardPile duration:0.6 options:UIViewAnimationOptionTransitionCurlUp animations:^{
            targetView.hidden = NO;
            currentView.hidden = YES;
            pageCounter.text = [NSString stringWithFormat:@"Page %d of 3", activePage + 1];
        } completion:^(BOOL finished){
            activePage++;
        }];
    }
}

- (void)gotoPreviousPage
{
    if (activePage > 1 && activePage <= 3) {
        
        UIView *currentView;
        UIView *targetView;
        
        switch (activePage) {
            case 3:
                currentView = card_3;
                targetView = card_2;
                nextPageButton.enabled = YES;
                previousPageButton.enabled = YES;
                break;
                
            case 2:
                currentView = card_2;
                targetView = card_1;
                nextPageButton.enabled = YES;
                previousPageButton.enabled = NO;
                break;
                
            default:
                break;
        }
        
        [NSTimer scheduledTimerWithTimeInterval:0.447
                                         target:self
                                       selector:@selector(showPaperBottoms)
                                       userInfo:nil
                                        repeats:NO];
        
        [UIView transitionWithView:cardPile duration:0.6 options:UIViewAnimationOptionTransitionCurlDown animations:^{
            targetView.hidden = NO;
            currentView.hidden = YES;
            pageCounter.text = [NSString stringWithFormat:@"Page %d of 3", activePage - 1];
        } completion:^(BOOL finished){
            activePage--;
        }];
    }
}

- (void)hidePaperBottoms
{
    NSString *imageName;
    
    switch (activePage) {
        case 1:
            imageName = @"intro_interests_cards_bottom_2.png";
            break;
            
        case 2:
            imageName = @"intro_interests_cards_bottom_1.png";
            break;
            
        default:
            break;
    }
    
    cardPile_bg.image = [UIImage imageNamed:imageName];
}

- (void)showPaperBottoms
{
    NSString *imageName;
    
    switch (activePage) {
        case 3:
            imageName = @"intro_interests_cards_bottom_2.png";
            break;
            
        case 2:
            imageName = @"intro_interests_cards_bottom_3.png";
            break;
            
        default:
            break;
    }
    
    cardPile_bg.image = [UIImage imageNamed:imageName];
}

- (void)toggleInterest:(id)sender
{
    UIButton *interestButton = (UIButton *)sender;
    UIImageView *paperPin = (UIImageView *)[self.view viewWithTag:interestButton.tag + 1100];
    UIImageView *paperCutBg = (UIImageView *)[self.view viewWithTag:interestButton.tag + 1000];
    UIImageView *paperCut = (UIImageView *)[interestButton viewWithTag:999];
    
    CGRect position_final = paperPin.frame;
    CGRect position_init = position_final;
    position_init.origin.y = -38;
    
    interestButton.enabled = NO;
    
    if (paperCut.hidden) {
        paperCut.hidden = NO;
        paperCut.layer.opacity = 0;
        paperCutBg.hidden = NO;
        paperCutBg.layer.opacity = 0;
        
        paperPin.frame = position_init;
        paperPin.hidden = NO;
        
        [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            paperPin.frame = position_final;
        } completion:^(BOOL finished){
            // ANIMACEPTION!!!
            // (to create that momentum effect)
            [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                paperCut.layer.opacity = 1;
                paperCutBg.layer.opacity = 1;
            } completion:^(BOOL finished){
                [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
                    CGAffineTransform transform_button = CGAffineTransformMakeRotation(35 / 180.0 * M_PI);
                    interestButton.transform = transform_button;
                } completion:^(BOOL finished){
                    [UIView animateWithDuration:0.13 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
                        CGAffineTransform transform_button = CGAffineTransformMakeRotation(17 / 180.0 * M_PI);
                        interestButton.transform = transform_button;
                    } completion:^(BOOL finished){
                        [UIView animateWithDuration:0.12 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
                            CGAffineTransform transform_button = CGAffineTransformMakeRotation(30 / 180.0 * M_PI);
                            interestButton.transform = transform_button;
                        } completion:^(BOOL finished){
                            [UIView animateWithDuration:0.11 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
                                CGAffineTransform transform_button = CGAffineTransformMakeRotation(18 / 180.0 * M_PI);
                                interestButton.transform = transform_button;
                            } completion:^(BOOL finished){
                                [UIView animateWithDuration:0.11 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
                                    CGAffineTransform transform_button = CGAffineTransformMakeRotation(22 / 180.0 * M_PI);
                                    interestButton.transform = transform_button;
                                } completion:^(BOOL finished){
                                    interestButton.enabled = YES;
                                }];
                            }];
                        }];
                    }];
                }];
            }];
        }];
        
        [selectedInterests addObject:[NSNumber numberWithInt:interestButton.tag]];
    } else {
        [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            paperPin.frame = position_init;
        } completion:^(BOOL finished){
            [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                CGAffineTransform transform_button = CGAffineTransformMakeRotation(0 / 180.0 * M_PI);
                interestButton.transform = transform_button;
            } completion:^(BOOL finished){
                paperCutBg.layer.opacity = 0;
                paperCutBg.hidden = YES;
                paperPin.hidden = YES;
                paperPin.frame = position_final;
                
                [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                    paperCut.layer.opacity = 0;
                    
                } completion:^(BOOL finished){
                    paperCut.hidden = YES;
                    
                    interestButton.enabled = YES;
                }];
            }];
        }];
        
        [selectedInterests removeObject:[NSNumber numberWithInt:interestButton.tag]];
    }
    
    // Enable the "Next" button only if we have items selected.
    if ([selectedInterests count] > 0) {
        saveButton.enabled = YES;
    } else {
        saveButton.enabled = NO;
    }
    
    if (activePage == 3) {
        if ([selectedInterests count] > 0) {
            nextPageButton.enabled = YES;
        } else {
            nextPageButton.enabled = NO;
        }
    }
}

- (void)viewDidLoad
{
    TipboxAppDelegate *appDelegate = (TipboxAppDelegate *)[[UIApplication sharedApplication] delegate];
    global = appDelegate.global;
    CGRect screenBound = [[UIScreen mainScreen] bounds];
    CGFloat screenHeight = screenBound.size.height;
    
    selectedInterests = [[NSMutableArray alloc] init];
    
    [self setTitle:@"Quick Start Guide"];
    saveButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleBordered target:self action:@selector(getTopicsForInterests)];
    saveButton.style = UIBarButtonItemStyleDone;
    saveButton.enabled = NO;
    
    if (![configuration isEqualToString:@"feed"]) {
        skipButton = [[UIBarButtonItem alloc] initWithTitle:@"Skip" style:UIBarButtonItemStyleBordered target:self action:@selector(skipIntro)];
    }
    
    self.navigationItem.rightBarButtonItem = saveButton;
    self.navigationItem.leftBarButtonItem = skipButton;
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_paper_texture.png"]];
    
    activePage = 1;
    
    UISwipeGestureRecognizer *recognizer;
    
    recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(gotoPreviousPage)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [[self view] addGestureRecognizer:recognizer];
    [recognizer release];
    
    recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(gotoNextPage)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionUp)];
    [[self view] addGestureRecognizer:recognizer];
    [recognizer release];
    
    recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(gotoPreviousPage)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionDown)];
    [[self view] addGestureRecognizer:recognizer];
    [recognizer release];
    
    recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(gotoNextPage)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionLeft)];
    [[self view] addGestureRecognizer:recognizer];
    [recognizer release];
    
    if ([appDelegate.currentDeviceModel isEqualToString:@"iPhone5,1"]) {
        cardPile = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, screenHeight - 74)];
        card_1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, screenHeight - 74)];
        card_2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, screenHeight - 70)];
        card_3 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, screenHeight - 66)];
        
        card_1_bg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"intro_interests_card_bg_1_568h.png"]];
        card_2_bg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"intro_interests_card_bg_2_568h.png"]];
        card_3_bg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"intro_interests_card_bg_3_568h.png"]];
        
        card_1_bg.frame = CGRectMake(0, 0, 320, 486);
        card_2_bg.frame = CGRectMake(0, 0, 320, 490);
        card_3_bg.frame = CGRectMake(0, 0, 320, 495);
    } else {
        cardPile = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 406)];
        card_1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 406)];
        card_2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 410)];
        card_3 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 414)];
        
        card_1_bg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"intro_interests_card_bg_1.png"]];
        card_2_bg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"intro_interests_card_bg_2.png"]];
        card_3_bg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"intro_interests_card_bg_3.png"]];
        
        card_1_bg.frame = CGRectMake(0, 0, 320, 406);
        card_2_bg.frame = CGRectMake(0, 0, 320, 410);
        card_3_bg.frame = CGRectMake(0, 0, 320, 414);
    }
    
    card_1.opaque = YES;
    card_2.opaque = YES;
    card_2.hidden = YES;
    card_3.opaque = YES;
    card_3.hidden = YES;
    
    cardPile_bg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"intro_interests_cards_bottom_3.png"]];
    cardPile_bg.userInteractionEnabled = YES;
    cardPile_bg.frame = CGRectMake(0, screenHeight - 74, 320, 10);
    
    cardPile_bottom = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"intro_interests_cards_bottom.png"]];
    cardPile_bottom.userInteractionEnabled = YES;
    cardPile_bottom.frame = CGRectMake(0, screenHeight - 82, 320, 17);
    
    card_1_bg.userInteractionEnabled = YES;
    card_2_bg.userInteractionEnabled = YES;
    card_3_bg.userInteractionEnabled = YES;
    
    nextPageButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [nextPageButton addTarget:self action:@selector(gotoNextPage) forControlEvents:UIControlEventTouchUpInside];
    [nextPageButton setBackgroundImage:[UIImage imageNamed:@"paper_next_button.png"] forState:UIControlStateNormal];
    [nextPageButton setBackgroundImage:[UIImage imageNamed:@"paper_next_button_highlighted.png"] forState:UIControlStateHighlighted];
    nextPageButton.frame  = CGRectMake(250, screenHeight - 145, 37, 37);
    
    previousPageButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [previousPageButton addTarget:self action:@selector(gotoPreviousPage) forControlEvents:UIControlEventTouchUpInside];
    [previousPageButton setBackgroundImage:[UIImage imageNamed:@"paper_previous_button.png"] forState:UIControlStateNormal];
    [previousPageButton setBackgroundImage:[UIImage imageNamed:@"paper_previous_button_highlighted.png"] forState:UIControlStateHighlighted];
    previousPageButton.frame  = CGRectMake(30, screenHeight - 145, 37, 37);
    previousPageButton.enabled = NO; // Disabled when the view loads.
    
    pageCounter = [[LPLabel alloc] initWithFrame:CGRectMake(67, screenHeight - 135, 183, 16)];
    pageCounter.backgroundColor = [UIColor clearColor];
    pageCounter.textColor = [UIColor colorWithRed:157.0/255.0 green:157.0/255.0 blue:157.0/255.0 alpha:1.0];
    pageCounter.shadowColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    pageCounter.numberOfLines = 1;
    pageCounter.textAlignment = UITextAlignmentCenter;
    pageCounter.font = [UIFont fontWithName:@"HelveticaNeue" size:MIN_MAIN_FONT_SIZE];
    pageCounter.text = @"Page 1 of 3";
    
    LPLabel *intro = [[LPLabel alloc] initWithFrame:CGRectMake(33, 33, 257, 57)];
    intro.backgroundColor = [UIColor clearColor];
    intro.textColor = [UIColor colorWithRed:157.0/255.0 green:157.0/255.0 blue:157.0/255.0 alpha:1.0];
    intro.shadowColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    intro.numberOfLines = 0;
    intro.font = [UIFont fontWithName:@"HelveticaNeue" size:MIN_MAIN_FONT_SIZE];
    intro.text = @"Pick a few categories that interest you, and we'll show you some tips you'll like!";
    
    UIView *card_1_dotted_separator = [[UIView alloc] initWithFrame:CGRectMake(33, 108, 258, 2)];
    card_1_dotted_separator.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"dotted_line_grey.png"]];
    
    UIView *card_1_vertical_separator = [[UIView alloc] initWithFrame:CGRectMake(160, 130, 1, 190)];
    card_1_vertical_separator.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"paper_seperator_vertical.png"]];
    
    UIView *card_2_vertical_separator = [[UIView alloc] initWithFrame:CGRectMake(160, 33, 1, 290)];
    card_2_vertical_separator.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"paper_seperator_vertical.png"]];
    
    UIView *card_3_vertical_separator = [[UIView alloc] initWithFrame:CGRectMake(160, 33, 1, 290)];
    card_3_vertical_separator.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"paper_seperator_vertical.png"]];
    
    CGRect buttonLabelFrame = CGRectMake(30, 70, 99, 17);
    
    LPLabel *buttonLabel_life = [[LPLabel alloc] initWithFrame:buttonLabelFrame];
    buttonLabel_life.backgroundColor = [UIColor clearColor];
    buttonLabel_life.textColor = [UIColor colorWithRed:54.0/255.0 green:54.0/255.0 blue:54.0/255.0 alpha:1.0];
    buttonLabel_life.shadowColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    buttonLabel_life.numberOfLines = 1;
    buttonLabel_life.minimumFontSize = 8.;
    buttonLabel_life.adjustsFontSizeToFitWidth = YES;
    buttonLabel_life.font = [UIFont fontWithName:@"HelveticaNeue" size:MIN_MAIN_FONT_SIZE];
    buttonLabel_life.textAlignment = UITextAlignmentCenter;
    buttonLabel_life.text = @"Lifestyle";
    
    LPLabel *buttonLabel_relations = [[LPLabel alloc] initWithFrame:buttonLabelFrame];
    buttonLabel_relations.backgroundColor = [UIColor clearColor];
    buttonLabel_relations.textColor = [UIColor colorWithRed:54.0/255.0 green:54.0/255.0 blue:54.0/255.0 alpha:1.0];
    buttonLabel_relations.shadowColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    buttonLabel_relations.numberOfLines = 1;
    buttonLabel_relations.minimumFontSize = 8.;
    buttonLabel_relations.adjustsFontSizeToFitWidth = YES;
    buttonLabel_relations.font = [UIFont fontWithName:@"HelveticaNeue" size:MIN_MAIN_FONT_SIZE];
    buttonLabel_relations.textAlignment = UITextAlignmentCenter;
    buttonLabel_relations.text = @"Relationships";
    
    LPLabel *buttonLabel_tech = [[LPLabel alloc] initWithFrame:buttonLabelFrame];
    buttonLabel_tech.backgroundColor = [UIColor clearColor];
    buttonLabel_tech.textColor = [UIColor colorWithRed:54.0/255.0 green:54.0/255.0 blue:54.0/255.0 alpha:1.0];
    buttonLabel_tech.shadowColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    buttonLabel_tech.numberOfLines = 1;
    buttonLabel_tech.minimumFontSize = 8.;
    buttonLabel_tech.adjustsFontSizeToFitWidth = YES;
    buttonLabel_tech.font = [UIFont fontWithName:@"HelveticaNeue" size:MIN_MAIN_FONT_SIZE];
    buttonLabel_tech.textAlignment = UITextAlignmentCenter;
    buttonLabel_tech.text = @"Science & Tech";
    
    LPLabel *buttonLabel_sports = [[LPLabel alloc] initWithFrame:buttonLabelFrame];
    buttonLabel_sports.backgroundColor = [UIColor clearColor];
    buttonLabel_sports.textColor = [UIColor colorWithRed:54.0/255.0 green:54.0/255.0 blue:54.0/255.0 alpha:1.0];
    buttonLabel_sports.shadowColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    buttonLabel_sports.numberOfLines = 1;
    buttonLabel_sports.minimumFontSize = 8.;
    buttonLabel_sports.adjustsFontSizeToFitWidth = YES;
    buttonLabel_sports.font = [UIFont fontWithName:@"HelveticaNeue" size:MIN_MAIN_FONT_SIZE];
    buttonLabel_sports.textAlignment = UITextAlignmentCenter;
    buttonLabel_sports.text = @"Sports";
    
    LPLabel *buttonLabel_business = [[LPLabel alloc] initWithFrame:buttonLabelFrame];
    buttonLabel_business.backgroundColor = [UIColor clearColor];
    buttonLabel_business.textColor = [UIColor colorWithRed:54.0/255.0 green:54.0/255.0 blue:54.0/255.0 alpha:1.0];
    buttonLabel_business.shadowColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    buttonLabel_business.numberOfLines = 1;
    buttonLabel_business.minimumFontSize = 8.;
    buttonLabel_business.adjustsFontSizeToFitWidth = YES;
    buttonLabel_business.font = [UIFont fontWithName:@"HelveticaNeue" size:MIN_MAIN_FONT_SIZE];
    buttonLabel_business.textAlignment = UITextAlignmentCenter;
    buttonLabel_business.text = @"Business";
    
    LPLabel *buttonLabel_travel = [[LPLabel alloc] initWithFrame:buttonLabelFrame];
    buttonLabel_travel.backgroundColor = [UIColor clearColor];
    buttonLabel_travel.textColor = [UIColor colorWithRed:54.0/255.0 green:54.0/255.0 blue:54.0/255.0 alpha:1.0];
    buttonLabel_travel.shadowColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    buttonLabel_travel.numberOfLines = 1;
    buttonLabel_travel.minimumFontSize = 8.;
    buttonLabel_travel.adjustsFontSizeToFitWidth = YES;
    buttonLabel_travel.font = [UIFont fontWithName:@"HelveticaNeue" size:MIN_MAIN_FONT_SIZE];
    buttonLabel_travel.textAlignment = UITextAlignmentCenter;
    buttonLabel_travel.text = @"Travel";
    
    LPLabel *buttonLabel_food = [[LPLabel alloc] initWithFrame:buttonLabelFrame];
    buttonLabel_food.backgroundColor = [UIColor clearColor];
    buttonLabel_food.textColor = [UIColor colorWithRed:54.0/255.0 green:54.0/255.0 blue:54.0/255.0 alpha:1.0];
    buttonLabel_food.shadowColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    buttonLabel_food.numberOfLines = 1;
    buttonLabel_food.minimumFontSize = 8.;
    buttonLabel_food.adjustsFontSizeToFitWidth = YES;
    buttonLabel_food.font = [UIFont fontWithName:@"HelveticaNeue" size:MIN_MAIN_FONT_SIZE];
    buttonLabel_food.textAlignment = UITextAlignmentCenter;
    buttonLabel_food.text = @"Food & Drink";
    
    LPLabel *buttonLabel_games = [[LPLabel alloc] initWithFrame:buttonLabelFrame];
    buttonLabel_games.backgroundColor = [UIColor clearColor];
    buttonLabel_games.textColor = [UIColor colorWithRed:54.0/255.0 green:54.0/255.0 blue:54.0/255.0 alpha:1.0];
    buttonLabel_games.shadowColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    buttonLabel_games.numberOfLines = 1;
    buttonLabel_games.minimumFontSize = 8.;
    buttonLabel_games.adjustsFontSizeToFitWidth = YES;
    buttonLabel_games.font = [UIFont fontWithName:@"HelveticaNeue" size:MIN_MAIN_FONT_SIZE];
    buttonLabel_games.textAlignment = UITextAlignmentCenter;
    buttonLabel_games.text = @"Games";
    
    LPLabel *buttonLabel_health = [[LPLabel alloc] initWithFrame:buttonLabelFrame];
    buttonLabel_health.backgroundColor = [UIColor clearColor];
    buttonLabel_health.textColor = [UIColor colorWithRed:54.0/255.0 green:54.0/255.0 blue:54.0/255.0 alpha:1.0];
    buttonLabel_health.shadowColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    buttonLabel_health.numberOfLines = 1;
    buttonLabel_health.minimumFontSize = 8.;
    buttonLabel_health.adjustsFontSizeToFitWidth = YES;
    buttonLabel_health.font = [UIFont fontWithName:@"HelveticaNeue" size:MIN_MAIN_FONT_SIZE];
    buttonLabel_health.textAlignment = UITextAlignmentCenter;
    buttonLabel_health.text = @"Health";
    
    LPLabel *buttonLabel_fashion = [[LPLabel alloc] initWithFrame:buttonLabelFrame];
    buttonLabel_fashion.backgroundColor = [UIColor clearColor];
    buttonLabel_fashion.textColor = [UIColor colorWithRed:54.0/255.0 green:54.0/255.0 blue:54.0/255.0 alpha:1.0];
    buttonLabel_fashion.shadowColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    buttonLabel_fashion.numberOfLines = 1;
    buttonLabel_fashion.minimumFontSize = 8.;
    buttonLabel_fashion.adjustsFontSizeToFitWidth = YES;
    buttonLabel_fashion.font = [UIFont fontWithName:@"HelveticaNeue" size:MIN_MAIN_FONT_SIZE];
    buttonLabel_fashion.textAlignment = UITextAlignmentCenter;
    buttonLabel_fashion.text = @"Fashion";
    
    LPLabel *buttonLabel_places = [[LPLabel alloc] initWithFrame:buttonLabelFrame];
    buttonLabel_places.backgroundColor = [UIColor clearColor];
    buttonLabel_places.textColor = [UIColor colorWithRed:54.0/255.0 green:54.0/255.0 blue:54.0/255.0 alpha:1.0];
    buttonLabel_places.shadowColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    buttonLabel_places.numberOfLines = 1;
    buttonLabel_places.minimumFontSize = 8.;
    buttonLabel_places.adjustsFontSizeToFitWidth = YES;
    buttonLabel_places.font = [UIFont fontWithName:@"HelveticaNeue" size:MIN_MAIN_FONT_SIZE];
    buttonLabel_places.textAlignment = UITextAlignmentCenter;
    buttonLabel_places.text = @"Places";
    
    LPLabel *buttonLabel_art = [[LPLabel alloc] initWithFrame:buttonLabelFrame];
    buttonLabel_art.backgroundColor = [UIColor clearColor];
    buttonLabel_art.textColor = [UIColor colorWithRed:54.0/255.0 green:54.0/255.0 blue:54.0/255.0 alpha:1.0];
    buttonLabel_art.shadowColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    buttonLabel_art.numberOfLines = 1;
    buttonLabel_art.minimumFontSize = 8.;
    buttonLabel_art.adjustsFontSizeToFitWidth = YES;
    buttonLabel_art.font = [UIFont fontWithName:@"HelveticaNeue" size:MIN_MAIN_FONT_SIZE];
    buttonLabel_art.textAlignment = UITextAlignmentCenter;
    buttonLabel_art.text = @"Art, Music, & Design";
    
    LPLabel *buttonLabel_education = [[LPLabel alloc] initWithFrame:buttonLabelFrame];
    buttonLabel_education.backgroundColor = [UIColor clearColor];
    buttonLabel_education.textColor = [UIColor colorWithRed:54.0/255.0 green:54.0/255.0 blue:54.0/255.0 alpha:1.0];
    buttonLabel_education.shadowColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    buttonLabel_education.numberOfLines = 1;
    buttonLabel_education.minimumFontSize = 8.;
    buttonLabel_education.adjustsFontSizeToFitWidth = YES;
    buttonLabel_education.font = [UIFont fontWithName:@"HelveticaNeue" size:MIN_MAIN_FONT_SIZE];
    buttonLabel_education.textAlignment = UITextAlignmentCenter;
    buttonLabel_education.text = @"Education";
    
    UIImageView *paperPin_1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pin_blue_pinned.png"]];
    paperPin_1.frame = CGRectMake(35, 115, 21, 40);
    paperPin_1.tag = 1100;
    paperPin_1.hidden = YES;
    
    UIImageView *paperPin_2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pin_blue_pinned.png"]];
    paperPin_2.frame = CGRectMake(196, 115, 21, 40);
    paperPin_2.tag = 1101;
    paperPin_2.hidden = YES;
    
    UIImageView *paperPin_3 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pin_blue_pinned.png"]];
    paperPin_3.frame = CGRectMake(35, 215, 21, 40);
    paperPin_3.tag = 1102;
    paperPin_3.hidden = YES;
    
    UIImageView *paperPin_4 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pin_blue_pinned.png"]];
    paperPin_4.frame = CGRectMake(196, 215, 21, 40);
    paperPin_4.tag = 1103;
    paperPin_4.hidden = YES;
    
    UIImageView *paperPin_5 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pin_blue_pinned.png"]];
    paperPin_5.frame = CGRectMake(35, 15, 21, 40);
    paperPin_5.tag = 1104;
    paperPin_5.hidden = YES;
    
    UIImageView *paperPin_6 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pin_blue_pinned.png"]];
    paperPin_6.frame = CGRectMake(196, 15, 21, 40);
    paperPin_6.tag = 1105;
    paperPin_6.hidden = YES;
    
    UIImageView *paperPin_7 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pin_blue_pinned.png"]];
    paperPin_7.frame = CGRectMake(35, 115, 21, 40);
    paperPin_7.tag = 1106;
    paperPin_7.hidden = YES;
    
    UIImageView *paperPin_8 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pin_blue_pinned.png"]];
    paperPin_8.frame = CGRectMake(196, 115, 21, 40);
    paperPin_8.tag = 1107;
    paperPin_8.hidden = YES;
    
    UIImageView *paperPin_9 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pin_blue_pinned.png"]];
    paperPin_9.frame = CGRectMake(35, 215, 21, 40);
    paperPin_9.tag = 1108;
    paperPin_9.hidden = YES;
    
    UIImageView *paperPin_10 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pin_blue_pinned.png"]];
    paperPin_10.frame = CGRectMake(196, 215, 21, 40);
    paperPin_10.tag = 1109;
    paperPin_10.hidden = YES;
    
    UIImageView *paperPin_11 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pin_blue_pinned.png"]];
    paperPin_11.frame = CGRectMake(35, 15, 21, 40);
    paperPin_11.tag = 1110;
    paperPin_11.hidden = YES;
    
    UIImageView *paperPin_12 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pin_blue_pinned.png"]];
    paperPin_12.frame = CGRectMake(196, 15, 21, 40);
    paperPin_12.tag = 1111;
    paperPin_12.hidden = YES;
    
    UIImageView *paperPin_13 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pin_blue_pinned.png"]];
    paperPin_13.frame = CGRectMake(35, 115, 21, 40);
    paperPin_13.tag = 1112;
    paperPin_13.hidden = YES;
    
    UIImageView *paperCutBg_1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"intro_interests_card_cut_bg.png"]];
    paperCutBg_1.frame = CGRectMake(15, 123, 131, 100);
    paperCutBg_1.tag = 1000;
    paperCutBg_1.hidden = YES;
    
    UIImageView *paperCutBg_2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"intro_interests_card_cut_bg.png"]];
    paperCutBg_2.frame = CGRectMake(176, 123, 131, 100);
    paperCutBg_2.tag = 1001;
    paperCutBg_2.hidden = YES;
    
    UIImageView *paperCutBg_3 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"intro_interests_card_cut_bg.png"]];
    paperCutBg_3.frame = CGRectMake(15, 223, 131, 100);
    paperCutBg_3.tag = 1002;
    paperCutBg_3.hidden = YES;
    
    UIImageView *paperCutBg_4 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"intro_interests_card_cut_bg.png"]];
    paperCutBg_4.frame = CGRectMake(176, 223, 131, 100);
    paperCutBg_4.tag = 1003;
    paperCutBg_4.hidden = YES;
    
    UIImageView *paperCutBg_5 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"intro_interests_card_cut_bg.png"]];
    paperCutBg_5.frame = CGRectMake(15, 23, 131, 100);
    paperCutBg_5.tag = 1004;
    paperCutBg_5.hidden = YES;
    
    UIImageView *paperCutBg_6 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"intro_interests_card_cut_bg.png"]];
    paperCutBg_6.frame = CGRectMake(176, 23, 131, 100);
    paperCutBg_6.tag = 1005;
    paperCutBg_6.hidden = YES;
    
    UIImageView *paperCutBg_7 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"intro_interests_card_cut_bg.png"]];
    paperCutBg_7.frame = CGRectMake(15, 123, 131, 100);
    paperCutBg_7.tag =1006;
    paperCutBg_7.hidden = YES;
    
    UIImageView *paperCutBg_8 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"intro_interests_card_cut_bg.png"]];
    paperCutBg_8.frame = CGRectMake(176, 123, 131, 100);
    paperCutBg_8.tag = 1007;
    paperCutBg_8.hidden = YES;
    
    UIImageView *paperCutBg_9 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"intro_interests_card_cut_bg.png"]];
    paperCutBg_9.frame = CGRectMake(15, 223, 131, 100);
    paperCutBg_9.tag = 1008;
    paperCutBg_9.hidden = YES;
    
    UIImageView *paperCutBg_10 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"intro_interests_card_cut_bg.png"]];
    paperCutBg_10.frame = CGRectMake(176, 223, 131, 100);
    paperCutBg_10.tag = 1009;
    paperCutBg_10.hidden = YES;
    
    UIImageView *paperCutBg_11 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"intro_interests_card_cut_bg.png"]];
    paperCutBg_11.frame = CGRectMake(15, 23, 131, 100);
    paperCutBg_11.tag = 1010;
    paperCutBg_11.hidden = YES;
    
    UIImageView *paperCutBg_12 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"intro_interests_card_cut_bg.png"]];
    paperCutBg_12.frame = CGRectMake(176, 23, 131, 100);
    paperCutBg_12.tag = 1011;
    paperCutBg_12.hidden = YES;
    
    UIImageView *paperCutBg_13 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"intro_interests_card_cut_bg.png"]];
    paperCutBg_13.frame = CGRectMake(15, 123, 131, 100);
    paperCutBg_13.tag = 1012;
    paperCutBg_13.hidden = YES;
    
    CGRect paperCutFrame = CGRectMake(15, 10, 131, 100);
    
    UIImageView *paperCut_1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"intro_interests_card_cut.png"]];
    paperCut_1.frame = paperCutFrame;
    paperCut_1.tag = 999;
    paperCut_1.hidden = YES;
    
    UIImageView *paperCut_2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"intro_interests_card_cut.png"]];
    paperCut_2.frame = paperCutFrame;
    paperCut_2.tag = 999;
    paperCut_2.hidden = YES;
    
    UIImageView *paperCut_3 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"intro_interests_card_cut.png"]];
    paperCut_3.frame = paperCutFrame;
    paperCut_3.tag = 999;
    paperCut_3.hidden = YES;
    
    UIImageView *paperCut_4 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"intro_interests_card_cut.png"]];
    paperCut_4.frame = paperCutFrame;
    paperCut_4.tag = 999;
    paperCut_4.hidden = YES;
    
    UIImageView *paperCut_5 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"intro_interests_card_cut.png"]];
    paperCut_5.frame = paperCutFrame;
    paperCut_5.tag = 999;
    paperCut_5.hidden = YES;
    
    UIImageView *paperCut_6 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"intro_interests_card_cut.png"]];
    paperCut_6.frame = paperCutFrame;
    paperCut_6.tag = 999;
    paperCut_6.hidden = YES;
    
    UIImageView *paperCut_7 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"intro_interests_card_cut.png"]];
    paperCut_7.frame = paperCutFrame;
    paperCut_7.tag = 999;
    paperCut_7.hidden = YES;
    
    UIImageView *paperCut_8 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"intro_interests_card_cut.png"]];
    paperCut_8.frame = paperCutFrame;
    paperCut_8.tag = 999;
    paperCut_8.hidden = YES;
    
    UIImageView *paperCut_9 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"intro_interests_card_cut.png"]];
    paperCut_9.frame = paperCutFrame;
    paperCut_9.tag = 999;
    paperCut_9.hidden = YES;
    
    UIImageView *paperCut_10 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"intro_interests_card_cut.png"]];
    paperCut_10.frame = paperCutFrame;
    paperCut_10.tag = 999;
    paperCut_10.hidden = YES;
    
    UIImageView *paperCut_11 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"intro_interests_card_cut.png"]];
    paperCut_11.frame = paperCutFrame;
    paperCut_11.tag = 999;
    paperCut_11.hidden = YES;
    
    UIImageView *paperCut_12 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"intro_interests_card_cut.png"]];
    paperCut_12.frame = paperCutFrame;
    paperCut_12.tag = 999;
    paperCut_12.hidden = YES;
    
    UIImageView *paperCut_13 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"intro_interests_card_cut.png"]];
    paperCut_13.frame = paperCutFrame;
    paperCut_13.tag = 999;
    paperCut_13.hidden = YES;
    
    UIButton *interestButton_life = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    [interestButton_life addTarget:self action:@selector(toggleInterest:) forControlEvents:UIControlEventTouchUpInside];
    [interestButton_life setImage:[UIImage imageNamed:@"intro_interest_life.png"] forState:UIControlStateNormal];
    interestButton_life.tag = 0;
    interestButton_life.showsTouchWhenHighlighted = YES;
    
    UIButton *interestButton_relations = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    [interestButton_relations addTarget:self action:@selector(toggleInterest:) forControlEvents:UIControlEventTouchUpInside];
    [interestButton_relations setImage:[UIImage imageNamed:@"intro_interest_relations.png"] forState:UIControlStateNormal];
    interestButton_relations.tag = 1;
    interestButton_relations.showsTouchWhenHighlighted = YES;
    
    UIButton *interestButton_tech = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    [interestButton_tech addTarget:self action:@selector(toggleInterest:) forControlEvents:UIControlEventTouchUpInside];
    [interestButton_tech setImage:[UIImage imageNamed:@"intro_interest_tech.png"] forState:UIControlStateNormal];
    interestButton_tech.tag = 2;
    interestButton_tech.showsTouchWhenHighlighted = YES;
    
    UIButton *interestButton_sports = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    [interestButton_sports addTarget:self action:@selector(toggleInterest:) forControlEvents:UIControlEventTouchUpInside];
    [interestButton_sports setImage:[UIImage imageNamed:@"intro_interest_sports.png"] forState:UIControlStateNormal];
    interestButton_sports.tag = 3;
    interestButton_sports.showsTouchWhenHighlighted = YES;
    
    UIButton *interestButton_business = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    [interestButton_business addTarget:self action:@selector(toggleInterest:) forControlEvents:UIControlEventTouchUpInside];
    [interestButton_business setImage:[UIImage imageNamed:@"intro_interest_business.png"] forState:UIControlStateNormal];
    interestButton_business.tag = 4;
    interestButton_business.showsTouchWhenHighlighted = YES;
    
    UIButton *interestButton_travel = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    [interestButton_travel addTarget:self action:@selector(toggleInterest:) forControlEvents:UIControlEventTouchUpInside];
    [interestButton_travel setImage:[UIImage imageNamed:@"intro_interest_travel.png"] forState:UIControlStateNormal];
    interestButton_travel.tag = 5;
    interestButton_travel.showsTouchWhenHighlighted = YES;
    
    UIButton *interestButton_food = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    [interestButton_food addTarget:self action:@selector(toggleInterest:) forControlEvents:UIControlEventTouchUpInside];
    [interestButton_food setImage:[UIImage imageNamed:@"intro_interest_food.png"] forState:UIControlStateNormal];
    interestButton_food.tag = 6;
    interestButton_food.showsTouchWhenHighlighted = YES;
    
    UIButton *interestButton_games = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    [interestButton_games addTarget:self action:@selector(toggleInterest:) forControlEvents:UIControlEventTouchUpInside];
    [interestButton_games setImage:[UIImage imageNamed:@"intro_interest_games.png"] forState:UIControlStateNormal];
    interestButton_games.tag = 7;
    interestButton_games.showsTouchWhenHighlighted = YES;
    
    UIButton *interestButton_health = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    [interestButton_health addTarget:self action:@selector(toggleInterest:) forControlEvents:UIControlEventTouchUpInside];
    [interestButton_health setImage:[UIImage imageNamed:@"intro_interest_health.png"] forState:UIControlStateNormal];
    interestButton_health.tag = 8;
    interestButton_health.showsTouchWhenHighlighted = YES;
    
    UIButton *interestButton_fashion = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    [interestButton_fashion addTarget:self action:@selector(toggleInterest:) forControlEvents:UIControlEventTouchUpInside];
    [interestButton_fashion setImage:[UIImage imageNamed:@"intro_interest_fashion.png"] forState:UIControlStateNormal];
    interestButton_fashion.tag = 9;
    interestButton_fashion.showsTouchWhenHighlighted = YES;
    
    UIButton *interestButton_places = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    [interestButton_places addTarget:self action:@selector(toggleInterest:) forControlEvents:UIControlEventTouchUpInside];
    [interestButton_places setImage:[UIImage imageNamed:@"pub_category_place.png"] forState:UIControlStateNormal];
    interestButton_places.tag = 10;
    interestButton_places.showsTouchWhenHighlighted = YES;
    
    UIButton *interestButton_art = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    [interestButton_art addTarget:self action:@selector(toggleInterest:) forControlEvents:UIControlEventTouchUpInside];
    [interestButton_art setImage:[UIImage imageNamed:@"intro_interest_art.png"] forState:UIControlStateNormal];
    interestButton_art.tag = 11;
    interestButton_art.showsTouchWhenHighlighted = YES;
    
    UIButton *interestButton_education = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    [interestButton_education addTarget:self action:@selector(toggleInterest:) forControlEvents:UIControlEventTouchUpInside];
    [interestButton_education setImage:[UIImage imageNamed:@"intro_interest_education.png"] forState:UIControlStateNormal];
    interestButton_education.tag = 12;
    interestButton_education.showsTouchWhenHighlighted = YES;
    
    interestButton_life.layer.anchorPoint = CGPointMake(0.3, 0.3);
    interestButton_relations.layer.anchorPoint = CGPointMake(0.3, 0.3);
    interestButton_tech.layer.anchorPoint = CGPointMake(0.3, 0.3);
    interestButton_sports.layer.anchorPoint = CGPointMake(0.3, 0.3);
    interestButton_business.layer.anchorPoint = CGPointMake(0.3, 0.3);
    interestButton_travel.layer.anchorPoint = CGPointMake(0.3, 0.3);
    interestButton_food.layer.anchorPoint = CGPointMake(0.3, 0.3);
    interestButton_games.layer.anchorPoint = CGPointMake(0.3, 0.3);
    interestButton_health.layer.anchorPoint = CGPointMake(0.3, 0.3);
    interestButton_fashion.layer.anchorPoint = CGPointMake(0.3, 0.3);
    interestButton_places.layer.anchorPoint = CGPointMake(0.3, 0.3);
    interestButton_art.layer.anchorPoint = CGPointMake(0.3, 0.3);
    interestButton_education.layer.anchorPoint = CGPointMake(0.3, 0.3);
    
    interestButton_life.frame = CGRectMake(0, 113, 159, 90);
    interestButton_relations.frame = CGRectMake(161, 113, 159, 90);
    interestButton_tech.frame = CGRectMake(0, 213, 159, 90);
    interestButton_sports.frame = CGRectMake(161, 213, 159, 90);
    interestButton_business.frame = CGRectMake(0, 13, 159, 90);
    interestButton_travel.frame = CGRectMake(161, 13, 159, 90);
    interestButton_food.frame = CGRectMake(0, 113, 159, 90);
    interestButton_games.frame = CGRectMake(161, 113, 159, 90);
    interestButton_health.frame = CGRectMake(0, 213, 159, 90);
    interestButton_fashion.frame = CGRectMake(161, 213, 159, 90);
    interestButton_places.frame = CGRectMake(0, 13, 159, 90);
    interestButton_art.frame = CGRectMake(161, 13, 159, 90);
    interestButton_education.frame = CGRectMake(0, 113, 159, 90);
    
    [interestButton_life addSubview:paperCut_1];
    [interestButton_life sendSubviewToBack:paperCut_1];
    [interestButton_relations addSubview:paperCut_2];
    [interestButton_relations sendSubviewToBack:paperCut_2];
    [interestButton_tech addSubview:paperCut_3];
    [interestButton_tech sendSubviewToBack:paperCut_3];
    [interestButton_sports addSubview:paperCut_4];
    [interestButton_sports sendSubviewToBack:paperCut_4];
    [interestButton_business addSubview:paperCut_5];
    [interestButton_business sendSubviewToBack:paperCut_5];
    [interestButton_travel addSubview:paperCut_6];
    [interestButton_travel sendSubviewToBack:paperCut_6];
    [interestButton_food addSubview:paperCut_7];
    [interestButton_food sendSubviewToBack:paperCut_7];
    [interestButton_games addSubview:paperCut_8];
    [interestButton_games sendSubviewToBack:paperCut_8];
    [interestButton_health addSubview:paperCut_9];
    [interestButton_health sendSubviewToBack:paperCut_9];
    [interestButton_fashion addSubview:paperCut_10];
    [interestButton_fashion sendSubviewToBack:paperCut_10];
    [interestButton_places addSubview:paperCut_11];
    [interestButton_places sendSubviewToBack:paperCut_11];
    [interestButton_art addSubview:paperCut_12];
    [interestButton_art sendSubviewToBack:paperCut_12];
    [interestButton_education addSubview:paperCut_13];
    [interestButton_education sendSubviewToBack:paperCut_13];
    
    [interestButton_life addSubview:buttonLabel_life];
    [interestButton_relations addSubview:buttonLabel_relations];
    [interestButton_tech addSubview:buttonLabel_tech];
    [interestButton_sports addSubview:buttonLabel_sports];
    [interestButton_business addSubview:buttonLabel_business];
    [interestButton_travel addSubview:buttonLabel_travel];
    [interestButton_food addSubview:buttonLabel_food];
    [interestButton_games addSubview:buttonLabel_games];
    [interestButton_health addSubview:buttonLabel_health];
    [interestButton_fashion addSubview:buttonLabel_fashion];
    [interestButton_places addSubview:buttonLabel_places];
    [interestButton_art addSubview:buttonLabel_art];
    [interestButton_education addSubview:buttonLabel_education];
    
    [self.view addSubview:cardPile_bottom];
    [self.view addSubview:cardPile_bg];
    [self.view addSubview:cardPile];
    [cardPile addSubview:card_3];
    [cardPile addSubview:card_2];
    [cardPile addSubview:card_1];
    [cardPile addSubview:nextPageButton];
    [cardPile addSubview:previousPageButton];
    [cardPile addSubview:pageCounter];
    [card_1 addSubview:card_1_bg];
    [card_1 addSubview:intro];
    [card_1 addSubview:card_1_dotted_separator];
    [card_1 addSubview:card_1_vertical_separator];
    [card_1 addSubview:paperCutBg_1];
    [card_1 addSubview:paperCutBg_2];
    [card_1 addSubview:paperCutBg_3];
    [card_1 addSubview:paperCutBg_4];
    [card_1 addSubview:interestButton_sports];
    [card_1 addSubview:interestButton_tech];
    [card_1 addSubview:interestButton_relations];
    [card_1 addSubview:interestButton_life];
    [card_1 addSubview:paperPin_1];
    [card_1 addSubview:paperPin_2];
    [card_1 addSubview:paperPin_3];
    [card_1 addSubview:paperPin_4];
    [card_2 addSubview:card_2_bg];
    [card_2 addSubview:card_2_vertical_separator];
    [card_2 addSubview:paperCutBg_5];
    [card_2 addSubview:paperCutBg_6];
    [card_2 addSubview:paperCutBg_7];
    [card_2 addSubview:paperCutBg_8];
    [card_2 addSubview:paperCutBg_9];
    [card_2 addSubview:paperCutBg_10];
    [card_2 addSubview:interestButton_fashion];
    [card_2 addSubview:interestButton_health];
    [card_2 addSubview:interestButton_games];
    [card_2 addSubview:interestButton_food];
    [card_2 addSubview:interestButton_travel];
    [card_2 addSubview:interestButton_business];
    [card_2 addSubview:paperPin_5];
    [card_2 addSubview:paperPin_6];
    [card_2 addSubview:paperPin_7];
    [card_2 addSubview:paperPin_8];
    [card_2 addSubview:paperPin_9];
    [card_2 addSubview:paperPin_10];
    [card_3 addSubview:card_3_bg];
    [card_3 addSubview:card_3_vertical_separator];
    [card_3 addSubview:paperCutBg_11];
    [card_3 addSubview:paperCutBg_12];
    [card_3 addSubview:paperCutBg_13];
    [card_3 addSubview:interestButton_education];
    [card_3 addSubview:interestButton_art];
    [card_3 addSubview:interestButton_places];
    [card_3 addSubview:paperPin_11];
    [card_3 addSubview:paperPin_12];
    [card_3 addSubview:paperPin_13];
    
    [intro release];
    [card_1_dotted_separator release];
    [card_1_vertical_separator release];
    [card_2_vertical_separator release];
    [card_3_vertical_separator release];
    [interestButton_life release];
    [interestButton_relations release];
    [interestButton_sports release];
    [interestButton_tech release];
    [interestButton_business release];
    [interestButton_travel release];
    [interestButton_food release];
    [interestButton_games release];
    [interestButton_health release];
    [interestButton_fashion release];
    [interestButton_places release];
    [interestButton_art release];
    [interestButton_education release];
    [buttonLabel_life release];
    [buttonLabel_relations release];
    [buttonLabel_tech release];
    [buttonLabel_sports release];
    [buttonLabel_business release];
    [buttonLabel_travel release];
    [buttonLabel_food release];
    [buttonLabel_games release];
    [buttonLabel_health release];
    [buttonLabel_fashion release];
    [buttonLabel_places release];
    [buttonLabel_art release];
    [buttonLabel_education release];
    [paperPin_1 release];
    [paperPin_2 release];
    [paperPin_3 release];
    [paperPin_4 release];
    [paperPin_5 release];
    [paperPin_6 release];
    [paperPin_7 release];
    [paperPin_8 release];
    [paperPin_9 release];
    [paperPin_10 release];
    [paperPin_11 release];
    [paperPin_12 release];
    [paperPin_13 release];
    [paperCutBg_1 release];
    [paperCutBg_2 release];
    [paperCutBg_3 release];
    [paperCutBg_4 release];
    [paperCutBg_5 release];
    [paperCutBg_6 release];
    [paperCutBg_7 release];
    [paperCutBg_8 release];
    [paperCutBg_9 release];
    [paperCutBg_10 release];
    [paperCutBg_11 release];
    [paperCutBg_12 release];
    [paperCutBg_13 release];
    [paperCut_1 release];
    [paperCut_2 release];
    [paperCut_3 release];
    [paperCut_4 release];
    [paperCut_5 release];
    [paperCut_6 release];
    [paperCut_7 release];
    [paperCut_8 release];
    [paperCut_9 release];
    [paperCut_10 release];
    [paperCut_11 release];
    [paperCut_12 release];
    [paperCut_13 release];
    [super viewDidLoad];
}

#pragma mark Customizations when the view appears/disappears
- (void)viewWillAppear:(BOOL)animated
{
    TipboxAppDelegate *appDelegate = (TipboxAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [appDelegate tabbarShadowMode_nobar];
    [appDelegate navbarShadowMode_navbar];
    [appDelegate showNavbarShadowAnimated:YES];
    [appDelegate showTabbarShadowAnimated:YES];
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


- (void)dealloc
{
    [selectedInterests release];
    [saveButton release];
    [skipButton release];
    [cardPile release];
    [card_1 release];
    [card_2 release];
    [card_3 release];
    [cardPile_bg release];
    [cardPile_bottom release];
    [card_1_bg release];
    [card_2_bg release];
    [card_3_bg release];
    [pageCounter release];
    [super dealloc];
}


@end
