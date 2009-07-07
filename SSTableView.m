//
//  SSTableView.m
//  GeoTag
//
//  Created by Marco S Hyman on 7/5/09.
//

#import "SSTableView.h"

@implementation SSTableView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here if needed in the future
    }
    return self;
}


/*
 * Select the row that the user right clicked on before passing the
 * event off to the super class for context menu processing.
 */
- (void) rightMouseDown: (NSEvent *) event
{
    NSLog(@"%@ received %@", self, NSStringFromSelector(_cmd));
    // figure out the row where the click occurred
    NSPoint eventLocation = [event locationInWindow];  
    NSPoint localPoint = [self convertPointFromBase: eventLocation];  
    NSInteger row = [self rowAtPoint: localPoint];
    NSLog(@"row %ld", (long) row);
    // select the row if it is not selected and selection is allowed
    // otherwise deselect the current row
    if (! [self isRowSelected: row]) {
	[self selectRowIndexes: [NSIndexSet indexSetWithIndex: row]
	  byExtendingSelection: NO];
	if (! [self isRowSelected: row])
	    [self deselectAll: self];
	[self reloadData];
    }
    [super rightMouseDown: event];
}


@end
