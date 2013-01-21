#import "H3dsTexture.h"

@implementation H3dsTexture

-(id)	init
    {
    if		(self = [super init]) {texturename[0] = '\0';}
    return	self;
    }

-(char*)getTextureName	{return texturename;}
-(void) setTextureName	:(char*)newTextureName {strcpy (texturename, newTextureName);}

@end
