#import "Mesh3DS.h"
#import "TRIANGLE.h"
#import "SURFACE.h"

@interface Mesh3DS (OpenGL_Routines)

-(void)	Convert_to_OpenGL;

-(void)	AddMaterial     :(GLfloat*)ambient	:(GLfloat*)diffuse	:(GLfloat*)specular     :(GLfloat)shininess     :(GLfloat)alpha
                        :(char*)name        :(char*)textureName :(char*)bumpmapName     :(BOOL)doubleSided;

-(void)	AddPolygon              :(TRIANGLE*)triangle	:(char*)MaterialName;

-(int)	FindMaterialIndex       :(char*)name;

-(void)	LinkVerticesToPolygons;

-(bool)	CalculateSurfaceNormal	:(SURFACE*)surface;

-(void)	CalculateVertexNormalsAndTangents;

-(void) SetupVertexAndFragmentShaders;

-(void) SetupVBOandIBOs;

-(void) ShaderStatus            :(GLuint)Object	:(GLenum)Parameter;

@end