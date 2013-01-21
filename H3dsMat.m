#import "H3dsMat.h"

@implementation H3dsMat

-(id)	init
    {
    if	(self = [super init])
		{
		name[0]         = '\0';
            
		transparency    = 0.0;
        shininess       = 0.0;
            
        doublesided     = false;

		ambient         = [[H3dsRGBColor alloc] init];
		diffuse         = [[H3dsRGBColor alloc] init];
		specular        = [[H3dsRGBColor alloc] init];
		texture         = [[H3dsTexture alloc] init];
        bumpmap         = [[H3dsTexture alloc] init];
		}
    return	self;
    }

-(H3dsRGBColor*) getAmbient     {return ambient;}
-(H3dsRGBColor*) getDiffuse     {return diffuse;}
-(H3dsRGBColor*) getSpecular    {return specular;}
-(H3dsTexture*)  getTexture     {return texture;}
-(H3dsTexture*)  getBumpMap     {return bumpmap;}

-(float*)   getTransparency     {return &transparency;}
-(float*)   getShininess        {return &shininess;}

-(BOOL*)    getDoubleSided      {return &doublesided;}

-(char*)    getMatName          {return name;}

-(void)     setMatName :(char*)newMatName	{strcpy (name, newMatName);}

-(void)dealloc
{
	[ambient release];
	[diffuse release];
	[specular release];
	[texture release];
	
    [super dealloc];
}
@end
