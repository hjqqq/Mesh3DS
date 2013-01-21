#import "Constants.h"

@interface H3dsMatList : NSObject
    {
    char			name[MAXNAMESIZE];
    NSMutableArray	*faces;
    }

-(id)	getFaces;
-(id)	addFace		:(int)n;

-(char*)getName;
-(void) setName		:(char*)newName;

-(void) dealloc;
@end
