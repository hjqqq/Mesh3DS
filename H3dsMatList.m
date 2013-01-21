#import "H3dsMatList.h"

@implementation H3dsMatList

-(id)init
    {
    if	(self = [super init])
		{
		name[0] = '\0';
		faces	= [[NSMutableArray alloc] init];
		}
    return	self;
    }

-(id)getFaces	{return faces;}

-(id)addFace :(int)n
    {
	[faces addObject:[NSNumber numberWithInteger:n]];

    return [faces lastObject];
    }
    
-(char*)getName	{return name;}

-(void)setName	:(char*)new_name {strcpy (name, new_name);}

-(void)dealloc
    {
	[faces release];

    [super dealloc];
    }

@end
