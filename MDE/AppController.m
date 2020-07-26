//
//  AppController.m
//  MDE
//
//  Created by robert on 4/27/20.
//  Copyright © 2020 local. All rights reserved.
//

#import "AppController.h"

#include <stdlib.h>

#include "wadfile.h"

extern Texture *textures;
extern Palette *palette;
extern Sprite *sprites;
extern unsigned char **sprite_images;
extern int TARGET_SPRITE;
extern int sprites_count;

@implementation AppController

- (id)init {
    self = [super init];
    if (self) {
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self
               selector:@selector(handleMapViewChange:)
                   name:MDEMapViewChangedNotification
                 object:nil];

        [nc addObserver:self
               selector:@selector(handlePropertiesPanelChange:)
                   name:MDEPropertiesPanelUpdatedNotification
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
    // this code shows a sprite
    printf("Bark!\n");

    int SPR;
    // SPR = TARGET_SPRITE;
    int nMin = 1;
    int nMax = sprites_count;
    SPR = rand() % (nMax - nMin) + nMin;
    
    NSImage *image;
    int width, height;
    width = sprites[SPR].height;
    height = sprites[SPR].width;
    
    int pixel_count = width * height; // source is indexed 8-bit color
    int bpp = 4;
    size_t bufferLength = pixel_count * bpp;
    
    printf("panClicked - sprite %d, width %d, height %d, pixel_count %d\n", SPR, width, height, pixel_count);
     
    // step through image data 64x64
    // create 4 bpp version using palette

    unsigned char *data;
    data = malloc(sizeof(unsigned char) * bufferLength);
    int idx;
    for (int i = 0; i < pixel_count; i++) {
        idx = i * 4;
        data[idx + 0] = palette[sprite_images[SPR][i]].r;
        data[idx + 1] = palette[sprite_images[SPR][i]].g;
        data[idx + 2] = palette[sprite_images[SPR][i]].b;
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
                                    provider,
                                    NULL,
                                    NO,
                                    renderingIntent);

    image = [[NSImage alloc] initWithCGImage:iref size:NSMakeSize(width, height)];
    [textureView setImage:image];
}

- (void)fooClicked:(id)sender {
    // this code actually shows wall texture
    printf("Bark!\n");
    
    NSImage *image;
    int width, height;
    width = height = 64;
    size_t bufferLength = width * height * 4;
     
    // step through image data 64x64
    // create 4 bpp version using palette

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
                                    provider,
                                    NULL,
                                    NO,
                                    renderingIntent);

    image = [[NSImage alloc] initWithCGImage:iref size:NSMakeSize(width, height)];
    [textureView setImage:image];
    [[textureView layer] setMagnificationFilter:kCAFilterNearest];
    free(data);
}

- (void)handleMapViewChange:(NSNotification *)note
{
    // update x/y values
    [viewPositionX setStringValue:[[note userInfo] objectForKey:@"vx"]];
    [viewPositionY setStringValue:[[note userInfo] objectForKey:@"vy"]];
}

- (void)handlePropertiesPanelChange:(NSNotification *)note
{
    switch (mv.editMode) {
        case EDIT_MODE_PAN:
            break;
        case EDIT_MODE_THINGS: {
            [thingX setStringValue:[[note userInfo] objectForKey:@"tx"]];
            [thingY setStringValue:[[note userInfo] objectForKey:@"ty"]];
            [thingType setStringValue:[[note userInfo] objectForKey:@"ttype"]];
            [thingAngle setStringValue:[[note userInfo] objectForKey:@"tangle"]];
            [thingAppears setStringValue:[[note userInfo] objectForKey:@"twhen"]];
            [thingObjectID setStringValue:[[note userInfo] objectForKey:@"tid"]];
            break;
        }
        case EDIT_MODE_VERTEXES: {
            [vertexPositionX setStringValue:[[note userInfo] objectForKey:@"vx"]];
            [vertexPositionY setStringValue:[[note userInfo] objectForKey:@"vy"]];
            [vertexObjectID setStringValue:[[note userInfo] objectForKey:@"vid"]];
            break;
        }
        case EDIT_MODE_LINEDEFS: {
            [lineID setStringValue:[[note userInfo] objectForKey:@"lid"]];
            [lineVertexes setStringValue:[[note userInfo] objectForKey:@"lvertexes"]];
            [lineFlags setStringValue:[[note userInfo] objectForKey:@"lflags"]];
            [lineType setStringValue:[[note userInfo] objectForKey:@"ltype"]];
            [lineSectorTag setStringValue:[[note userInfo] objectForKey:@"lsectortag"]];
            [lineSide1ID setStringValue:[[note userInfo] objectForKey:@"lsidedef1"]];
            [lineSide2ID setStringValue:[[note userInfo] objectForKey:@"lsidedef2"]];
            break;
        }
        default: {
            break;
        }
    }

}

- (IBAction)modeChanged:(id)sender {
    NSString *modeSetting = [modeSelect titleOfSelectedItem];
    
    if ([modeSetting isEqualToString:@"Pan"]) {
        [mv setEditMode:EDIT_MODE_PAN];
    } else if ([modeSetting isEqualToString:@"Things"]) {
        mv.editMode = EDIT_MODE_THINGS;
        [propertiesPanel selectTabViewItemWithIdentifier:@"Things"];
    } else if ([modeSetting isEqualToString:@"Vertexes"]) {
        mv.editMode = EDIT_MODE_VERTEXES;
        [propertiesPanel selectTabViewItemWithIdentifier:@"Vertexes"];
    } else if ([modeSetting isEqualToString:@"LineDefs"]) {
        mv.editMode = EDIT_MODE_LINEDEFS;
        [propertiesPanel selectTabViewItemWithIdentifier:@"Lines"];
     } else if ([modeSetting isEqualToString:@"Sectors"]) {
        [propertiesPanel selectTabViewItemWithIdentifier:@"Sectors"];
        mv.editMode = EDIT_MODE_SECTORS;
    }
    NSLog(@"val: %d", mv.editMode);
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
