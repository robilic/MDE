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
    // float zoomFactor;
    int editMode;
    NSPoint lastMouse;
    int16_t viewportX, viewportY; // upper left location of the viewport
    float z;
    float c;
}

- (void)awakeFromNib {
    printf("AwakeFromNib()\n");
    z = 3;
    viewportX = viewportY = -1000;
    editMode = EDIT_MODE_PAN;
}

- (BOOL) isFlipped
{
    return YES;
}

- (void)durf {
    printf("Durf.\n");
}

- (void) setEditMode:(int) m {
    editMode = m;
}

- (void) setZoomFactor:(NSNumber *) zoomFactor {
    z = [zoomFactor floatValue];
    [self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)dirtyRect
{
    printf("Edit mode: %d\n", editMode);
    
    [super drawRect:dirtyRect];
    // This next line sets the the current fill color parameter of the Graphics Context
    [[NSColor blackColor] setFill];
    // This next function fills a rect the same as dirtyRect with the current fill color of the Graphics Context.
    NSRectFill(dirtyRect);
    
    NSPoint start, end;
    int i;
    // draw sidedefs
    for (i = 0; i < linedefs_count; i++) {
        start = NSMakePoint((vertexes[linedefs[i].start].x-viewportX) / z, (-vertexes[linedefs[i].start].y-viewportY) / z);
        end   = NSMakePoint((vertexes[linedefs[i].end].x-viewportX) / z, (-vertexes[linedefs[i].end].y-viewportY) / z);
        c = 50 + (sidedefs[linedefs[i].sidedef1].sector * 2);
        //printf("%f %f ", c, c/256);
        [[NSColor colorWithDeviceRed:0.8 green:c/225 blue:c/256 alpha:1.0] set];
        [NSBezierPath strokeLineFromPoint:start toPoint:end];
    }

    NSRect t;
    NSBezierPath *path;
    
    // draw vertexes
    for (i = 0; i < things_count; i++) {
        [[NSColor yellowColor] set];
        t = NSMakeRect(((things[i].xpos-viewportX)/z)-3, ((-things[i].ypos-viewportY)/z)-3, 6, 6);
        path = [NSBezierPath bezierPath];
        [path appendBezierPathWithOvalInRect: t];
        [path stroke];
    }
}

// Mouse events

- (void)mouseDown:(NSEvent *)theEvent
{
    switch (editMode) {
        case EDIT_MODE_PAN:
            //NSPoint pointInView = [self convertPoint:[theEvent locationInWindow] fromView:nil];
            lastMouse = [self convertPoint:[theEvent locationInWindow] fromView:nil];
            // subtract the difference from viewport coords to get new coords
            break;
    }
}

- (void)mouseDragged:(NSEvent *)theEvent
{
    NSPoint pointInView = [self convertPoint:[theEvent locationInWindow] fromView:nil];

    switch (editMode) {
        case EDIT_MODE_PAN:
            // ghetto scrolling
            viewportX = ceil(viewportX + (z*(lastMouse.x-pointInView.x)));
            viewportY = ceil(viewportY + (z*(lastMouse.y-pointInView.y)));
            //printf("viewport is at %d, %d\n", viewportX, viewportY);
            lastMouse = pointInView;
            break;
    }
    [self setNeedsDisplay:YES];
}

- (void)mouseUp:(NSEvent *)theEvent {
    // do we even need to do anything here?
}

@end
