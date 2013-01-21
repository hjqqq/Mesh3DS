@interface H3dsFace : NSObject
    {
    short	p0, p1, p2;
    short	flags;
    }

-(short)getP0;
-(short)getP1;
-(short)getP2;

-(void) setP0 	:(float)new_P0;
-(void) setP1 	:(float)new_P1;
-(void) setP2 	:(float)new_P2;
-(void) setFlags:(float)new_Flags;

@end
