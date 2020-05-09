//
//  viewportThumbnail.m
//  MDE
//
//  Created by robert on 4/26/20.
//  Copyright © 2020 local. All rights reserved.
//

#import "ViewportThumbnail.h"

@implementation ViewportThumbnail {
    int viewportX, viewportY; // the upper left corner of the viewport/MapView
    float mapViewWidth, mapViewHeight; // the size of the MapView
    float thumbnailHeight, thumbnailWidth; // the thumbnail's view size, must be equal
    float zoomFactor;
    float scale; // originally was going to be 65536 / 128 = 512
}

- (void)awakeFromNib {
    NSRect thumbnailRect = [self bounds];
    thumbnailHeight = thumbnailRect.size.height;
    thumbnailWidth = thumbnailRect.size.width;
    scale = 65536 / thumbnailWidth;
}

- (void) drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    [[NSColor grayColor] setFill];
    NSRectFill(self.bounds);
        
    NSRect viewportLocation =
        NSMakeRect(((thumbnailWidth / 2) + viewportX) / scale, ((thumbnailHeight / 2) + viewportY) / scale,
                   (mapViewWidth * zoomFactor) / scale, (mapViewHeight * zoomFactor) / scale);

    [[NSColor selectedControlColor] set];
    NSRectFill(viewportLocation);
}

@end
