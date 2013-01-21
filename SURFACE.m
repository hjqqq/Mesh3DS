#import "SURFACE.h"

@implementation SURFACE

-(id)	init {
	
    if	((self = [super init])) {
		
		p0 = p1 = p2 = 0;
		nx = ny = nz = 0.0;
	}
	
    return self;
}

-(GLuint) getP0		{return p0;}
-(GLuint) getP1		{return p1;}
-(GLuint) getP2		{return p2;}

-(void)	 setP0 :(GLuint)new_p0	{p0=new_p0;}
-(void)	 setP1 :(GLuint)new_p1	{p1=new_p1;}
-(void)	 setP2 :(GLuint)new_p2	{p2=new_p2;}

-(GLfloat) getNX	{return nx;}
-(GLfloat) getNY	{return ny;}
-(GLfloat) getNZ	{return nz;}

-(void)	 setNX :(GLfloat)new_nx	{nx=new_nx;}
-(void)	 setNY :(GLfloat)new_ny	{ny=new_ny;}
-(void)	 setNZ :(GLfloat)new_nz	{nz=new_nz;}

@end
