#import "POLYGONLIST.h"
#import "SURFACE.h"

@implementation POLYGONLIST

-(id)init {
	
    if	((self = [super init]))
		{
        name[0]             = '\0';
        texturename[0]      = '\0';
        bumpmapname[0]      = '\0';
            
		textureID           = 0;
        bumpMapID           = 0;
        materialIBO         = 0;
        iboSize             = 0;
            
        iboBuffer           = nil;
            
		TriangleIndexList	= [[NSMutableArray alloc] init];
		}
    return self;
}
    
-(void)dealloc {
	
    if	(glIsTexture (textureID))  glDeleteTextures (1, &textureID);
        
    if  (glIsTexture(bumpMapID))   glDeleteTextures (1, &bumpMapID);
        
    if  (glIsBuffer (materialIBO)) glDeleteBuffers  (1, &materialIBO);
    
    if  (iboBuffer != nil) free (iboBuffer);

    [TriangleIndexList release];

    [super dealloc];
}

-(id)	getTriangleIndexList		{return TriangleIndexList;}
-(int)	getTriangleIndexListCount	{return [TriangleIndexList count];}

-(id)	addTriangleIndexList {
	
    [TriangleIndexList addObject:[[[SURFACE alloc] init] autorelease]];

    return [TriangleIndexList lastObject];
}

-(char*)	getName			{return name;}
-(char*)    getTextureName  {return texturename;}
-(char*)    getBumpMapName  {return bumpmapname;}

-(void)		genTextureID	{glGenTextures          (1, &textureID);}       //TODO: add some retry/error checking in case generating ID fails. Maybe also return the ID on success?
-(void)     genBumpMapID    {glGenTextures          (1, &bumpMapID);}       //TODO: Also, if there is already an ID assigned, unbind and delete it?
-(void)     genMaterialIBO  {glGenBuffers           (1, &materialIBO);} 

-(GLuint)	getTextureID	{return textureID;}
-(GLuint)   getBumpMapID    {return bumpMapID;}
-(GLuint)   getMaterialIBO  {return materialIBO;}
-(GLuint*)  getIBOBuffer    {return iboBuffer;}
-(GLuint)   getIBOSize      {return iboSize;}

-(GLfloat*)	getAmbient		{return ambient;}
-(GLfloat*)	getDiffuse		{return diffuse;}
-(GLfloat*)	getSpecular		{return specular;}
-(GLfloat)  getShininess    {return shininess;}
-(GLfloat)  getAlpha        {return alpha;}

-(BOOL)		getDoubleSided	{return doublesided;}

-(void)		setName			:(char*)new_Name			{strcpy (name, new_Name);}
-(void)		setTextureName	:(char*)new_TextureName		{strcpy (texturename, new_TextureName);}
-(void)     setBumpMapName  :(char*)new_BumpMapName     {strcpy (bumpmapname, new_BumpMapName);}

-(void)		setAmbient 		:(GLfloat*)new_Ambient		{memcpy (&ambient, new_Ambient,  sizeof(ambient));}
-(void)		setDiffuse 		:(GLfloat*)new_Diffuse		{memcpy (&diffuse, new_Diffuse,  sizeof(diffuse));}
-(void)		setSpecular		:(GLfloat*)new_Specular		{memcpy (&specular, new_Specular, sizeof(specular));}
-(void)		setShininess    :(GLfloat)new_Shininess     {shininess = new_Shininess;}
-(void)		setAlpha        :(GLfloat)new_Alpha         {alpha = new_Alpha;}

-(void)		setDoubleSided	:(BOOL)new_DoubleSided		{doublesided = new_DoubleSided;}

-(void)     setIBOBuffer    :(GLuint*)new_iboBuffer     {iboBuffer = new_iboBuffer;}
-(void)     setIBOSize      :(GLuint)new_iboSize        {iboSize = new_iboSize;}

@end
