#import	"Constants.h"
#import "H3dsTexture.h"
#import "H3dsRGBColor.h"

@interface H3dsMat : NSObject
    {
    char            name[MAXNAMESIZE];
    float           transparency;
    float           shininess;
        
    BOOL            doublesided;
        
    H3dsRGBColor	*ambient;
    H3dsRGBColor	*diffuse;
    H3dsRGBColor	*specular;
    H3dsTexture		*texture;
    H3dsTexture     *bumpmap;
    }

-(H3dsRGBColor*)    getAmbient;
-(H3dsRGBColor*)    getDiffuse;
-(H3dsRGBColor*)    getSpecular;
-(H3dsTexture*)     getTexture;
-(H3dsTexture*)     getBumpMap;

-(float*)   getTransparency;
-(float*)   getShininess;

-(BOOL*)    getDoubleSided;

-(char*)    getMatName;
-(void)     setMatName	:(char*)newMatName;

@end
