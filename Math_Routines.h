#import "Constants.h"
#import "Mesh3DS.h"
#import "VERTEX.h"
#import "SURFACE.h"

@interface Mesh3DS (Math_Routines)

-(GLfloat)	Angle		:(SURFACE*)surface	:(GLuint)vertex;

-(Vector3f)	Tangent		:(SURFACE*)surface	:(GLuint)vertex;

-(GLfloat)	Cos_angle	:(SURFACE*)surface1	:(SURFACE*)surface2;

-(double)	Distance	:(VERTEX*)v1		:(VERTEX*)v2;

@end
