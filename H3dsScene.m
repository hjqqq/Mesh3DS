#import "H3dsScene.h"

@implementation H3dsScene

-(id)init
    {
    if	(self = [super init])
		{
		material	= [[NSMutableArray alloc] init];
		meshobjlist	= [[NSMutableArray alloc] init];
		}
    return self;
    }
    
-(id)addMaterial
    {
	H3dsMat *h3dsMat = [[H3dsMat alloc] init];
	
	[material addObject:h3dsMat];
	
	[h3dsMat release];

    return [material lastObject];
    }

-(id)addMeshObj
    {
	H3dsMeshObj *h3dsMeshObj = [[H3dsMeshObj alloc] init];
	
	[meshobjlist addObject:h3dsMeshObj];
	
	[h3dsMeshObj release];

    return [meshobjlist lastObject];
    }

-(id)getMaterial			{return material;}

-(id)getMeshObjList			{return meshobjlist;}

-(int)getMaterialCount		{return [material count];}

-(int)getMeshObjListCount	{return [meshobjlist count];}

-(void)dealloc {

	[material release];
	[meshobjlist release];

    [super dealloc];
    }

@end
