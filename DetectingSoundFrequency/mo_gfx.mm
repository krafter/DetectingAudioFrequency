/*----------------------------------------------------------------------------
  MoMu: A Mobile Music Toolkit
  Copyright (c) 2010 Nicholas J. Bryan, Jorge Herrera, Jieun Oh, and Ge Wang
  All rights reserved.
    http://momu.stanford.edu/toolkit/
 
  Mobile Music Research @ CCRMA
  Music, Computing, Design Group
  Stanford University
    http://momu.stanford.edu/
    http://ccrma.stanford.edu/groups/mcd/
 
 MoMu is distributed under the following BSD style open source license:
 
 Permission is hereby granted, free of charge, to any person obtaining a 
 copy of this software and associated documentation files (the
 "Software"), to deal in the Software without restriction, including
 without limitation the rights to use, copy, modify, merge, publish,
 distribute, sublicense, and/or sell copies of the Software, and to
 permit persons to whom the Software is furnished to do so, subject to
 the following conditions:
 
 The authors encourage users of MoMu to include this copyright notice,
 and to let us know that you are using MoMu. Any person wishing to 
 distribute modifications to the Software is encouraged to send the 
 modifications to the original authors so that they can be incorporated 
 into the canonical version.
 
 The Software is provided "as is", WITHOUT ANY WARRANTY, express or implied,
 including but not limited to the warranties of MERCHANTABILITY, FITNESS
 FOR A PARTICULAR PURPOSE and NONINFRINGEMENT.  In no event shall the authors
 or copyright holders by liable for any claim, damages, or other liability,
 whether in an actino of a contract, tort or otherwise, arising from, out of
 or in connection with the Software or the use or other dealings in the 
 software.
 -----------------------------------------------------------------------------*/
//-----------------------------------------------------------------------------
// name: mo_gfx.cpp
// desc: MoPhO API for graphics
//
// authors: Ge Wang (ge@ccrma.stanford.edu)
//          Nick Bryan
//          Jieun Oh
//          Jorge Hererra
//
//    date: Fall 2009
//    version: 1.0.0
//
// Mobile Music research @ CCRMA, Stanford University:
//     http://momu.stanford.edu/
//-----------------------------------------------------------------------------
#include "mo_gfx.h"
#include <math.h>
#include <OpenGLES/ES1/gl.h>
#include <OpenGLES/ES1/glext.h>


// vector static
GLfloat Vector3D::nowhere = 0.0f;
GLfloat Vector3D::zero = 0.0;


//-----------------------------------------------------------------------------
// name: perspective()
// desc: set perspective projection
//       (from jshmrsn, macrumors forum)
//-----------------------------------------------------------------------------
void MoGfx::perspective( double fovy, double aspectRatio, double zNear, double zFar )
{
    double xmin, xmax, ymin, ymax;

    // projection
    glMatrixMode( GL_PROJECTION );
    // identity
    glLoadIdentity();

    // set field of view
    ymax = zNear * tan( fovy * M_PI / 360.0 );
    ymin = -ymax;
    xmin = ymin * aspectRatio;
    xmax = ymax * aspectRatio;

    // set the frustum
    glFrustumf( xmin, xmax, ymin, ymax, zNear, zFar );

    // set hint
    glHint( GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST );
    
    // modelview
    glMatrixMode( GL_MODELVIEW );
    // set to identity
    glLoadIdentity();

    // enable depth mask
    // glDepthMask( GL_TRUE );
}




//-----------------------------------------------------------------------------
// name: ortho()
// desc: set ortho projection
//       (from jshmrsn, macrumors forum)
//-----------------------------------------------------------------------------
void MoGfx::ortho( GLint width, GLint height, GLint landscape )
{
    glMatrixMode( GL_PROJECTION );
    glLoadIdentity();                  
    glOrthof( 0, width, 0, height, -1, 1 );

    glMatrixMode( GL_MODELVIEW );
    glLoadIdentity();
    // landscape
    if( landscape != 0 )
    {
        // translate
        glTranslatef( width/2, height/2, 0 );
        // rotate around z
        glRotatef( landscape > 0 ? -90 : 90, 0, 0, 1 );
        
        // translate
        glTranslatef( -height/2, -width/2, 0 );
    }
}




//-----------------------------------------------------------------------------
// name: lookAt()
// desc: set eye, at, up vector
//       (from jshmrsn, macrumors forum)
//-----------------------------------------------------------------------------
void MoGfx::lookAt( double eye_x, double eye_y, double eye_z,
                    double at_x, double at_y, double at_z,
                    double up_x, double up_y, double up_z )
{
    GLfloat m[16];
    GLfloat x[3], y[3], z[3];
    GLfloat mag;

    /* Make rotation matrix */

    /* Z vector */
    z[0] = eye_x - at_x;
    z[1] = eye_y - at_y;
    z[2] = eye_z - at_z;

    mag = sqrt( z[0] * z[0] + z[1] * z[1] + z[2] * z[2] );
    if( mag )
    {   /* mpichler, 19950515 */
        z[0] /= mag;
        z[1] /= mag;
        z[2] /= mag;
    }

    /* Y vector */
    y[0] = up_x;
    y[1] = up_y;
    y[2] = up_z;

    /* X vector = Y cross Z */
    x[0] = y[1] * z[2] - y[2] * z[1];
    x[1] = -y[0] * z[2] + y[2] * z[0];
    x[2] = y[0] * z[1] - y[1] * z[0];

    /* Recompute Y = Z cross X */
    y[0] = z[1] * x[2] - z[2] * x[1];
    y[1] = -z[0] * x[2] + z[2] * x[0];
    y[2] = z[0] * x[1] - z[1] * x[0];

    /* mpichler, 19950515 */
    /* cross product gives area of parallelogram, which is < 1.0 for
     * non-perpendicular unit-length vectors; so normalize x, y here
     */
    mag = sqrt( x[0] * x[0] + x[1] * x[1] + x[2] * x[2] );
    if( mag )
    {
        x[0] /= mag;
        x[1] /= mag;
        x[2] /= mag;
    }
    mag = sqrt( y[0] * y[0] + y[1] * y[1] + y[2] * y[2] );
    if( mag )
    {
        y[0] /= mag;
        y[1] /= mag;
        y[2] /= mag;
    }

#define M(row,col)  m[col*4+row]
    M(0,0) = x[0];
    M(0,1) = x[1];
    M(0,2) = x[2];
    M(0,3) = 0.0;
    M(1,0) = y[0];
    M(1,1) = y[1];
    M(1,2) = y[2];
    M(1,3) = 0.0;
    M(2,0) = z[0];
    M(2,1) = z[1];
    M(2,2) = z[2];
    M(2,3) = 0.0;
    M(3,0) = 0.0;
    M(3,1) = 0.0;
    M(3,2) = 0.0;
    M(3,3) = 1.0;    
#undef M

    // multiply into m
    glMultMatrixf( m );

    // translate eye to origin
    glTranslatef( -eye_x, -eye_y, -eye_z );
    glRotatef(90.0f, 0, 0, 1);
}



//-----------------------------------------------------------------------------
// name: loadTexture()
// desc: loads an OpenGL ES texture
//       (from jshmrsn, macrumors forum)
//-----------------------------------------------------------------------------
bool MoGfx::loadTexture( NSString * name, NSString * ext )
{
    // load the resource
    NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:ext];
    NSData *texData = [[NSData alloc] initWithContentsOfFile:path];
    UIImage *image = [[UIImage alloc] initWithData:texData];
    if (image == nil)
    {
        NSLog( @"[mo_gfx]: cannot load file: %@.%@", name, ext );
        return FALSE;
    }
    
    // log
    NSLog( @"loading texture: %@.%@...", name, ext );

    // load image
    loadTexture( image );

    // cleanup
    [image release];
    [texData release];
    
    return true;
}


//-----------------------------------------------------------------------------
// name: loadTexture()
// desc: loads an OpenGL ES texture
//       (from jshmrsn, macrumors forum)
//-----------------------------------------------------------------------------
bool MoGfx::loadTexture( UIImage * image )
{
    if (image == nil)
    {
        NSLog( @"[mo_gfx]: error: UIImage == nil..." );
        return FALSE;
    }
    
    // convert to RGBA
    GLuint width = CGImageGetWidth( image.CGImage );
    GLuint height = CGImageGetHeight( image.CGImage );
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    void *imageData = malloc( height * width * 4 );
    CGContextRef context = CGBitmapContextCreate( 
        imageData, width, height, 8, 4 * width, colorSpace, 
        kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big );
    CGColorSpaceRelease( colorSpace );
    CGContextClearRect( context, CGRectMake( 0, 0, width, height ) );
    CGContextTranslateCTM( context, 0, height - height );
    CGContextDrawImage( context, CGRectMake( 0, 0, width, height ), image.CGImage );
    
    // load the texture
    glTexImage2D( GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, 
                  GL_RGBA, GL_UNSIGNED_BYTE, imageData );
    
    // free resource - OpenGL keeps image internally
    CGContextRelease(context);
    free(imageData);
    
    return true;
}


//-----------------------------------------------------------------------------
// name: isPointInTriangle2D()
// desc: point in triangle test (2D)
//-----------------------------------------------------------------------------
bool MoGfx::isPointInTriangle2D( const Vector3D & p, const Vector3D & a, 
                                 const Vector3D & b, const Vector3D & c )
{
    Vector3D v0 = c - a;
    Vector3D v1 = b - a;
    Vector3D v2 = p - a;
    
    // Compute dot products
    GLfloat dot00 = v0*v0;
    GLfloat dot01 = v0*v1;
    GLfloat dot02 = v0*v2;
    GLfloat dot11 = v1*v1;
    GLfloat dot12 = v1*v2;
    
    // Compute barycentric coordinates
    GLfloat invDenom = 1 / (dot00 * dot11 - dot01 * dot01);
    GLfloat u = (dot11 * dot02 - dot01 * dot12) * invDenom;
    GLfloat v = (dot00 * dot12 - dot01 * dot02) * invDenom;
    
    // Check if point is in triangle
    return (u > 0) && (v > 0) && (u + v < 1);
}




//-----------------------------------------------------------------------------
// name: getCurrentTime()
// desc: get current time for simulation
//-----------------------------------------------------------------------------
double MoGfx::getCurrentTime( bool fresh )
{
    if( fresh )
    {
        ourPrevTime = ourCurrTime;
        gettimeofday( &ourCurrTime, NULL );
    }
    
    return ourCurrTime.tv_sec + (double)ourCurrTime.tv_usec / 1000000;
}




//-----------------------------------------------------------------------------
// name: resetCurrentTime()
// desc: reset current time for simulation
//-----------------------------------------------------------------------------
void MoGfx::resetCurrentTime()
{
    ourPrevTime.tv_sec = 0;
    ourPrevTime.tv_usec = 0;
}




//-----------------------------------------------------------------------------
// name: delta()
// desc: get current time delta for simulation
//-----------------------------------------------------------------------------
GLfloat MoGfx::delta()
{
    double prev = ourPrevTime.tv_sec + (double)ourPrevTime.tv_usec / 1000000;
    double curr = ourCurrTime.tv_sec + (double)ourCurrTime.tv_usec / 1000000;
    // first 0
    return (prev == 0 ? 0.0f : (GLfloat)(curr - prev)) * ourDeltaFactor;
}




//-----------------------------------------------------------------------------
// name: setDeltaFactor()
// desc: set time delta factor for simulation
//-----------------------------------------------------------------------------
void MoGfx::setDeltaFactor( GLfloat factor )
{
    ourDeltaFactor = factor;
}




// static instantiation
struct timeval MoGfx::ourCurrTime;
struct timeval MoGfx::ourPrevTime;
GLfloat MoGfx::ourDeltaFactor = 1.0f;
