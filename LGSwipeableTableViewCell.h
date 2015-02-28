//
//  LGSwipeableTableViewCell.h
// 
//
//  Created by Lionel GUEGANTON on 8/07/14.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, LGSwipeDirection)  {
    LGSwipeDirectionNone,
    LGSwipeDirectionLeft,
    LGSwipeDirectionRight
};

@class LGSwipeableTableViewCell;

@protocol LGSwipeableTableViewCellDelegate <NSObject>
-(void) swipeableTableViewCellDidBeginDragging:(LGSwipeableTableViewCell*)swipeableCell;
@optional
-(void) swipeableTableViewCell:(LGSwipeableTableViewCell*)swipeableCell isSwipingToOffset:(NSInteger)swipeOffset;
-(void) swipeableTableViewCellDidExpand:(LGSwipeableTableViewCell*)swipeableCell;
-(void) swipeableTableViewCellDidCollapse:(LGSwipeableTableViewCell*)swipeableCell;
@end

/**
 +-------------+
 |
 |             |
 +-------------+
 */
@interface LGSwipeableTableViewCell : UITableViewCell <UIScrollViewDelegate> {
    IBOutlet UIView* _rightSwipeActionView;
    IBOutlet UIView* _leftSwipeActionsView;
    IBOutlet UIView* _swipeableContentView;
    UIScrollView* _scrollView;
    
    CGPoint _offsetLeftSwiped;
    CGPoint _offsetRightSwiped;
    CGPoint _offsetIdle;
    
    LGSwipeDirection _state;
    
    /** If at the end of the drag, the velocity is not fast enough, setting this flag to
     `YES` will trigger an animation to make the scrollView go until the proper content offset. */ 
    BOOL _shouldFinishDragProperly;
    
    id<LGSwipeableTableViewCellDelegate> _swipeDelegate;
}

@property (readwrite) LGSwipeDirection state;

@property (readwrite, retain) UIView* rightSwipeActionView;

@property (readwrite, retain) UIView* leftSwipeActionsView;

@property (readwrite, retain) UIView* swipeableContentView;

@property (readwrite, assign) id<LGSwipeableTableViewCellDelegate> swipeDelegate;

@end