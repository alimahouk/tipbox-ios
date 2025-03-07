#import "Sound.h"

@implementation Sound

+ (void)soundEffect:(int)soundNumber
{
	
    NSString *effect = @"";
    NSString *type = @"";
	
	switch (soundNumber) {
		case 0:
			effect = @"slide";
			type = @"caf";
			break;
		default:
			break;
	}
	
    SystemSoundID soundID;
	
    NSString *path = [[NSBundle mainBundle] pathForResource:effect ofType:type];
    NSURL *url = [NSURL fileURLWithPath:path];
	
    AudioServicesCreateSystemSoundID((CFURLRef)url, &soundID);
    AudioServicesPlaySystemSound(soundID);
}

- (void)dealloc
{
    [super dealloc];
}

@end
