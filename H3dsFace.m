#import "H3dsFace.h"

@implementation H3dsFace

-(id)	init
    {
    if	(self = [super init])
		{
		p0 = p1 = p2 = 0;
		flags		 = 0;
		}
    return	self;
    }

-(short)getP0	{return p0;}
-(short)getP1	{return p1;}
-(short)getP2	{return p2;}

-(void) setP0 	:(float)new_P0 	  {p0 = new_P0;}
-(void) setP1 	:(float)new_P1 	  {p1 = new_P1;}
-(void) setP2 	:(float)new_P2 	  {p2 = new_P2;}
-(void) setFlags:(float)new_Flags {flags = new_Flags;}

@end
