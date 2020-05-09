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
    IBOutlet NSTextField *viewportXlabel, *viewportYlabel;
    IBOutlet MapView *mv;
    IBOutlet ViewportThumbnail *vt;
    __weak IBOutlet NSPopUpButton *zoomSelect;
    __weak IBOutlet NSPopUpButtonCell *modeSelect;
}

- (IBAction)zoomChanged:(id)sender;
- (IBAction)modeChanged:(id)sender;

- (void)windowDidResize: (NSNotification *)notification;
- (NSSize)windowWillResize:(NSWindow *)sender toSize:(NSSize)frameSize;



@end

NS_ASSUME_NONNULL_END
