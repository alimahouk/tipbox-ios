//
//  LPLabel.m "Letterpress Label"
//  Tipbox
//
//  Created by Ali Mahouk on 2/25/12.
//  Copyright (c) 2012 Scapehouse. All rights reserved.
//

#import "LPLabel.h"

@implementation LPLabel

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code
        textLabel = [[UILabel alloc] init];
        upperShadowLabel = [[UILabel alloc] init];
        lowerShadowLabel = [[UILabel alloc] init];
        [self addSubview:upperShadowLabel];
        [self addSubview:lowerShadowLabel];
        [self addSubview:textLabel];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        upperShadowLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, -1, frame.size.width, frame.size.height)];
        lowerShadowLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 1, frame.size.width, frame.size.height)];
        [self addSubview:upperShadowLabel];
        [self addSubview:lowerShadowLabel];
        [self addSubview:textLabel];
    }
    return self;
}

- (void)setFrame:(CGRect)frame
{
    super.frame = frame;
    textLabel.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    upperShadowLabel.frame = CGRectMake(0, -1, frame.size.width, frame.size.height);
    lowerShadowLabel.frame = CGRectMake(0, 1, frame.size.width, frame.size.height);
}

- (void)setText:(NSString *)text
{
    textLabel.text = text;
    upperShadowLabel.text = text;
    lowerShadowLabel.text = text;
    
    [self formatLabel];
}

- (NSString *)text
{
    return textLabel.text;
}

- (void)setTextColor:(UIColor *)textColor
{
    textLabel.textColor = textColor;
    super.textColor = textColor;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    upperShadowLabel.backgroundColor = backgroundColor;
}

- (void)setShadowColor:(UIColor *)shadowColor
{
    lowerShadowLabel.textColor = shadowColor;
}

- (void)formatLabel
{
    super.backgroundColor = [UIColor clearColor];
    
    textLabel.backgroundColor = [UIColor clearColor];
    textLabel.textColor = super.textColor;
    textLabel.numberOfLines = super.numberOfLines;
    textLabel.lineBreakMode = super.lineBreakMode;
    textLabel.textAlignment = super.textAlignment;
    textLabel.minimumFontSize = super.minimumFontSize;
    textLabel.adjustsFontSizeToFitWidth = [super adjustsFontSizeToFitWidth];
    textLabel.font = [UIFont fontWithName:super.font.fontName size:super.font.pointSize];
    
    upperShadowLabel.textColor = [UIColor colorWithRed:213.0/255.0 green:213.0/255.0 blue:213.0/255.0 alpha:0.8];
    upperShadowLabel.numberOfLines = super.numberOfLines;
    upperShadowLabel.lineBreakMode = super.lineBreakMode;
    upperShadowLabel.textAlignment = super.textAlignment;
    upperShadowLabel.minimumFontSize = super.minimumFontSize;
    upperShadowLabel.adjustsFontSizeToFitWidth = [super adjustsFontSizeToFitWidth];
    upperShadowLabel.font = [UIFont fontWithName:super.font.fontName size:super.font.pointSize];
    
    lowerShadowLabel.backgroundColor = [UIColor clearColor];
    lowerShadowLabel.numberOfLines = super.numberOfLines;
    lowerShadowLabel.lineBreakMode = super.lineBreakMode;
    lowerShadowLabel.textAlignment = super.textAlignment;
    lowerShadowLabel.minimumFontSize = super.minimumFontSize;
    lowerShadowLabel.adjustsFontSizeToFitWidth = [super adjustsFontSizeToFitWidth];
    lowerShadowLabel.font = [UIFont fontWithName:super.font.fontName size:super.font.pointSize];
}

- (void)dealloc
{
    [textLabel release];
    [upperShadowLabel release];
    [lowerShadowLabel release];
    [super dealloc];
}

@end
