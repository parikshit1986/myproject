//
//  NLCMultiCollectionDragger.m
//  MyProjects
//
//  Created by Gaige B. Paulsen on 6/24/14.
//  Copyright (c) 2014 Gaige B. Paulsen. All rights reserved.
//

#import "NLCMultiCollectionDragger.h"
#import "NLCAppDelegate.h"

@interface NLCMultiCollectionDragger ()
{
    CADisplayLink *_scrollDisplayLink;
    CGFloat _scrollRate;
    
    CGPoint location;
}
@property(strong) UILongPressGestureRecognizer *panRecognizer;
@property(strong) UIView *dragView;
@property (strong) NLCAppDelegate *appDelegate;
@property (strong)NSTimer *timer;
@end

@implementation NLCMultiCollectionDragger

- (instancetype)init
{
    self = [super init];
    if (self) {
        _collectionViews = @[];
        _appDelegate = GetAppDelegate();
        
    }
    return self;
}

-(void)addDraggableView:(UIView*)view
{
    _collectionViews = [_collectionViews arrayByAddingObject: view];
}

-(void)addTableView:(UITableView *)tableView
{
    NSAssert( [tableView isKindOfClass: [UITableView class]], @"Not table view");
    [self addDraggableView: tableView];
}

-(void)addCollectionView:(UICollectionView *)collectionView
{
    NSAssert( NO,  @"Not implemented");
    NSAssert( [collectionView isKindOfClass: [UICollectionView class]], @"Not collection view");
    [self addDraggableView: collectionView];
}

-(void)setHostingView:(UIView *)hostingView
{
    if (_hostingView) {
        if (_panRecognizer) {
            [_hostingView removeGestureRecognizer: _panRecognizer];
            _panRecognizer = nil;
        }
    }
    
    _hostingView = hostingView;
    if (_hostingView) {
#ifdef UBER_RECOGNIZER
        UILongPressGestureRecognizer *recognizer = [[UILongPressGestureRecognizer alloc] initWithTarget: self action: @selector(panGestureAction:)];
        recognizer.delegate = self;
        self.panRecognizer = recognizer;
        
        [_hostingView addGestureRecognizer: _panRecognizer];
#endif // UBER_RECOGNIZER
        
        
//        NSLog(@"panrecogniser %@",self.panRecognizer);
        
        // [self gestureRecognizer:self.panRecognizer shouldRequireFailureOfGestureRecognizer:((UIScrollView*) [self.sourceView superview]).panGestureRecognizer];
        
        
        // [self.panRecognizer requireGestureRecognizerToFail: ((UIScrollView*) [self.sourceView superview]).panGestureRecognizer];
        //
        //        for (UIGestureRecognizer * gestureRecognizer in [((UIScrollView*) [self.sourceView superview]) gestureRecognizers]) {
        //            if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]) {
        //                [self.panRecognizer requireGestureRecognizerToFail:gestureRecognizer];
        //            }else if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]){
        //                //[self.panRecognizer requireGestureRecognizerToFail:gestureRecognizer];
        //            }
        //        }
        
        [self gestureRecognizer:self.panRecognizer shouldRequireFailureOfGestureRecognizer:((UIScrollView*) [self.sourceView superview]).panGestureRecognizer];
        
    }
}

-(UITableView*)tableViewForRecognizerLocation:(UIGestureRecognizer*)recognizer
{
    
    NSLog(@"gesture - %@", recognizer);
    
    __block UITableView *resultView=nil;
    
    [_collectionViews enumerateObjectsUsingBlock:^(UITableView *view, NSUInteger idx, BOOL *stop) {
        CGPoint startPoint = [recognizer locationInView: view];
        
        if([view pointInside: startPoint withEvent:nil]){
            resultView = view;
            *stop=YES;
        }
    }];
    
    return resultView;
}

-(BOOL)panStart:(UILongPressGestureRecognizer*)recognizer
{
    __block BOOL panStarted=NO;
    // locate the source view
    [_collectionViews enumerateObjectsUsingBlock:^(UITableView *view, NSUInteger idx, BOOL *stop) {
        CGPoint startPoint = [recognizer locationInView: view];
        
        if([view pointInside: startPoint withEvent:nil]){
            self.startIndexPath = [view indexPathForRowAtPoint: startPoint];
            if (self.startIndexPath) {
                self.sourceView = view;
                self.startPoint = [recognizer locationInView: self.hostingView];
                
                UITableViewCell *cell = [self.sourceView cellForRowAtIndexPath: _startIndexPath];
                self.cellOffset= [recognizer locationInView: cell];
                [self beginDraggingCell: cell];
                
                panStarted=YES;
                *stop=YES;
            } else{
                
//                NSLog( @"Drag started in non-cell for %@",view);
            }
        }
    }];
    _appDelegate.isPanStarted=YES;
    return panStarted;
}

-(void)exitTargetView
{
    self.targetView = nil;
    self.targetIndexPath =nil;
}

-(void)enterTargetView:(UITableView*)targetView
{
    //    NSLog(@"Entering target view %@", targetView);
    self.targetView = targetView;
}

- (void)trackInTragetViewWithRecognizer:(UILongPressGestureRecognizer*)recognizer
{
    CGPoint targetPoint = [recognizer locationInView: self.targetView];
    NSIndexPath *currentCellPath = [self.targetView indexPathForRowAtPoint: targetPoint];
    if ( (!self.targetIndexPath) || (![self.targetIndexPath isEqual: currentCellPath]) ) {
        // change the path, because we didn't have one before or we aren't the same
//        NSLog( @"target path now %@", currentCellPath);
        self.targetIndexPath = currentCellPath;
    } else {
        // leave the same
//        NSLog( @"target path now no scroll %@", currentCellPath);
        //[self.targetView scrollToRowAtIndexPath:_targetIndexPath  atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}

- (void)trackInSourceViewWithRecognizer:(UILongPressGestureRecognizer*)recognizer
{
    NSLog(@"No track");
    CGPoint targetPoint = [recognizer locationInView: self.sourceView];
    location = [recognizer locationInView: self.sourceView];
    NSIndexPath *currentCellPath = [self.sourceView indexPathForRowAtPoint: targetPoint];
    if (!self.targetIndexPath) {
        // no previous location
        if (![currentCellPath isEqual: _startIndexPath]) {
            // we moved into somewhere we weren't before
            [self enterTargetView: _sourceView];
            self.targetIndexPath = currentCellPath;
        }
    } else if (![self.targetIndexPath isEqual: currentCellPath]) {
        // change the path, because we didn't have one before or we aren't the same
        //        NSLog( @"target path now %@", currentCellPath);
        self.targetIndexPath = currentCellPath;
    } else {
        // leave the same

        if (self.sourceView.tag == 101 || self.sourceView.tag == 22) {
            
            CGRect rect = ((UIScrollView*)[self.targetView superview]).bounds;
            // adjust rect for content inset as we will use it below for calculating scroll zones
            rect.size.height -= ((UIScrollView*)[self.targetView superview]).contentInset.top;
            
            // tell us if we should scroll and which direction
            CGFloat scrollZoneHeight = rect.size.height / 6;
            CGFloat bottomScrollBeginning = ((UIScrollView*)[self.targetView superview]).contentOffset.y + ((UIScrollView*)[self.targetView superview]).contentInset.top + rect.size.height - scrollZoneHeight;
            CGFloat topScrollBeginning = ((UIScrollView*)[self.targetView superview]).contentOffset.y + ((UIScrollView*)[self.targetView superview]).contentInset.top + scrollZoneHeight;
            
         
            // we're in the bottom zone
            if (location.y > bottomScrollBeginning - 10)
            {
                _scrollRate =  (location.y - bottomScrollBeginning-5) / scrollZoneHeight;
                // [self updateDraggingCellToLocationInHostedView:location];
            }
            // we're in the top zone
            else if (location.y <= topScrollBeginning +10)
            {
                _scrollRate =  (location.y - topScrollBeginning+30) / scrollZoneHeight;
                //[self updateDraggingCellToLocationInHostedView:location];
            }
            else
            {
                _scrollRate = 0;
                //(location.y -  topScrollBeginning)/ scrollZoneHeight;
            }
            
            CGPoint currentOffset = ((UIScrollView*)[self.targetView superview]).contentOffset;
            CGPoint newOffset = CGPointMake(currentOffset.x, currentOffset.y + _scrollRate * 10);
            
            if (newOffset.y < -((UIScrollView*)[self.targetView superview]).contentInset.top)
            {
                newOffset.y = -((UIScrollView*)[self.targetView superview]).contentInset.top;
            }
            else if (((UIScrollView*)[self.targetView superview]).contentSize.height + ((UIScrollView*)[self.targetView superview]).contentInset.bottom < ((UIScrollView*)[self.targetView superview]).frame.size.height)
            {
                newOffset = currentOffset;
            }
            else if (newOffset.y > (((UIScrollView*)[self.targetView superview]).contentSize.height + ((UIScrollView*)[self.targetView superview]).contentInset.bottom) - ((UIScrollView*)[self.targetView superview]).frame.size.height)
            {
                newOffset.y = (((UIScrollView*)[self.targetView superview]).contentSize.height + ((UIScrollView*)[self.targetView superview]).contentInset.bottom) - ((UIScrollView*)[self.targetView superview]).frame.size.height;
            }
            
            CGFloat scrollX = ((UIScrollView*)[self.targetView superview]).frame.origin.x;
            
            [UIView animateWithDuration:0.3 animations:^{
//                [((UIScrollView*)[self.targetView superview]) setContentOffset:CGPointMake(scrollX,newOffset.y)];
            }];
            
        }else{
            
            [self.targetView scrollToRowAtIndexPath:_targetIndexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
        }
    }
}

-(void)panChanged:(UILongPressGestureRecognizer*)recognizer
{
    CGPoint currentPoint= [recognizer locationInView: self.sourceView];
    
    if ([_sourceView pointInside: currentPoint withEvent: nil]) {
        [self trackInSourceViewWithRecognizer: recognizer];
        
    } else {
        UITableView *currentView = [self tableViewForRecognizerLocation: recognizer];
        if (!currentView) {
            // reset the targetIndexPath because we just moved out of the _sourceView
            self.targetIndexPath =nil;
            [self exitTargetView];
        } else if (currentView == self.targetView) {
            [self trackInTragetViewWithRecognizer: recognizer];
        } else {
            [self exitTargetView];
            [self enterTargetView: currentView];
        }
    }
    
    //NSLog(@"drag point %f",currentPoint.y);
    [self updateDraggingCellToLocationInHostedView: [recognizer locationInView: self.hostingView]];
    
    //new code
    
    if(self.sourceView.tag == 101)
    {
//        NSLog(@"aaayooo 2");
        const CGPoint point = [recognizer locationInView:self.sourceView.superview.superview];
        
        // update position of the drag view
        // don't let it go past the top or the bottom too far
        if (location.y >= 0 && location.y <= self.sourceView.contentSize.height + 50)
        {
            
            self.dragView.center = CGPointMake(self.sourceView.center.x, point.y);
            
            // NSIndexPath *currentCellPath = [self.sourceView indexPathForRowAtPoint: point];
            // self.targetIndexPath=currentCellPath;
        }
    }
}

-(void)panEnded:(UILongPressGestureRecognizer *)recognizer{
    
    if (self.sourceView.tag == 101) {
        
        CGPoint targetPoint = [recognizer locationInView: self.sourceView];
        targetPoint.x=280;
        
        NSIndexPath *currentCellPath = [self.sourceView indexPathForRowAtPoint: targetPoint];
        UITableViewCell *cell=[self.sourceView cellForRowAtIndexPath:currentCellPath];
        CGRect re=cell.frame;
        
//        NSLog(@"%f =====  %f", re.origin.y+(re.size.height/2),  targetPoint.y );
        if(re.origin.y+(re.size.height/2)+9 < targetPoint.y && _startIndexPath.row > currentCellPath.row ){
            if (currentCellPath)
                currentCellPath = [NSIndexPath indexPathForRow:currentCellPath.row+1 inSection:currentCellPath.section];
        }else if(re.origin.y+(re.size.height/2)+9 > targetPoint.y && _startIndexPath.row < currentCellPath.row ){
            currentCellPath = [NSIndexPath indexPathForRow:currentCellPath.row-1 inSection:currentCellPath.section];
        }
        
        self.targetIndexPath = currentCellPath;
 
        [self enterTargetView: _sourceView];
        if (!currentCellPath){
            self.targetIndexPath=currentCellPath;
            if(targetPoint.y < 150)
            {
                NSIndexPath *ip= [NSIndexPath indexPathForRow:0 inSection:0];
                self.targetIndexPath=ip;
            }
        }
    }
    // without a source, it's pointless
    if (_sourceView && _startIndexPath && _targetView) {
        if (_targetIndexPath){
            //            NSIndexPath *ip= [NSIndexPath indexPathForRow:0 inSection:0];
            //            _targetIndexPath=ip;
//            self.targetIndexPath = _startIndexPath;
        
//        NSLog(@"_sourceView - %@ ====== _targetView - %@",_sourceView, _targetView);
        if ([_delegate moveObjectFromTable: _sourceView cell:_startIndexPath toTable:_targetView cell: _targetIndexPath]) {
            //            NSLog( @"Successfully moved to %@", _targetIndexPath);
        } else {
            //            NSLog( @"Move incomplete, put it back");
        }
        }
    }
    
    GetAppDelegate().isCellMoving = NO;
    for (UIView *view in GetAppDelegate().pageControl.view.subviews) {
        if ([view isKindOfClass:UIScrollView.class]) {
            UIScrollView *scrollView = (UIScrollView *)view;
            [scrollView setScrollEnabled:YES];
        }
    }
    
    [self panReset];
}

-(void)panCancelled:(UILongPressGestureRecognizer*)recognizer
{
    [self panReset];
}

-(void)panFailed:(UILongPressGestureRecognizer*)recognizer
{
    [self panReset];
}

-(void)panReset
{
    [self endDraggingCell];
    _sourceView=nil;
    _startIndexPath=nil;
    _targetView=nil;
    _targetIndexPath=nil;
    
    [_scrollDisplayLink invalidate];
    
}

-(void)panGestureAction:(UILongPressGestureRecognizer*)recognizer
{
//       NSLog( @"Recognizer: %@ - State %d", recognizer,recognizer.state);
    
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
            if (![self panStart: recognizer]) {
                recognizer.enabled=NO;
                recognizer.enabled=YES;
            }
            break;
        case UIGestureRecognizerStateChanged:
            [self panChanged: recognizer];
            break;
        case UIGestureRecognizerStateCancelled:
            _appDelegate.isPanStarted=NO;
            [self panCancelled: recognizer];
            break;
        case UIGestureRecognizerStateEnded:
            //[self panChanged: recognizer];
            //            _appDelegate.isCellMoving = NO;
            //            _appDelegate.isDuplicate = NO;
            _appDelegate.isPanStarted=NO;
            [self panEnded: recognizer];
            break;
        case UIGestureRecognizerStateFailed:
            _appDelegate.isPanStarted=NO;
            [self panFailed: recognizer];
            break;
            
        default:
            //NSLog( @"Unknown state");
            break;
    }
}

-(BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    UITableView *view = [self tableViewForRecognizerLocation:gestureRecognizer];
    if (view) {
        if ([_delegate beginDragFromTable: view recognizer: gestureRecognizer]) {
            return YES;
        }
    }
    return NO;
}

-(void)beginDraggingCell:(NLCEditableTextTableViewCell*)cell
{
    //NSAssert(self.dragView==nil, @"should not have this twice");
    if (self.dragView)
        [self endDraggingCell];
    
    // Want to create an image context - the size of complex view and the scale of the device screen
    UIGraphicsBeginImageContextWithOptions(cell.bounds.size, YES, 0.0);
    // Render our snapshot into the image context
    [cell drawViewHierarchyInRect: cell.bounds afterScreenUpdates:NO];
    
    // Grab the image from the context
    UIImage *cellImage = UIGraphicsGetImageFromCurrentImageContext();
    // Finish using the context
    UIGraphicsEndImageContext();
    
    // new code added
    
    //    NSLog(@"%@", _sourceView);
    if (_sourceView.tag == 101) {
        
//        NSLog(@"aaayooo 4");
        
        CGRect clippedRect = CGRectMake(cell.bounds.origin.x, cell.bounds.origin.y, 330,  cell.ViewBG.bounds.size.height);
        UIGraphicsBeginImageContextWithOptions(clippedRect.size, NO, 0.0);
        {
            clippedRect = CGRectMake(0, 0, 330, cell.ViewBG.bounds.size.height);
            UIGraphicsBeginImageContextWithOptions(clippedRect.size, NO, 0.0);
            
            [cellImage drawAtPoint:(CGPoint){-clippedRect.origin.x, -clippedRect.origin.y}];
            cellImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }
        //    CGContextRelease(imageContext);
        UIGraphicsEndImageContext();
    }
    
    // new code ended
    UIImageView *imageView = [[UIImageView alloc] initWithImage:cellImage];
    {
     
        // border
        [imageView.layer setBorderColor:[UIColor blackColor].CGColor];
        [imageView.layer setBorderWidth:1.5f];
        
        // drop shadow
        [imageView.layer setShadowColor:[UIColor blackColor].CGColor];
        [imageView.layer setShadowOpacity:0.8f];
        [imageView.layer setShadowRadius: 3.0f];
        [imageView.layer setShadowOffset:CGSizeMake(2.0, 2.0)];
        
    }
    
    // TODO: Rerender the view with a border so that we can transparency
    self.dragView = imageView;
    [self.hostingView addSubview: self.dragView];
    
    // new code
    if (self.sourceView.tag == 101 && self.sourceView.tag != 123) {
//        NSLog(@"aaayooo 5");
        _scrollDisplayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(scrollTableWithCell:)];
        [_scrollDisplayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    }
 
    
    CGRect frame = self.dragView.frame;
    frame.origin= self.startPoint;
    frame.origin.x-=self.cellOffset.x;
    frame.origin.y-=self.cellOffset.y;
    [self.dragView setFrame:frame];
    [self.dragView setBackgroundColor:[UIColor clearColor]];
}

-(void)updateDraggingCellToLocationInHostedView:(CGPoint)locationInHostedView
{
//    NSLog(@"No update");
    if (self.sourceView.tag == 101) {
        
//        NSLog(@"aaayooo 6");
        CGPoint currentOffset = ((UIScrollView*)[self.targetView superview]).contentOffset;
        CGPoint newOffset = CGPointMake(currentOffset.x, currentOffset.y + _scrollRate * 10);
        
//        NSLog(@"newoffset  _scrollRate  %f",_scrollRate);
        
        if (newOffset.y < -((UIScrollView*)[self.targetView superview]).contentInset.top)
        {
            newOffset.y = -((UIScrollView*)[self.targetView superview]).contentInset.top;
            
//            NSLog(@"newoffset up %f" ,newOffset.y);
        }
        else if (((UIScrollView*)[self.targetView superview]).contentSize.height + ((UIScrollView*)[self.targetView superview]).contentInset.bottom < ((UIScrollView*)[self.targetView superview]).frame.size.height)
        {
            newOffset = currentOffset;
//            NSLog(@"newoffset current %f" ,newOffset.y);
        }
        else if (newOffset.y > (((UIScrollView*)[self.targetView superview]).contentSize.height + ((UIScrollView*)[self.targetView superview]).contentInset.bottom) - ((UIScrollView*)[self.targetView superview]).frame.size.height)
        {
            newOffset.y = (((UIScrollView*)[self.targetView superview]).contentSize.height + ((UIScrollView*)[self.targetView superview]).contentInset.bottom) - ((UIScrollView*)[self.targetView superview]).frame.size.height;
//            NSLog(@"newoffset bottom %f" ,newOffset.y);
        }
        
        // CGRect rect1 = self.targetView.frame;
        CGFloat scrollX = ((UIScrollView*)[self.targetView superview]).frame.origin.x;
        
        [UIView animateWithDuration:0.3 animations:^{
            [((UIScrollView*)[self.targetView superview]) setContentOffset:CGPointMake(scrollX,newOffset.y)];
        }];
    }else{
        
        CGRect frame = self.dragView.frame;
        frame.origin= locationInHostedView;
        frame.origin.x-=self.cellOffset.x;
        frame.origin.y-=self.cellOffset.y;
        [self.dragView setFrame:frame];
//        NSLog(@"_scrollRate wwww - %f", _scrollRate);
//        NSLog(@"frame.origin.y wwww - %f", frame.origin.y);
        if(frame.origin.y <70){
       
            CGPoint currentOffset = ((UIScrollView*)[self.targetView superview]).contentOffset;
            CGPoint newOffset = CGPointMake(currentOffset.x, currentOffset.y );
            newOffset.y = -((UIScrollView*)[self.targetView superview]).contentInset.top;
            CGFloat scrollX = ((UIScrollView*)[self.targetView superview]).frame.origin.x;
            
            [UIView animateWithDuration:0.3 animations:^{
                [((UIScrollView*)[self.targetView superview]) setContentOffset:CGPointMake(scrollX, newOffset.y)];
            }];
        }
        
        if(frame.origin.y > 580){
            
            CGPoint currentOffset = ((UIScrollView*)[self.targetView superview]).contentOffset;
            CGPoint newOffset = CGPointMake(currentOffset.x, currentOffset.y + 2.9  * 2);
            
//               newOffset.y = (((UIScrollView*)[self.targetView superview]).contentSize.height + ((UIScrollView*)[self.targetView superview]).contentInset.bottom) - ((UIScrollView*)[self.targetView superview]).frame.size.height;
            CGFloat scrollX = ((UIScrollView*)[self.targetView superview]).frame.origin.x;
            
            [UIView animateWithDuration:0.3 animations:^{
                [((UIScrollView*)[self.targetView superview]) setContentOffset:CGPointMake(scrollX, newOffset.y)];
            }];
        }
        
    }
    
    
    
}

-(void)endDraggingCell
{
    _appDelegate.isCellMoving = NO;
    _appDelegate.isDuplicate = NO;
    [UIView animateWithDuration:0.2
                     animations:^{self.dragView.alpha = 0.0;
                         [_sourceView reloadData];
                         [_targetView reloadData];
                         if(_sourceView.tag == 101){
                             
                         }
                     }
                     completion:^(BOOL finished){   [self.dragView removeFromSuperview];
                     }];
    
    self.dragView = nil;
    
    UIScrollView  *scrollView = (UIScrollView*)[_sourceView superview];
    
    NSArray *allSubviews = [scrollView subviews];
    for (int i= 0 ; i< allSubviews.count; i++) {
        UIView *subView  = [allSubviews objectAtIndex:i];
        //to move connected resource TableView
        if( (((UITableView *)subView).tag == 101))
        {
            [((UITableView *)subView) reloadData];
            
        }
    }
    
    
}

// Allow simultaneous recognition
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
shouldRecognizeSimultaneouslyWithGestureRecognizer:
(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if ([otherGestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        return YES;
    }
    
    return NO;
}


- (void)scrollTableWithCell:(NSTimer *)timer
{
    [self updateDraggingCellToLocationInHostedView:[self.panRecognizer locationInView:self.sourceView]];
}

@end
