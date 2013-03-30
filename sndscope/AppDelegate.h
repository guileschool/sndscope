//
//  AppDelegate.h
//  sndscope
//
//  Created by Nico Kreipke on 29.03.13.
//  Copyright (c) 2013 Nico Kreipke. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "sndscope.h"
#import "DrawView.h"

@interface AppDelegate : NSObject <NSApplicationDelegate, NSWindowDelegate> {
    scope_t *s;
    NSSound *audio;
    NSString *path;
}

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet DrawView *drawView;

@property (strong) NSTimer *timer;

@end
