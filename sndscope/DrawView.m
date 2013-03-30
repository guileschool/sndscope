//
//  DrawView.m
//  sndscope
//
//  Created by Nico Kreipke on 29.03.13.
//  Copyright (c) 2013 Nico Kreipke. All rights reserved.
//

#import "DrawView.h"

#define DISPLAY_RESOLUTION 4

#define INTERFACE_COLOR colorWithDeviceRed:0.2 green:0.2 blue:1.0 alpha:1.0

#define DISPLAY_FONT @"Modern Dot Digital-7"
//included as dot.ttf

@implementation DrawView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

-(void)putr:(float)l r:(float)r {
//    NSRectFill(NSMakeRect(l, r, 2, 2));
    NSRectFillUsingOperation(NSMakeRect(l, r, DISPLAY_RESOLUTION, DISPLAY_RESOLUTION), NSCompositePlusLighter);
}

-(void)putstr:(NSString*)str pt:(NSPoint)pt {
    [str drawAtPoint:pt withAttributes:@{NSFontAttributeName: [NSFont fontWithName:DISPLAY_FONT size:20],
                              NSForegroundColorAttributeName: [NSColor INTERFACE_COLOR]}];
}

- (void)drawRect:(NSRect)dirtyRect
{
    [[NSColor blackColor] setFill];
    NSRectFill(dirtyRect);
    
    if (self.loading) {
        [self putstr:@"Loading" pt:NSMakePoint(10, 10)];
        return;
    }
    
    if (!self.fld) {
        return;
    }//1837
    
    [[NSColor INTERFACE_COLOR] setFill];
    
    int l = self.fllen / 2;//7348
//    printf("l = %i",l);
    [self putstr:[NSString stringWithFormat:@"~%@   pscale=%i   beams=%i",self.fileName,DISPLAY_RESOLUTION,l] pt:NSMakePoint(10, 10)];
    
    BOOL overload = NO;
    
    for (int i = 0; i < l; i++) {
        float rl = *(self.fld + (i*2));
        float rr = *(self.fld + (i*2) + 1);
        
        if (rl == 0 || rr == 0 || rl == 1 || rr == 1) {
            overload = YES;
        }
        
        int rlb = dirtyRect.origin.x + (dirtyRect.size.width * rl);
        int rrb = dirtyRect.origin.x + (dirtyRect.size.width * rr);
        [self putr:rlb r:rrb];
    }
    
    if (overload) {
        //file is clipped
//        [self putstr:@"OVERLOAD" pt:NSMakePoint(10, 30)];
    }
    
//    float rectl = dirtyRect.origin.x + (dirtyRect.size.width * self.lval);
//    float rectr = dirtyRect.origin.y + (dirtyRect.size.height * self.rval);
//    
//    
//    [[NSColor greenColor] setFill];
//    
//    NSRectFill(NSMakeRect(rectl, rectr, 1, 1));
}

@end
