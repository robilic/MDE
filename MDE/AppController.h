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
    IBOutlet NSSlider *zoomScaleSlider;
    IBOutlet MapView *mv;
    IBOutlet ViewportThumbnail *vt;
}

- (IBAction)zoomSlider:(id)sender;

@end

NS_ASSUME_NONNULL_END
