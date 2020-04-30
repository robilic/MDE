//
//  MapView.h
//  MDE
//
//  Created by robert on 4/24/20.
//  Copyright © 2020 local. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface MapView : NSView

- (BOOL) isFlipped;
- (void) durf;
- (void) setZoomFactor:(NSNumber *) zoomFactor;

@end

NS_ASSUME_NONNULL_END
