#import "TRIANGLE.h"

@implementation TRIANGLE

-(id)	init {
	
    if	((self = [super init])) {
		
		p0 = p1 = p2 = 0;
	}
	
    return self;
}

-(GLuint) getP0	{return p0;}
-(GLuint) getP1	{return p1;}
-(GLuint) getP2	{return p2;}

-(void) setP0	:(GLuint)new_P0		{p0=new_P0;}
-(void) setP1	:(GLuint)new_P1		{p1=new_P1;}
-(void) setP2	:(GLuint)new_P2		{p2=new_P2;}

@end
