#import <QuartzCore/QuartzCore.h>
#import "Intro_TutorialViewController.h"
#import "TipboxAppDelegate.h"
#import "Intro_InterestsViewController.h"

#define MAIN_FONT_SIZE 18
#define MIN_MAIN_FONT_SIZE 15
#define SECONDARY_FONT_SIZE 12
#define MIN_SECONDARY_FONT_SIZE 10

@implementation Intro_TutorialViewController

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

- (void)skipTutorial
{
    Intro_InterestsViewController *interestsForm = [[Intro_InterestsViewController alloc] init];
    interestsForm.configuration = @"signup";
    [self.navigationController pushViewController:interestsForm animated:YES];
    [interestsForm release];
    interestsForm = nil;
}

- (void)play
{
    CGRect screenBound = [[UIScreen mainScreen] bounds];
    CGFloat screenHeight = screenBound.size.height;
    
    TipboxAppDelegate *appDelegate = (TipboxAppDelegate *)[[UIApplication sharedApplication] delegate];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    [self.navigationController.view setFrame:CGRectMake(0, 0, 320, screenHeight + 20)];
    
    [appDelegate hideNavbarShadowAnimated:YES];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    usefulCount = 0; // Reset this counter.
    
    // Fade out the replay button.
    [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        replayButton.alpha = 0;
        finalWord.alpha = 0;
    } completion:^(BOOL finished){
        
    }];
    
    // ANIMATION: the greeting fade.
    [UIView animateWithDuration:0.25 delay:0.3 options:UIViewAnimationOptionCurveLinear animations:^{
        welcomeLabel_1.alpha = 1;
    } completion:^(BOOL finished){
        [UIView animateWithDuration:0.25 delay:1.1 options:UIViewAnimationOptionCurveLinear animations:^{
            welcomeLabel_1.alpha = 0;
        } completion:^(BOOL finished){
            
        }];
    }];
    
    // ANIMATION: the tour fade.
    [UIView animateWithDuration:0.25 delay:2.0 options:UIViewAnimationOptionCurveLinear animations:^{
        welcomeLabel_2.alpha = 1;
    } completion:^(BOOL finished){
        [UIView animateWithDuration:0.25 delay:2.8 options:UIViewAnimationOptionCurveLinear animations:^{
            welcomeLabel_2.alpha = 0;
        } completion:^(BOOL finished){
            
        }];
    }];
    
    // ANIMATION: Card slide in and bounce.
    [UIView animateWithDuration:0.3 delay:6.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        card.frame = CGRectMake(0, screenHeight - 375, 320, 224);
    } completion:^(BOOL finished){
        [UIView animateWithDuration:0.05 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            CGAffineTransform transform_card = CGAffineTransformMakeRotation(10 / 180.0 * M_PI);
            card.transform = transform_card;
        } completion:^(BOOL finished){
            [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
                CGAffineTransform transform_card = CGAffineTransformMakeRotation(-10 / 180.0 * M_PI);
                card.transform = transform_card;
            } completion:^(BOOL finished){
                [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
                    CGAffineTransform transform_card = CGAffineTransformMakeRotation(5 / 180.0 * M_PI);
                    card.transform = transform_card;
                } completion:^(BOOL finished){
                    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
                        CGAffineTransform transform_card = CGAffineTransformMakeRotation(-5 / 180.0 * M_PI);
                        card.transform = transform_card;
                    } completion:^(BOOL finished){
                        [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
                            CGAffineTransform transform_card = CGAffineTransformMakeRotation(0 / 180.0 * M_PI);
                            card.transform = transform_card;
                        } completion:^(BOOL finished){
                            
                        }];
                    }];
                }];
            }];
        }];
    }];
    
    // ANIMATION: 1st popover fade in.
    [UIView animateWithDuration:0.25 delay:7.0 options:UIViewAnimationOptionCurveLinear animations:^{
        popover_1.frame = CGRectMake(popover_1.frame.origin.x, popover_1.frame.origin.y + 10, popover_1.frame.size.width, popover_1.frame.size.height);
        popover_1.alpha = 1;
    } completion:^(BOOL finished){
        [UIView animateWithDuration:0.25 delay:3.0 options:UIViewAnimationOptionCurveLinear animations:^{
            popover_1.frame = CGRectMake(popover_1.frame.origin.x, popover_1.frame.origin.y - 10, popover_1.frame.size.width, popover_1.frame.size.height);
            popover_1.alpha = 0;
        } completion:^(BOOL finished){
            
        }];
    }];
    
    // ANIMATION: 2nd popover fade in.
    [UIView animateWithDuration:0.25 delay:11.0 options:UIViewAnimationOptionCurveLinear animations:^{
        popover_2.frame = CGRectMake(popover_2.frame.origin.x, popover_2.frame.origin.y + 10, popover_2.frame.size.width, popover_2.frame.size.height);
        popover_2.alpha = 1;
    } completion:^(BOOL finished){
        [UIView animateWithDuration:0.25 delay:3.0 options:UIViewAnimationOptionCurveLinear animations:^{
            popover_2.frame = CGRectMake(popover_2.frame.origin.x, popover_2.frame.origin.y - 10, popover_2.frame.size.width, popover_2.frame.size.height);
            popover_2.alpha = 0;
        } completion:^(BOOL finished){
            
        }];
    }];
    
    // ANIMATION: 3rd popover fade in.
    [UIView animateWithDuration:0.25 delay:15.0 options:UIViewAnimationOptionCurveLinear animations:^{
        popover_3.frame = CGRectMake(popover_3.frame.origin.x, popover_3.frame.origin.y + 10, popover_3.frame.size.width, popover_3.frame.size.height);
        popover_3.alpha = 1;
    } completion:^(BOOL finished){
        [UIView animateWithDuration:0.25 delay:3.0 options:UIViewAnimationOptionCurveLinear animations:^{
            popover_3.frame = CGRectMake(popover_3.frame.origin.x, popover_3.frame.origin.y - 10, popover_3.frame.size.width, popover_3.frame.size.height);
            popover_3.alpha = 0;
        } completion:^(BOOL finished){
            
        }];
    }];
    
    // ANIMATION: 4th popover fade in.
    [UIView animateWithDuration:0.25 delay:19.0 options:UIViewAnimationOptionCurveLinear animations:^{
        popover_4.frame = CGRectMake(popover_4.frame.origin.x, popover_4.frame.origin.y + 10, popover_4.frame.size.width, popover_4.frame.size.height);
        popover_4.alpha = 1;
    } completion:^(BOOL finished){
        // Demo the button...
        [NSTimer scheduledTimerWithTimeInterval:0.1
                                         target:self
                                       selector:@selector(triggerMarkUseful)
                                       userInfo:nil
                                        repeats:NO];
        
        [NSTimer scheduledTimerWithTimeInterval:0.9
                                         target:self
                                       selector:@selector(triggerMarkUseful)
                                       userInfo:nil
                                        repeats:NO];
        
        [UIView animateWithDuration:0.25 delay:3.0 options:UIViewAnimationOptionCurveLinear animations:^{
            popover_4.frame = CGRectMake(popover_4.frame.origin.x, popover_4.frame.origin.y - 10, popover_4.frame.size.width, popover_4.frame.size.height);
            popover_4.alpha = 0;
        } completion:^(BOOL finished){
            
        }];
    }];
    
    // ANIMATION: 5th popover fade in.
    [UIView animateWithDuration:0.25 delay:23.0 options:UIViewAnimationOptionCurveLinear animations:^{
        popover_5.frame = CGRectMake(popover_5.frame.origin.x, popover_5.frame.origin.y + 10, popover_5.frame.size.width, popover_5.frame.size.height);
        popover_5.alpha = 1;
    } completion:^(BOOL finished){
        
    }];
    
    // ANIMATION: usefulness counter fade in.
    [UIView animateWithDuration:0.25 delay:27.0 options:UIViewAnimationOptionCurveLinear animations:^{
        usefulnessMeter.frame = CGRectMake(usefulnessMeter.frame.origin.x, usefulnessMeter.frame.origin.y + 10, usefulnessMeter.frame.size.width, usefulnessMeter.frame.size.height);
        usefulnessMeter.alpha = 1;
    } completion:^(BOOL finished){
        [NSTimer scheduledTimerWithTimeInterval:0.3
                                         target:self
                                       selector:@selector(updateUsefulCount)
                                       userInfo:nil
                                        repeats:NO];
        
        [NSTimer scheduledTimerWithTimeInterval:1.0
                                         target:self
                                       selector:@selector(updateUsefulCount)
                                       userInfo:nil
                                        repeats:NO];
        
        [NSTimer scheduledTimerWithTimeInterval:1.4
                                         target:self
                                       selector:@selector(updateUsefulCount)
                                       userInfo:nil
                                        repeats:NO];
        
        [NSTimer scheduledTimerWithTimeInterval:2.0
                                         target:self
                                       selector:@selector(updateUsefulCount)
                                       userInfo:nil
                                        repeats:NO];
        
        [NSTimer scheduledTimerWithTimeInterval:2.6
                                         target:self
                                       selector:@selector(updateUsefulCount)
                                       userInfo:nil
                                        repeats:NO];
    }];
    
    // ANIMATION: genius icon fade in.
    [UIView animateWithDuration:0.25 delay:30.0 options:UIViewAnimationOptionCurveLinear animations:^{
        geniusIcon.frame = CGRectMake(geniusIcon.frame.origin.x, geniusIcon.frame.origin.y + 10, geniusIcon.frame.size.width, geniusIcon.frame.size.height);
        geniusIcon.alpha = 1;
    } completion:^(BOOL finished){
        finalWord.alpha = 1;
        
        // ANIMATION: Card slide out.
        [UIView animateWithDuration:0.4 delay:2.5 options:UIViewAnimationOptionCurveEaseOut animations:^{
            card.frame = CGRectMake(0, 490, 320, 224);
        } completion:^(BOOL finished){
            card.frame = CGRectMake(0, -240, 320, 480);
            geniusIcon.frame = CGRectMake(geniusIcon.frame.origin.x, geniusIcon.frame.origin.y - 10, geniusIcon.frame.size.width, geniusIcon.frame.size.height);
            geniusIcon.alpha = 0;
        }];
        
        [UIView animateWithDuration:0.25 delay:2.5 options:UIViewAnimationOptionCurveLinear animations:^{
            popover_5.frame = CGRectMake(popover_5.frame.origin.x, popover_5.frame.origin.y - 10, popover_5.frame.size.width, popover_5.frame.size.height);
            popover_5.alpha = 0;
            
            usefulnessMeter.frame = CGRectMake(usefulnessMeter.frame.origin.x, usefulnessMeter.frame.origin.y - 10, usefulnessMeter.frame.size.width, usefulnessMeter.frame.size.height);
            usefulnessMeter.alpha = 0;
        } completion:^(BOOL finished){
            [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
            [self.navigationController.view setFrame:CGRectMake(0, 0, 320, screenHeight)];
            [self.navigationController setNavigationBarHidden:NO animated:YES];
            [appDelegate showNavbarShadowAnimated:YES];
            
            [UIView animateWithDuration:0.25 delay:0.3 options:UIViewAnimationOptionCurveLinear animations:^{
                replayButton.alpha = 1;
            } completion:^(BOOL finished){
                
            }];
        }];
    }];
}

- (void)triggerMarkUseful
{
    [card markUseful];
}

- (void)updateUsefulCount
{
    NSInteger randomIncrement = arc4random_uniform(20);
    usefulCount += randomIncrement;
    
    if (usefulCount > 1) {
        usefulnessMeter.text = [NSString stringWithFormat:@"%d PEOPLE FOUND THIS USEFUL", usefulCount];
    } else if (usefulCount == 1) {
        usefulnessMeter.text = [NSString stringWithFormat:@"1 PERSON FOUND THIS USEFUL"];
    } else if (usefulCount == 0) {
        usefulnessMeter.text = [NSString stringWithFormat:@"NOBODY FOUND THIS USEFUL YET"];
    }
}

- (void)viewDidLoad
{
    TipboxAppDelegate *appDelegate = (TipboxAppDelegate *)[[UIApplication sharedApplication] delegate];
    global = appDelegate.global;
    CGRect screenBound = [[UIScreen mainScreen] bounds];
    CGFloat screenHeight = screenBound.size.height;
    
    [self setTitle:@"Quick Start Guide"];
    skipButton = [[UIBarButtonItem alloc] initWithTitle:@"Continue" style:UIBarButtonItemStyleBordered target:self action:@selector(skipTutorial)];
    skipButton.style = UIBarButtonItemStyleDone;
    
    [self.navigationItem setHidesBackButton:YES animated:YES];
    self.navigationItem.rightBarButtonItem = skipButton;
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_paper_texture.png"]];
    
    card = [[TipCard alloc] init];
    
    geniusIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"genius_star.png"]];
    geniusIcon.alpha = 0.0;
    geniusIcon.frame = CGRectMake(145, 11, 16, 16);
    
    NSMutableDictionary *tipData = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"", @"id",
                                    @"", @"userid",
                                    @"Ali Mahouk", @"fullname",
                                    @"MachOSX", @"username",
                                    @"", @"catid",
                                    @"", @"subcat",
                                    @"thing", @"parentcat",
                                    @"Many people don't know this, but you can edit or even delete your messages after they've been sent. Try right-clicking a sent message & look for these options.", @"content",
                                    @"", @"topicid",
                                    @"Skype", @"topicContent",
                                    @"", @"relativeTime",
                                    @"2m", @"relativeTimeShort",
                                    @"", @"time",
                                    @"f3a81e8e362ddbd0d54b84a39d9232134e31c118", @"pichash", nil];
    
    card.showsMarkUsefulButton = YES;
    [card populateCellWithContent:tipData];
    
    replayButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    [replayButton setImage:[UIImage imageNamed:@"tutorial_replay.png"] forState:UIControlStateNormal];
    [replayButton addTarget:self action:@selector(play) forControlEvents:UIControlEventTouchUpInside];
    replayButton.frame = CGRectMake(20, 20, 21, 21);
    replayButton.opaque = YES;
    replayButton.alpha = 0;
    
    welcomeLabel_1 = [[UILabel alloc] initWithFrame:CGRectMake(20, screenHeight - 280, 280, 30)];
    welcomeLabel_1.backgroundColor = [UIColor clearColor];
    welcomeLabel_1.textColor = [UIColor colorWithRed:76.0/255.0 green:86.0/255.0 blue:108.0/255.0 alpha:1.0];
    welcomeLabel_1.shadowColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    welcomeLabel_1.shadowOffset = CGSizeMake(0, 1);
    welcomeLabel_1.numberOfLines = 1;
    welcomeLabel_1.minimumFontSize = 8.;
    welcomeLabel_1.adjustsFontSizeToFitWidth = YES;
    welcomeLabel_1.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:28];
    welcomeLabel_1.textAlignment = UITextAlignmentCenter;
    welcomeLabel_1.text = [NSString stringWithFormat:@"Hi, %@!", [global readProperty:@"name"]];
    welcomeLabel_1.alpha = 0;
    
    welcomeLabel_2 = [[UILabel alloc] initWithFrame:CGRectMake(20, screenHeight - 310, 280, 100)];
    welcomeLabel_2.backgroundColor = [UIColor clearColor];
    welcomeLabel_2.textColor = [UIColor colorWithRed:76.0/255.0 green:86.0/255.0 blue:108.0/255.0 alpha:1.0];
    welcomeLabel_2.shadowColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    welcomeLabel_2.shadowOffset = CGSizeMake(0, 1);
    welcomeLabel_2.numberOfLines = 0;
    welcomeLabel_2.font = [UIFont fontWithName:@"HelveticaNeue" size:22];
    welcomeLabel_2.textAlignment = UITextAlignmentCenter;
    welcomeLabel_2.text = @"Let's go on a very quick tour of Tipbox.";
    welcomeLabel_2.alpha = 0;
    
    popover_1 = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"popup_tooltip_noarrow.png"] stretchableImageWithLeftCapWidth:21.0 topCapHeight:21.0]];
    popover_1.opaque = YES;
    popover_1.frame = CGRectMake(55, screenHeight - 460, 210, 80);
    popover_1.alpha = 0;
    
    UILabel *popoverLabel_1 = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, 175, 35)];
    popoverLabel_1.backgroundColor = [UIColor clearColor];
    popoverLabel_1.textColor = [UIColor whiteColor];
    popoverLabel_1.shadowColor = [UIColor colorWithWhite:0.0 alpha:1.0];
    popoverLabel_1.shadowOffset = CGSizeMake(0, -1);
    popoverLabel_1.numberOfLines = 0;
    popoverLabel_1.font = [UIFont fontWithName:@"HelveticaNeue" size:SECONDARY_FONT_SIZE];
    popoverLabel_1.text = @"Tipbox is all about tips like this one.";
    
    popover_2 = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"popup_tooltip_center.png"] stretchableImageWithLeftCapWidth:21.0 topCapHeight:21.0]];
    popover_2.opaque = YES;
    popover_2.frame = CGRectMake(55, screenHeight - 420, 210, 110);
    popover_2.alpha = 0;
    
    UILabel *popoverLabel_2 = [[UILabel alloc] initWithFrame:CGRectMake(20, 15, 175, 70)];
    popoverLabel_2.backgroundColor = [UIColor clearColor];
    popoverLabel_2.textColor = [UIColor whiteColor];
    popoverLabel_2.shadowColor = [UIColor colorWithWhite:0.0 alpha:1.0];
    popoverLabel_2.shadowOffset = CGSizeMake(0, -1);
    popoverLabel_2.numberOfLines = 0;
    popoverLabel_2.font = [UIFont fontWithName:@"HelveticaNeue" size:SECONDARY_FONT_SIZE];
    popoverLabel_2.text = @"As you can see, it's pretty simple and personal. 200 characters is as long as tips can go.";
    
    popover_3 = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"popup_tooltip_left.png"] stretchableImageWithLeftCapWidth:21.0 topCapHeight:21.0]];
    popover_3.opaque = YES;
    popover_3.frame = CGRectMake(10, screenHeight - 295, 210, 100);
    popover_3.alpha = 0;
    
    UILabel *popoverLabel_3 = [[UILabel alloc] initWithFrame:CGRectMake(20, 15, 175, 60)];
    popoverLabel_3.backgroundColor = [UIColor clearColor];
    popoverLabel_3.textColor = [UIColor whiteColor];
    popoverLabel_3.shadowColor = [UIColor colorWithWhite:0.0 alpha:1.0];
    popoverLabel_3.shadowOffset = CGSizeMake(0, -1);
    popoverLabel_3.numberOfLines = 0;
    popoverLabel_3.font = [UIFont fontWithName:@"HelveticaNeue" size:SECONDARY_FONT_SIZE];
    popoverLabel_3.text = @"This is the topic of the tip. It tells people what you're talking about.";
    
    popover_4 = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"popup_tooltip_right.png"] stretchableImageWithLeftCapWidth:21.0 topCapHeight:21.0]];
    popover_4.opaque = YES;
    popover_4.frame = CGRectMake(107, screenHeight - 365, 210, 90);
    popover_4.alpha = 0;
    
    UILabel *popoverLabel_4 = [[UILabel alloc] initWithFrame:CGRectMake(20, 15, 175, 50)];
    popoverLabel_4.backgroundColor = [UIColor clearColor];
    popoverLabel_4.textColor = [UIColor whiteColor];
    popoverLabel_4.shadowColor = [UIColor colorWithWhite:0.0 alpha:1.0];
    popoverLabel_4.shadowOffset = CGSizeMake(0, -1);
    popoverLabel_4.numberOfLines = 0;
    popoverLabel_4.font = [UIFont fontWithName:@"HelveticaNeue" size:SECONDARY_FONT_SIZE];
    popoverLabel_4.text = @"You can tap this button to show that you found this tip useful!";
    
    popover_5 = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"popup_tooltip_noarrow.png"] stretchableImageWithLeftCapWidth:21.0 topCapHeight:21.0]];
    popover_5.opaque = YES;
    popover_5.frame = CGRectMake(45, -5, 230, 90);
    popover_5.alpha = 0;
    
    UILabel *popoverLabel_5 = [[UILabel alloc] initWithFrame:CGRectMake(20, 15, 185, 50)];
    popoverLabel_5.backgroundColor = [UIColor clearColor];
    popoverLabel_5.textColor = [UIColor whiteColor];
    popoverLabel_5.shadowColor = [UIColor colorWithWhite:0.0 alpha:1.0];
    popoverLabel_5.shadowOffset = CGSizeMake(0, -1);
    popoverLabel_5.numberOfLines = 0;
    popoverLabel_5.font = [UIFont fontWithName:@"HelveticaNeue" size:SECONDARY_FONT_SIZE];
    popoverLabel_5.text = @"If lots of people find your tips on a topic useful, you become the \"Genius\" of that topic!";
    
    usefulnessMeter = [[UILabel alloc] initWithFrame:CGRectMake(15, screenHeight - 405, 290, 20)];
    usefulnessMeter.backgroundColor = [UIColor clearColor];
	usefulnessMeter.textColor = [UIColor colorWithRed:145.0/255.0 green:145.0/255.0 blue:145.0/255.0 alpha:1.0];
    usefulnessMeter.shadowColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    usefulnessMeter.shadowOffset = CGSizeMake(0, 1);
	usefulnessMeter.numberOfLines = 1;
	usefulnessMeter.font = [UIFont boldSystemFontOfSize:MIN_MAIN_FONT_SIZE];
    usefulnessMeter.opaque = YES;
    usefulnessMeter.text = [NSString stringWithFormat:@"NOBODY FOUND THIS USEFUL YET"];
    usefulnessMeter.alpha = 0;
    
    finalWord = [[UILabel alloc] initWithFrame:CGRectMake(20, screenHeight - 310, 280, 100)];
    finalWord.backgroundColor = [UIColor clearColor];
    finalWord.textColor = [UIColor colorWithRed:76.0/255.0 green:86.0/255.0 blue:108.0/255.0 alpha:1.0];
    finalWord.shadowColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    finalWord.shadowOffset = CGSizeMake(0, 1);
    finalWord.numberOfLines = 0;
    finalWord.font = [UIFont fontWithName:@"HelveticaNeue" size:22];
    finalWord.textAlignment = UITextAlignmentCenter;
    finalWord.text = @"Great! You're now ready to start exploring Tipbox. Happy tip hunting!";
    finalWord.alpha = 0;
    
    [self.view addSubview:finalWord];
    [self.view addSubview:usefulnessMeter];
    [self.view addSubview:card];
    [self.view addSubview:welcomeLabel_1];
    [self.view addSubview:welcomeLabel_2];
    [self.view addSubview:popover_1];
    [self.view addSubview:popover_2];
    [self.view addSubview:popover_3];
    [self.view addSubview:popover_4];
    [self.view addSubview:popover_5];
    [self.view addSubview:replayButton];
    [card addSubview:geniusIcon];
    [popover_1 addSubview:popoverLabel_1];
    [popover_2 addSubview:popoverLabel_2];
    [popover_3 addSubview:popoverLabel_3];
    [popover_4 addSubview:popoverLabel_4];
    [popover_5 addSubview:popoverLabel_5];
    
    card.frame = CGRectMake(0, -240, 320, 480);
    
    [self play];
    
    [popoverLabel_1 release];
    [popoverLabel_2 release];
    [popoverLabel_3 release];
    [popoverLabel_4 release];
    [popoverLabel_5 release];
    [super viewDidLoad];
}

#pragma mark Customizations when the view appears/disappears
- (void)viewWillAppear:(BOOL)animated
{
    CGRect screenBound = [[UIScreen mainScreen] bounds];
    CGFloat screenHeight = screenBound.size.height;
    
    TipboxAppDelegate *appDelegate = (TipboxAppDelegate *)[[UIApplication sharedApplication] delegate];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    [self.navigationController.view setFrame:CGRectMake(0, 0, 320, screenHeight + 20)];
    
    [appDelegate tabbarShadowMode_nobar];
    [appDelegate navbarShadowMode_navbar];
    [appDelegate hideNavbarShadowAnimated:YES];
    [appDelegate showTabbarShadowAnimated:YES];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    CGRect screenBound = [[UIScreen mainScreen] bounds];
    CGFloat screenHeight = screenBound.size.height;
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
    [self.navigationController.view setFrame:CGRectMake(0, 0, 320, screenHeight)];
    
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


- (void)dealloc
{
    [card release];
    [replayButton release];
    [geniusIcon release];
    [usefulnessMeter release];
    [welcomeLabel_1 release];
    [welcomeLabel_2 release];
    [popover_1 release];
    [popover_2 release];
    [popover_3 release];
    [popover_4 release];
    [popover_5 release];
    [finalWord release];
    [super dealloc];
}


@end
