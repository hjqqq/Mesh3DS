#import "H3dsRGBColor.h"

@implementation H3dsRGBColor

-(id)	init
    {
    if	(self = [super init])
		{
		red     = 0.0;
		green	= 0.0;
		blue	= 0.0;
		}
    return	self;
    }

-(void) setRed	:(float)newRed	{red = newRed;}
-(void) setGreen:(float)newGreen{green = newGreen;}
-(void) setBlue	:(float)newBlue	{blue = newBlue;}

-(GLfloat) getRed	{return red;}
-(GLfloat) getGreen	{return green;}
-(GLfloat) getBlue	{return blue;}

@end
