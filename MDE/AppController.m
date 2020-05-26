//
//  AppController.m
//  MDE
//
//  Created by robert on 4/27/20.
//  Copyright © 2020 local. All rights reserved.
//

#import "AppController.h"

@implementation AppController

- (id)init {
    self = [super init];
    if (self) {
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self
               selector:@selector(handleMapViewChange:)
                   name:MDEMapViewChangedNotification
                 object:nil];
        NSLog(@"Registered with notification center");
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    // Drawing code here.
}

- (void)bark {
    printf("Bark!\n");
}

- (void)handleMapViewChange:(NSNotification *)note
{
    // update x/y values
    [viewPositionX setStringValue:[[note userInfo] objectForKey:@"vx"]];
    [viewPositionY setStringValue:[[note userInfo] objectForKey:@"vy"]];
    
}

- (IBAction)modeChanged:(id)sender {
    NSString *modeSetting = [modeSelect titleOfSelectedItem];
    
    if ([modeSetting isEqualToString:@"Pan"]) {
        [mv setEditMode:EDIT_MODE_PAN];
    } else if ([modeSetting isEqualToString:@"Things"]) {
        [mv setEditMode:EDIT_MODE_THINGS];
    } else if ([modeSetting isEqualToString:@"Vertexes"]) {
        [mv setEditMode:EDIT_MODE_VERTEXES];
    } else if ([modeSetting isEqualToString:@"LineDefs"]) {
        [mv setEditMode:EDIT_MODE_LINEDEFS];
    } else if ([modeSetting isEqualToString:@"SideDefs"]) {
        [mv setEditMode:EDIT_MODE_SIDEDEFS];
    } else if ([modeSetting isEqualToString:@"Sectors"]) {
        [mv setEditMode:EDIT_MODE_SECTORS];
    }
}

- (IBAction)zoomChanged:(id)sender {
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    [mv setZoomFactor:[f numberFromString:[zoomSelect titleOfSelectedItem]]];
}

- (void)windowDidResize:(NSNotification *)notification {
//    printf("windowDidResize\n");
}

- (NSSize)windowWillResize:(NSWindow *)sender toSize:(NSSize)frameSize {
//    printf("Window resized to %f tall by %f wide\n", frameSize.height, frameSize.width);
    return frameSize;
}

@end
