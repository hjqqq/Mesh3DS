@interface Mesh3DS : NSObject
{
    NSMutableArray	*PolyList;				// Array of POLYGONLIST entries - indexed per material to hold material properties and linked triangles
    NSMutableArray	*VertexList;			// Array of VERTEX entries		- indexed per vertex to hold positions, normals, texcoords and tangents
    NSMutableArray	*SurfaceList;			// Array of NSMutableArrays		- indexed per vertex to hold an array of SURFACEs at/sharing the vertex

    id				Scene;
    
    FILE			*InFile;
    NSString        *MeshFileName;
    
    GLfloat			cosineThreshold;		// Cosine of threshold angle which determines when vertices shared between surfaces are split
    
    GLuint          meshVBO;                // Unique ID of a monolithic Vertex Buffer Object (VBO) for all mesh vertices, normals, texcoords amd tangents
    
    GLfloat         *vboBuffer;             // Client-side buffer storing all vertex positions, normals, texcoords and tangents prior to upload to VBO
    GLuint          vboSize;
    
    GLuint          ShaderProgram;          // Compiled Shader program ID
    GLuint          VertexShader;           // Vertex Shader unique ID
    GLuint          FragmentShader;         // Fragment Shader ID

    bool			Force2Sided;			// Flag to force 2-Sided materials
    bool			DefaultMaterialWarning; // Flag set if no default material seen
}

-(id)	init		:(GLfloat)threshold :(bool)force2sided;
-(void)	dealloc;

-(bool)	Parse3DS	:(NSString*)filename;	// Load data structures, display lists, etc.
-(void)	Display;							// Display mesh onto the current OpenGL Rendering Context
-(void)	Zoom		:(GLfloat)factor;		// Scale all mesh vertices equally, which leaves normals unaffected

@end