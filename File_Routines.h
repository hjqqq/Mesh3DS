#import "Mesh3DS.h"
#import "H3dsMat.h"
#import "H3dsScene.h"
#import "H3dsMeshObj.h"

@interface Mesh3DS (File_Routines)

-(void)		Dread					:(void*)dest	:(int)len;
-(void)		Dsetpos					:(int)pos;
-(int)		Dgetpos;

-(bool)		HRead3dsScene			:(FILE*)ptr     :(int)size;

-(void)		ReadMainBlocks			:(int)p;
-(void)		ReadObjMeshBlocks		:(int)p;

-(void)		ReadMaterialBlocks		:(int)p;
-(void)		ReadMatChunk			:(H3dsMat*)mat;
-(void)		ReadShadingChunk		:(int)p         :(H3dsRGBColor*)rgb;
-(void)		ReadTextureChunk		:(int)p         :(H3dsTexture*)texture;
-(void)		ReadBumpMapChunk		:(int)p         :(H3dsTexture*)texture;
-(void)		ReadDoublesidedChunk	:(BOOL*)twoSidedMaterial;
-(void)		ReadTransparencyChunk	:(int)p         :(float*)transparency;
-(void)		ReadShininessChunk      :(int)p         :(float*)shininess;
-(void)		ReadAmountChunk			:(short*)amount;

-(void)		ReadObjBlocks			:(int)p;

-(void)		ReadTriMeshBlocks		:(int)p         :(char*)name;
-(void)		ReadVertList			:(H3dsMeshObj*)meshobj;
-(short)	ReadFaceList			:(H3dsMeshObj*)meshobj;
-(void)		ReadMapList				:(H3dsMeshObj*)meshobj;
-(void)		ReadTraMatrix			:(H3dsMeshObj*)meshobj;
-(void)		ReadFaceMaterial		:(H3dsMeshObj*)meshobj;
-(void)		ReadDefaultMaterial		:(H3dsMeshObj*)meshobj	:(short)nf;

-(void)		ReadTextureNameChunk	:(int)p         :(H3dsTexture*)texture;
-(void)		ReadRGBByte				:(int)p         :(H3dsRGBColor*)rgb;
-(void)		ReadRGBFloat			:(int)p         :(H3dsRGBColor*)rgb;

-(bool)		LoadTextureFile			:(char*)szFileName	:(GLuint)Texture_ID;

@end
