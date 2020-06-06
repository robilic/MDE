//
//  wadfile.h
//  MDE
//
//  Created by robert on 4/21/20.
//  Copyright © 2020 local. All rights reserved.
//

#ifndef wadfile_h
#define wadfile_h

// .WAD file header
// Should start out like
// 00000000: 4957 4144 f004 0000 b4b7 3f00 0000 001f  IWAD......?.....
typedef struct {
    char type[ 4];               /* type of WAD file (IWAD or PWAD) */
    int32_t dirsize;                /* number of directory entries */
    int32_t dirstart;               /* offset to start of directory, AFTER the data */
} WADFileHeader;

// Directory Entry, 16 bytes long
typedef struct
{
   int32_t start;                  /* offset to start of data */
   int32_t size;                   /* byte size of data */
   char name[ 8];               /* name of data block, E1M1, TEXTURE1 ... */
} WADFileDirectoryEntry;

// From DEU

typedef struct
{
   int16_t xpos;      /* x position */
   int16_t ypos;      /* y position */
   int16_t angle;     /* facing angle */
   int16_t type;      /* thing type */
   int16_t when;      /* appears when? */
} Thing;

typedef struct
{
   int16_t start;     /* from this vertex ... */
   int16_t end;       /* ... to this vertex */
   int16_t flags;     /* see NAMES.C for more info */
   int16_t type;      /* see NAMES.C for more info */
   int16_t tag;       /* crossing this linedef activates the sector with the same tag */
   int16_t sidedef1;  /* sidedef */
   int16_t sidedef2;  /* only if this line adjoins 2 sectors */
} LineDef;

typedef struct
{
   int16_t xoff;      /* X offset for texture */
   int16_t yoff;      /* Y offset for texture */
   char tex1[8];  /* texture name for the part above */
   char tex2[8];  /* texture name for the part below */
   char tex3[8];  /* texture name for the regular part */
   int16_t sector;    /* adjacent sector */
} SideDef;

typedef struct
{
   int16_t x;         /* X coordinate */
   int16_t y;         /* Y coordinate */
} Vertex;

typedef struct
{
   struct SEG *next;    /* next Seg in list */
   int16_t start;     /* from this vertex ... */
   int16_t end;       /* ... to this vertex */
   uint16_t angle;/* angle (0 = east, 16384 = north, ...) */
   int16_t linedef;   /* linedef that this seg goes along*/
   int16_t flip;      /* true if not the same direction as linedef */
   uint16_t dist; /* distance from starting point16_t */
} SEG;

typedef struct
{
   struct SSector *next;      /* next Sub-Sector in list */
   int16_t num;       /* number of Segs in this Sub-Sector */
   int16_t first;     /* first Seg */
} SSector;

typedef struct {
   int16_t x, y;                         /* starting point16_t */
   int16_t dx, dy;                       /* offset to ending point16_t */
   int16_t miny1, maxy1, minx1, maxx1;   /* bounding rectangle 1 */
   int16_t miny2, maxy2, minx2, maxx2;   /* bounding rectangle 2 */
   int16_t child1, child2;               /* Node or SSector (if high bit is set) */
   struct Node *node1, *node2;                /* pointer if the child is a Node */
   int16_t num;                          /* number given to this Node */
} Node;

typedef struct
{
   int16_t floorh;    /* floor height */
   int16_t ceilh;     /* ceiling height */
   char floort[8];/* floor texture */
   char ceilt[8]; /* ceiling texture */
   int16_t light;     /* light level (0-255) */
   int16_t special;   /* special behaviour (0 = normal, 9 = secret, ...) */
   int16_t tag;       /* sector activated by a linedef with the same tag */
} Sector;


/* object types */
#define OBJ_THINGS              1
#define OBJ_LINEDEFS            2
#define OBJ_SIDEDEFS            3
#define OBJ_VERTEXES            4
#define OBJ_SEGS                5
#define OBJ_SSECTORS            6
#define OBJ_NODES               7
#define OBJ_SECTORS             8
#define OBJ_REJECT              9
#define OBJ_BLOCKMAP            10

#endif /* wadfile_h */

/* Floor and ceiling textures */
typedef struct
{
    char name[8];
    char data[4096];
} Texture;
