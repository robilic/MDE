//
//  AppController.m
//  MDE
//
//  Created by robert on 4/27/20.
//  Copyright © 2020 local. All rights reserved.
//

#import "AppController.h"

#include "wadfile.h"

extern Texture *textures;
extern Palette *palette;

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

- (void)panClicked:(id)sender {
    printf("Bark!\n");

}

- (void)fooClicked:(id)sender {
    printf("Bark!\n");
    
    NSImage *image;
    int width, height;
    width = height = 64;
    int sourceLength = 4096; // source is indexed 8-bit color
    size_t bufferLength = width * height * 4;
     
    // step through image data 64x64
    // create 4 bpp version using palette
    // data = malloc(32*4096)
    //
    unsigned char *data;
    data = malloc(sizeof(unsigned char) * 4 * 4096);
    int idx;
    for (int i = 0; i < 4096; i++) {
        idx = i * 4;
        data[idx + 0] = palette[textures[27].data[i]].r;
        data[idx + 1] = palette[textures[27].data[i]].g;
        data[idx + 2] = palette[textures[27].data[i]].b;
        data[idx + 3] = 255; // alpha
    }
     
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, data, bufferLength, NULL);
    size_t bitsPerComponent = 8;
    size_t bitsPerPixel = 32;
    size_t bytesPerRow = 4 * width;
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedLast;
    CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;

    CGImageRef iref = CGImageCreate(width,
                                    height,
                                    bitsPerComponent,
                                    bitsPerPixel,
                                    bytesPerRow,
                                    colorSpaceRef,
                                    bitmapInfo,
                                    provider,   // data provider
                                    NULL,       // decode
                                    NO,        // should interpolate
                                    renderingIntent);

    image = [[NSImage alloc] initWithCGImage:iref size:NSMakeSize(width, height)];
    [textureView setImage:image];
    
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
