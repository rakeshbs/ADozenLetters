#define DEGREES_TO_RADIANS(x) ((x) / 180.0 * M_PI)
#define RADIANS_TO_DEGREES(x) ((x) / M_PI * 180.0)

typedef struct 
{
    GLfloat	x;
    GLfloat y;
    GLfloat z;
} Vertex3D;

typedef struct
{
    GLfloat	x;
    GLfloat y;
    GLfloat z;
    GLfloat w;
    
} Vertex4D;

typedef Vertex3D Vector3D;

static inline GLfloat Vertex3DDistanceBetweenVertices 
    (Vertex3D vertex1, Vertex3D vertex2)
{
    GLfloat deltaX, deltaY, deltaZ;
    
    deltaX = vertex2.x - vertex1.x;
    deltaY = vertex2.y - vertex1.y;
    deltaZ = vertex2.z - vertex1.z;
    
    return sqrtf((deltaX * deltaX) + 
                 (deltaY * deltaY) + 
                 (deltaZ * deltaZ));
}
static inline GLfloat Vector3DMagnitude(Vector3D vector)
{
    return sqrtf((vector.x * vector.x) + 
                 (vector.y * vector.y) + 
                 (vector.z * vector.z)); 
}
static inline GLfloat Vector3DDotProduct
(Vector3D vector1, Vector3D vector2)
{		
    return (vector1.x*vector2.x) + 
    (vector1.y*vector2.y) + 
    (vector1.z*vector2.z);
}
static inline Vector3D Vector3DCrossProduct
    (Vector3D vector1, Vector3D vector2)
{
    Vector3D ret;
    ret.x = (vector1.y * vector2.z) - (vector1.z * vector2.y);
    ret.y = (vector1.z * vector2.x) - (vector1.x * vector2.z);
    ret.z = (vector1.x * vector2.y) - (vector1.y * vector2.x);
    return ret;
}
static inline void Vector3DNormalize(Vector3D *vector)
{
    GLfloat vecMag = Vector3DMagnitude(*vector);
    if ( vecMag == 0.0 )
    {
        vector->x = 1.0;
        vector->y = 0.0;
        vector->z = 0.0;
        return;
    }
    vector->x /= vecMag;
    vector->y /= vecMag;
    vector->z /= vecMag;
}
static inline Vector3D Vector3DMakeWithStartAndEndPoints
(Vertex3D start, Vertex3D end)
{
    Vector3D ret;
    ret.x = end.x - start.x;
    ret.y = end.y - start.y;
    ret.z = end.z - start.z;
    return ret;
}
static inline Vector3D Vector3DMakeNormalizedVectorWithStartAndEndPoints
(Vertex3D start, Vertex3D end)
{
    Vector3D ret = Vector3DMakeWithStartAndEndPoints(start, end);
    Vector3DNormalize(&ret);
    return ret;
} 
static inline void Vector3DFlip (Vector3D *vector)
{
    vector->x = -vector->x;
    vector->y = -vector->y;
    vector->z = -vector->z;
}
typedef struct {
    GLubyte	red;
    GLubyte green;
    GLubyte blue;
    GLubyte alpha;
} Color4B;

static inline void Vector3DCopy(Vector3D *source,Vector3D *destination)
{
    destination->x = source->x;
    destination->y = source->y;
    destination->z = source->z;
}

static inline void Color4fCopy(Color4B *source,Color4B *destination)
{
    destination->blue = source->blue;
    destination->green = source->green;
    destination->red = source->red;
    destination->alpha = source->alpha;
}

static inline void Vector3DCopyS(Vector3D source,Vector3D *destination)
{
    destination->x = source.x;
    destination->y = source.y;
    destination->z = source.z;
}


static inline void Color4fCopyS(Color4B source,Color4B *destination)
{
    destination->blue = source.blue;
    destination->green = source.green;
    destination->red = source.red;
    destination->alpha = source.alpha;
}

typedef GLfloat Matrix3D[16];
static inline void Matrix3DSetIdentity(Matrix3D matrix)
{
    matrix[0] = matrix[5] = matrix[10] = matrix[15] = 1.0;
    matrix[1] = matrix[2] = matrix[3] = matrix[4] = 0.0;
    matrix[6] = matrix[7] = matrix[8] = matrix[9] = 0.0;    
    matrix[11] = matrix[12] = matrix[13] = matrix[14] = 0.0;
}
static inline void Matrix3DSetTranslation
    (Matrix3D matrix, GLfloat xTranslate, 
     GLfloat yTranslate, GLfloat zTranslate)
{
    matrix[0] = matrix[5] = matrix[10] = matrix[15] = 1.0;
    matrix[1] = matrix[2] =  matrix[3] =  matrix[4] = 0.0;
    matrix[6] = matrix[7] =  matrix[8] =  matrix[9] = 0.0;    
    matrix[11] = 0.0;
    matrix[12] = xTranslate;
    matrix[13] = yTranslate;
    matrix[14] = zTranslate;   
}
static inline void Matrix3DSetScaling
    (Matrix3D matrix, GLfloat xScale, 
     GLfloat yScale, GLfloat zScale)
{
    matrix[1] = matrix[2] = matrix[3] = matrix[4] = 0.0;
    matrix[6] = matrix[7] = matrix[8] = matrix[9] = 0.0;
    matrix[11] = matrix[12] = matrix[13] = matrix[14] = 0.0;
    matrix[0] = xScale;
    matrix[5] = yScale;
    matrix[10] = zScale;
    matrix[15] = 1.0;
}
static inline void Matrix3DSetUniformScaling
    (Matrix3D matrix, GLfloat scale)
{
    Matrix3DSetScaling(matrix, scale, scale, scale);
}
static inline void Matrix3DSetZRotationUsingRadians
    (Matrix3D matrix, GLfloat radians)
{
    matrix[0] = cosf(radians);
    matrix[1] = sinf(radians);
    matrix[4] = -matrix[1];
    matrix[5] = matrix[0];
    matrix[2] = matrix[3] = matrix[6] = matrix[7] = matrix[8] = 0.0;
    matrix[9] = matrix[11] = matrix[12] = matrix[13] = matrix[14] = 0.0;
    matrix[10] = matrix[15] = 1.0;
}
static inline void Matrix3DSetZRotationUsingDegrees
    (Matrix3D matrix, GLfloat degrees)
{
    Matrix3DSetZRotationUsingRadians(matrix, DEGREES_TO_RADIANS(degrees));
}
static inline void Matrix3DSetXRotationUsingRadians
(Matrix3D matrix, GLfloat radians)
{
    matrix[0] = matrix[15] = 1.0;
    matrix[1] = matrix[2] = matrix[3] = matrix[4] = 0.0;
    matrix[7] = matrix[8] = 0.0;    
    matrix[11] = matrix[12] = matrix[13] = matrix[14] = 0.0;
    
    matrix[5] = cosf(radians);
    matrix[6] = -sinf(radians);
    matrix[9] = -matrix[6];
    matrix[10] = matrix[5];
}
static inline void Matrix3DSetXRotationUsingDegrees
(Matrix3D matrix, GLfloat degrees)
{
    Matrix3DSetXRotationUsingRadians(matrix,DEGREES_TO_RADIANS(degrees));
}
static inline void Matrix3DSetYRotationUsingRadians
(Matrix3D matrix, GLfloat radians)
{
    matrix[0] = cosf(radians);
    matrix[2] = sinf(radians);
    matrix[8] = -matrix[2];
    matrix[10] = matrix[0];
    matrix[1] = matrix[3] = matrix[4] = matrix[6] = matrix[7] = 0.0;
    matrix[9] = matrix[11] = matrix[13] = matrix[12] = matrix[14] = 0.0;
    matrix[5] = matrix[15] = 1.0;
}
static inline void Matrix3DSetYRotationUsingDegrees
(Matrix3D matrix, GLfloat degrees)
{
    Matrix3DSetYRotationUsingRadians(matrix, DEGREES_TO_RADIANS(degrees));
}
static inline void Matrix3DSetRotationByRadians
(Matrix3D matrix, GLfloat radians, Vector3D vector)
{
    GLfloat mag = sqrtf((vector.x * vector.x) + 
                        (vector.y * vector.y) + 
                        (vector.z * vector.z));
    if (mag == 0.0)
    {
        vector.x = 1.0;
        vector.y = 0.0;
        vector.z = 0.0;
    }
    else if (mag != 1.0)
    {
        vector.x /= mag;
        vector.y /= mag;
        vector.z /= mag;
    }
    
    GLfloat c = cosf(radians);
    GLfloat s = sinf(radians);
    matrix[3] = matrix[7] = matrix[11] = 0.0;
    matrix[12] = matrix[13] = matrix[14] = 0.0;
    matrix[15] = 1.0;
    
    matrix[0]  = (vector.x * vector.x) * (1-c) + c;
    matrix[1]  = (vector.y * vector.x) * (1-c) + (vector.z * s);
    matrix[2]  = (vector.x * vector.z) * (1-c) - (vector.y * s);
    matrix[4]  = (vector.x * vector.y) * (1-c) - (vector.z * s);
    matrix[5]  = (vector.y * vector.y) * (1-c) + c;
    matrix[6]  = (vector.y * vector.z) * (1 - c) + (vector.x*s);
    matrix[8]  = (vector.x * vector.z) * (1 - c) + (vector.y*s);
    matrix[9]  = (vector.y * vector.z) * (1 - c) - (vector.x*s);
    matrix[10] = (vector.z * vector.z) * (1 - c) + c;
}
static inline void Matrix3DSetRotationByDegrees
    (Matrix3D matrix, GLfloat degrees, Vector3D vec)
{
    Matrix3DSetRotationByRadians(matrix, DEGREES_TO_RADIANS(degrees), vec);
}
static inline void Matrix3DMultiply(Matrix3D m1, Matrix3D m2, Matrix3D result)
{
    result[0] = m1[0] * m2[0] + m1[4] * m2[1] 
    + m1[8] * m2[2] + m1[12] * m2[3];
    result[1] = m1[1] * m2[0] + m1[5] * m2[1] 
    + m1[9] * m2[2] + m1[13] * m2[3];
    result[2] = m1[2] * m2[0] + m1[6] * m2[1] 
    + m1[10] * m2[2] + m1[14] * m2[3];
    result[3] = m1[3] * m2[0] + m1[7] * m2[1]
    + m1[11] * m2[2] + m1[15] * m2[3];
    
    result[4] = m1[0] * m2[4] + m1[4] * m2[5] 
    + m1[8] * m2[6] + m1[12] * m2[7];
    result[5] = m1[1] * m2[4] + m1[5] * m2[5] 
    + m1[9] * m2[6] + m1[13] * m2[7];
    result[6] = m1[2] * m2[4] + m1[6] * m2[5] 
    + m1[10] * m2[6] + m1[14] * m2[7];
    result[7] = m1[3] * m2[4] + m1[7] * m2[5] 
    + m1[11] * m2[6] + m1[15] * m2[7];
    
    result[8] = m1[0] * m2[8] + m1[4] * m2[9] 
    + m1[8] * m2[10] + m1[12] * m2[11];
    result[9] = m1[1] * m2[8] + m1[5] * m2[9] 
    + m1[9] * m2[10] + m1[13] * m2[11];
    result[10] = m1[2] * m2[8] + m1[6] * m2[9] 
    + m1[10] * m2[10] + m1[14] * m2[11];
    result[11] = m1[3] * m2[8] + m1[7] * m2[9] 
    + m1[11] * m2[10] + m1[15] * m2[11];
    
    result[12] = m1[0] * m2[12] + m1[4] * m2[13] 
    + m1[8] * m2[14] + m1[12] * m2[15];
    result[13] = m1[1] * m2[12] + m1[5] * m2[13] 
    + m1[9] * m2[14] + m1[13] * m2[15];
    result[14] = m1[2] * m2[12] + m1[6] * m2[13] 
    + m1[10] * m2[14] + m1[14] * m2[15];
    result[15] = m1[3] * m2[12] + m1[7] * m2[13] 
    + m1[11] * m2[14] + m1[15] * m2[15];
}

static inline Vertex4D Matrix3DMultiplyWithVector3D(Matrix3D m, Vector3D *v)
{
    Vertex4D result;
    
    result.x = m[0] * v->x + m[4] * v->y + m[8] * v->z + m[12];
    result.y = m[1] * v->x + m[5] * v->y + m[9] * v->z + m[13];
    result.z = m[2] * v->x + m[6] * v->y + m[10] * v->z + m[14];
    result.w = m[3] * v->x + m[7] * v->y + m[11] * v->z + m[15];
    return result;
}

static inline void Matrix3DSetOrthoProjection(Matrix3D matrix, GLfloat left, 
    GLfloat right, GLfloat bottom, GLfloat top, GLfloat near, GLfloat far)
{
    matrix[1] = matrix[2] = matrix[3] = matrix[4] = matrix[6] = 0.f;
    matrix[7] = matrix[8] = matrix[9] = matrix[11] = 0.f;
    matrix[0] = 2.f / (right - left);
    matrix[5] = 2.f / (top - bottom);
    matrix[10] = -2.f / (far - near);
    matrix[12] = (right + left) / (right - left);
    matrix[13] = (top + bottom) / (top - bottom);
    matrix[14] = (far + near) / (far - near);
    matrix[15] = 1.f;
}
static inline void Matrix3DSetFrustumProjection(Matrix3D matrix, 
                                                GLfloat left, GLfloat right, 
                                                GLfloat bottom, GLfloat top, 
                                                GLfloat zNear, GLfloat zFar)
{
    matrix[1] = matrix[2] = matrix[3] = matrix[4] = 0.f;
    matrix[6] = matrix[7] = matrix[12] = matrix[13] = matrix[15] = 0.f;
    
    
    matrix[0] = 2 * zNear / (right - left);
    matrix[5] = 2 * zNear / (top - bottom);
    matrix[8] = (right + left) / (right - left);
    matrix[9] = (top + bottom) / (top - bottom);
    matrix[10] = -(zFar + zNear) / (zFar - zNear);
    matrix[11] = -1.f;
    matrix[14] = -(2 * zFar * zNear) / (zFar - zNear);
}

static inline void Matrix3DCopyS(Matrix3D source,Matrix3D destination)
{
    for (int i =0;i<16;i++)
    {
        destination[i] = source[i];
    }
}

static inline void Matrix3DCopy(Matrix3D *source,Matrix3D *destination)
{
    for (int i =0;i<16;i++)
    {
        *(destination)[i]= *(source)[i];
    }
}

static inline void Matrix3DSetPerspectiveProjectionWithFieldOfView
    (Matrix3D matrix, GLfloat fieldOfVision, GLfloat near,
     GLfloat far, GLfloat aspectRatio)
{
    GLfloat size = near * tanf(DEGREES_TO_RADIANS(fieldOfVision) / 2.0); 
    Matrix3DSetFrustumProjection( matrix,
                                 -size, 
                                 size,
                                 -size / aspectRatio,
                                 size / aspectRatio,
                                 near,
                                 far);


}

typedef struct
{
    GLfloat	s;
    GLfloat t;
} TextureCoord;

static inline void TextureCoordCopy(TextureCoord *source,TextureCoord *destination)
{
    destination->s = source->s;
    destination->t = source->t;

}

static inline void TextureCoordCopyS(TextureCoord source,TextureCoord *destination)
{
    destination->s = source.s;
    destination->t = source.t;
}


#if defined(__ARM_NEON__)

void NEON_Matrix4Mul(const float* a, const float* b, float* output )
{
	__asm__ volatile
	(
	 // Store A & B leaving room for q4-q7, which should be preserved
	 "vldmia %1, { q0-q3 } \n\t"
	 "vldmia %2, { q8-q11 }\n\t"
     
	 // result = first column of B x first row of A
	 "vmul.f32 q12, q8, d0[0]\n\t"
	 "vmul.f32 q13, q8, d2[0]\n\t"
	 "vmul.f32 q14, q8, d4[0]\n\t"
	 "vmul.f32 q15, q8, d6[0]\n\t"
     
	 // result += second column of B x second row of A
	 "vmla.f32 q12, q9, d0[1]\n\t"
	 "vmla.f32 q13, q9, d2[1]\n\t"
	 "vmla.f32 q14, q9, d4[1]\n\t"
	 "vmla.f32 q15, q9, d6[1]\n\t"
     
	 // result += third column of B x third row of A
	 "vmla.f32 q12, q10, d1[0]\n\t"
	 "vmla.f32 q13, q10, d3[0]\n\t"
	 "vmla.f32 q14, q10, d5[0]\n\t"
	 "vmla.f32 q15, q10, d7[0]\n\t"
     
	 // result += last column of B x last row of A
	 "vmla.f32 q12, q11, d1[1]\n\t"
	 "vmla.f32 q13, q11, d3[1]\n\t"
	 "vmla.f32 q14, q11, d5[1]\n\t"
	 "vmla.f32 q15, q11, d7[1]\n\t"
     
	 // output = result registers
	 "vstmia %0, { q12-q15 }"
	 : // no output
	 : "r" (output), "r" (a), "r" (b) 	// input - note *value* of pointer doesn't change
	 : "memory", "q0", "q1", "q2", "q3", "q8", "q9", "q10", "q11", "q12", "q13", "q14", "q15" //clobber
	 );
}

void NEON_Matrix4Vector4Mul(const float* m, const Vector3D* v, Vertex4D* output)
{
	__asm__ volatile
	(
	 // Store m & v - avoiding q4-q7 which need to be preserved - q0 = result
	 "vldmia %1, { q8-q11 }	\n\t"	// q8-q11 = m
	 "vldmia %2, { q1 }		\n\t"	// q1     = v
     
	 // result = first column of A x V.x
	 "vmul.f32 q0, q8, d2[0]\n\t"
     
	 // result += second column of A x V.y
	 "vmla.f32 q0, q9, d2[1]\n\t"
     
	 // result += third column of A x V.z
	 "vmla.f32 q0, q10, d3[0]\n\t"
     
	 // result += last column of A x V.w
	 "vmla.f32 q0, q11, d3[1]\n\t"
     
	 // output = result registers
	 "vstmia %0, { q0 }"
     
	 : // no output
	 : "r" (output), "r" (m), "r" (v) 	// input - note *value* of pointer doesn't change
	 : "memory", "q0", "q1", "q8", "q9", "q10", "q11" //clobber
	 );
}

#endif

