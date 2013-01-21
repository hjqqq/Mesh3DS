#import "H3dsMeshObj.h"

@implementation H3dsMeshObj

-(id)init
    {
    if	(self = [super init])
		{
		name[0]     = '\0';
		matrix      = 0;

		facelist	= [[NSMutableArray alloc] init];
		vertlist	= [[NSMutableArray alloc] init];
		bindings	= [[NSMutableArray alloc] init];
		maplist		= [[NSMutableArray alloc] init];
		}
    return self;
    }

-(id)addMatList
    {
    [bindings addObject:[[[H3dsMatList alloc] init] autorelease]];

    return [bindings lastObject];
    }

-(id)addFace
    {
	[facelist addObject:[[[H3dsFace alloc] init] autorelease]];

    return [facelist lastObject];
    }

-(id)addVert
    {
	[vertlist addObject:[[[H3dsVert alloc] init] autorelease]];
	
    return [vertlist lastObject];
    }

-(id)addMap
    {
	[maplist addObject:[[[H3dsMap alloc] init] autorelease]];
	
    return [maplist lastObject];
    }

-(id)getFaceList	{return facelist;}
-(id)getVertList	{return vertlist;}
-(id)getBindings	{return bindings;}
-(id)getMapList		{return maplist;}

-(void)setName		:(char*)new_name	{strcpy (name, new_name);}

-(void)setTraMatrix	:(float*)newMatrix	{memcpy (TraMatrix, newMatrix, 12);}

-(void)setTraMatrixFlag	:(bool)flag		{matrix = flag;}
    
-(void)dealloc {
	
	[facelist release];
	[vertlist release];
	[bindings release];
	[maplist release];
	
    [super dealloc];
}

@end
