//
//  LGSwipeableContentScrollView.m
//  
//
//  Created by Lionel on 29/01/14.
//
//

#import "LGSwipeableContentScrollView.h"

@implementation LGSwipeableContentScrollView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    // Fwd the event to the chain of responder so that the UITableViewCell content receives it.
    [self.nextResponder touchesBegan:touches withEvent:event];
}

-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    // Fwd the event to the chain of responder so that the UITableViewCell content receives it.
    [self.nextResponder touchesEnded:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.nextResponder touchesMoved:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.nextResponder touchesCancelled:touches withEvent:event];
}

@end
