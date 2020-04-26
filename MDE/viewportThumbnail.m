//
//  viewportThumbnail.m
//  MDE
//
//  Created by robert on 4/26/20.
//  Copyright © 2020 local. All rights reserved.
//

#import "ViewportThumbnail.h"

@implementation ViewportThumbnail {
    int viewportX, viewportY;
    float zoomFactor;
}

- (void) drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];

   // This next line sets the the current fill color parameter of the Graphics Context
    [[NSColor grayColor] setFill];
   // This next function fills a rect the same as dirtyRect with the current fill color of the Graphics Context.
    NSRectFill(self.bounds);
    
    int thumbHeight, thumbWidth;
    thumbHeight = self.bounds.size.height;
    thumbWidth = self.bounds.size.width;
    
    NSRect viewportLocation = NSMakeRect(20,60, 40,40);
    [[NSColor selectedControlColor] set];
    NSRectFill(viewportLocation);
   // You might want to use _bounds or self.bounds if you want to be sure to fill the entire bounds rect of the view.
}

@end
