@interface TRIANGLE : NSObject {
	
    GLuint	p0, p1, p2;						// Indexes into vertex array
}

-(GLuint) getP0;
-(GLuint) getP1;
-(GLuint) getP2;

-(void)   setP0	:(GLuint)new_P0;
-(void)   setP1	:(GLuint)new_P1;
-(void)   setP2	:(GLuint)new_P2;

@end
