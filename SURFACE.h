@interface SURFACE : NSObject {
	
    GLuint	p0, p1, p2;
    GLfloat	nx, ny, nz;
}

-(GLuint) getP0;
-(GLuint) getP1;
-(GLuint) getP2;

-(void)	 setP0 :(GLuint)new_p0;
-(void)	 setP1 :(GLuint)new_p1;
-(void)	 setP2 :(GLuint)new_p2;

-(GLfloat) getNX;
-(GLfloat) getNY;
-(GLfloat) getNZ;

-(void)	 setNX :(GLfloat)new_nx;
-(void)	 setNY :(GLfloat)new_ny;
-(void)	 setNZ :(GLfloat)new_nz;

@end
