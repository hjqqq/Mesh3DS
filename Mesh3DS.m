#import "Constants.h"

#import "Mesh3DS.h"
#import "H3dsScene.h"
#import "POLYGONLIST.h"
#import "File_Routines.h"
#import "OpenGL_Routines.h"

@implementation Mesh3DS

- (id) init :(GLfloat)threshold :(bool)force2sided {
	
	if	((self = [super init]))	{
		
		InFile					= 0;
        VertexShader            = 0;
        FragmentShader          = 0;
        ShaderProgram           = 0;
        vboSize                 = 0;
        vboBuffer               = nil;
        MeshFileName            = nil;
		
		if (Scene)		[Scene release];		Scene		= nil;									// If an object pointer is valid, release it. Set the pointer to nil regardless
		if (PolyList)	[PolyList release];		PolyList	= nil;									//TODO: Why can't I figure out how to free these objects between mesh loads?
		if (VertexList) [VertexList release];	VertexList	= nil;
		if (SurfaceList)[SurfaceList release];	SurfaceList = nil;

        DefaultMaterialWarning	= false;
		
        Force2Sided				= force2sided;
		
		cosineThreshold			= threshold;
	}
    
	return self;
}

-(bool)Parse3DS :(NSString*)filename {
	
    FILE	*inf;
    long	size;
	
    if	(!(inf = fopen ([filename UTF8String], "rb"))) return false;
    
	if	(fseek (inf, 0, SEEK_END)) { fclose	(inf); return false; }
	
    if	((size = ftell (inf)) == -1L) { fclose (inf); return false;	}
	
    rewind (inf);

	MeshFileName	= filename;																		// Save the mesh file path for possible use by LoadTextureFile
	
	if (PolyList)	{[PolyList release];	PolyList = nil;}										// On subsequent calls, release any currently in use PolyList and VertexList
	if (VertexList) {[VertexList release];	VertexList = nil;}

	Scene			= [[H3dsScene alloc] init];
	
	PolyList		= [[NSMutableArray alloc] init];
	VertexList		= [[NSMutableArray alloc] init];
	SurfaceList		= [[NSMutableArray alloc] init];
	
    if	(![self HRead3dsScene :inf :size]) {														// Parse the 3DS mesh into local H3ds* data structures. If error, clean and return
		
		fclose	(inf);
		
		[Scene release];		Scene = nil;
		[PolyList release];		PolyList = nil;
		[VertexList release];	VertexList = nil;
		[SurfaceList release];	SurfaceList = nil;
		
		return false;
	}
	
    fclose (inf);
	
    [self Convert_to_OpenGL];																		// Convert H3ds* to OpenGL compatible public structures (Mesh3DS->VertexList, etc.)
	
	[Scene release];		Scene = nil;															// Release redundant objects; only the VertexList and PolyList are needed
	[SurfaceList release];	SurfaceList = nil;
    
    return true;
}

-(void)Display {
	
    for	(POLYGONLIST *poly_entry in PolyList) {                                                     // For each material in PolyList:
		
        if  (glIsBuffer ([poly_entry getMaterialIBO])) {                                            // If there's a valid Index Buffer Object (IBO),
			
            glBindBuffer (GL_ELEMENT_ARRAY_BUFFER, [poly_entry getMaterialIBO]);                    // Bind the IBO, which indexes all this material's vertex positions, normals, texcoords and tangents
            
            glMaterialfv (GL_FRONT_AND_BACK, GL_AMBIENT,  [poly_entry getAmbient]);                 // Set the material colour properties
            glMaterialfv (GL_FRONT_AND_BACK, GL_DIFFUSE,  [poly_entry getDiffuse]);
            glMaterialfv (GL_FRONT_AND_BACK, GL_SPECULAR, [poly_entry getSpecular]);
            glMaterialf  (GL_FRONT_AND_BACK, GL_SHININESS,[poly_entry getShininess]);
            
			
			if	(glIsProgram (ShaderProgram)) {														// Only if a valid shader program is loaded:
				
				glUseProgram (ShaderProgram);														// Add the shaders to the rendering state
				
				GLboolean TextureFlag = glGetUniformLocation (ShaderProgram, "TextureFlag");		// Set fragment shader uniform variables
				GLint     TextureUnit = glGetUniformLocation (ShaderProgram, "TextureUnit");

				GLboolean BumpMapFlag = glGetUniformLocation (ShaderProgram, "BumpMapFlag");
				GLint     BumpMapUnit = glGetUniformLocation (ShaderProgram, "BumpMapUnit");
				
				glActiveTexture	(GL_TEXTURE0);														// Activate texture unit 0 in advance of texture binding

				if  (glIsTexture ([poly_entry getTextureID])) {                                     // If there is a TextureID assigned to this material:
					
                    glBindTexture   (GL_TEXTURE_2D, [poly_entry getTextureID]);						// Bind the colour map to unit 0
					
                    glUniform1i     (TextureUnit, 0);												// Tell shader colour map is on unit 0 
					
					glUniform1i     (TextureFlag, true);											// Set texture map flag indicating TextureUnit is valid

				} else {
					
					glBindTexture   (GL_TEXTURE_2D, 0);												// Otherwise, unbind any texture on active texture unit 0

					glUniform1i     (TextureFlag, false);											// Clear the flag indicating whether a valid bump map exists here
				}
				
				glActiveTexture		(GL_TEXTURE1);													// Activate texture unit 1 for bump maps

				if (glIsTexture     ([poly_entry getBumpMapID])) {									// Does this material have a bump map? If so:

					glBindTexture   (GL_TEXTURE_2D, [poly_entry getBumpMapID]);						// Bind the bump map texture object on texture unit 1
					
					glUniform1i     (BumpMapUnit, 1);												// Pass bump map texture unit number (Why can't we use GL_TEXTUREn enum here?)
					
					glUniform1i     (BumpMapFlag, true);											// Set 'bump map valid' flag. (Separate units because multiple GL_TEXTURE_2Ds on same unit disallowed)
					
				} else {
					
					glBindTexture   (GL_TEXTURE_2D, 0);												// Otherwise, unbind any texture on active texture unit 1

					glUniform1i     (BumpMapFlag, false);											// Clear the flag indicating whether a valid bump map exists here
				}
			}
			
            glDrawElements  (GL_TRIANGLES, ([poly_entry getTriangleIndexListCount] * 3), GL_UNSIGNED_INT, BUFFER_OFFSET(0));    // Draw mesh using IBO, which indexes VBO
        }
    }
    
    glActiveTexture (GL_TEXTURE0);  glBindTexture (GL_TEXTURE_2D, 0);                               // Unbind any leftover texture mapping from activated texture units
    glActiveTexture (GL_TEXTURE1);  glBindTexture (GL_TEXTURE_2D, 0);
    
    glUseProgram    (0);                                                                            // Turn off shaders in case our caller still uses fixed functionality OpenGL
}

-(void)Zoom :(GLfloat)zoom {
	
    for (id vertex in VertexList) [vertex Zoom:zoom];		// Scale all mesh vertices
	
    [self SetupVBOandIBOs];									// Build a new VBO and IBOs
}

-(void)dealloc {
	
    glBindBuffer    (GL_ARRAY_BUFFER, 0);                   // Unbind Vertex Buffer Object (VBO)
    glBindBuffer    (GL_ELEMENT_ARRAY_BUFFER, 0);			// Unbind Indexed Buffer Object (IBO)
	
    glUseProgram    (0);                                    // Turn off Vertex & Fragment Shader programs
    
    glDeleteBuffers (1, &meshVBO);                          // Delete the monolithic mesh Vertex Buffer Object
	
    if (vboBuffer != nil) free (vboBuffer);                 // Free VBO buffer contents (IBOs are freed by POLYGONLIST dealloc)
	
	[Scene release]; Scene = nil;							// Destruct Scene and subordinate public object arrays
	
	[PolyList release];		PolyList = nil;
    [VertexList release];	VertexList = nil;
    [SurfaceList release];	SurfaceList = nil;
    
    [super dealloc];
}

@end
