//
//  LPLabel.h "Letterpress Label"
//  Tipbox
//
//  Created by Ali Mahouk on 2/25/12.
//  Copyright (c) 2012 Scapehouse. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LPLabel : UILabel {
    UILabel *textLabel;
    UILabel *upperShadowLabel;
    UILabel *lowerShadowLabel;
}

- (void)formatLabel;

@end
