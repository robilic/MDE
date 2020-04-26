//
//  MapView.m
//  MDE
//
//  Created by robert on 4/24/20.
//  Copyright © 2020 local. All rights reserved.
//

#import "MapView.h"

#include "wadfile.h"

extern int linedefs_count;
extern int things_count;

extern Thing *things;
extern Vertex *vertexes;
extern LineDef *linedefs;
extern SideDef *sidedefs;

float c;

@implementation MapView {
    float zoomFactor;
    int16_t viewportX, viewportY; // upper left location of the viewport
}

- (BOOL) isFlipped
{
    return YES;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    // This next line sets the the current fill color parameter of the Graphics Context
    [[NSColor blackColor] setFill];
    // This next function fills a rect the same as dirtyRect with the current fill color of the Graphics Context.
    NSRectFill(dirtyRect);
    
    NSPoint start, end;
    int i;
    
    for (i = 0; i < linedefs_count; i++) {
        start = NSMakePoint((vertexes[linedefs[i].start].x/5)+200, (-vertexes[linedefs[i].start].y/5)-300);
        end   = NSMakePoint((vertexes[linedefs[i].end].x/5)+200, (-vertexes[linedefs[i].end].y/5)-300);
        c = 50 + (sidedefs[linedefs[i].sidedef1].sector * 2);
        //printf("%f %f ", c, c/256);
        [[NSColor colorWithDeviceRed:0.8 green:c/225 blue:c/256 alpha:1.0] set];
        [NSBezierPath strokeLineFromPoint:start toPoint:end];
    }

    NSRect t;
    NSBezierPath *path;
    
    for (i = 0; i < things_count; i++) {
        [[NSColor yellowColor] set];
        t = NSMakeRect((things[i].xpos/5)+200-3, (-things[i].ypos/5)-300-3, 6, 6);
        path = [NSBezierPath bezierPath];
        [path appendBezierPathWithOvalInRect: t];
        [path stroke];
    }
}
@end
