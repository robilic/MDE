//
//  AppController.h
//  MDE
//
//  Created by robert on 4/27/20.
//  Copyright © 2020 local. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#include "MapView.h"
#include "ViewportThumbnail.h"

NS_ASSUME_NONNULL_BEGIN

@interface AppController : NSView {
    IBOutlet MapView *mv;
    IBOutlet ViewportThumbnail *vt;
    IBOutlet NSButton *panButton;
    __weak IBOutlet NSPopUpButton *zoomSelect;
    __weak IBOutlet NSPopUpButtonCell *modeSelect;
    IBOutlet NSTextField *viewPositionX;
    IBOutlet NSTextField *viewPositionY;
    IBOutlet NSTabView *propertiesPanel;
    IBOutlet NSImageView *textureView;
    // Properties Panels
    
    // Vertexes
    IBOutlet NSTextField *vertexObjectID;
    IBOutlet NSTextField *vertexPositionX;
    IBOutlet NSTextField *vertexPositionY;
    
    // Things
    IBOutlet NSTextField *thingObjectID;
    IBOutlet NSTextField *thingX;
    IBOutlet NSTextField *thingY;
    IBOutlet NSTextField *thingType;
    IBOutlet NSTextField *thingAngle;
    IBOutlet NSTextField *thingAppears;
    
    // Lines
    IBOutlet NSTextField *lineID;
    IBOutlet NSTextField *lineFlags;
    IBOutlet NSTextField *lineType;
    IBOutlet NSTextField *lineSectorTag;
    IBOutlet NSTextField *lineVertexes;
    IBOutlet NSTextField *lineLength;
    // SideDef1
    IBOutlet NSTextField *lineSide1ID;
    IBOutlet NSTextField *lineSide1NormalTexture;
    IBOutlet NSTextField *lineSide1UpperTexture;
    IBOutlet NSTextField *lineSide1LowerTexture;
    IBOutlet NSTextField *lineSide1TextureOffsetX;
    IBOutlet NSTextField *lineSide1TextureOffsetY;
    IBOutlet NSTextField *lineSide1Sector;
    // SideDef2
    IBOutlet NSTextField *lineSide2ID;
    IBOutlet NSTextField *lineSide2NormalTexture;
    IBOutlet NSTextField *lineSide2UpperTexture;
    IBOutlet NSTextField *lineSide2LowerTexture;
    IBOutlet NSTextField *lineSide2TextureOffsetX;
    IBOutlet NSTextField *lineSide2TextureOffsetY;
    IBOutlet NSTextField *lineSide2Sector;
}

- (IBAction)zoomChanged:(id)sender;
- (IBAction)modeChanged:(id)sender;
- (IBAction)panClicked:(id)sender;

- (void)windowDidResize: (NSNotification *)notification;
- (NSSize)windowWillResize:(NSWindow *)sender toSize:(NSSize)frameSize;

@end

NS_ASSUME_NONNULL_END
