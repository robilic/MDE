//
//  MapView.h
//  MDE
//
//  Created by robert on 4/24/20.
//  Copyright © 2020 local. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define EDIT_MODE_PAN      0
#define EDIT_MODE_THINGS   1
#define EDIT_MODE_VERTEXES 2
#define EDIT_MODE_LINEDEFS 3
#define EDIT_MODE_SIDEDEFS 4
#define EDIT_MODE_SECTORS  5

NS_ASSUME_NONNULL_BEGIN

@interface MapView : NSView

- (BOOL) isFlipped;
- (void) durf;
- (void) setZoomFactor:(NSNumber *) zoomFactor;
- (void) setEditMode:(int) m;

@end

extern NSString *const MDEMapViewChangedNotification;
extern NSString *const MDEPropertiesPanelUpdatedNotification;

NS_ASSUME_NONNULL_END
