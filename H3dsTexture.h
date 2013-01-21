#import "Constants.h"

@interface H3dsTexture : NSObject
    {
    char	texturename[MAXNAMESIZE];
    }

-(char*)getTextureName;
-(void) setTextureName	:(char*)newTextureName;

@end
