//
//  AppDelegate.h
//  MDE
//
//  Created by robert on 4/21/20.
//  Copyright © 2020 local. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (weak) IBOutlet NSComboBox *zoomFactor;
@property (weak) IBOutlet NSTextField *viewportYLocation;
@property (weak) IBOutlet NSTextField *viewportXLocation;

@end

