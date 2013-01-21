#import "Constants.h"

@interface POLYGONLIST : NSObject {
	
    char		name[MAXNAMESIZE];			// Material name	(e.g. "VS Matte 151")
    char		texturename[MAXNAMESIZE];	// Texture name		(e.g. "Duranium.tga")
    char        bumpmapname[MAXNAMESIZE];   // Bumpmap name     (e.g. "Luminous.gif")
        
    GLfloat		ambient[4];
    GLfloat		diffuse[4];
    GLfloat		specular[4];
    GLfloat     shininess;
    GLfloat		alpha;

    BOOL		doublesided;
        
    GLuint		textureID;
    GLuint      bumpMapID;

    GLuint      materialIBO;                // IBO indexes into the VBO for this material's vertices, normals and texcoords

    GLuint      *iboBuffer;                 // Client-side IBO buffer, an index to Points of surfaces using this material
    GLuint      iboSize;
        
    NSMutableArray	*TriangleIndexList;		// Array of SURFACEs, whose Points (P0, P1, P2) are indices into VertexList
}

-(id)		getTriangleIndexList;
-(int)		getTriangleIndexListCount;

-(id)		addTriangleIndexList;

-(char*)	getName;
-(char*)    getTextureName;
-(char*)    getBumpMapName;

-(void)		genTextureID;
-(void)     genBumpMapID;
-(void)     genMaterialIBO;

-(GLuint)	getTextureID;
-(GLuint)   getBumpMapID;
-(GLuint)   getMaterialIBO;

-(GLuint*)  getIBOBuffer;
-(GLuint)   getIBOSize;

-(GLfloat*)	getAmbient;
-(GLfloat*)	getDiffuse;
-(GLfloat*)	getSpecular;
-(GLfloat)  getShininess;
-(GLfloat)  getAlpha;

-(BOOL)		getDoubleSided;

-(void)		setName			:(char*)new_Name;
-(void)		setTextureName	:(char*)new_TextureName;
-(void)     setBumpMapName  :(char*)new_BumpMapName;
-(void)		setAmbient 		:(GLfloat*)new_Ambient;
-(void)		setDiffuse 		:(GLfloat*)new_Diffuse;
-(void)		setSpecular		:(GLfloat*)new_Specular;
-(void)     setShininess    :(GLfloat)new_Shininess;
-(void)		setAlpha        :(GLfloat)new_Alpha;
-(void)		setDoubleSided	:(BOOL)new_DoubleSided;

-(void)     setIBOBuffer    :(GLuint*)new_iboBuffer;
-(void)     setIBOSize      :(GLuint)new_iboSize;

@end
