#import "UIStrobeLight.h"

@implementation UIStrobeLight

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)activateStrobeLight
{
    self.animationImages = [NSArray arrayWithObjects:	
								  [UIImage imageNamed:@"Login_Strobe_Light_1.png"],
								  [UIImage imageNamed:@"Login_Strobe_Light_2.png"],
								  [UIImage imageNamed:@"Login_Strobe_Light_3.png"],
								  [UIImage imageNamed:@"Login_Strobe_Light_4.png"],
								  [UIImage imageNamed:@"Login_Strobe_Light_5.png"],
								  [UIImage imageNamed:@"Login_Strobe_Light_6.png"],
								  [UIImage imageNamed:@"Login_Strobe_Light_7.png"],
								  [UIImage imageNamed:@"Login_Strobe_Light_8.png"],
								  [UIImage imageNamed:@"Login_Strobe_Light_9.png"],
								  [UIImage imageNamed:@"Login_Strobe_Light_10.png"],
								  [UIImage imageNamed:@"Login_Strobe_Light_11.png"],
								  [UIImage imageNamed:@"Login_Strobe_Light_12.png"],
								  [UIImage imageNamed:@"Login_Strobe_Light_13.png"],
								  [UIImage imageNamed:@"Login_Strobe_Light_14.png"],
								  [UIImage imageNamed:@"Login_Strobe_Light_15.png"],
								  [UIImage imageNamed:@"Login_Strobe_Light_16.png"],
								  [UIImage imageNamed:@"Login_Strobe_Light_17.png"],
								  [UIImage imageNamed:@"Login_Strobe_Light_18.png"],
								  [UIImage imageNamed:@"Login_Strobe_Light_19.png"],
								  [UIImage imageNamed:@"Login_Strobe_Light_20.png"],
								  [UIImage imageNamed:@"Login_Strobe_Light_21.png"],
								  [UIImage imageNamed:@"Login_Strobe_Light_22.png"],
								  [UIImage imageNamed:@"Login_Strobe_Light_23.png"],
								  [UIImage imageNamed:@"Login_Strobe_Light_24.png"],
								  [UIImage imageNamed:@"Login_Strobe_Light_25.png"],
								  [UIImage imageNamed:@"Login_Strobe_Light_26.png"],
								  [UIImage imageNamed:@"Login_Strobe_Light_27.png"],
								  [UIImage imageNamed:@"Login_Strobe_Light_28.png"],
								  [UIImage imageNamed:@"Login_Strobe_Light_29.png"],
								  [UIImage imageNamed:@"Login_Strobe_Light_30.png"],
								  [UIImage imageNamed:@"Login_Strobe_Light_31.png"],
								  [UIImage imageNamed:@"Login_Strobe_Light_32.png"],
								  [UIImage imageNamed:@"Login_Strobe_Light_33.png"],
								  [UIImage imageNamed:@"Login_Strobe_Light_34.png"],
								  [UIImage imageNamed:@"Login_Strobe_Light_35.png"],
								  [UIImage imageNamed:@"Login_Strobe_Light_36.png"],
								  [UIImage imageNamed:@"Login_Strobe_Light_37.png"],
								  [UIImage imageNamed:@"Login_Strobe_Light_38.png"],
								  [UIImage imageNamed:@"Login_Strobe_Light_39.png"],
								  [UIImage imageNamed:@"Login_Strobe_Light_40.png"],
								  [UIImage imageNamed:@"Login_Strobe_Light_41.png"],
								  [UIImage imageNamed:@"Login_Strobe_Light_42.png"],
								  [UIImage imageNamed:@"Login_Strobe_Light_43.png"],
								  [UIImage imageNamed:@"Login_Strobe_Light_44.png"],
								  [UIImage imageNamed:@"Login_Strobe_Light_45.png"],
								  [UIImage imageNamed:@"Login_Strobe_Light_46.png"],
								  [UIImage imageNamed:@"Login_Strobe_Light_47.png"],
								  [UIImage imageNamed:@"Login_Strobe_Light_48.png"],
								  [UIImage imageNamed:@"Login_Strobe_Light_49.png"],
								  [UIImage imageNamed:@"Login_Strobe_Light_50.png"],
								  [UIImage imageNamed:@"Login_Strobe_Light_51.png"],
								  [UIImage imageNamed:@"Login_Strobe_Light_52.png"],
								  [UIImage imageNamed:@"Login_Strobe_Light_53.png"],
								  [UIImage imageNamed:@"Login_Strobe_Light_54.png"],
								  [UIImage imageNamed:@"Login_Strobe_Light_55.png"],
								  [UIImage imageNamed:@"Login_Strobe_Light_56.png"],
								  [UIImage imageNamed:@"Login_Strobe_Light_57.png"],
								  [UIImage imageNamed:@"Login_Strobe_Light_58.png"],
								  [UIImage imageNamed:@"Login_Strobe_Light_59.png"],
								  [UIImage imageNamed:@"Login_Strobe_Light_60.png"],
								  [UIImage imageNamed:@"Login_Strobe_Light_61.png"],
								  [UIImage imageNamed:@"Login_Strobe_Light_62.png"],
								  [UIImage imageNamed:@"Login_Strobe_Light_63.png"],
								  [UIImage imageNamed:@"Login_Strobe_Light_64.png"],
								  [UIImage imageNamed:@"Login_Strobe_Light_65.png"],
								  [UIImage imageNamed:@"Login_Strobe_Light_66.png"],
								  [UIImage imageNamed:@"Login_Strobe_Light_67.png"],
								  [UIImage imageNamed:@"Login_Strobe_Light_68.png"],
								  [UIImage imageNamed:@"Login_Strobe_Light_69.png"],
								  [UIImage imageNamed:@"Login_Strobe_Light_70.png"],
								  [UIImage imageNamed:@"Login_Strobe_Light_71.png"],
								  [UIImage imageNamed:@"Login_Strobe_Light_72.png"],
								  [UIImage imageNamed:@"Login_Strobe_Light_73.png"],
								  [UIImage imageNamed:@"Login_Strobe_Light_74.png"],
								  [UIImage imageNamed:@"Login_Strobe_Light_75.png"],
								  [UIImage imageNamed:@"Login_Strobe_Light_76.png"],
								  [UIImage imageNamed:@"Login_Strobe_Light_77.png"],
								  [UIImage imageNamed:@"Login_Strobe_Light_78.png"],
								  [UIImage imageNamed:@"Login_Strobe_Light_79.png"],
								  [UIImage imageNamed:@"Login_Strobe_Light_80.png"],
								  [UIImage imageNamed:@"Login_Strobe_Light_81.png"],
								  [UIImage imageNamed:@"Login_Strobe_Light_82.png"],
								  [UIImage imageNamed:@"Login_Strobe_Light_83.png"],
								  [UIImage imageNamed:@"Login_Strobe_Light.png"],
								  [UIImage imageNamed:@"Login_Strobe_Light.png"],
								  [UIImage imageNamed:@"Login_Strobe_Light.png"],
								  [UIImage imageNamed:@"Login_Strobe_Light.png"],
								  [UIImage imageNamed:@"Login_Strobe_Light.png"], nil]; // I repeated the last few frames to ease out the ending.
	
	// All frames will execute in 1.75 seconds.
	self.animationDuration = 1.75;
	
	// Repeat the annimation forever.
	self.animationRepeatCount = 0;
	
	// Start animating.
	[self startAnimating];
}

- (void)affirmativeStrobeLight
{
    [self stopAnimating];
    self.image = [UIImage imageNamed:@"Login_Strobe_Light_Affirmative.png"];
    [NSTimer scheduledTimerWithTimeInterval:3.0
                                     target:self
                                   selector:@selector(deactivateStrobeLight)
                                   userInfo:nil
                                    repeats:NO];
}

- (void)negativeStrobeLight
{
    [self stopAnimating];
    self.image = [UIImage imageNamed:@"Login_Strobe_Light_Negative.png"];
    [NSTimer scheduledTimerWithTimeInterval:3.0
                                     target:self
                                   selector:@selector(deactivateStrobeLight)
                                   userInfo:nil
                                    repeats:NO];
}

- (void)defaultStrobeLight
{
    [self stopAnimating];
    self.image = [UIImage imageNamed:@"Login_Strobe_Light.png"];
}

- (void)deactivateStrobeLight
{
    [self stopAnimating];
    
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished){
        self.image = nil;
        self.alpha = 1;
    }];
    
}

@end
