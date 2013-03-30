//
//  DrawView.h
//  sndscope
//
//  Created by Nico Kreipke on 29.03.13.
//  Copyright (c) 2013 Nico Kreipke. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface DrawView : NSView

@property float *fld;
@property int fllen;

@property BOOL loading;

@end
