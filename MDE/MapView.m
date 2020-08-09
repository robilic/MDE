//
//  MapView.m
//  MDE
//
//  Created by robert on 4/24/20.
//  Copyright © 2020 local. All rights reserved.
//

#import "MapView.h"

#include <math.h>
#include <stdlib.h>

#include "wadfile.h"
#include "deu_things.h"

extern int linedefs_count;
extern int things_count;
extern int vertexes_count;

extern Thing *things;
extern Vertex *vertexes;
extern LineDef *linedefs;
extern SideDef *sidedefs;

float c;

NSString *const MDEMapViewChangedNotification = @"MDEMapViewChanged";
NSString *const MDEPropertiesPanelUpdatedNotification = @"MDEPropertiesPanelUpdated";
NSNotificationCenter *nc;

@implementation MapView {
    NSPoint lastMouse;      // last recorded position of mouse
    int16_t viewportX, viewportY; // upper left location of the viewport
    float z;                // this is the zoom/scale setting...needs a new name
    float c;                // generic color variable until we find out 'smarter' colors
    int selectedObjectID;   // object which is currently selected
    int gridSize;
}

- (void) awakeFromNib {
    printf("AwakeFromNib()\n");
    z = 3;
    viewportX = viewportY = -1000;
    _editMode = EDIT_MODE_PAN;
    nc = [NSNotificationCenter defaultCenter];
    selectedObjectID = -1;
    gridSize = 64;
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

- (void) setZoomFactor:(NSNumber *) zoomFactor {
    z = [zoomFactor floatValue];
    [self setNeedsDisplay:YES];
}

- (void) drawRect:(NSRect)dirtyRect
{
    NSPoint start, end;
    [super drawRect:dirtyRect];

    // Draw background
    [[NSColor blackColor] setFill];
    NSRectFill(dirtyRect);
    
    float zoomedGridSize = (gridSize / z);
    // Draw grid
    int gridStartX, gridStartY;
    int gridOffsetX, gridOffsetY;
    
    gridOffsetX = viewportX % gridSize;
    gridOffsetY = viewportY % gridSize;

    NSRect viewRect = [self bounds];
    
    // this fixes the missing first grid squares when on the negative side of the map
    if (viewportX > 0) {
        gridStartX = (gridSize - gridOffsetX) / z;
    } else {
        gridStartX = ((gridSize - gridOffsetX) - gridSize) / z;
    }
    
    if (viewportY > 0) {
        gridStartY = (gridSize - gridOffsetY) / z;
    } else {
        gridStartY = ((gridSize - gridOffsetY) - gridSize) / z;
    }
    
    printf("viewPort: %d, %d, offsets: %d, %d, grid size: %d, view is %fx%f\n", viewportX, viewportY, gridOffsetX, gridOffsetY, gridSize, viewRect.size.width, viewRect.size.height);
    
    [[NSColor darkGrayColor] setStroke];
    NSBezierPath *path = [NSBezierPath bezierPath];
    
    for (int x = gridStartX; x < viewRect.size.width; x += zoomedGridSize) {
        [path moveToPoint:CGPointMake(x, 0)];
        [path lineToPoint:CGPointMake(x, viewRect.size.height)];
    }
    for (int y = gridStartY; y < viewRect.size.height; y += zoomedGridSize) {
        [path moveToPoint:CGPointMake(0, y)];
        [path lineToPoint:CGPointMake(viewRect.size.width, y)];
    }
    [path closePath];
    [path stroke];
    
    
    //[[NSColor blueColor] setStroke];
    
    // draw LINEDEFS
    for (int i = 0; i < linedefs_count; i++) {
        start = NSMakePoint((vertexes[linedefs[i].start].x-viewportX) / z, (vertexes[linedefs[i].start].y-viewportY) / z);
        end   = NSMakePoint((vertexes[linedefs[i].end].x-viewportX) / z, (vertexes[linedefs[i].end].y-viewportY) / z);
        c = 50 + (sidedefs[linedefs[i].sidedef1].sector * 2);
        //printf("%f %f ", c, c/256);
        [[NSColor colorWithDeviceRed:0.8 green:c/225 blue:c/256 alpha:1.0] set];
        [NSBezierPath strokeLineFromPoint:start toPoint:end];
    }
    
    // draw VERTEXES
    NSRect v;
    NSBezierPath *vPath;

    for (int i = 0; i < vertexes_count; i++) {
        [[NSColor grayColor] set];
        v = NSMakeRect(((vertexes[i].x-viewportX)/z)-1, ((vertexes[i].y-viewportY)/z)-1, 2, 2);
        vPath = [NSBezierPath bezierPath];
        [vPath appendBezierPathWithOvalInRect: v];
        [vPath stroke];
    }
    // NOT IMPLEMENTED
    
    // draw THINGS
    NSRect highlight;
    //NSBezierPath *path;

    for (int i = 0; i < things_count; i++) {
        [[NSColor yellowColor] set];
        highlight = NSMakeRect(((things[i].xpos-viewportX)/z)-3, ((things[i].ypos-viewportY)/z)-3, 6, 6);
        path = [NSBezierPath bezierPath];
        [path appendBezierPathWithOvalInRect: highlight];
        [path stroke];
    }
    
    // draw highlighted entity
    // if MODE == "foo" ...
    if (selectedObjectID > -1) {
        switch (_editMode) {
            case EDIT_MODE_THINGS:
                [[NSColor cyanColor] set];
                highlight = NSMakeRect(((things[selectedObjectID].xpos-viewportX)/z)-5, ((things[selectedObjectID].ypos-viewportY)/z)-5, 10, 10);
                path = [NSBezierPath bezierPath];
                [path appendBezierPathWithOvalInRect: highlight];
                [path stroke];
                break;
            case EDIT_MODE_VERTEXES:
                [[NSColor cyanColor] set];
                highlight = NSMakeRect(((vertexes[selectedObjectID].x-viewportX)/z)-3, ((vertexes[selectedObjectID].y-viewportY)/z)-3, 6, 6);
                path = [NSBezierPath bezierPath];
                [path appendBezierPathWithOvalInRect: highlight];
                [path stroke];
                break;
            case EDIT_MODE_LINEDEFS:
                start = NSMakePoint((vertexes[linedefs[selectedObjectID].start].x-viewportX) / z, (vertexes[linedefs[selectedObjectID].start].y-viewportY) / z);
                end   = NSMakePoint((vertexes[linedefs[selectedObjectID].end].x-viewportX) / z, (vertexes[linedefs[selectedObjectID].end].y-viewportY) / z);
                [[NSColor colorWithDeviceRed:0 green:255 blue:255 alpha:1.0] set];
                [NSBezierPath strokeLineFromPoint:start toPoint:end];
            default:
                break;
        }
    }
}

- (void) updatePropertiesPanel
{
    switch (_editMode) {
        case EDIT_MODE_PAN:
            break;
        case EDIT_MODE_THINGS: {
            NSNumber *tx = [NSNumber numberWithInt:things[selectedObjectID].xpos];
            NSNumber *ty = [NSNumber numberWithInt:things[selectedObjectID].ypos];
            NSString *tangle = [NSString stringWithUTF8String:deu_GetAngleName(things[selectedObjectID].angle)];
            NSString *ttype = [NSString stringWithUTF8String:deu_GetThingName(things[selectedObjectID].type)];
            NSString *twhen = [NSString stringWithUTF8String:deu_GetWhenName(things[selectedObjectID].when)];
            NSNumber *tid = [NSNumber numberWithInt:selectedObjectID];

            NSDictionary *d = [NSDictionary dictionaryWithObjectsAndKeys:tx, @"tx", ty, @"ty", tangle, @"tangle", ttype, @"ttype", twhen, @"twhen", tid, @"tid", nil];
            [nc postNotificationName:MDEPropertiesPanelUpdatedNotification
                              object:self
                            userInfo:d];
            break;
        }
        case EDIT_MODE_VERTEXES: {
            NSNumber *vx = [NSNumber numberWithInt:vertexes[selectedObjectID].x];
            NSNumber *vy = [NSNumber numberWithInt:vertexes[selectedObjectID].y];
            NSNumber *vid = [NSNumber numberWithInt:selectedObjectID];
            
            NSDictionary *d = [NSDictionary dictionaryWithObjectsAndKeys:vx, @"vx", vy, @"vy", vid, @"vid", nil];
            [nc postNotificationName:MDEPropertiesPanelUpdatedNotification
                              object:self
                            userInfo:d];
            break;
        }
        case EDIT_MODE_LINEDEFS: {
            NSString *lvertexes = [NSString stringWithFormat:@"%d, %d", linedefs[selectedObjectID].start, linedefs[selectedObjectID].end];
            NSNumber *lflags = [NSNumber numberWithInt:linedefs[selectedObjectID].flags];
            NSNumber *ltype = [NSNumber numberWithInt:linedefs[selectedObjectID].type];
            NSNumber *lsectortag = [NSNumber numberWithInt:linedefs[selectedObjectID].tag];
            NSNumber *lsidedef1 = [NSNumber numberWithInt:linedefs[selectedObjectID].sidedef1];
            NSNumber *lsidedef2 = [NSNumber numberWithInt:linedefs[selectedObjectID].sidedef2];
            NSNumber *lid = [NSNumber numberWithInt:selectedObjectID];

            NSDictionary *d = [NSDictionary dictionaryWithObjectsAndKeys:lid, @"lid", lvertexes, @"lvertexes", lflags, @"lflags", ltype, @"ltype", lsectortag, @"lsectortag", lsidedef1, @"lsidedef1", lsidedef2, @"lsidedef2", nil];
            [nc postNotificationName:MDEPropertiesPanelUpdatedNotification
                              object:self
                            userInfo:d];
            break;
        }
        default: {
            break;
        }
    }
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
    // we have WINDOW coords and we have LEVEL coords....
    
    curXpos = round(pointInView.x);
    curYpos = round(pointInView.y);

    if ((curXpos == lastXpos) && (curYpos == lastYpos)) {
        // mouse didn't move far enough to matter
    } else {
        lastXpos = curXpos;
        lastYpos = curYpos;
    }
    // calc level coords
    // move these to structs....
    int cursorLevelPosX = viewportX + (curXpos * z);
    int cursorLevelPosY = viewportY + (curYpos * z);
    
    int thing_hit_radius = 5 * z;
    int vertex_hit_radius = 3 * z;

    switch (_editMode) {
        case EDIT_MODE_PAN:
//            printf("Mouse is at coords %d, %d\n", curXpos, curYpos);
            break;
        case EDIT_MODE_THINGS:
            for (int i = 0; i < things_count; i++) {
                if ((cursorLevelPosX > things[i].xpos - thing_hit_radius) && (cursorLevelPosX < things[i].xpos + thing_hit_radius)) {
                    if ((cursorLevelPosY > things[i].ypos - thing_hit_radius) && (cursorLevelPosY < things[i].ypos + thing_hit_radius)) {
                        //printf("Mouse hit on thing %d, type = %x (%d), attributes = %x\n", i, things[i].type, things[i].type, things[i].when);
                        selectedObjectID = i;
                        [self updatePropertiesPanel];
                        [self setNeedsDisplay:YES];
                    }
                }
            }
            break;
        case EDIT_MODE_VERTEXES:
            for (int i = 0; i < vertexes_count; i++) {
                if ((cursorLevelPosX > vertexes[i].x - vertex_hit_radius) && (cursorLevelPosX < vertexes[i].x + vertex_hit_radius)) {
                    if ((cursorLevelPosY > vertexes[i].y - vertex_hit_radius) && (cursorLevelPosY < vertexes[i].y + vertex_hit_radius)) {
                        //printf("Mouse hit on thing %d, x:%d, y:%d\n", i, vertexes[i].x, vertexes[i].y);
                        selectedObjectID = i;
                        [self updatePropertiesPanel];
                        [self setNeedsDisplay:YES];
                    }
                }
            }
            break;
        case EDIT_MODE_LINEDEFS: {
            for (int i = 0; i < linedefs_count; i++) {
                if (hitDetectLine(i, cursorLevelPosX, cursorLevelPosY)) {
                    printf("Hit on line %d\n", i);
                    selectedObjectID = i;
                    [self updatePropertiesPanel];
                    [self setNeedsDisplay:YES];
                }
            }
        }
            break;
        default:
            break;
    }
}

- (void) mouseDown:(NSEvent *)theEvent
{
    lastMouse = [self convertPoint:[theEvent locationInWindow] fromView:nil];
}

- (void) mouseDragged:(NSEvent *)theEvent
{
    NSPoint pointInView = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    switch (_editMode) {
        case EDIT_MODE_PAN:
        {
            // "scrolling"
            viewportX = round(viewportX + (z*(lastMouse.x-pointInView.x)));
            viewportY = round(viewportY + (z*(lastMouse.y-pointInView.y)));
            //printf("viewport is at %d, %d\n", viewportX, viewportY);
            lastMouse = pointInView;

            NSNumber *vx = [NSNumber numberWithInt:viewportX];
            NSNumber *vy = [NSNumber numberWithInt:viewportY];
            NSDictionary *d = [NSDictionary dictionaryWithObjectsAndKeys:vx, @"vx", vy, @"vy", nil];
            [nc postNotificationName:MDEMapViewChangedNotification
                              object:self
                            userInfo:d];
            break;
        }
        case EDIT_MODE_THINGS:
        {
            if (selectedObjectID > -1) {
                printf("Started drag of THING %d at %d, %d, dragging to %d, %d\n", selectedObjectID, things[selectedObjectID].xpos, things[selectedObjectID].ypos, viewportX + (int)pointInView.x, viewportY + (int)pointInView.y);
                things[selectedObjectID].xpos = viewportX + (int)(z*pointInView.x);
                things[selectedObjectID].ypos = viewportY + (int)(z*pointInView.y);
                [self updatePropertiesPanel];
                [self setNeedsDisplay:YES];
            }
            break;
        }
        case EDIT_MODE_VERTEXES:
        {
            if (selectedObjectID > -1) {
                printf("Started drag of THING %d at %d, %d, dragging to %d, %d\n", selectedObjectID, vertexes[selectedObjectID].x, vertexes[selectedObjectID].y, viewportX + (int)pointInView.x, viewportY + (int)pointInView.y);
                vertexes[selectedObjectID].x = viewportX + (int)(z*pointInView.x);
                vertexes[selectedObjectID].y = viewportY + (int)(z*pointInView.y);
                [self updatePropertiesPanel];
                [self setNeedsDisplay:YES];
            }
            break;
        }
        case EDIT_MODE_LINEDEFS:
        {
            if (selectedObjectID > -1) {
                vertexes[linedefs[selectedObjectID].start].x += (int)(z*(pointInView.x-lastMouse.x));
                vertexes[linedefs[selectedObjectID].start].y += (int)(z*(pointInView.y-lastMouse.y));
                vertexes[linedefs[selectedObjectID].end].x += (int)(z*(pointInView.x-lastMouse.x));
                vertexes[linedefs[selectedObjectID].end].y += (int)(z*(pointInView.y-lastMouse.y));
                [self updatePropertiesPanel];
                [self setNeedsDisplay:YES];
            }
            break;
        }
        default:
        {
            break;
        }
    }
    [self setNeedsDisplay:YES];
    [self superview];
    lastMouse = pointInView;
}

#pragma Utilities

double pointDistance(int x1, int y1, int x2, int y2)
{
    // calculate the hypotenuse to find the distance
    return sqrt(pow(x2 - x1, 2) + pow(y2 - y1, 2));
}

int hitDetectLine(int line, int testx, int testy)
{
    double buffer = 3; // how close we must be to being on in the line
    double d1 = pointDistance(testx, testy, vertexes[linedefs[line].end].x, vertexes[linedefs[line].end].y);
    double d2 = pointDistance(testx, testy, vertexes[linedefs[line].start].x, vertexes[linedefs[line].start].y);
    double ll = pointDistance(vertexes[linedefs[line].end].x, vertexes[linedefs[line].end].y, vertexes[linedefs[line].start].x, vertexes[linedefs[line].start].y);
    
    if (d1 + d2 >= ll - buffer && d1 + d2 <= ll + buffer) {
        return true;
    } else {
        return false;
    }
}

@end
