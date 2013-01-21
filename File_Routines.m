#import "File_Routines.h"

@implementation Mesh3DS (File_Routines)

-(void)Dread :(void*)dest :(int)len					// Reads len bytes from the file into the memory pointed to by *dest
{
    if	(fread(dest, len, 1, InFile) != 1)
    {
		NSLog (@"Error reading 3DS Mesh File.");    //TODO: Replace with error dialogue
		return;
    }
    
	if	(CFByteOrderGetCurrent() == CFByteOrderLittleEndian) return;	// If on an Intel CPU, no conversion needed
	
    if	(len == 2)									// Otherwise, convert little endian 3DS data into big endian format
    {
		*(UInt16*) dest = CFSwapInt16 (*(UInt16*)dest);
        
		return;
    }
	
    if	(len == 4)
    {
		*(UInt32*) dest = CFSwapInt32 (*(UInt32*)dest);
        
		return;
    }
}

-(void)Dsetpos :(int) pos
{
    if (fseek(InFile, (long)pos, SEEK_SET) != 0) printf("Error moving filepointer\n");
}

-(int)Dgetpos
{
    long pos;
  	
    if ((pos = ftell(InFile)) == -1L) printf("Error getting fileposition\n");
    
    return (int) pos;
}

-(bool)HRead3dsScene :(FILE*)ptr :(int)size 
{
    int             len, pc;
    unsigned short  ident;
    
    InFile	= ptr;
    
    pc		= [self Dgetpos];
    
    [self Dread :&ident :sizeof(ident)];
    [self Dread :&len   :sizeof(len)];
    
    if	(ident != CHUNK_MAIN)
    {
		printf ("Not in 3DS format.\n");    //TODO: Replace this printf's and NSLog's with an error dialogue
		return false;
    }
    
    [self ReadMainBlocks :(pc+len)];
    
    return true;
}

-(void)ReadMainBlocks :(int)p
{
    int             len, pc;
    unsigned short  ident;
    
    while	((pc = [self Dgetpos]) < p)
    {
		[self Dread :&ident :sizeof(ident)];
		[self Dread :&len   :sizeof(len)];
		
		switch	(ident)
        {
			case CHUNK_OBJMESH:
                
				[self ReadObjMeshBlocks :(pc+len)];
				break;
                
			case CHUNK_KEYFRAMER:
                
			default:
                
				[self Dsetpos :(pc+len)];
        }
    }
}

-(void)ReadObjMeshBlocks :(int)p
{
    int             len, pc;
    unsigned short  ident;
    
    while ((pc = [self Dgetpos]) < p)
    {
		[self Dread :&ident :sizeof(ident)];
		[self Dread :&len   :sizeof(len)];
        
		switch	(ident)
        {
			case CHUNK_MATERIAL:
                
				[self ReadMaterialBlocks :(pc+len)]; 
				break;
                
			case CHUNK_OBJBLOCK:
                
				[self ReadObjBlocks :(pc+len)]; 
				break;
                
			default:
                
				[self Dsetpos :(pc+len)];
        }
    }
}

-(void)ReadMaterialBlocks :(int)p
{
    int             len, pc;
    unsigned short  ident;
    
    H3dsMat *materialobj = [Scene addMaterial];
    
    while	((pc = [self Dgetpos]) < p)
    {
		[self Dread :&ident :sizeof(ident)];
		[self Dread :&len   :sizeof(len)];
        
		switch	(ident)
        {
			case CHUNK_MATNAME:
                
				[self ReadMatChunk :materialobj]; 
				break;
                
			case CHUNK_AMBIENT:
                
				[self ReadShadingChunk :(pc+len) :[materialobj getAmbient]];
				break;
                
			case CHUNK_DIFFUSE:
                
				[self ReadShadingChunk :(pc+len) :[materialobj getDiffuse]];
				break;
                
			case CHUNK_SPECULAR:
                
				[self ReadShadingChunk :(pc+len) :[materialobj getSpecular]];
				break;
                
			case CHUNK_TEXTURE:
                
				[self ReadTextureChunk :(pc+len) :[materialobj getTexture]];
				break;
                
			case CHUNK_BUMPMAP:
                
				[self ReadBumpMapChunk :(pc+len) :[materialobj getBumpMap]];
				break;
                
			case CHUNK_DOUBLESIDED:
                
				[self ReadDoublesidedChunk :[materialobj getDoubleSided]];
				break;
                
			case CHUNK_TRANSPARENCY:
                
				[self ReadTransparencyChunk :(pc+len) :[materialobj getTransparency]];
				break;
                
            case CHUNK_SHININESS:
                
                [self ReadShininessChunk :(pc+len) :[materialobj getShininess]];
                break;
                
			default: 
                
				[self Dsetpos :(pc+len)];
				break;
        }
    }
}

-(void)ReadMatChunk :(H3dsMat*)mat
{
    int     n = 0;
    char	name[MAXNAMESIZE];
    
    do
	{
        [self Dread :&name[n++] :1];
        
	} while	(name[n-1] != '\0' && n < sizeof(name));
    
	name[n-1] = '\0';
    
	[mat setMatName :name];
}

-(void)ReadShadingChunk :(int)p :(H3dsRGBColor*)rgb
{
    int             len, pc;
    unsigned short  ident;
    
    while ((pc = [self Dgetpos]) < p)
    {
		[self Dread :&ident :sizeof(ident)];
		[self Dread :&len   :sizeof(len)];
		
		switch	(ident)
        {
			case CHUNK_RGB1:
                
				[self ReadRGBFloat :(pc+len) :rgb];
				break;
                
			case CHUNK_RGB2:
                
				[self ReadRGBByte :(pc+len) :rgb];
				break;
                
			default:
                
				[self Dsetpos :(pc+len)];
        }
    }
}

-(void)ReadTextureChunk :(int)p :(H3dsTexture*)texture
{
    int             len, pc;
    unsigned short  ident;
    
    while ((pc = [self Dgetpos]) < p)
    {
		[self Dread :&ident :sizeof(ident)];
		[self Dread :&len   :sizeof(len)];
        
		switch	(ident)
        {
			case CHUNK_MAPFILENAME:
                
				[self ReadTextureNameChunk :(pc+len) :texture]; 
				break;
                
			default:
                
				[self Dsetpos :(pc+len)];
        }
    }
}

-(void)ReadBumpMapChunk :(int)p :(H3dsTexture*)texture
{
    int             len, pc;
    unsigned short  ident;
    
    while ((pc = [self Dgetpos]) < p)
    {
		[self Dread :&ident :sizeof(ident)];
		[self Dread :&len   :sizeof(len)];
        
		switch	(ident)
        {
			case CHUNK_MAPFILENAME:
                
				[self ReadTextureNameChunk :(pc+len) :texture]; 
				break;
                
			default:
                
				[self Dsetpos :(pc+len)];
        }
    }
}

-(void)ReadDoublesidedChunk :(BOOL*)twoSidedMaterial
{
    *twoSidedMaterial = true;           // If this chunk exists at all, the current material is two-sided and won't get backface culled
}

-(void)ReadTransparencyChunk :(int)p :(float*)transparency
{
    short           amount = 0;
    int             len, pc;
    unsigned short  ident;
    
    while ((pc = [self Dgetpos]) < p)
    {
		[self Dread :&ident :sizeof(ident)];
		[self Dread :&len   :sizeof(len)];
		
		switch	(ident)
        {
			case CHUNK_AMOUNT:
                
				[self ReadAmountChunk :&amount];
				break;
                
			default:
                
				[self Dsetpos :(pc+len)];
        }
    }
	
    *transparency = (float) amount;     // As read from the 3DS file, this is a 'percentage transparency'. We'll invert this
}                                       // to an 'alpha opacity' value as needed for OpenGL in the Convert_to_OpenGL routine 

-(void)ReadShininessChunk :(int)p :(float*)shininess
{
    short           amount = 0;
    int             len, pc;
    unsigned short  ident;
    
    while ((pc = [self Dgetpos]) < p)
    {
		[self Dread :&ident :sizeof(ident)];
		[self Dread :&len   :sizeof(len)];
		
		switch	(ident)
        {
			case CHUNK_AMOUNT:
                
				[self ReadAmountChunk :&amount];
				break;
                
			default:
                
				[self Dsetpos :(pc+len)];
        }
    }
	
    *shininess = (float) amount;        // As read from the 3DS file, this is a 'percentage shininess'. We'll scale this
}                                       // from [0..128] in the Convert_to_OpenGL routine

-(void)ReadAmountChunk :(short*)amount
{
    short	temp;
    
    [self Dread	:&temp :sizeof(temp)];
    
    *amount = temp;
}

-(void)ReadObjBlocks :(int)p
{
    int             n = 0;
    int             len, pc;
    unsigned short  ident;
    
    char	name[MAXNAMESIZE];
  	
    do
    {
		[self Dread :&name[n++] :1];
        
    } while	(name[n-1] != '\0' && n < sizeof(name));
    
    name[n-1] = '\0';
    
    while	((pc = [self Dgetpos]) < p)
    {
		[self Dread :&ident  :sizeof(ident)];
		[self Dread :&len    :sizeof(len)];
        
		switch	(ident)
        {
			case CHUNK_TRIMESH:
                
				[self ReadTriMeshBlocks :pc+len :name];
				break;
                
			default:
                
				[self Dsetpos :(pc+len)];
        }
    }
    [self Dsetpos :p];
}

-(void)ReadTriMeshBlocks :(int)p :(char*)name
{
    short           fl = 0;
    int             len, pc;
    unsigned short  ident;
    
    bool	found_facematerial = false;
    
    H3dsMeshObj *meshobj = [Scene addMeshObj];
    
    [meshobj setName :name];
    
    while ((pc = [self Dgetpos]) < p)
    {
		[self Dread :&ident :sizeof(ident)];
		[self Dread :&len :sizeof(len)];
        
		switch	(ident)
        {
			case CHUNK_VERTLIST:
                
				[self ReadVertList :meshobj];
                
				break;
                
			case CHUNK_FACELIST:
                
				fl = [self ReadFaceList :meshobj];
                
				break;
                
			case CHUNK_MAPLIST:
                
				[self ReadMapList :meshobj];
                
				break;
                
			case CHUNK_TRMATRIX:
                
				[self ReadTraMatrix :meshobj];
                
				break;
                
			case CHUNK_FACEMAT:
                
				[self ReadFaceMaterial :meshobj];
                
				found_facematerial = true;
				
                break;
                
			default:
                
				[self Dsetpos :(pc+len)];
        }
    }
	
	if	(!found_facematerial)
    {
		DefaultMaterialWarning	= true;
        
		[self ReadDefaultMaterial :meshobj :fl];    // Couldn't find any materials, so make one up
    }
}

-(void)ReadVertList :(H3dsMeshObj*)meshobj
{
    short	nv;
    float	x, y, z;
    
    [self Dread :&nv :sizeof(nv)];
    
    for	(int n=0; n < nv; n++)
    {
		H3dsVert *vertex_entry	= [meshobj addVert];
        
		[self Dread :&x :sizeof(x)]; [vertex_entry setX:x];
		[self Dread :&y :sizeof(y)]; [vertex_entry setY:y];
		[self Dread :&z :sizeof(z)]; [vertex_entry setZ:z];
    }
}

-(short)ReadFaceList :(H3dsMeshObj*)meshobj
{
    short	nf;
    short	swap;
    short	p0, p1, p2, flags;
	
    [self Dread :&nf :sizeof(nf)];
	
    for (int n=0; n < nf; n++)
	{
		H3dsFace *face_entry = [meshobj addFace];
		
		[self Dread :&p0 :sizeof(p0)];
		[self Dread :&p1 :sizeof(p1)]; 
		[self Dread :&p2 :sizeof(p2)];
		
		[self Dread :&flags :sizeof(flags)];
        
		if (flags == 0x07)		//0x07 means that the AB, BC, and CA edges are all wound in the reverse order, so swap the last two vertices
	    {
			swap	= p1;
			p1		= p2;
			p2		= swap;
	    }
		
		[face_entry setP0:p0];
		[face_entry setP1:p1];
		[face_entry setP2:p2];
		[face_entry setFlags:flags];
	}
    
    return (nf);
}

-(void)ReadMapList :(H3dsMeshObj*)meshobj
{
    short	nv;
    float	u, v;
    
    [self Dread :&nv :sizeof(nv)];
    
    for (int n=0; n < nv; n++)
    {
		H3dsMap *map_entry = [meshobj addMap];
        
		[self Dread :&u :sizeof(float)]; [map_entry setU:u];
		[self Dread :&v :sizeof(float)]; [map_entry setV:v];
    }
}

-(void)ReadTraMatrix :(H3dsMeshObj*)meshobj
{
    float	matrix[3*4];                            // 3*3 rotation matrix, 3*1 translation matrix
    
    for (int i=0; i < 12; i++) [self Dread :&matrix[i] :sizeof(float)];
    
    [meshobj setTraMatrix :matrix];
    
    [meshobj setTraMatrixFlag :true];
}

-(void)ReadFaceMaterial :(H3dsMeshObj*)meshobj
{
    int             n = 0;
    unsigned short	nf;
    unsigned short	facevalue;
    char            name[MAXNAMESIZE];
    
    do                                              // Read the material name first
    {
		[self Dread :&name[n++] :1];
        
    } while	(name[n-1] != '\0' && n < sizeof(name));
    
    name[n-1] = '\0';
    
    H3dsMatList	*binding_entry	= [meshobj addMatList];
    
    [binding_entry setName :name];
    
    [self Dread :&nf :sizeof(nf)];                  // Then the number of faces
    
    for	(n=0; n < nf; n++)                          // Bind the face values, which are meshobj->facelist array indexes, to this material name
    {
		[self Dread :&facevalue :sizeof(facevalue)];
        
		[binding_entry addFace:facevalue];
    }
}

-(void)ReadDefaultMaterial :(H3dsMeshObj*)meshobj :(short)nf
{
    H3dsMatList	*binding_entry	= [meshobj addMatList];
    
    [binding_entry setName :"WG_DEFAULT"];			// The material name is first
    
    for	(int n=0; n < nf; n++)						// Bind meshobj->facelist faces (as read by ReadFaceList above) to the default material
    {
		[binding_entry addFace:n];
    }
}

-(void)ReadTextureNameChunk :(int)p :(H3dsTexture*)texture
{
    int		n = 0;
    char	name[MAXNAMESIZE];
    
    do
	{
        [self Dread :&name[n++] :1];
        
	} while	(name[n-1] != '\0' && n < sizeof(name));
    
    name[n-1] = '\0';
    
    [texture setTextureName :name];
}

-(void)ReadRGBFloat :(int)p :(H3dsRGBColor*)rgb
{
    float red, green , blue;
    
    [self Dread :&red   :sizeof(float)];
    [self Dread :&green :sizeof(float)];
    [self Dread	:&blue  :sizeof(float)];
    
    [rgb setRed		:(float) red];
    [rgb setGreen	:(float) green];
    [rgb setBlue	:(float) blue];
}

-(void)ReadRGBByte :(int)p :(H3dsRGBColor*)rgb
{
    unsigned char red, green, blue;
    
    [self Dread :&red   :sizeof(red)];
    [self Dread :&green :sizeof(green)];
    [self Dread :&blue  :sizeof(blue)];
    
    [rgb setRed		:(float) (red	/ 256.0)];
    [rgb setGreen	:(float) (green / 256.0)];
    [rgb setBlue	:(float) (blue	/ 256.0)];
}

-(bool)LoadTextureFile :(char*)szFileName :(GLuint)Texture_ID
{
    int					rowNum, destRowNum = 0;
    unsigned char		*flippedBytes;
    NSBitmapImageRep	*image;
    
    if (!Texture_ID) return false;
    
    NSString *path      = [MeshFileName stringByStandardizingPath];                                     // Get path including mesh filename
    NSString *purePath  = [[path stringByDeletingLastPathComponent] stringByAppendingString:@"/"];      // Remove mesh filename and add back a traiing '/'
    
    NSString *texture   = [purePath stringByAppendingString:[[[NSString alloc] initWithCString:szFileName encoding:NSUTF8StringEncoding] autorelease]]; // Add texture filename to path

	if (!(image = [NSBitmapImageRep imageRepWithContentsOfFile:texture])) return false;
    
	if (!(flippedBytes = calloc ([image bytesPerRow] * [image pixelsHigh], 1))) return false;
    
	for	(rowNum = [image pixelsHigh] - 1; rowNum >= 0; rowNum--, destRowNum++)                          // Flip texture data from top to bottom (i.e. align with the OpenGL coordinate system)
    {
		memcpy	(flippedBytes		+ (destRowNum * [image bytesPerRow]),
                 [image bitmapData]	+ (rowNum	  * [image bytesPerRow]),
                 [image bytesPerRow]);
    }

	glBindTexture	(GL_TEXTURE_2D, Texture_ID);
    
	glTexParameteri	(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameteri	(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    
	glTexParameteri	(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
	glTexParameteri	(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);

	if      ([image bitsPerPixel] == 32) glTexImage2D	(GL_TEXTURE_2D, 0, GL_RGBA8, [image pixelsWide], [image pixelsHigh], 0, GL_RGBA, GL_UNSIGNED_INT_8_8_8_8_REV, flippedBytes);
    else                                 glTexImage2D	(GL_TEXTURE_2D, 0, GL_RGB8,  [image pixelsWide], [image pixelsHigh], 0, GL_RGB,  GL_UNSIGNED_BYTE,			  flippedBytes);
    
	free	(flippedBytes);
	
	return	true;
}

@end
