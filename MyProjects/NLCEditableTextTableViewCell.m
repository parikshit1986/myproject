//
//  NLCEditableTextTableViewCell.m
//  MyProjects
//
//  Created by Gaige B. Paulsen on 5/27/14.
//  Copyright (c) 2014 Gaige B. Paulsen. All rights reserved.
//

#import "NLCEditableTextTableViewCell.h"



@implementation NLCEditableTextTableViewCell

//@synthesize appDelegate;
@synthesize tblClass;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    return [self initWithStyle:style reuseIdentifier:reuseIdentifier dragRecognizerTarget:nil selector:nil];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier dragRecognizerTarget:(id)target selector:(SEL)selector
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        if (target) {
            [self addDragMarkerWithDragReconizerTarget: target selector:selector];
        }
    }
    return self;
}
-(void)layoutSubviews {
    [super layoutSubviews];
    CGRect newCellSubViewsFrame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height+10);
    //  CGRect newCellViewFrame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
    
    self.contentView.frame = self.contentView.bounds = self.backgroundView.frame = self.accessoryView.frame = newCellSubViewsFrame;
    //    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 10.0) {
    //
    //        if ([self.editField.text containsString:@"NEXT System enabled actions that enable YOU/Players to make progress towards the Objective."] || [self.editField.text containsString:@"NEXT System enabled actions that enable YOU/Players to make progress towards the Objective."] || [self.editField.text containsString:@"Obstacles that impede progress towards the Objective."]) {
    //
    //            self.contentView.frame=CGRectMake(0, 0, self.frame.size.width, 120);;
    //           self.editField.frame=CGRectMake(self.editField.frame.origin.x, self.editField.frame.origin.y, self.editField.frame.size.width, 190);
    //            _editFieldHeightConstraint = [NSLayoutConstraint constraintWithItem: _editField attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:100];
    //            [self.editField addConstraint: _editFieldHeightConstraint];
    //
    //        }
    //
    //    }
    
    
}


-(void)awakeFromNib
{
    [super awakeFromNib];
    //appDelegate = GetAppDelegate();
    self.textDelegate = nil;
    _editField.delegate = self;
    
    _editField.textContainer.lineFragmentPadding=0;
    self.tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(editTap:)];
    self.tapRecognizer.delaysTouchesBegan=YES;
    [self.contentView addGestureRecognizer: self.tapRecognizer];
    [_editField addGestureRecognizer: self.tapRecognizer];
    
    // NOTE: do not do this unless you add a width constraint.  It causes the content view to resize proportionately to the contents, which causes all of the subordinate views to be screwed up.
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 10.0) {
        self.contentView.translatesAutoresizingMaskIntoConstraints=NO;
        _editField.translatesAutoresizingMaskIntoConstraints=NO;
        [self addConstraint: [NSLayoutConstraint constraintWithItem: self.contentView attribute:NSLayoutAttributeWidth relatedBy: NSLayoutRelationEqual toItem: self attribute:NSLayoutAttributeWidth multiplier:1.0 constant:1.0]];
    }
    else{
        [self addConstraint: [NSLayoutConstraint constraintWithItem: self.contentView attribute:NSLayoutAttributeWidth relatedBy: NSLayoutRelationEqual toItem: self attribute:NSLayoutAttributeWidth multiplier:1.0 constant:1.0]];
    }
    
    self.normalTextColor = [_editField.textColor copy];
    self.placeholderTextColor = [UIColor lightGrayColor];
    self.addIndex =-1;
}

-(void)dealloc
{
    _editField.delegate=nil;
    _dragRecognizer.delegate=nil;
    _dragTapRecognizer.delegate=nil;
}

- (void)addDragMarkerWithDragReconizerTarget:(id)target selector:(SEL)selector
{
    if (target) {
        self.dragRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:target action: selector];
        self.dragRecognizer.delegate =self;
        [self.dragMarker addGestureRecognizer: self.dragRecognizer];
        self.dragMarker.userInteractionEnabled=YES;
    }
}

-(void)addDragMarkerTapTarget:(id)target selector:(SEL)selector
{
    if (target) {
        self.dragTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:target action: selector];
        self.dragTapRecognizer.delegate =self;
        [self.dragMarker addGestureRecognizer: self.dragTapRecognizer];
        self.dragMarker.userInteractionEnabled=YES;
        [self.tapRecognizer requireGestureRecognizerToFail: self.dragTapRecognizer];
        if (self.dragRecognizer)
            [self.dragTapRecognizer requireGestureRecognizerToFail: self.dragRecognizer];
    } else {
        [self.dragMarker removeGestureRecognizer: self.dragTapRecognizer];
        self.dragTapRecognizer =nil;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

#pragma mark -

- (void)setTextDelegate:(id <NLCEditableTextTableViewCellDelegate>)aDelegate
{
    _textDelegate = aDelegate;
}

-(id<UITextViewDelegate>)textDelegate
{
    return _textDelegate;
}

#pragma mark - Text View (new)

-(BOOL)isEmpty
{
    return [_editField.textColor isEqual:self.placeholderTextColor] || _editField.text.length==0;
}

-(void)setTextValue:(NSString*)textValue
{
    if (self.placeholderText) {
        if (textValue.length>0) {
            _editField.textColor = self.normalTextColor;
            _editField.text = textValue;
        } else {
            if (self.placeholderText) {
                _editField.textColor = self.placeholderTextColor;
                _editField.text = self.placeholderText;
            }
        }
    } else {
        _editField.text = textValue;
    }
    if (_editFieldHeightConstraint) {
        [self.editField removeConstraint: _editFieldHeightConstraint];
        self.editFieldHeightConstraint=nil;
        [self setNeedsUpdateConstraints];
    }
}

-(NSString*)textValue
{
    if (self.isEmpty) {
        return @"";
    }
    return _editField.text;
}

-(BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if ([_textDelegate respondsToSelector: @selector(textViewShouldBeginEditing:)]) {
        return [_textDelegate textViewShouldBeginEditing: textView];
    }
    GetAppDelegate().currentEditedTextView = self.editField;
    return YES;
}

-(void)textViewDidBeginEditing:(UITextView *)textView
{
    NSIndexPath    *indexPath = [_tableView indexPathForCell:self];
    [_tableView.delegate tableView:_tableView didSelectRowAtIndexPath:indexPath];
    if ([_textDelegate respondsToSelector: @selector(textViewDidBeginEditing:)]) {
        [_textDelegate textViewDidBeginEditing: textView];
    }
    if ([textView.textColor isEqual: self.placeholderTextColor]) {
        textView.selectedRange = NSMakeRange(0, 0);
    }
    GetAppDelegate().currentEditedTextView = self.editField;
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString: @"\n"]) {
        if ([_textDelegate respondsToSelector: @selector(nlcEditableCell:textFieldShouldReturn:)]) {
            if (![_textDelegate nlcEditableCell:self textFieldShouldReturn:textView]) {
                return NO;
            }
        } else {
            [textView resignFirstResponder];
        }
    } else if ([text isEqualToString: @"\t"]) {
        [textView resignFirstResponder];
        return YES;
    } else if ([_textDelegate respondsToSelector: @selector(textView:shouldChangeTextInRange:replacementText:)]) {
        return [_textDelegate textView: textView shouldChangeTextInRange:range replacementText: text];
    }
    
    NSString *str=_editField.text;
    NSString *str2 =resourcePlaceholderText;
    if( text.length > 0  && ([str isEqualToString:implicationSuccessPlaceHolderText] || [str isEqualToString:implicationUnSucessPlaceHolderText] ||[str isEqualToString:experienceSuccessPlaceHolderText] ||  [str isEqualToString:experienceUnSuccessPlaceHolderText] || [str isEqualToString:actionPlaceholderText] || [str isEqualToString:barrierPlaceholderText] || [str isEqualToString:str2] || [str isEqualToString:intentionsPlaceholderText] || [str isEqualToString:objectivePlaceholderText])){
        
        _editField.textColor = self.normalTextColor;
        _editField.text = @"";
    }
    
    GetAppDelegate().currentEditedTextView = self.editField;
    return YES;
}

-(BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    if ([_textDelegate respondsToSelector: @selector(textViewShouldEndEditing:)])
        return [_textDelegate textViewShouldEndEditing: textView];
    return YES;
}

-(void)textViewDidEndEditing:(UITextView *)textView
{
    
    if(_editField.text.length == 0){
        _editField.textColor = self.placeholderTextColor;
        _editField.text = _placeholderText;
        _editField.selectedRange=NSMakeRange(0, 0);
    }
    if ([_textDelegate respondsToSelector: @selector(textViewDidEndEditing:)])
        [_textDelegate textViewDidEndEditing: textView];
    
    [_textDelegate saveEditedDataForCell: self];
    self.editField.editable=NO;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        UIScrollView  *scrollView = (UIScrollView*)[[[self superview] superview] superview];
        NSArray *allSubviews = [scrollView subviews];
        for (int i= 0 ; i< allSubviews.count; i++) {
            UIView *subView  = [allSubviews objectAtIndex:i];
            //to move connected resource TableView
            if( (((UITableView *)subView).tag == 101))
            {
                GetAppDelegate().isCellMoving = NO;
                //            GetAppDelegate().isCellMoving = NO;
                [((UITableView *)subView) reloadData];
                
            }
        }
    });
    GetAppDelegate().currentEditedTextView = self.editField;
}

- (void)textViewDidChange:(UITextView *)textView
{
    
    if(_editField.text.length == 0){
        _editField.textColor = self.placeholderTextColor;
        _editField.text = _placeholderText;
        _editField.selectedRange=NSMakeRange(0, 0);
    }
    if (_editFieldHeightConstraint) {
        CGFloat newHeight = [self textViewHeight];
        CGFloat currentHeight = [_editFieldHeightConstraint constant];
        
        if (newHeight!=currentHeight) {
            //            [self.editField removeConstraint: _editFieldHeightConstraint];
            self.editFieldHeightConstraint=nil;
            [self setNeedsUpdateConstraints];
            [self updateConstraintsIfNeeded];
            [self setNeedsLayout];
            [self layoutIfNeeded];
            [self.textDelegate nlcEditableCellResized: self toHeight: newHeight];
            
            
            //              if(self.editField.editable && ((UITableView*)[[self superview] superview]).tag == 22){
            ////                  [self moveResorces:newHeight withCurrentHeight:currentHeight];
            //              }
            //new code
            //            if(self.editField.editable && ((UITableView*)[[self superview] superview]).tag == 1010 ){
            //                UIScrollView  *scrollView = (UIScrollView*)[[[self superview] superview] superview];
            //
            //                NSArray *allSubviews = [scrollView subviews];
            //                for (int i= 0 ; i< allSubviews.count; i++) {
            //                    UIView *subView  = [allSubviews objectAtIndex:i];
            //                    //to move connected resource TableView
            //                    if([subView isKindOfClass:[UITableView class]] && (((UITableView *)subView).tag != 101) && (((UITableView *)subView).parentTableTag >= self.indexOfCell))
            //                    {
            //                        if( (((UITableView *)subView).parentTableTag == self.indexOfCell)){
            //                            float htOfView =0;
            //                            if(subView.frame.size.height > newHeight-25 ){
            //                                subView.frame = CGRectMake(subView.frame.origin.x, subView.frame.origin.y + htOfView, subView.frame.size.width, subView.frame.size.height);
            //                                self.seperatorHeight.constant = subView.frame.size.height -newHeight+25;
            //                                [self setNeedsLayout];
            //                            }else{
            //                                subView.frame = CGRectMake(subView.frame.origin.x, subView.frame.origin.y + htOfView, subView.frame.size.width, newHeight);
            //                                self.seperatorHeight.constant = 50;
            //                                [self setNeedsLayout];
            //                            }
            //                        }else{
            //                             //To move other  below  TableView
            //                            subView.frame = CGRectMake(subView.frame.origin.x, subView.frame.origin.y + (newHeight-currentHeight), subView.frame.size.width, subView.frame.size.height);
            //                        }
            //                    }
            //
            //                    //to move connected view to resource table
            //                    if([subView isKindOfClass:[UIView class]] && (((UIView *)subView).tag >= 1000+self.indexOfCell))
            //                    {
            //                        if( (((UIView *)subView).tag == 1000+self.indexOfCell)){
            //                            //to  move current  view
            //                            subView.frame = CGRectMake(subView.frame.origin.x, subView.frame.origin.y, subView.frame.size.width, subView.frame.size.height);
            //                        }else{
            //                               //To move other  below  view
            //                            subView.frame = CGRectMake(subView.frame.origin.x, subView.frame.origin.y + (newHeight-currentHeight), subView.frame.size.width, subView.frame.size.height);
            //                        }
            //                    }
            //                }
            //
            //            }
            
        }
    }
}
//-(void)moveResorces:(float)newHeight withCurrentHeight:(float)currentHeight{
//    //new code
//        UIScrollView  *scrollView = (UIScrollView*)[[[self superview] superview] superview];
//         UITableView  *tv = (UITableView*)[[self superview] superview];
//
//        NSArray *allSubviews = [scrollView subviews];
//        for (int i= 0 ; i< allSubviews.count; i++) {
//            UIView *subView  = [allSubviews objectAtIndex:i];
//            //to move connected resource TableView
//            if([subView isKindOfClass:[UITableView class]] && ((UITableView *)subView).tag == 22 && ((UITableView *)subView).parentTableTag >= tv.parentTableTag)
//            {
//                if( (((UITableView *)subView).parentTableTag == tv.parentTableTag)){
//
//                   subView.frame = CGRectMake(subView.frame.origin.x, subView.frame.origin.y , subView.frame.size.width, subView.frame.size.height + currentHeight);
//
//
//                }else{
//
//                    //To move other  below  TableView
//                    subView.frame = CGRectMake(subView.frame.origin.x, subView.frame.origin.y + (newHeight-currentHeight), subView.frame.size.width, subView.frame.size.height);
//                }
//            }
//            if(((UITableView *)subView).tag == 101)
//            {
//                NSIndexPath *indxPath=[NSIndexPath indexPathForRow:tv.parentTableTag inSection:0];
//                NLCEditableTextTableViewCell *cell =[((UITableView *)subView) cellForRowAtIndexPath:indxPath];
//
//                cell.seperatorHeight.constant +=currentHeight;
//                [cell setNeedsLayout];
//                [cell updateConstraintsIfNeeded];
//                [cell setNeedsLayout];
//
//                cell.addIndex=indxPath.row;
//                [((UITableView *)subView) beginUpdates];
//                [((UITableView *)subView) reloadRowsAtIndexPaths:@[indxPath] withRowAnimation:UITableViewRowAnimationLeft];
//                [((UITableView *)subView) endUpdates];
//
//                [cell setNeedsLayout];
//                [cell updateConstraintsIfNeeded];
//                [cell setNeedsLayout];
//
//            }
//
//            //to move connected view to resource table
//            if([subView isKindOfClass:[UIView class]] && (((UIView *)subView).tag >= 1000+self.indexOfCell))
//            {
//                if( (((UIView *)subView).tag == 1000+self.indexOfCell)){
//                    //to  move current  view
//                    subView.frame = CGRectMake(subView.frame.origin.x, subView.frame.origin.y, subView.frame.size.width, subView.frame.size.height);
//                }else{
//                    //To move other  below  view
//                    subView.frame = CGRectMake(subView.frame.origin.x, subView.frame.origin.y + (newHeight-currentHeight), subView.frame.size.width, subView.frame.size.height);
//                }
//            }
//        }
//}

- (void)startEditing
{
    // finish editing elsewhere and start editing here
    self.editField.editable=YES;
    [self.editField becomeFirstResponder];
}

#pragma mark -

-(BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return YES;
}

#pragma mark - tap recognizer
-(void)editTap:(UITapGestureRecognizer*)recognizer
{
    if (self.editField.editable)
        return;
    
    [self startEditing];
}

-(void)updateConstraints
{
    if (!_editFieldHeightConstraint && _editField)  {
        CGFloat textViewheight = [self textViewHeight];
        NSLayoutConstraint *heightConstraint;
        for (NSLayoutConstraint *constraint in self.editField.constraints) {
            if (constraint.firstAttribute == NSLayoutAttributeHeight) {
                heightConstraint = constraint;
                heightConstraint.constant = textViewheight;
                 break;
            }
        }
        
        _editFieldHeightConstraint = [NSLayoutConstraint constraintWithItem: _editField attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:textViewheight];
        //        [self.editField addConstraint: _editFieldHeightConstraint];
    }
    [super updateConstraints];
}


-(CGFloat)textViewHeight
{
    CGFloat textViewheight = (CGFloat)ceil([self.editField sizeThatFits:CGSizeMake(self.editField.frame.size.width-30, FLT_MAX)].height);
    //    if (textViewheight <30) {
    //       // textViewheight=30;
    //    }
    return textViewheight + 15;
}


@end

