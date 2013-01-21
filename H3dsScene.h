#import "H3dsMeshObj.h"
#import "H3dsMat.h"

@interface H3dsScene : NSObject
    {
    NSMutableArray	*material;				// Object array of H3dsMat objects
    NSMutableArray	*meshobjlist;			// Object array of H3dsMeshObj objects
    }

-(id)addMaterial;
-(id)addMeshObj;

-(id)getMaterial;
-(id)getMeshObjList;

-(int)getMaterialCount;
-(int)getMeshObjListCount;

@end
