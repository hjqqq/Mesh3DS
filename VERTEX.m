#import "VERTEX.h"

@implementation VERTEX

-(id)	init {
	
    if	((self = [super init])) {x = y = z = nx = ny = nz = u = v = tx = ty = tz = 0.0;}
        
    return self;
}

-(id)	init	:(GLfloat)new_X     :(GLfloat)new_Y     :(GLfloat)new_Z
                :(GLfloat)new_NX    :(GLfloat)new_NY    :(GLfloat)new_NZ
                :(GLfloat)new_U     :(GLfloat)new_V
				:(GLfloat)new_TX    :(GLfloat)new_TY    :(GLfloat)new_TZ {
	
    if	((self = [super init])) {
		
        x  = new_X;		y  = new_Y;		z  = new_Z;
		nx = new_NX;	ny = new_NY;	nz = new_NZ;
		u  = new_U;		v  = new_V;
        tx = new_TX;    ty = new_TY;    tz = new_TZ;
    }
    
    return self;
}
    
-(GLfloat) getX		{return x;}
-(GLfloat) getY		{return y;}
-(GLfloat) getZ		{return z;}

-(GLfloat) getNX	{return nx;}
-(GLfloat) getNY	{return ny;}
-(GLfloat) getNZ	{return nz;}

-(GLfloat) getU		{return u;}
-(GLfloat) getV		{return v;}

-(GLfloat) getTX	{return tx;}
-(GLfloat) getTY	{return ty;}
-(GLfloat) getTZ	{return tz;}

-(void)	setX	:(GLfloat)new_X		{x=new_X;}
-(void)	setY	:(GLfloat)new_Y		{y=new_Y;}
-(void)	setZ	:(GLfloat)new_Z		{z=new_Z;}

-(void)	setNX	:(GLfloat)new_NX	{nx=new_NX;}
-(void)	setNY	:(GLfloat)new_NY	{ny=new_NY;}
-(void)	setNZ	:(GLfloat)new_NZ	{nz=new_NZ;}

-(void)	setU	:(GLfloat)new_U		{u=new_U;}
-(void)	setV	:(GLfloat)new_V		{v=new_V;}

-(void)	setTX	:(GLfloat)new_TX	{tx=new_TX;}
-(void)	setTY	:(GLfloat)new_TY	{ty=new_TY;}
-(void)	setTZ	:(GLfloat)new_TZ	{tz=new_TZ;}

-(void)	Zoom	:(float)zoom		{x *= zoom; y *= zoom; z *= zoom;}

@end
