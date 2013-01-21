#import "OpenGL_Routines.h"
#import "Math_Routines.h"
#import "File_Routines.h"
#import "POLYGONLIST.h"
#import "H3dsScene.h"
#import "VERTEX.h"

@implementation Mesh3DS (OpenGL_Routines)

/*
 * Convert the arrays built during 3DS file parsing to the public data structures: Mesh3DS->PolyList, VertexList and SurfaceList
 */

-(void) Convert_to_OpenGL {
	
    int		j, k, maplistCount, vertlistCount, vertexOffset;
        
    GLfloat	ambient[]	 = {0.2, 0.2, 0.2, 1.0};											// Some default material properties
    GLfloat	diffuse[]	 = {0.2, 0.2, 0.2, 1.0};
    GLfloat	specular[]	 = {0.2, 0.2, 0.2, 1.0};

    GLfloat	alpha		 = 1.0;
	GLfloat shininess	 = 0.0;

    if	(DefaultMaterialWarning) [self AddMaterial :ambient :diffuse :specular :shininess :alpha :"WG_DEFAULT" :"" :"" :false];

    for (H3dsMat *mat in [Scene getMaterial]) {												// For all materials in the scene:
		
		alpha		= 1.0 - (*[mat getTransparency] / 100);									// Invert '% transparency' to an OpenGL 'alpha opacity'

		shininess	= (*[mat getShininess]) * 128 / 100;									// Convert '% shininess' to a range from [0,128]
		
		ambient[0]	= [[mat getAmbient] getRed];											// Migrate remaining 3DS material properties
		ambient[1]	= [[mat getAmbient] getGreen];
		ambient[2]	= [[mat getAmbient] getBlue];
		ambient[3]	= 1.0;
		
		diffuse[0]	= [[mat getDiffuse] getRed];
		diffuse[1]	= [[mat getDiffuse] getGreen];
		diffuse[2]	= [[mat getDiffuse] getBlue];
		diffuse[3]	= alpha;																// glLightModel man page indicates that the fragment alpha is set per the material diffuse alpha value
																							// Also http://www.sjbaker.org/steve/omniv/opengl_lighting.html has a good synopsis of lighting issues
		specular[0]	= [[mat getSpecular] getRed];
		specular[1]	= [[mat getSpecular] getGreen];
		specular[2]	= [[mat getSpecular] getBlue];
		specular[3]	= 1.0;

		[self AddMaterial :ambient :diffuse :specular :shininess :alpha						// AddMaterial will populate the PolyList array with POLYGONLIST objects, indexed by material name
						  :[mat getMatName]
						  :[[mat getTexture] getTextureName]
						  :[[mat getBumpMap] getTextureName]
						  :*[mat getDoubleSided]];
	}

    vertexOffset = 0;																		// A stepper with which to walk through the grand unified VertexList

	TRIANGLE *triangle = [[TRIANGLE alloc] init];											// Instantiate a scratch triangle object, outside the loops below

    for (H3dsMeshObj *meshobj in [Scene getMeshObjList]) {									// For all mesh objects in the scene:

		vertlistCount = [[meshobj getVertList] count];										// For this meshobj, get the count of vertices...
        
		maplistCount = [[meshobj getMapList] count];										// ... and the count of texture mapped vertices

        for (j=0; j < vertlistCount; j++) {                                                 // For each vertex in this mesh object:

			NSMutableArray *SurfaceList_entry = [[NSMutableArray alloc] init];				// Add a placeholder in SurfaceList...
			
			[SurfaceList addObject:SurfaceList_entry];										// ... for the list of SURFACEs at this vertex
			
			[SurfaceList_entry release];													// Once added, it's safe to release the scratch pointer

			H3dsVert *vertex_entry = [[meshobj getVertList] objectAtIndex:j];				// Get a pointer to the current mesh object's vertlist array
            
			VERTEX   *vertex = [[VERTEX alloc] init];										// Instantiate a new VERTEX object, consolidating vertex & texture data
            
			[vertex setX :[vertex_entry getX]];												//TODO: Maybe add an option to swap Y and Z axes for better 3DS compatibility?
			[vertex setY :[vertex_entry getY]];												//TODO: (As is, we need Blender's 3DS Export set to 'Z Forward' and 'Y Up')
			[vertex setZ :[vertex_entry getZ]];
            
			if	((maplistCount > 0) && (j < maplistCount)) {								// If there are any texture mapped coordinates at all,
																							// 3DS aligns them 1:1 to the meshobj->vertlist entries
				H3dsMap *map_entry = [[meshobj getMapList] objectAtIndex:j];				// So, get a pointer to the current mesh object's maplist
                
				[vertex setU :[map_entry getU]];											// Extract the U and V texture coordinates for the new VERTEX
				[vertex setV :[map_entry getV]];
			}
            
			[VertexList addObject:vertex];													// Add the new vertex onto the VertexList grand unified vertex array
            
			[vertex release];																// (Autoreleased vertices seem to cause GC induced screen stuttering?)
        }
        
		for (H3dsMatList *bindings_entry in [meshobj getBindings]) {						// For all material-to-facelist bindings...

			for	(k=0; k < [[bindings_entry getFaces] count]; k++) {							// ... and for all faces in this binding...

				int face = [[[bindings_entry getFaces] objectAtIndex:k] intValue];			// ... read the facelist array index (e.g. faces[0] holds 23)
                
				H3dsFace *facelist_entry = [[meshobj getFaceList] objectAtIndex:face];		// De-reference that facelist entry (e.g. facelist[23])
                
				[triangle setP0:([facelist_entry getP0] + vertexOffset)];					// ... and use the Points of that face...
				[triangle setP1:([facelist_entry getP1] + vertexOffset)];					// ... to populate the scratch triangle object
				[triangle setP2:([facelist_entry getP2] + vertexOffset)];					// (Again, Points are indices to VertexList entries)
                
				[self AddPolygon :triangle :[bindings_entry getName]];						// Create a SURFACE from this triangle by defining surface normals,
            }                                                                               // creating a 2nd side (if needed) and adding the new surface(s) to the
        }                                                                                   // PolyList[material].TriangleIndexList array of material bound surfaces
        
		vertexOffset += [[meshobj getVertList] count];										// Advance the VertexList stepper along to the next meshobj's first vertex
    }
    
	[triangle release];																		// (A non-autoreleased triangle seems to reduce screen stutter when the GC runs)

    [self LinkVerticesToPolygons];                                                          // Prepare to calculate vertex normals, as compared to the surface normals we have
	
    [self CalculateVertexNormalsAndTangents];                                               // Compute vertex normals and tangents, roughly averaged among triangles sharing a vertex
	
	[self SetupVertexAndFragmentShaders];													// Create vertex and fragment shaders to handle per-pixel lighting, texturing and bump mapping
	
	[self SetupVBOandIBOs];																	// Create a VBO for all vertex attributes, plus an IBO (per material) to index the single VBO
}

-(void) AddMaterial :(GLfloat*)ambient	:(GLfloat*)diffuse	:(GLfloat*)specular	:(GLfloat)shininess	 :(GLfloat)alpha
				    :(char*)name		:(char*)textureName	:(char*)bumpmapName	:(BOOL)doubleSided {
	
	POLYGONLIST *poly_entry	= [[POLYGONLIST alloc] init];
	
    [poly_entry setAmbient		:ambient];
    [poly_entry setDiffuse		:diffuse];
    [poly_entry setSpecular		:specular];
	[poly_entry setShininess	:shininess];
    [poly_entry setAlpha		:alpha];
    
    if	(Force2Sided)	[poly_entry setDoubleSided	:true];									// Propagate flag which forces 2-Sided Materials
    else				[poly_entry setDoubleSided	:doubleSided];							// ... otherwise, use what's in the mesh file
	
    [poly_entry setName :name];																// Set the material name
	
    if (strlen (textureName) != 0) {														// If there is a texture file

		[poly_entry genTextureID];															// Generate a Texture object ID

		[poly_entry setTextureName :textureName];											// Set the texture file name

		[self LoadTextureFile :textureName :[poly_entry getTextureID]];						// Load the texture file
	}
	
	if (strlen (bumpmapName) != 0) {														// Same if there is a bump map file
		
		[poly_entry genBumpMapID];															// Generate a Texture object ID
		 
		[poly_entry setBumpMapName :bumpmapName];											// Set the bump map file name

		[self LoadTextureFile :bumpmapName :[poly_entry getBumpMapID]];						// Load the bump map file
	}
	
	[PolyList addObject:poly_entry];

	[poly_entry release];
}

-(void) AddPolygon :(TRIANGLE*)triangle :(char*)MaterialName {
	
    int MaterialNum	= [self FindMaterialIndex :MaterialName];								// Find the PolyList aray index for this material
	
	if (MaterialNum == -1) return;															// Bypass unlikely case of unknown material index
	
    POLYGONLIST *poly_entry	= [PolyList objectAtIndex:MaterialNum];							// De-reference the listhead of POLYGONLIST entries
	
    SURFACE	*surface_entry	= [poly_entry addTriangleIndexList];							// Create a new SURFACE object bound to this material
	
    [surface_entry setP0:[triangle getP0]];													// Populate the surface Points...
    [surface_entry setP1:[triangle getP1]];
    [surface_entry setP2:[triangle getP2]];
	
    [self CalculateSurfaceNormal :surface_entry];											// ... as well as the (normalized) surface normals
	
    if	([poly_entry getDoubleSided]) {														// If this material is double-sided:

		SURFACE *surface_entry	= [poly_entry addTriangleIndexList];						// Create a new surface bound to the material
		
		[surface_entry setP0:[triangle getP0]];												// Note: this 2nd surface is wound in reverse
		[surface_entry setP1:[triangle getP2]];
		[surface_entry setP2:[triangle getP1]];
		
		[self CalculateSurfaceNormal :surface_entry];										// Calculate the 2nd surface's normal vector
	}
}

-(int)  FindMaterialIndex :(char*)name {
	
    for (int n=0; n < [PolyList count]; n++) {

		POLYGONLIST *poly = [PolyList objectAtIndex:n];
		
		if (strcmp (name, [poly getName]) == 0) return n;
	}
	
    int choice =  NSRunAlertPanel  (@"Mesh3DS->FindMaterialIndex reports:",
									@"Failed to locate material name: (%s) within PolyList!",
									@"Ignore", @"Quit", nil, name);
	
    if (choice == NSAlertDefaultReturn) return (-1);
    if (choice == NSAlertAlternateReturn) ExitToShell();
    
    return (-1);
}

-(bool) CalculateSurfaceNormal :(SURFACE*)surface {											// Refer to http://www.opengl.org/wiki/Calculating_a_Surface_Normal
	
    Vector3f	normal;

    GLfloat		Ax, Ay, Az;
    GLfloat		Bx, By, Bz;
	
    GLfloat		length = 0.0;

    VERTEX *p0 = [VertexList objectAtIndex:[surface getP0]];
    VERTEX *p1 = [VertexList objectAtIndex:[surface getP1]];
    VERTEX *p2 = [VertexList objectAtIndex:[surface getP2]];
	
    Ax = [p1 getX] - [p0 getX];
    Ay = [p1 getY] - [p0 getY];
    Az = [p1 getZ] - [p0 getZ];
	
    Bx = [p2 getX] - [p0 getX];
    By = [p2 getY] - [p0 getY];
    Bz = [p2 getZ] - [p0 getZ];
	
	normal.x = (Ay*Bz - Az*By);																// Find the cross product
    normal.y = (Az*Bx - Ax*Bz);
    normal.z = (Ax*By - Ay*Bx);
	
    length = (normal.x * normal.x) +														// Make the normal a unit vector
			 (normal.y * normal.y) +
			 (normal.z * normal.z);
	
	if (!length) return false;																// Ignore degenerate polygons - most graphics cards won't draw them anyway
	
    length = (GLfloat) 1.0 / (GLfloat) sqrt (length);
	
	normal.x *= length;
    normal.y *= length;
    normal.z *= length;

	[surface setNX:normal.x];
    [surface setNY:normal.y];
    [surface setNZ:normal.z];
	
    return true;
}

-(void) LinkVerticesToPolygons {

/*
 * Prior to calculating vertex normals and tangents, we need to link all vertices to the polygons that reference them.
 *
 * For each material in the PolyList array:
 *  For each surface bound to the material:
 *    For each point of the surface:
 *
 *	 - Get the vertex number of the Point; suitable for referencing vertex indexed arrays
 *	 - Index into the SurfaceList for the listhead of surfaces at/sharing the vertex
 *	 - Add an entry for the surface to the list of surfaces referencing the vertex
 *
 * Subsequently, CalculateVertexNormalsAndTangents will use the SurfaceList to compute vertex normals and tangents, roughly averaged among all surfaces referencing each vertex
 *
 */

    for (POLYGONLIST *poly_entry in PolyList) {

		for (SURFACE *surface_entry in [poly_entry getTriangleIndexList]) {
			
			[[SurfaceList objectAtIndex:[surface_entry getP0]] addObject:surface_entry];
			[[SurfaceList objectAtIndex:[surface_entry getP1]] addObject:surface_entry];
			[[SurfaceList objectAtIndex:[surface_entry getP2]] addObject:surface_entry];
		}
	}
}

-(void) CalculateVertexNormalsAndTangents {
	
/*
 * Compute vertex normal and tangent vectors, roughly averaged across any adjacent surfaces sharing the vertex, for use by the fragment shader.
 *
 * Vector normalization is deferred to the vertex shader, while the fragment shader performs Gram-Schmidt orthonormalization processing and per-pixel lighting.
 */

    SURFACE	*firstSurface, *currentSurface;															// Pointers to the first surface at this vertex and the current surface if the vertex is shared

    for (int i = 0; i < [VertexList count]; i++) {													// For every vertex in the mesh (including any new 'split' vertices added within this loop):

		VERTEX	 *vertex_entry = [VertexList objectAtIndex:i];										// Get a pointer to the current vertex entry
		
		[vertex_entry setNX:0.0f];	[vertex_entry setNY:0.0f];	[vertex_entry setNZ:0.0f];			// Initialize vertex normal vector
		
		[vertex_entry setTX:0.0f];	[vertex_entry setTY:0.0f];	[vertex_entry setTZ:0.0f];			// Initialize vertex tangent
		
		NSMutableArray *surfaces = [SurfaceList objectAtIndex:i];									// Get the list of surfaces at this vertex

		int numSurfaces = [surfaces count];															// Get the number of surfaces at this vertex
		
		if (numSurfaces == 0) continue;																// Ignore isolated vertices (points & lines)

		firstSurface = [surfaces objectAtIndex:0];													// Note the first surface for comparison

		for (int surface = 0; surface < numSurfaces; surface++) {									// For each surface referencing this vertex:

			currentSurface = [surfaces objectAtIndex:surface];										// Get a pointer to the current surface object

			Vector3f vertexTangent = [self Tangent :currentSurface :i];								// Compute the vertex tangent vector for bump mapping

			if  (numSurfaces == 1) {																// For a vertex having only one surface referencing it:

				[vertex_entry setNX:[currentSurface getNX]];										// Propagate the current surface normal as the vertex normal
				[vertex_entry setNY:[currentSurface getNY]];
				[vertex_entry setNZ:[currentSurface getNZ]];
				
				[vertex_entry setTX:vertexTangent.x];												// Record the computed vertex tangent vector
				[vertex_entry setTY:vertexTangent.y];				
				[vertex_entry setTZ:vertexTangent.z];

			} else {																				// Otherwise, there are at least 2 surfaces referencing this vertex. In this case, determine:
				
				if	([self Cos_angle :firstSurface :currentSurface] <= cosineThreshold) {			// Do we need to split this vertex? For an example threshold angle of 90°, the cosine(90°) is 0.0.
																									// The dot product of two surface normals whose angle between them >= 90° will be a cosine <= 0.0,
																									// ∴ if the angle between the first and current surface normals is >= 90°, then split this vertex:
					
					VERTEX	*new_vertex = [[[VERTEX alloc] init	:[vertex_entry getX]	:[vertex_entry getY]	:[vertex_entry getZ]	// position
																:0.0					:0.0					:0.0					// normal
																:[vertex_entry getU]	:[vertex_entry getV]							// texcoord
																:0.0					:0.0					:0.0] autorelease];		// tangent
					
					[VertexList addObject:new_vertex];												// Add the cloned vertex to VertexList (normals & tangents are added when outer for loop hits new vertex)
					
					int lastVertex = [VertexList count] - 1;										// Get an index to the vertex we just added (saves some dereferencing)
					
					if ([currentSurface getP0] == i) [currentSurface setP0 :(lastVertex)];			// Remap whichever surface point needs to change to the newly added vertex
					if ([currentSurface getP1] == i) [currentSurface setP1 :(lastVertex)];
					if ([currentSurface getP2] == i) [currentSurface setP2 :(lastVertex)];
					
					[SurfaceList addObject:[[[NSMutableArray alloc] init] autorelease]];			// Add an empty surface array listhead for the new vertex onto SurfaceList
					
					[[SurfaceList lastObject] addObject:currentSurface];							// Add the re-mapped surface to the empty surface array for subsequent outer loop processing
					
				} else {																			// If not splitting, accumulate the vertex normal & tangent vectors across all unsplit surfaces

					[vertex_entry setNX:([vertex_entry getNX] + [currentSurface getNX])];			// These accumulated vectors will be pseudo-averaged when the vertex shader performs normalization
					[vertex_entry setNY:([vertex_entry getNY] + [currentSurface getNY])];
					[vertex_entry setNZ:([vertex_entry getNZ] + [currentSurface getNZ])];
					
					[vertex_entry setTX:([vertex_entry getTX] + (vertexTangent.x))];
					[vertex_entry setTY:([vertex_entry getTY] + (vertexTangent.y))];
					[vertex_entry setTZ:([vertex_entry getTZ] + (vertexTangent.z))];
				}
			}
		}
	}
}

-(void) ShaderStatus :(GLuint)Object :(GLenum)Parameter {
	
	GLchar	messages[256];
    GLint	status, logMessageLength;
	
	switch (Parameter) {
			
		case GL_COMPILE_STATUS:
			
			glGetShaderiv (Object, GL_COMPILE_STATUS, &status);
			
			if (status == GL_FALSE) {
				
				glGetShaderInfoLog (Object, sizeof(messages), 0, &messages[0]);
				
				NSLog (@"Mesh3DS->ShaderStatus reports GL_COMPILE_STATUS for Shader #%d as: %s", Object, messages);
				
				glDeleteShader (Object);
				
				exit (-1);
			}
			break;
			
		case GL_LINK_STATUS:
			
			glGetProgramiv (Object, GL_LINK_STATUS, &status);
			
			if (status == GL_FALSE) {
				
				glGetProgramiv (Object, GL_INFO_LOG_LENGTH, &logMessageLength);
				
				if (logMessageLength == 0) {
					
					NSLog (@"Mesh3DS->ShaderStatus reports GL_LINK_STATUS as GL_FALSE, but without any further message text");			
					
				} else {
					
					glGetProgramInfoLog (Object, sizeof(messages), 0, &messages[0]);
					
					NSLog (@"Mesh3DS->ShaderStatus reports GL_LINK_STATUS as GL_FALSE, with message text as: %s", messages);					
				}
				
				glDetachShader	(ShaderProgram, VertexShader);
				glDetachShader	(ShaderProgram, FragmentShader);
				
				glDeleteShader	(VertexShader);
				glDeleteShader	(FragmentShader);
				
				VertexShader	= 0;
				FragmentShader	= 0;
				ShaderProgram	= 0;
				
				exit (-1);
			}
			
			break;
			
		case GL_VALIDATE_STATUS:
			
			glGetProgramiv (Object, GL_VALIDATE_STATUS, &status);

			if (status == GL_FALSE) {
				
				glGetProgramiv (Object, GL_INFO_LOG_LENGTH, &logMessageLength);
				
				if (logMessageLength == 0) {
					
					NSLog (@"Mesh3DS->ShaderStatus reports GL_VALIDATE_STATUS as GL_FALSE, but without any further message text");			
					
				} else {
					
					glGetProgramInfoLog (Object, sizeof(messages), 0, &messages[0]);
					
					NSLog (@"Mesh3DS->ShaderStatus reports GL_VALIDATE_STATUS as GL_FALSE, with message text as: %s", messages);					
				}
				
				glDetachShader	(ShaderProgram, VertexShader);
				glDetachShader	(ShaderProgram, FragmentShader);
				
				glDeleteShader	(VertexShader);
				glDeleteShader	(FragmentShader);
				
				VertexShader	= 0;
				FragmentShader	= 0;
				ShaderProgram	= 0;
				
				exit (-1);
			}
			break;
			
		default:
			
			break;
	}
}

-(void) SetupVertexAndFragmentShaders {
	
	const GLchar* vertexShaderSource = STRINGIFY (														// Vertex shader transforms vertex, normal and tangent vectors to view space; texcoords are passed through as-is
												  
		attribute	vec3	Position;																	// Attributes input to vertex shader
		attribute	vec3	Normal;
		attribute	vec2	TexCoord;
		attribute	vec3	Tangent;

		varying		vec3	position;																	// Varying output to fragment shader - to be interpolated by the OpenGL rasterizer before delivery to fragment shader
		varying		vec3	normal;
		varying		vec2	texcoord;
		varying		vec3	tangent;

		void main (void) {																				
		  
			gl_Position		= gl_ModelViewProjectionMatrix * vec4 (Position, 1.0);						// Transform vertex to clip space via gl_Position built-in variable (needed by subsequent stages in the OpenGL pipeline)

			position		= (gl_ModelViewMatrix * vec4 (Position, 1.0)).xyz;							// Vary out vertex position to fragment shader, transformed to view space (all these attributes arrive here in object space)

			normal			= normalize ((gl_NormalMatrix * Normal).xyz);								// Vary out vertex normal, transformed to view space (gl_NormalMatrix: translate/rotate only submatrix of gl_ModelViewMatrix)

			tangent			= normalize ((gl_NormalMatrix * Tangent).xyz);								// Vary out vertex tangent, transformed to view space (gl_NormalMatrix used again here to isolate vector scaling problems)

			texcoord		= TexCoord;																	// Vary out vertex texcoords, which arrive at the fragment shader interpolated across the vertices of the primitive
		}
  );
	
	const GLchar* fragmentShaderSource = STRINGIFY (													// Fragment shader handles lighting, including transforming bump normals from tangent space to object space
													
		varying	vec3		position;																	// Fragment position, normal, texcoord and tangent interpolated across vertices of the current primitive
		varying	vec3		normal;
		varying	vec2		texcoord;
		varying	vec3		tangent;
		
		uniform bool		TextureFlag;																// Flags whether TextureUnit is valid (i.e. contains a valid texture unit number)
		uniform bool		BumpMapFlag;																// Flags whether BumpMapUnit contains a valid texture unit number
		
		uniform sampler2D	TextureUnit;																// Colour map's texture unit number
		uniform sampler2D	BumpMapUnit;																// Bump map's texture unit number; different than colour map unit (only one GL_TEXTURE_2D target type allowed per unit)
		
		vec3 CalcBumpedNormal() {																		// Calculate an object space bump map normal to give the illusion of depth
			
			vec3 BumpedNormal;
			
			vec3 N	= normalize (normal);																// Build the tangent->object space 'Basis' (TBN Matrix) needed for transformations
			
			vec3 T	= normalize (tangent);																// TBN Matrix is made up of the interpolated vertex Tangent and Normals; Bitangent is derived
			
				 T	= normalize (T - dot (T, N) * N);													// Perform Gram-Schmidt processing of vertex normal and tangent to ensure an orthonormal basis
																										// (since the normal and tangent were probably averaged across >1 triangles and certainly interpolated)
			vec3 B	= cross (T, N);	   
			
			BumpedNormal  =  texture2D (BumpMapUnit, texcoord.xy).rgb;									// Extract the tangent space bump map normal (a vector of 3 floats) from the bump map texcoords 
			
			BumpedNormal  =  (BumpedNormal * 2.0) - vec3 (1.0);											// Expand the RGB encoded floats from ([0..1]) to floats of XYZ coordinates ([-1..+1])
			
			return normalize (BumpedNormal * mat3 (T, B, N));											// Transform the tangent space bump map normal vector to object space
		}
		
		void main (void) {
			
			vec3	N;																					// Normal vector
			vec3	L;																					// Light direction vector
			vec3	H;																					// Half-vector between light and viewer
			
			float	attenuation;																		// Distance to point light source attenuation factor
			
			vec4 fragmentColor = gl_FrontLightModelProduct.sceneColor;									// Derived: Ecm + Acm + Acs (gl_MaterialParameters.emission + .ambient + gl_LightModelParameters.ambient)
			
			for (int i=0; i < 8; i++) {																	// For up to 8 lights:
				
				if (gl_LightSource[i].position.w == 0.0) {												// Determine if this a Directional or Point light source
					
					L	= gl_LightSource[i].position.xyz;												// Position means direction from which infinite light rays are cast
					
					attenuation = 1.0;																	// Directional lights are infinitely distant, so attenuation is disabled
					
				} else {																				// Otherwise, attenuate the Point/Spot light
					
					L	= gl_LightSource[i].position.xyz - position;									// Vector from fragment to light source
					
					float D	= length (L);																// Distance to light source
					
					attenuation = 1.0 / (gl_LightSource[i].constantAttenuation  +						// Attenuate by distance
										 gl_LightSource[i].linearAttenuation    * D +
										 gl_LightSource[i].quadraticAttenuation * D * D);
				}
				
				N	= (BumpMapFlag) ? CalcBumpedNormal() : normalize (normal);							// If bump mapping, transform bump map normal from tangent->object space; else, use interpolated vertex normal
				
				L	= normalize (L);																	// Normalize the light direction vector
				
				H	= normalize (gl_LightSource[i].halfVector.xyz);										// Normalize the half-vector between viewer and light vectors
				
				float	NdotL	= max (dot (N, L), 0.0);												// Compute the dot product of the selected normal vector and light direction vectors, or at least 0.0
				float	NdotH	= max (dot (N, H), 0.0);												// And the dot product of selected normal and halfway-between-viewer-and-light vectors, also >= 0.0
				
				float	power	= (NdotL == 0.0) ? 0.0 : pow (NdotH, gl_FrontMaterial.shininess);		// If N∙L is 0.0, the light is 'behind' the surface and outside [-90˚, +90˚], so no specularity
																										// Otherwise, raise N∙H to the power of the material shininess to define specular hightlights
				vec4	ambient	= gl_FrontLightProduct[i].ambient;
				vec4	diffuse	= gl_FrontLightProduct[i].diffuse  * NdotL;								// gl_FrontLightProduct[i] is apparantly equivalent to (gl_FrontMaterial * gl_LightSource[i])
				vec4	specular= gl_FrontLightProduct[i].specular * power;
				
				fragmentColor	+= ((ambient + diffuse + specular) * attenuation);						// Add the light values to the running total for the fragment, attenuated as required
			}
			
			if (TextureFlag) {																			// If this fragment has a valid sampler2D texture unit assigned:
				
				vec4	texel = texture2D (TextureUnit, texcoord.st);									// Extract the texel at this fragment's texture coordinates
				
				float	combinedAlpha = (texel.a * gl_FrontMaterial.diffuse.a);							// Combine the alpha values from both texel and fragment
				
				gl_FragColor = vec4 (fragmentColor.rgb * texel.rgb, combinedAlpha);						// Provide a GL_MODULATE equivalent fragment color
				
			} else {
				
				gl_FragColor = fragmentColor;															// Otherwise, just provide the lit sceneColor
			}
		}
	);
	
	int shaderLength	= strlen (vertexShaderSource);
    
	VertexShader		= glCreateShader (GL_VERTEX_SHADER);										// Create ID for Vertex Shader
	glShaderSource		(VertexShader, 1, (const char**) &vertexShaderSource, &shaderLength);		// Define Vertex Shader source code
	glCompileShader		(VertexShader);	[self ShaderStatus:VertexShader :GL_COMPILE_STATUS];
    
    shaderLength		= strlen (fragmentShaderSource);
    
	FragmentShader		= glCreateShader (GL_FRAGMENT_SHADER);										// Fragment Shader ID
	glShaderSource		(FragmentShader, 1, (const char**) &fragmentShaderSource, &shaderLength);	// Fragment Shader code
	glCompileShader		(FragmentShader); [self ShaderStatus:FragmentShader :GL_COMPILE_STATUS];
	
	ShaderProgram		= glCreateProgram();														// Create the Shader program
	glAttachShader		(ShaderProgram, VertexShader);												// Attach Vertex and Fragment Shaders
	glAttachShader		(ShaderProgram, FragmentShader);
	
	glBindAttribLocation(ShaderProgram, 0, "Position");												// Bind attribute locations (glBindAttributeLocation calls must preceed glLinkProgram)
	glBindAttribLocation(ShaderProgram, 1, "Normal");
	glBindAttribLocation(ShaderProgram, 2, "TexCoord");
	glBindAttribLocation(ShaderProgram, 3, "Tangent");
	
	glLinkProgram		(ShaderProgram);	[self ShaderStatus:ShaderProgram :GL_LINK_STATUS];		// Link the shader program to attribute locations per above glBindAttribLocation calls
	
#ifdef DEBUG			// To add a DEBUG pre-processor macro (that works, i.e. just for Debug builds) refer to: http://stackoverflow.com/a/11470231 (MUST do a Clean when switching between Debug/Release modes!)
	
	glValidateProgram	(ShaderProgram);	[self ShaderStatus:ShaderProgram :GL_VALIDATE_STATUS];	// One final status check (in DEBUG mode only) and Mesh3DS->Display will glUseProgram at render time
	
#endif					// Refer to: http://www.opengl.org/discussion_boards/showthread.php/176366-Samplers-of-different-types-use-the-same-textur?p=1231277&viewfull=1#post1231277
}

-(void) SetupVBOandIBOs {

/*
 *
 * First, build a monolithic client-side vertex buffer containing interleaved vertex positions, normals, texcoords and tangents from all materials, combined
 *
 */
    vboSize = [VertexList count] * 11 * sizeof(GLfloat);											// 11 GLfloats per VERTEX array element (3 Vertex Coords, 3 Normals, 2 Texture Coords, 3 Tangents)
	
	do {																							// Collapse the VertexList array to interleaved VBO format for uploading to the GPU

		if	(vboBuffer != nil) free (vboBuffer);
		
		if	((vboBuffer = malloc (vboSize)) != nil) {												// (this local client-side VBO buffer is freed in Mesh3DS->dealloc)

			int j = 0;
			
			for	(int i=0; i < [VertexList count]; i++) {											// Copy the vertex coordinates, normals, texcoords and tangents into the client-side VBO buffer

				VERTEX *vertex_entry = [VertexList objectAtIndex:i];
				
				vboBuffer[j++]	= [vertex_entry getX];												// Vertext position coordinates
				vboBuffer[j++]	= [vertex_entry getY];
				vboBuffer[j++]	= [vertex_entry getZ];
				
				vboBuffer[j++]	= [vertex_entry getNX];												// Vertex normal vector
				vboBuffer[j++]	= [vertex_entry getNY];
				vboBuffer[j++]	= [vertex_entry getNZ];
				
				vboBuffer[j++]	= [vertex_entry getU];												// Vertex texcoords
				vboBuffer[j++]	= [vertex_entry getV];	
				
				vboBuffer[j++]	= [vertex_entry getTX];												// Vertex tangent vector
				vboBuffer[j++]	= [vertex_entry getTY];
				vboBuffer[j++]	= [vertex_entry getTZ];
			}
			
		} else {
			
			int choice =  NSRunAlertPanel  (@"Mesh3DS->SetupVBOandIBOs reports:",
											@"Failed to malloc %d bytes of local VBO memory!",
											@"Quit", @"Retry", nil, vboSize);
			
			if (choice == NSAlertDefaultReturn) ExitToShell();
			if (choice == NSAlertAlternateReturn) continue;
		}
		
	} while (vboBuffer == nil);

/*
 * Next, create a Vertex Buffer Object (VBO) on the Graphics Processing Unit (GPU) to receive our client-side vertex buffer contents
 */

    glGenBuffers			  (1, &meshVBO);											// Generate a unique ID for the single Vertex Buffer Object of our mesh
    glBindBuffer			  (GL_ARRAY_BUFFER, 0);
    glBindBuffer			  (GL_ARRAY_BUFFER, meshVBO);								// Bind the VBO to high-speed memory on the Graphics Processing Unit (GPU)
    glBufferData			  (GL_ARRAY_BUFFER, vboSize, vboBuffer, GL_STATIC_DRAW);	// Upload vboBuffer to the GPU (vboBuffer gets freed in Mesh3DS->dealloc)
	
	glVertexAttribPointer	  (0, 3, GL_FLOAT, GL_FALSE, 44, BUFFER_OFFSET (0));		// Attribute 0: Vertex Position (3 floats)
	glVertexAttribPointer	  (1, 3, GL_FLOAT, GL_FALSE, 44, BUFFER_OFFSET (12));		//     "     1: Vertex Normal   (3 floats)
	glVertexAttribPointer	  (2, 2, GL_FLOAT, GL_FALSE, 44, BUFFER_OFFSET (24));		//     "     2: Vertex TexCoord (2 floats)
	glVertexAttribPointer	  (3, 3, GL_FLOAT, GL_FALSE, 44, BUFFER_OFFSET (32));		//     "     3: Vertex Tangent  (3 floats, total of 11 floats * 4 bytes per float = stride of 44 bytes)

	glEnableVertexAttribArray (0);														// Attribute 0 is bound to 'Position' attribute in vertex shader (see glLinkProgram call above)
	glEnableVertexAttribArray (1);														//     "     1 is bound to 'Normal'
	glEnableVertexAttribArray (2);														//     "     2 is bound to 'TexCoord'
	glEnableVertexAttribArray (3);														//     "     3 is bound to 'Tangent'
	
/*
 * Lastly, for each material, create a unique Index Buffer Object (IBO) to index the VBO vertices for the material's interleaved vertices, normals, texcoords and tangents
 */

	for	(POLYGONLIST *poly_entry in PolyList) {											// For each material in the PolyList array:

        int triangleCount = [poly_entry getTriangleIndexListCount];						// Get the number of triangles bound to this material
        
		if (triangleCount == 0) continue;												// Skip this material if it has no triangles bound to it

		[poly_entry setIBOSize :(triangleCount * 3 * sizeof(GLuint))];					// 3 GLuint Points per TriangleIndexList (i.e. SURFACE) array element, each point indexes into the main VBO array

		GLuint *iboBuffer = [poly_entry getIBOBuffer];									// Get a local copy of the pointer to this material's IBO buffer (just to save some typing)
		
		do {

			if	(iboBuffer != nil) free (iboBuffer);									// Free any previous iboBuffer contents
			
			if	((iboBuffer = malloc ([poly_entry getIBOSize])) == nil) {				// Note that the memory iboBuffer points to will be freed when this PolyList entry's dealloc is called

				int choice =  NSRunAlertPanel  (@"Mesh3DS->SetupVBOandIBOs reports:",
												@"Failed to malloc %d bytes of local IBO memory!",
												@"Quit", @"Retry", nil, [poly_entry getIBOSize]);
				
				if (choice == NSAlertDefaultReturn) ExitToShell();
				if (choice == NSAlertAlternateReturn) continue;
			}
			
		} while (iboBuffer == nil);
		
        [poly_entry setIBOBuffer :iboBuffer];											// Save the local IBO buffer pointer to the PolyList entry
        
		int k = 0;

		for (SURFACE *surface_entry in [poly_entry getTriangleIndexList]) {				// For each surface in this material, load index values (i.e. surface points) into the IBO buffer

			iboBuffer[k++]	= [surface_entry getP0];
			iboBuffer[k++]	= [surface_entry getP1];
			iboBuffer[k++]	= [surface_entry getP2];
		}

		[poly_entry genMaterialIBO];													// Generate an Index Buffer Object for this material

		glBindBuffer	(GL_ELEMENT_ARRAY_BUFFER, [poly_entry getMaterialIBO]);			// Bind to the IBO buffer, which indexes the VBO for drawing
		
		glBufferData    (GL_ELEMENT_ARRAY_BUFFER, [poly_entry getIBOSize], [poly_entry getIBOBuffer], GL_STATIC_DRAW);	// Upload this material's IBO
		
		glBindBuffer	(GL_ELEMENT_ARRAY_BUFFER, 0);									// Unbind the IBO from client-side until it's time to draw
		
		glBindBuffer	(GL_ARRAY_BUFFER, 0);											// Unbind the VBO also, leaving them server-side
	}
}

@end