#import "H3dsVert.h"

@implementation H3dsVert

-(id)	init
    {
    if		(self = [super init]) {x = y = z = 0.0;}
    return	self;
    }

-(float)getX	{return x;}
-(float)getY	{return y;}
-(float)getZ	{return z;}

-(void) setX 	:(float)new_X 	  {x = new_X;}
-(void) setY 	:(float)new_Y 	  {y = new_Y;}
-(void) setZ 	:(float)new_Z 	  {z = new_Z;}

@end
