//
//  AppDelegate.m
//  sndscope
//
//  Created by Nico Kreipke on 29.03.13.
//  Copyright (c) 2013 Nico Kreipke. All rights reserved.
//

#import "AppDelegate.h"

#define FRAMERATE 24

#define DUR (1.0f/(float)FRAMERATE)

@implementation AppDelegate

-(void)load {
    NSOpenPanel *open = [NSOpenPanel openPanel];
    open.allowsMultipleSelection = NO;
    open.message = @"Please choose an audio file.";
    open.allowedFileTypes = [NSArray arrayWithObject:@"wav"];
    
    [open beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {
        if (result == NSFileHandlingPanelOKButton) {
            self.drawView.loading = YES;
            [self.drawView setNeedsDisplay:YES];
            
            path = [open.URL path];
            const char * cpath = [path cStringUsingEncoding:NSUTF8StringEncoding];
            
            self.drawView.fileName = [open.URL lastPathComponent];
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
                s = scope_load(cpath);
                
                if (s) {
                    NSLog(@"buflen: %i ... bufend: %i",s->buf_len, s->buf_end);
                    
                    
                    [self performSelectorOnMainThread:@selector(start) withObject:nil waitUntilDone:NO];
                } else {
                    [self performSelectorOnMainThread:@selector(error) withObject:nil waitUntilDone:NO];
                }
                
            });
            
            
        }
    }];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    
    [self load];
    

    
//    [self tick];
    
    //Testing:
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
//        for (;;) {
//            int a = 5;
//            int b = a * 4;
//            a = b;
//        }
//    });
    

    
}
- (IBAction)pushLoad:(id)sender {
    if (audio) {
        if ([audio isPlaying]) {
            [audio stop];
        }
        audio = nil;
    }
    if (self.timer) {
        if ([self.timer isValid]) {
            [self.timer invalidate];
        }
        self.timer = nil;
    }
    if (s) {
        scope_free(s);
        s = NULL;
    }
    [self load];
}
- (IBAction)pushReload:(id)sender {
    if (!audio) {
        NSBeep();
        return;
    }
    if (![audio isPlaying]) {
        NSBeep();
        return;
    }
    if (!s) {
        NSBeep();
        return;
    }
    //reloads your sound file when it is already playing
    [audio stop];
    [audio play];
    scope_start(s);
}

-(void)start {
    
    audio = [[NSSound alloc] initWithContentsOfFile:path byReference:NO];
    if (!audio) {
        NSLog(@"not playable");
    }
    [audio play];
    
    scope_start(s);
    
    
    self.timer = [NSTimer timerWithTimeInterval:DUR target:self selector:@selector(tick) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
}

-(void)error {
    NSAlert *al = [NSAlert alertWithMessageText:@"Could not open file." defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@"Check log messages."];
    [al runModal];
}

-(void)applicationWillTerminate:(NSNotification *)notification {
    [self.timer invalidate];
    if (s) {
        scope_free(s);
    }
    if (self.drawView.fld) {
        free(self.drawView.fld);
    }
    NSLog(@"freed");
}

-(void)tick {
    self.drawView.loading = NO;
    if (self.drawView.fld) {
        free(self.drawView.fld);
        self.drawView.fld = NULL;
    }
    float *data = NULL;
    int dlen;
    scope_getr(s, &data, &dlen, DUR);
    if (data) {
        
        self.drawView.fld = data;
        self.drawView.fllen = dlen;
        [self.drawView setNeedsDisplay:YES];
    } else {
        NSLog(@"shutting down.");
        [self.timer invalidate];
        scope_free(s);
        s = NULL;
    }
//    scope_get(s, data);
//    if (data[0] >= -1.0f) {
//        float lval = data[0];
//        float rval = data[1];
//        self.drawView.lval = (1.0f + lval) / 2.0f;
//        self.drawView.rval = (1.0f + rval) / 2.0f;
//        [self.drawView setNeedsDisplay:YES];
//    }
    
//    NSLog(@"data: %f    %f",data[0],data[1]);
}


- (NSSize)windowWillResize:(NSWindow *)sender toSize:(NSSize)frameSize {
    if (frameSize.height == frameSize.width) {
        return frameSize;
    } else if (frameSize.height > frameSize.width) {
        return NSMakeSize(frameSize.width, frameSize.width);
    } else {
        return NSMakeSize(frameSize.height, frameSize.height);
    }
}

@end
