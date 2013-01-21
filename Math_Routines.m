#import "Math_Routines.h"

@implementation Mesh3DS (Math_Routines)

/*
 *	Returns the angle of a triangle at the specified vertex
 */

-(GLfloat)Angle	:(SURFACE*)surface :(GLuint)vertex {
    
	double result;
	double a, b, c;
    
	a = b = c = 0;
    
	if  (vertex == [surface getP0]) {				// Calculate length of sides a, b and c when ∠A is P0
        
	    a = [self Distance :[VertexList objectAtIndex:[surface getP1]] :[VertexList objectAtIndex:[surface getP2]]];
	    b = [self Distance :[VertexList objectAtIndex:[surface getP0]] :[VertexList objectAtIndex:[surface getP1]]];
	    c = [self Distance :[VertexList objectAtIndex:[surface getP0]] :[VertexList objectAtIndex:[surface getP2]]];
        
    } else if (vertex == [surface getP1]) {		// ... or, when ∠A is P1
        
	    a = [self Distance :[VertexList objectAtIndex:[surface getP2]] :[VertexList objectAtIndex:[surface getP0]]];
	    b = [self Distance :[VertexList objectAtIndex:[surface getP2]] :[VertexList objectAtIndex:[surface getP1]]];
	    c = [self Distance :[VertexList objectAtIndex:[surface getP0]] :[VertexList objectAtIndex:[surface getP1]]];
        
    } else if (vertex == [surface getP2]) {		// ... or, when ∠A is P2
        
	    a = [self Distance :[VertexList objectAtIndex:[surface getP1]] :[VertexList objectAtIndex:[surface getP0]]];
	    b = [self Distance :[VertexList objectAtIndex:[surface getP2]] :[VertexList objectAtIndex:[surface getP0]]];
	    c = [self Distance :[VertexList objectAtIndex:[surface getP1]] :[VertexList objectAtIndex:[surface getP2]]];
    }
    
	result  = (b*b + c*c - a*a);			// Compute the angle at this vertex as:  cosA = (b^2 + c^2 - a^2) / 2bc

	result /= (2*b*c);

	result	= acos (result);				// Take the inverse of cosA to get the angle in radians
	
	result *= (180.0/M_PI);
	
	return (GLfloat) result;				// Triangle ∠A at the requested vertex in degrees
}


/*
 * Returns a Tangent Vector for a given triangle and vertex
 */
 
- (Vector3f)Tangent :(SURFACE*)triangle :(GLuint)vertex {									// Based on http://ogldev.atspace.co.uk/www/tutorial26/tutorial26.html
	
	VERTEX		*v0, *v1, *v2;
	
	Vector3f	tangent = {0.0f, 0.0f, 0.0f};

	v0 = v1 = v2 = nil;
	
	if (vertex == [triangle getP0]) {
		
		v0 = [VertexList objectAtIndex:[triangle getP0]];
		v1 = [VertexList objectAtIndex:[triangle getP1]];
		v2 = [VertexList objectAtIndex:[triangle getP2]];
		
	} else if (vertex == [triangle getP1]) {
		
		v0 = [VertexList objectAtIndex:[triangle getP1]];
		v1 = [VertexList objectAtIndex:[triangle getP2]];
		v2 = [VertexList objectAtIndex:[triangle getP0]];
		
	} else if (vertex == [triangle getP2]) {
		
		v0 = [VertexList objectAtIndex:[triangle getP2]];
		v1 = [VertexList objectAtIndex:[triangle getP0]];
		v2 = [VertexList objectAtIndex:[triangle getP1]];
	}
	
	Vector3f Edge1	= {[v1 getX]-[v0 getX], [v1 getY]-[v0 getY], [v1 getZ]-[v0 getZ]};
	Vector3f Edge2	= {[v2 getX]-[v0 getX], [v2 getY]-[v0 getY], [v2 getZ]-[v0 getZ]};
	
	float DeltaU1	= [v1 getU]-[v0 getU];
	float DeltaV1	= [v1 getV]-[v0 getV];
	
	float DeltaU2	= [v2 getU]-[v0 getU];
	float DeltaV2	= [v2 getV]-[v0 getV];
	
	float r			= DeltaU1 * DeltaV2 - DeltaU2 * DeltaV1;
	
	if	(!r) return tangent;																// If there are no texcoords for this vertex, just return a null tangent vector
	
	float f			= 1.0f / r;
	
	tangent.x		= f * (DeltaV2 * Edge1.x - DeltaV1 * Edge2.x);
	tangent.y		= f * (DeltaV2 * Edge1.y - DeltaV1 * Edge2.y);
	tangent.z		= f * (DeltaV2 * Edge1.z - DeltaV1 * Edge2.z);
	
	return tangent;
}


/*
 *	Returns the Dot Product of two vectors; in this case two surface normals.
 *
 *  Since both surface normals are already normalized as unit vectors, their dot product is the same as the cosine of the angle between the normals.
 *
 *  See "Scalar projection" at https://en.wikipedia.org/wiki/Dot_product
 */

-(GLfloat)Cos_angle :(SURFACE*)s1 :(SURFACE*)s2	{
    
    return [s1 getNX] * [s2 getNX] + [s1 getNY] * [s2 getNY] + [s1 getNZ] * [s2 getNZ];
}


/*
 *	Distance between two 3D points
 */

-(double)Distance :(VERTEX*)v1 :(VERTEX*)v2	{
    
    double dx, dy, dz;
	
    dx = fabs (([v2 getX] - [v1 getX]) * ([v2 getX] - [v1 getX]));
    dy = fabs (([v2 getY] - [v1 getY]) * ([v2 getY] - [v1 getY]));
    dz = fabs (([v2 getZ] - [v1 getZ]) * ([v2 getZ] - [v1 getZ]));
    
    return sqrt (dx + dy + dz);
}

@end