/*
 * This program source code file is part of KiCad, a free EDA CAD application.
 *
 * Copyright (C) 2015-2016 Mario Luzeiro <mrluzeiro@ua.pt>
 * Copyright (C) 1992-2016 KiCad Developers, see AUTHORS.txt for contributors.
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, you may find one here:
 * http://www.gnu.org/licenses/old-licenses/gpl-2.0.html
 * or you may search the http://www.gnu.org website for the version 2 license,
 * or you may write to the Free Software Foundation, Inc.,
 * 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA
 */

/**
 * @file  cdummyblock.h
 * @brief
 */

#ifndef _CDUMMYBLOCK_H_
#define _CDUMMYBLOCK_H_

#include "cobject.h"

/**
 * A dummy block is used to fill the polygons. It will only will be intersepted
 * from top or from bottom
 */
class  CDUMMYBLOCK : public COBJECT
{

public:
    explicit CDUMMYBLOCK( const CBBOX &aBBox );

    void SetColor( SFVEC3F aObjColor ) { m_diffusecolor = aObjColor; }

// Imported from COBJECT
    bool Intersect( const RAY &aRay, HITINFO &aHitInfo ) const;
    bool IntersectP(const RAY &aRay , float aMaxDistance ) const;
    bool Intersects( const CBBOX &aBBox ) const;
    SFVEC3F GetDiffuseColor( const HITINFO &aHitInfo ) const;
private:
    SFVEC3F m_diffusecolor;
};


#endif // _CDUMMYBLOCK_H_
