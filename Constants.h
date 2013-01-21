#define	MAXNAMESIZE         16+1					// Filename size limit is defined by 3DS MAX, plus an extra byte to hold the null character as string terminator

#define BUFFER_OFFSET(i)   ((void*)nil + (i))       // A reminder that gl*Pointer/glDraw* addresses become relative to the last Buffer Object bound by glBindBuffer

#define STRINGIFY(A)        #A                      // Macro to help load Vertex and Fragment Shader source code strings, preserving indents for readability

typedef struct Vector3f {							// Trying to avoid C++ whenever possible, so just define a simple vector data type ourselves
	
	float x, y, z;

} Vector3f;

enum
    {
    CHUNK_RGB1				= 0x0010,
    CHUNK_RGB2				= 0x0011,
    CHUNK_RGB3				= 0x0012,
    CHUNK_AMOUNT			= 0x0030,
    CHUNK_MAIN				= 0x4D4D,
    CHUNK_OBJMESH			= 0x3D3D,
    CHUNK_BKGCOLOR			= 0x1200,
    CHUNK_AMBCOLOR			= 0x2100,
    CHUNK_OBJBLOCK			= 0x4000,
    CHUNK_TRIMESH			= 0x4100,
    CHUNK_VERTLIST			= 0x4110,
    CHUNK_FACELIST			= 0x4120,
    CHUNK_FACEMAT			= 0x4130,
    CHUNK_MAPLIST			= 0x4140,
    CHUNK_SMOOLIST			= 0x4150,
    CHUNK_TRMATRIX			= 0x4160,
    CHUNK_LIGHT				= 0x4600,
    CHUNK_SPOTLIGHT			= 0x4610,
    CHUNK_CAMERA			= 0x4700,
    CHUNK_MATERIAL			= 0xAFFF,
    CHUNK_MATNAME			= 0xA000,
    CHUNK_AMBIENT			= 0xA010,
    CHUNK_DIFFUSE			= 0xA020,
    CHUNK_SPECULAR			= 0xA030,
    CHUNK_SHININESS			= 0xA040,
    CHUNK_SHINE_STRENGTH	= 0xA041,
    CHUNK_TRANSPARENCY		= 0xA050,
    CHUNK_DOUBLESIDED		= 0xA081,
    CHUNK_XPFALLIN			= 0xA08A,
    CHUNK_TEXTURE			= 0xA200,
    CHUNK_BUMPMAP			= 0xA230,
    CHUNK_MAPFILENAME		= 0xA300,
    CHUNK_MAPOPTIONS		= 0xA351,
    CHUNK_KEYFRAMER			= 0xB000,
    CHUNK_FRAMES			= 0xB008
    };

/*
 
Various utility code parked here...
 
// Adaptive Analytic Texture Aliasing:
				float V			= texcoord.s;
				float frequency	= 6.0;
				float sawtooth	= fract (V * frequency);
				float triangle	= abs (2.0 * sawtooth - 1.0);
				float dp		= length (vec2 (dFdx(V), dFdy(V)));
				float edge		= dp * frequency * 2.0;
				float square	= smoothstep (0.5 - edge, 0.5 + edge, V);
				
				gl_FragColor	= vec4 (vec3 (square), 1.0) * fragmentColor * textureColor;

// Non-Adaptive Aliasing:
				float deriv		= fwidth (texcoord.s);
				float amt		= smoothstep (.5-deriv,.5+deriv, texcoord.s);
				gl_FragColor	= mix (textureColor, fragmentColor, amt);
 
//////////////

NSLog(@"Vertex %i Normal: %5.2f, %5.2f, %5.2f", i, [vertex_entry getNX], [vertex_entry getNY], [vertex_entry getNZ]);

NSLog(@"vertex=%i, surface=%i, points: %2i, %2i, %2i %@", i, surface, [currentSurface getP0], [currentSurface getP1], [currentSurface getP2], ([self Cos_angle :firstSurface :currentSurface] <= cosineThreshold) ? @"Split" : @"");

NSLog(@"Material name=%s, Texture name =%s, Alpha=%f, 2-Sided=%i, TextureID=%i", [poly_entry getName], [poly_entry getTextureName], [poly_entry getAlpha], [poly_entry getDoubleSided], [poly_entry getTextureID]);

NSLog(@"i=%i\niboSize=%i\n[PolyList count]=%lu\ngetTriangleIndexListCount=%i", i, [poly_entry getIBOSize], [PolyList count], [poly_entry getTriangleIndexListCount]);

 
 NSLog (@"Material: %s, Shininess: %f, Alpha: %f\n Ambient: %f, %f, %f, %f\n Diffuse: %f, %f, %f, %f\n Specular:%f, %f, %f, %f", [mat getMatName], shininess, alpha,
 ambient[0], ambient[1], ambient[2], ambient[3],
 diffuse[0],	diffuse[1], diffuse[2], diffuse[3],
 specular[0],specular[1],specular[2],specular[3]);
 
///////////////
 
#include <GLUT/glut.h> 
glFrontFace(GL_CW);
glutWireTeapot(10);
glFrontFace(GL_CCW); 
 
///////////////////////////////
#import "OpenGL/glu.h"

GLenum lastGLError;
while ((lastGLError = glGetError()) != GL_NO_ERROR) { NSLog (@"Mesh3DS->SetupVBOandIBOs glError at PolyList loop (VBO bind): %d (%s)", lastGLError, gluErrorString (lastGLError)); }


#define printOpenGLError() printOglError(__FILE__, __LINE__)
int printOglError(char *file, int line)
{
GLenum glErr;

glErr = glGetError();
while (glErr != GL_NO_ERROR)
{
printf("glError in file %s @ line %d: %s\n", file, line, gluErrorString(glErr));
glErr = glGetError();
}
return glErr;
} 
 
/////////////////////////////// Simple X, Y, Z-axis at origin
glPushMatrix();
glLoadIdentity();
glLineWidth (4.0);

glBegin     (GL_LINES);
glColor3f   (1,0,0);
glVertex3f  (0,0,0);
glVertex3f  (10,0,0);

glColor3f   (0,1,0);
glVertex3f  (0,0,0);
glVertex3f  (0,10,0);

glColor3f   (0,0,1);
glVertex3f  (0,0,0);
glVertex3f  (0,0,10);
glEnd       ();

glLineWidth (1.0);
glPopMatrix ();	
 
*/