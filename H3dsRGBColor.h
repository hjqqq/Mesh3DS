@interface H3dsRGBColor : NSObject
    {
    float	red;
    float	green;
    float	blue;
    }

-(void) setRed		:(float)newRed;
-(void) setGreen	:(float)newGreen;
-(void) setBlue		:(float)newBlue;

-(GLfloat) getRed;
-(GLfloat) getGreen;
-(GLfloat) getBlue;

@end
