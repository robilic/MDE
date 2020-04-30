//
//  AppController.m
//  MDE
//
//  Created by robert on 4/27/20.
//  Copyright © 2020 local. All rights reserved.
//

#import "AppController.h"

@implementation AppController

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

- (IBAction)zoomSlider:(id)sender {
    printf("Something happened with the zoom slider. %f\n", [zoomScaleSlider floatValue]);
    [mv durf];
    float zv = [zoomScaleSlider floatValue];
    if (zv == 1) {
        zv = 0.25;
    } else if (zv == 2) {
        zv = 0.5;
    } else if (zv == 3) {
        zv = 0.75;
    } else if (zv == 4) {
        zv = 1.0;
    } else if (zv == 5) {
        zv = 1.5;
    } else if (zv == 6) {
        zv = 2.0;
    } else if (zv == 7) {
        zv = 2.5;
    } else if (zv == 8) {
        zv = 3.0;
    } else if (zv == 9) {
        zv = 5.0;
    }
    NSNumber *zoomFactor = [NSNumber numberWithFloat:zv];
    [mv setZoomFactor:zoomFactor];
    // numberwithFloat
    
    // Zoom levels: 0.25, 0.5, 0.75, 1.0, 1.5, 2.0, 2.5, 3.0, 4.0, 5.0, 8.0
    // Put a switch statement here...
}

@end
