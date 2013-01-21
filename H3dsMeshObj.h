#import "H3dsMatList.h"
#import "H3dsFace.h"
#import "H3dsVert.h"
#import "H3dsMap.h"

@interface H3dsMeshObj : NSObject
    {
    char    name[MAXNAMESIZE];          // object name, zero terminated
    bool	matrix;                     // true if transformation matrix is loaded
    float	TraMatrix[3*4];             // 3*3 rotation matrix, 3*1 translation matrix
    
    NSMutableArray	*facelist;			// Object Array of H3dsFace objects (face indices)
    NSMutableArray	*vertlist;			// Object Array of H3dsVert objects (vertices)
    NSMutableArray	*bindings;			// Object Array of H3dsMatList objects (to bind faces to materials)
    NSMutableArray	*maplist;			// Object Array of H3dsMap objects (texture coordinates)
    }

-(id)	getFaceList;
-(id)	getVertList;
-(id)	getBindings;
-(id)	getMapList;

-(void) setName         :(char*)newName;
-(void) setTraMatrix	:(float*)newMatrix;
-(void) setTraMatrixFlag:(bool)flag;

-(id)	addMatList;
-(id)	addFace;
-(id)	addVert;
-(id)	addMap;

@end
