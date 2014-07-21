//
//  LGSwipeableTableViewCell.m
// 
//
//  Created by Lionel GUEGANTON on 8/07/14.
//

#import "LGSwipeableTableViewCell.h"
#import "LGSwipeableContentScrollView.h"

#define kRequiredOffsetBeforeExpanding 50
#define kRequiredOffsetBeforeCollapsing 50

@implementation LGSwipeableTableViewCell

@synthesize delegate = _delegate;
@synthesize swipeableContentView = _swipeableContentView;

-(id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	if (self ) {
        [self initCommon];
    }
	return self;
}

-(instancetype) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initCommon];
    }
    return self;
}

-(void) initCommon {
    self.selectionStyle=UITableViewCellSelectionStyleNone;
    _enabledSwipeDirection  = LGSwipeDirectionLeft;
    
    CGFloat width = 320;
    CGFloat height = 60;
    
    CGRect frame = CGRectMake(0, 0, width, height);
    _scrollView = [[LGSwipeableContentScrollView alloc] initWithFrame:frame];
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.canCancelContentTouches = YES;
    _scrollView.scrollsToTop = NO;
    _scrollView.delaysContentTouches = YES;
    
    if (!_swipeableContentView)
        _swipeableContentView = [[self createContentViewForFrame:frame] retain];
    
    _scrollView.delegate = self;
    [self setActionsView:_actionsView];
    if (_swipeableContentView)
        [_scrollView addSubview:_swipeableContentView];
    [self.contentView addSubview:_scrollView];
}

-(void) dealloc {
	[_swipeableContentView release];
    _swipeableContentView = nil;
    _delegate = nil;
	[super dealloc];
}

/**
 Adjust expanded / Collapsed offset based on the given actionView + UIView hierarchy
 */
-(void) setActionsView:(UIView *)actionsView {
    if (actionsView) {
        [actionsView retain];
        [_actionsView removeFromSuperview];
        [_actionsView release];
        _actionsView = actionsView;
        if (_enabledSwipeDirection==LGSwipeDirectionRight) {
            _offsetCollapsed = CGPointMake(_actionsView.frame.size.width,0);
            _offsetExpanded = CGPointMake(0, 0);
        } else {
            _offsetCollapsed = CGPointMake(0, 0);
            _offsetExpanded = CGPointMake(_actionsView.frame.size.width,0);
            // right align the actions on the contentView.
            _actionsView.frame = CGRectMake(self.contentView.frame.size.width-_actionsView.frame.size.width, 0, _actionsView.frame.size.width, _actionsView.frame.size.height);
        }
        _scrollView.contentSize = CGSizeMake(_actionsView.frame.size.width+320, 60);
        [self.contentView insertSubview:_actionsView atIndex:0];
    }
}

-(UIView*) actionsView {
    return _actionsView;
}

-(void) awakeFromNib {
    [self setActionsView:_actionsView];
    if (_swipeableContentView)
        [_scrollView addSubview:_swipeableContentView];
}

-(UIView*) createContentViewForFrame:(CGRect)frame {
    return nil;
}

#pragma mark -

-(void) layoutSubviews {
	[super layoutSubviews];
    if (_enabledSwipeDirection==LGSwipeDirectionRight) {
        _swipeableContentView.frame = CGRectMake(_actionsView.frame.size.width, 0, 320, self.frame.size.height);
        // left align the actions on the contentView.
        _actionsView.frame = CGRectMake(0, 0, _actionsView.frame.size.width, self.frame.size.height);
    } else {
        _swipeableContentView.frame = CGRectMake(0, 0, _swipeableContentView.frame.size.width, self.frame.size.height);
        // right align the actions on the contentView.
        _actionsView.frame = CGRectMake(self.contentView.frame.size.width-_actionsView.frame.size.width, 0, _actionsView.frame.size.width, _actionsView.frame.size.height);
    }
    _scrollView.frame = CGRectMake(0, 0, 320, self.frame.size.height);
    _scrollView.contentOffset = _offsetCollapsed;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    //NSLog(@"[LGSwipeableTableViewCell] scrollView willBeginDragging");
    [_delegate swipeableTableViewCellDidBeginDragging:self];
    _shouldFinishDragProperly = NO;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    //NSLog(@"scroll view content offset : %@", NSStringFromCGPoint(scrollView.contentOffset));
    // Force the offset so that a swipe in the direction opposite to the configured one is impossible.
    if ((_enabledSwipeDirection==LGSwipeDirectionRight && scrollView.contentOffset.x>_offsetCollapsed.x) ||
        (_enabledSwipeDirection==LGSwipeDirectionLeft && scrollView.contentOffset.x<_offsetCollapsed.x))
        scrollView.contentOffset = _offsetCollapsed;
    
    BOOL isExpanded = CGPointEqualToPoint(scrollView.contentOffset, _offsetExpanded);
    BOOL isCollapsed = CGPointEqualToPoint(scrollView.contentOffset, _offsetCollapsed);
    if ((isExpanded && !_expanded) || (isCollapsed && _expanded)) {
        if (isExpanded)
            _expanded = YES;
        else if (isCollapsed)
            _expanded = NO;
        if (_expanded)
            [_delegate swipeableTableViewCellDidExpand:self];
        else
            [_delegate swipeableTableViewCellDidCollapse:self];
    }
    //NSLog(@"ScrollView expanded %@ %@", NSStringFromCGPoint(scrollView.contentOffset), _expanded?@"YES":@"NO");
}


-(void) scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    // once the drag is ended, we keep the contentOffset where it ended, the rest of the
    // scroll animation is handled by the expand / collapse.
    //NSLog(@"[LGSwipeableTableViewCell] scrollView willEndDragging velocity:%@ targetContentOffset:%@", NSStringFromCGPoint(velocity), NSStringFromCGPoint(*targetContentOffset));
    // if the velocity is not big enough, we stop the current scroll and will handover the animation
    // on ourselves (set the flag _shouldFinishDragProperly to YES) .
    if (fabsf(velocity.x)<1.5) {
        // Stops the current scroll movement
        *targetContentOffset = CGPointMake(_scrollView.contentOffset.x, _scrollView.contentOffset.y);
        _shouldFinishDragProperly = YES;
    }
}

-(void) scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    //NSLog(@"[LGSwipeableTableViewCell] did end dragging @%@[decelerate:%@] shouldFinishDragProperly:%@", NSStringFromCGPoint(scrollView.contentOffset), (decelerate)?@"YES":@"NO", _shouldFinishDragProperly?@"YES":@"NO");
    if(_shouldFinishDragProperly) {
        if (!_expanded) {
            CGFloat distanceToCollapsed = abs(scrollView.contentOffset.x - _offsetCollapsed.x);  
            BOOL shouldBeExpanded = distanceToCollapsed >= kRequiredOffsetBeforeExpanding;
            //NSLog(@"[LGSwipeableTableViewCell] the cell should be expanded %@", shouldBeExpanded?@"YES":@"NO");
            [self setExpanded:shouldBeExpanded];
        } else {
            BOOL shouldBeCollapsed = scrollView.contentOffset.x> kRequiredOffsetBeforeCollapsing;
            //NSLog(@"[LGSwipeableTableViewCell] the cell should be collapsed %@", shouldBeCollapsed?@"YES":@"NO");
            [self setExpanded:!shouldBeCollapsed];
        }
    }
}

#pragma mark -

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    //return [super hitTest:point withEvent:event];
    // are we in the transparent part of the scrollView ?
    CGFloat expandedWidth = abs(_scrollView.contentOffset.x - _offsetCollapsed.x);  
    
    //CGFloat expandedPartWidth = _offsetCollapsed.x - _scrollView.contentOffset.x;
    BOOL isInTransparentArea =  (_enabledSwipeDirection==LGSwipeDirectionRight && point.x < expandedWidth) ||
    (_enabledSwipeDirection==LGSwipeDirectionLeft && point.x > (self.contentView.frame.size.width-expandedWidth));
    //BOOL isInTransparentArea = CGRectContainsPoint(_actionsView.frame, point);
    if (isInTransparentArea) {
        //NSLog(@"this hit is relative to the actions");
        CGPoint p = [_actionsView convertPoint:point fromView:self.contentView];
        UIView* v = [_actionsView hitTest:p withEvent:event];
        return v;
    } else {
        UIView* returnedBySuper = [super hitTest:point withEvent:event];
        //NSLog(@"this hit is relative to the station cell %@", returnedBySuper);
        return returnedBySuper;
    }
    //NSLog(@"HIT TEST expanded width %f", expandedPartWidth);
    //return [super hitTest:point withEvent:event];
}

#pragma mark - Expanded handling
-(BOOL) expanded {
    return _expanded;
}

-(void) setExpanded:(BOOL)expanded {
    if (expanded ) {
        [UIView animateWithDuration:0.2
                              delay:0
                            options:UIViewAnimationCurveEaseOut
                         animations:^{
                             [_scrollView setContentOffset:_offsetExpanded animated:NO];
                         } completion:nil];
        /*
         // iOS 7 only
         [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.4 initialSpringVelocity:0.5 options:UIViewAnimationOptionCurveEaseIn animations:^{
            [_scrollView setContentOffset:expanded?_offsetExpanded:_offsetCollapsed animated:NO];
        } completion:nil];
         */
    } else {
        [UIView animateWithDuration:0.2
                              delay:0
                            options:UIViewAnimationCurveEaseOut
                         animations:^{
                             [_scrollView setContentOffset:_offsetCollapsed animated:NO];
                         } completion:nil];
    }
    
}

@end