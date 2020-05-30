//
//  MapView.m
//  MDE
//
//  Created by robert on 4/24/20.
//  Copyright © 2020 local. All rights reserved.
//

#import "MapView.h"

#include <math.h>

#include "wadfile.h"


extern int linedefs_count;
extern int things_count;

extern Thing *things;
extern Vertex *vertexes;
extern LineDef *linedefs;
extern SideDef *sidedefs;

float c;

NSString *const MDEMapViewChangedNotification = @"MDEMapViewChanged";;
NSNotificationCenter *nc;

@implementation MapView {
    // float zoomFactor;
    int editMode;
    NSPoint lastMouse;
    int16_t viewportX, viewportY; // upper left location of the viewport
    float z;
    float c;
}

- (void) awakeFromNib {
    printf("AwakeFromNib()\n");
    z = 3;
    viewportX = viewportY = -1000;
    editMode = EDIT_MODE_PAN;
    nc = [NSNotificationCenter defaultCenter];
}

- (void) viewDidMoveToWindow
{
    int options = NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways | NSTrackingInVisibleRect;
    NSTrackingArea *ta;
    ta = [[NSTrackingArea alloc] initWithRect:NSZeroRect
                                      options:options
                                        owner:self
                                     userInfo:nil];
    [self addTrackingArea:ta];
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

- (void) drawRect:(NSRect)dirtyRect
{
//    printf("Edit mode: %d\n", editMode);
    
    [super drawRect:dirtyRect];
    // This next line sets the the current fill color parameter of the Graphics Context
    [[NSColor blackColor] setFill];
    // This next function fills a rect the same as dirtyRect with the current fill color of the Graphics Context.
    NSRectFill(dirtyRect);
    
    NSPoint start, end;
    int i;
    // draw SIDEDEFS
    for (i = 0; i < linedefs_count; i++) {
        start = NSMakePoint((vertexes[linedefs[i].start].x-viewportX) / z, (-vertexes[linedefs[i].start].y-viewportY) / z);
        end   = NSMakePoint((vertexes[linedefs[i].end].x-viewportX) / z, (-vertexes[linedefs[i].end].y-viewportY) / z);
        c = 50 + (sidedefs[linedefs[i].sidedef1].sector * 2);
        //printf("%f %f ", c, c/256);
        [[NSColor colorWithDeviceRed:0.8 green:c/225 blue:c/256 alpha:1.0] set];
        [NSBezierPath strokeLineFromPoint:start toPoint:end];
    }
    
    // draw VERTEXES
    // NOT IMPLEMENTED
    
    // draw THINGS
    NSRect t;
    NSBezierPath *path;

    for (i = 0; i < things_count; i++) {
        [[NSColor yellowColor] set];
        t = NSMakeRect(((things[i].xpos-viewportX)/z)-3, ((-things[i].ypos-viewportY)/z)-3, 6, 6);
        path = [NSBezierPath bezierPath];
        [path appendBezierPathWithOvalInRect: t];
        [path stroke];
    }
    
    // draw highlighted entity
    // if MODE == "foo" ...
}

#pragma Mouse Events

- (void) mouseEntered:(NSEvent *)theEvent
{
    [[self window] setAcceptsMouseMovedEvents:YES];
    [[self window] makeFirstResponder:self];
}

- (void) mouseExited:(NSEvent *)theEvent
{
    [[self window] setAcceptsMouseMovedEvents:NO];
}

- (void) mouseMoved:(NSEvent *)theEvent
{
    static int lastXpos, lastYpos;
    int curXpos, curYpos;
    NSPoint pointInView = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    curXpos = round(pointInView.x);
    curYpos = round(pointInView.y);

    if ((curXpos == lastXpos) && (curYpos == lastYpos)) {
        // mouse didn't move far enough to matter
    } else {
        lastXpos = curXpos;
        lastYpos = curYpos;
        printf("Mouse is at coords %d, %d\n", curXpos, curYpos);
    }

    // check for entity under mouse cursor
}

- (void) mouseDown:(NSEvent *)theEvent
{
    NSPoint pointInView = [self convertPoint:[theEvent locationInWindow] fromView:nil];

    switch (editMode) {
        case EDIT_MODE_PAN:
            //NSPoint pointInView = [self convertPoint:[theEvent locationInWindow] fromView:nil];
            lastMouse = [self convertPoint:[theEvent locationInWindow] fromView:nil];
            // subtract the difference from viewport coords to get new coords
            break;
        default:
            printf("Mouse is at view coords: %f, %f\n", pointInView.x, pointInView.y); // x,y inside of mapview
            printf("Mouse is at level coords: %f, %f\n", viewportX + pointInView.x, viewportY + pointInView.y);
            break;
    }
}

- (void) mouseDragged:(NSEvent *)theEvent
{
    NSPoint pointInView = [self convertPoint:[theEvent locationInWindow] fromView:nil];

    switch (editMode) {
        case EDIT_MODE_PAN:
            // ghetto scrolling
            viewportX = ceil(viewportX + (z*(lastMouse.x-pointInView.x)));
            viewportY = ceil(viewportY + (z*(lastMouse.y-pointInView.y)));
            //printf("viewport is at %d, %d\n", viewportX, viewportY);
            lastMouse = pointInView;

            NSNumber *vx = [NSNumber numberWithInt:viewportX];
            NSNumber *vy = [NSNumber numberWithInt:viewportY];
            NSDictionary *d = [NSDictionary dictionaryWithObjectsAndKeys:vx, @"vx", vy, @"vy", nil];
            [nc postNotificationName:MDEMapViewChangedNotification
                              object:self
                            userInfo:d];
            
            //NSLog(@"Sending notification: %@", MDEMapViewChangedNotification);
            break;
    }
    [self setNeedsDisplay:YES];
    [self superview];
    
}

- (void) mouseUp:(NSEvent *)theEvent {
    // do we even need to do anything here?
}

@end
