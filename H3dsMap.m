#import "H3dsMap.h"

@implementation H3dsMap

-(id)	init
    {
    if		(self = [super init]) {u = v = 0.0;}
    return	self;
    }

-(float)getU {return u;}
-(float)getV {return v;}

-(void) setU :(float)new_u {u = new_u;}
-(void) setV :(float)new_v {v = new_v;}

@end
