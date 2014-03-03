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
// name: mo_gfx.h
// desc: MoPhO API for graphics routines
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
#ifndef __MO_GFX_H__
#define __MO_GFX_H__


#include "mo_def.h"
#include <math.h>
#include <sys/time.h>
#include <OpenGLES/ES1/gl.h>


//-----------------------------------------------------------------------------
// name: class Vector3D
// desc: 3d vector
//-----------------------------------------------------------------------------
class Vector3D
{
public:
    Vector3D( ) : x(0), y(0), z(0) { }
    Vector3D( GLfloat _x, GLfloat _y, GLfloat _z ) { set( _x, _y, _z ); }
    Vector3D( const Vector3D & other ) { *this = other; }
    ~Vector3D() { }
    
public:
    void set( GLfloat _x, GLfloat _y, GLfloat _z ) { x = _x; y = _y; z = _z; }
    void setAll( GLfloat val ) { x = y = z = val; }

public:
    GLfloat & operator []( int index )
    { if( index == 0 ) return x; if( index == 1 ) return y; 
      if( index == 2 ) return z; return nowhere; }
    const GLfloat & operator []( int index ) const
    { if( index == 0 ) return x; if( index == 1 ) return y; 
      if( index == 2 ) return z; return zero; }
    const Vector3D & operator =( const Vector3D & rhs )
    { x = rhs.x; y = rhs.y; z = rhs.z; return *this; }
    
    Vector3D operator +( const Vector3D & rhs ) const
    { Vector3D result = *this; result += rhs; return result; }
    Vector3D operator -( const Vector3D & rhs ) const
    { Vector3D result = *this; result -= rhs; return result; }
    Vector3D operator *( GLfloat scalar ) const
    { Vector3D result = *this; result *= scalar; return result; }

    inline void operator +=( const Vector3D & rhs )
    { x += rhs.x; y += rhs.y; z += rhs.z; }
    inline void operator -=( const Vector3D & rhs )
    { x -= rhs.x; y -= rhs.y; z -= rhs.z; }
    inline void operator *=( GLfloat scalar )
    { x *= scalar; y *= scalar; z *= scalar; }
    
    // dot product
    inline GLfloat operator *( const Vector3D & rhs ) const
    { GLfloat result = x*rhs.x + y*rhs.y + z*rhs.z; return result; }
    // magnitude
    inline GLfloat magnitude() const
    { return ::sqrt( x*x + y*y + z*z ); }
    // normalize
    inline void normalize()
    { GLfloat mag = magnitude(); if( mag == 0 ) return; *this *= 1/mag; }
    // 2d angles
    inline GLfloat angleXY() const
    { return ::atan2( y, x ); }
    inline GLfloat angleYZ() const
    { return ::atan2( z, y ); }
    inline GLfloat angleXZ() const
    { return ::atan2( z, x ); }

public: // using the 3-tuple for interpolation
    inline void interp()
    { value = (goal-value)*slew + value; }
    inline void update( GLfloat _goal )
    { goal = _goal; }
    inline void update( GLfloat _goal, GLfloat _slew )
    { goal = _goal; slew = _slew; }

public:
    // either use as .x, .y, .z OR .value, .goal, .slew
    union { GLfloat x; GLfloat value; };
    union { GLfloat y; GLfloat goal; };
    union { GLfloat z; GLfloat slew; };
    
public:
    static GLfloat nowhere;
    static GLfloat zero;
};


//-----------------------------------------------------------------------------
// name: class MoGfx
// desc: MoPhO graphics functions
//-----------------------------------------------------------------------------
class MoGfx
{
public: // GLU-like stuff
    // perspective projection
    static void perspective( double fovy, double aspectRatio, double zNear, double zFar );
    // orthographic projection
    static void ortho( GLint width = 480, GLint height = 320, GLint landscape = 0 );
    // look at
    static void lookAt( double eye_x, double eye_y, double eye_z,
                       double at_x, double at_y, double at_z,
                       double up_x, double up_y, double up_z );
    
    // load texture (call this with a texture bound)
    static bool loadTexture( NSString * name, NSString * ext );
    // load texture from a UIImage
    static bool loadTexture( UIImage * image );
    
    // point in triangle test (2D)
    static bool isPointInTriangle2D( const Vector3D & pt, const Vector3D & a, 
                                     const Vector3D & b, const Vector3D & c );

    // get current time
    static double getCurrentTime( bool fresh );
    // reset current time tracking
    static void resetCurrentTime();
    // get delta
    static GLfloat delta();
    // set delta factor
    static void setDeltaFactor( GLfloat factor );
    
public:
    static struct timeval ourPrevTime;
    static struct timeval ourCurrTime;
    static GLfloat ourDeltaFactor;
};


#endif
