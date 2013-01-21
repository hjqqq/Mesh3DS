@interface VERTEX : NSObject {
	
        GLfloat	x, y, z;						// Coordinates
        GLfloat	nx, ny, nz;						// Normal Vector
		GLfloat	u, v;							// Texture Coords
        GLfloat tx, ty, tz;                     // Tangent Vector
}

-(id)	init    :(GLfloat)new_X		:(GLfloat)new_Y		:(GLfloat)new_Z
                :(GLfloat)new_NX	:(GLfloat)new_NY	:(GLfloat)new_NZ
				:(GLfloat)new_U		:(GLfloat)new_V
				:(GLfloat)new_TX	:(GLfloat)new_TY	:(GLfloat)new_TZ;

-(GLfloat) getX;
-(GLfloat) getY;
-(GLfloat) getZ;

-(GLfloat) getNX;
-(GLfloat) getNY;
-(GLfloat) getNZ;

-(GLfloat) getU;
-(GLfloat) getV;

-(GLfloat) getTX;
-(GLfloat) getTY;
-(GLfloat) getTZ;

-(void)	setX	:(GLfloat)new_X;
-(void)	setY	:(GLfloat)new_Y;
-(void)	setZ	:(GLfloat)new_Z;

-(void)	setNX	:(GLfloat)new_NX;
-(void)	setNY	:(GLfloat)new_NY;
-(void)	setNZ	:(GLfloat)new_NZ;

-(void)	setU	:(GLfloat)new_U;
-(void)	setV	:(GLfloat)new_V;

-(void)	setTX	:(GLfloat)new_TX;
-(void)	setTY	:(GLfloat)new_TY;
-(void)	setTZ	:(GLfloat)new_TZ;

-(void)	Zoom	:(float)zoom;

@end
