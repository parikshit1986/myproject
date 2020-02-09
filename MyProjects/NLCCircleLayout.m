
/*
 File: NLCCircleLayout.m
 Abstract:
 
 Version: 1.1
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2012 Apple Inc. All Rights Reserved.
 
 
 WWDC 2012 License
 
 NOTE: This Apple Software was supplied by Apple as part of a WWDC 2012
 Session. Please refer to the applicable WWDC 2012 Session for further
 information.
 
 IMPORTANT: This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a non-exclusive license, under
 Apple's copyrights in this original Apple software (the "Apple
 Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 */

#import "NLCCircleLayout.h"
#import "NLCStakeholder.h"
#import "NLCStakeholderViewController.h"

@interface NLCCircleLayout()

// arrays to keep track of insert, delete index paths
@property (nonatomic, strong) NSMutableArray *deleteIndexPaths;
@property (nonatomic, strong) NSMutableArray *insertIndexPaths;

@end

NSString *kCircleLayout_newView = @"kCircleLayout_newView";

@implementation NLCCircleLayout

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder: aDecoder];
    if (self) {
        _sectionCount = 0;
//        _viewSize = CGRectMake(23, 23, 581,581);
//        _meViewSize = CGRectMake(110, 110, 121,121);
//        _playerSize = CGRectMake(118, 118, 344, 344);
       _viewSize = CGSizeMake( 150, 70);
       _meViewSize = CGSizeMake( 121, 121);
     _playerSize = CGSizeMake(140,70);
    
    }
    return self;
}

-(void)prepareLayout
{
    [super prepareLayout];
    
    
    
    CGSize size = self.collectionView.frame.size;
    
    
    _center = CGPointMake(size.width / 2.0f, size.height / 2.0f);
    _sectionCount = [[self collectionView] numberOfSections];
    
    CGFloat deltaR ;
    //size.width/ (2.0f*_sectionCount);
    NSMutableArray *radiiTemp = [NSMutableArray array];
    NSMutableArray *cellCountTemp = [NSMutableArray array];
    for ( NSInteger section = 0; section<_sectionCount; section++) {
        if (section == 2) {
            deltaR = size.width/(2.0f*_sectionCount);
        }else if (section == 1){
            deltaR = size.width/(2.0f*_sectionCount);
        }else{
            deltaR = size.width/(2.0f*_sectionCount);
        }
        
        [radiiTemp addObject: @(deltaR*section)];
        [cellCountTemp addObject: @([[self collectionView] numberOfItemsInSection: section])];
    }
    self.radii = [radiiTemp copy];
    self.cellCounts = cellCountTemp;
}

-(CGSize)collectionViewContentSize
{
    return [self collectionView].frame.size;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)path
{
    //    UICollectionViewLayoutAttributes* attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:path];
    //    if (path.section==0)
    //        attributes.size=_meViewSize;
    //    else
    //        attributes.size = _viewSize;
    //    NSUInteger section = (NSUInteger)path.section;
    //    CGFloat radius = (CGFloat)[self.radii[section] doubleValue];
    //    CGFloat cellCountForSection = (CGFloat)[self.cellCounts[section] doubleValue]-1;
    //     NSLog( @"%@, %ld ,%f  %f", attributes,(long)path.item,cellCountForSection,(1.5*M_PI*path.item/cellCountForSection)-(0.25*M_PI));
    //
    //    // CGFloat angle = cellCountForSection==0?0: (CGFloat)((1.5*M_PI*path.item/cellCountForSection)-(0.25*M_PI));
    //    CGFloat angle = cellCountForSection==0?0: (CGFloat)((2.3*M_PI*path.item/cellCountForSection));
    //
    //
    //    attributes.center = CGPointMake((CGFloat)(_center.x + radius * cos(angle)),
    //                                    (CGFloat)(_center.y + radius * sin(angle)));
    //
    //
    //
    //
    //    return attributes;
    UICollectionViewLayoutAttributes* attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:path];
    
//    if (path.section==0)
//        attributes.frame=_meViewSize;
//    else if(path.section ==1)
//        attributes.frame = _playerSize;
//    else
//        attributes.frame = _viewSize;
    
    if (path.section==0)
                attributes.size=_meViewSize;
            else if(path.section ==1)
                attributes.size = _playerSize;
            else
                attributes.size = _viewSize;
    
    NSUInteger section = (NSUInteger)path.section;
    
    
    
    CGFloat radius = (CGFloat)[self.radii[section] doubleValue];
    
    CGFloat cellCountForSection = (CGFloat)[self.cellCounts[section] doubleValue];
    // attributes.size = CGSizeMake(ITEM_SIZE, ITEM_SIZE);
    CGFloat angle;
    //    NLCStakeholder *stakeholder=nil;
    //       UIStoryboard *storyboard =[UIStoryboard storyboardWithName: @"Main" bundle:nil];
    //    NLCStakeholderViewController *obj = [storyboard instantiateViewControllerWithIdentifier: @"Stakeholders"];
    //    NSArray *stakeholders = [obj stakeholdersInOrderForRank: path.section];
    if (path.section == 0) {
        
        angle = cellCountForSection==0?0: (CGFloat)((2 * path.item * M_PI / cellCountForSection));
        
        attributes.center = CGPointMake(_center.x +5+ radius * cos(angle),
                                        _center.y + 20 + radius * sin(angle));
    }else if (path.section == 1) {
        
        angle = cellCountForSection==0?0: (CGFloat)((2* path.item * M_PI / cellCountForSection));
        
        //CGPoint _center1 = CGPointMake(_playerSize.size.width / 2.0f, _playerSize.size.height / 2.0f);
        
        attributes.center = CGPointMake(_center.x  + radius * cos(angle),
                                        _center.y + 20+ radius * sin(angle));
    }else{
    
        angle = cellCountForSection==0?0: (CGFloat)((2 * path.item * M_PI / cellCountForSection));
       // CGPoint _center2 = CGPointMake(_viewSize.size.width / 2.0f, _viewSize.size.height / 2.0f);
        
        attributes.center = CGPointMake(_center.x + 0 +radius * cos(angle),
                                       _center.y + 20+ radius * sin(angle));
 }
    
    
    return attributes;
    
    
}

-(UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind: kind withIndexPath:indexPath];
    
    if ([kind isEqualToString: kCircleLayout_newView]) {
        NSUInteger section = (NSUInteger)indexPath.section;
        CGFloat radius = (CGFloat)[self.radii[section] doubleValue];
        CGFloat cellCountForSection = (CGFloat)[self.cellCounts[section] doubleValue];
        //
        //        CGFloat angle = indexPath.item==0?0: (CGFloat)((1.5*M_PI*indexPath.item/cellCountForSection)-(0.25*M_PI));
        CGFloat angle;
//        if (indexPath.section == 1) {
//            
//            angle = cellCountForSection==0?0: (CGFloat)((2 * indexPath.item * M_PI / cellCountForSection));
//            
//            attributes.center = CGPointMake(_center.x + radius * cos(angle),
//                                            _center.y + radius * sin(angle));
//        }else{
//            angle = cellCountForSection==0?0: (CGFloat)((2 * indexPath.item * M_PI / cellCountForSection));
//            attributes.center = CGPointMake((CGFloat)(_center.x + radius * cos(angle)),
//                                            (CGFloat)(_center.y +  radius * sin(angle)));
//        }
        
        if (indexPath.section == 0) {
            
            angle = cellCountForSection==0?0: (CGFloat)((2 * indexPath.item * M_PI / cellCountForSection));
            
            attributes.center = CGPointMake(_center.x + radius * cos(angle),
                                            _center.y + radius * sin(angle));
        }else if (indexPath.section == 1) {
            
            angle = cellCountForSection==0?0: (CGFloat)((2.0* indexPath.item * M_PI / cellCountForSection));
            
            //CGPoint _center1 = CGPointMake(_playerSize.size.width / 2.0f, _playerSize.size.height / 2.0f);
            
            attributes.center = CGPointMake(_center.x + radius * cos(angle),
                                            _center.y + radius * sin(angle));
        }else{
            
            angle = cellCountForSection==0?0: (CGFloat)((2.0 * indexPath.item * M_PI / cellCountForSection));
            // CGPoint _center2 = CGPointMake(_viewSize.size.width / 2.0f, _viewSize.size.height / 2.0f);
            
            attributes.center = CGPointMake(_center.x +radius * cos(angle),
                                            _center.y + radius * sin(angle));
        }

        return attributes;
    }
    return nil;
}

-(NSArray*)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSMutableArray* attributes = [NSMutableArray array];
    for (NSInteger section = 0; section<self.sectionCount;section++) {
        for (NSInteger row = 0; row<[self.cellCounts[(NSUInteger)section] intValue]; row++) {
            NSIndexPath* indexPath = [NSIndexPath indexPathForItem: row inSection: section];
            [attributes addObject:[self layoutAttributesForItemAtIndexPath:indexPath]];
        }
        //        if (section>0)
        //            [attributes addObject: [self layoutAttributesForSupplementaryViewOfKind: kCircleLayout_newView atIndexPath: [NSIndexPath indexPathForItem:  0 inSection:section]]];
    }
    return attributes;
}

- (void)prepareForCollectionViewUpdates:(NSArray *)updateItems
{
    // Keep track of insert and delete index paths
    [super prepareForCollectionViewUpdates:updateItems];
    
    self.deleteIndexPaths = [NSMutableArray array];
    self.insertIndexPaths = [NSMutableArray array];
    
    for (UICollectionViewUpdateItem *update in updateItems)
    {
        if (update.updateAction == UICollectionUpdateActionDelete)
        {
            [self.deleteIndexPaths addObject:update.indexPathBeforeUpdate];
        }
        else if (update.updateAction == UICollectionUpdateActionInsert)
        {
            [self.insertIndexPaths addObject:update.indexPathAfterUpdate];
        }
    }
}

- (void)finalizeCollectionViewUpdates
{
    [super finalizeCollectionViewUpdates];
    // release the insert and delete index paths
    self.deleteIndexPaths = nil;
    self.insertIndexPaths = nil;
}

// Note: name of method changed
// Also this gets called for all visible cells (not just the inserted ones) and
// even gets called when deleting cells!
- (UICollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingItemAtIndexPath:(NSIndexPath *)itemIndexPath
{
    // Must call super
    UICollectionViewLayoutAttributes *attributes = [super initialLayoutAttributesForAppearingItemAtIndexPath:itemIndexPath];
    
    if ([self.insertIndexPaths containsObject:itemIndexPath])
    {
        // only change attributes on inserted cells
        if (!attributes)
            attributes = [self layoutAttributesForItemAtIndexPath:itemIndexPath];
        
        // Configure attributes ...
        attributes.alpha = 0.0;
        attributes.center = CGPointMake(_center.x, _center.y);
        attributes.transform3D = CATransform3DMakeScale(0.1f, 0.1f, 1.0);
    }
    
    return attributes;
}

// Note: name of method changed
// Also this gets called for all visible cells (not just the deleted ones) and
// even gets called when inserting cells!
- (UICollectionViewLayoutAttributes *)finalLayoutAttributesForDisappearingItemAtIndexPath:(NSIndexPath *)itemIndexPath
{
    // So far, calling super hasn't been strictly necessary here, but leaving it in
    // for good measure
    UICollectionViewLayoutAttributes *attributes = [super finalLayoutAttributesForDisappearingItemAtIndexPath:itemIndexPath];
    
    if ([self.deleteIndexPaths containsObject:itemIndexPath])
    {
        // only change attributes on deleted cells
        if (!attributes)
            attributes = [self layoutAttributesForItemAtIndexPath:itemIndexPath];
        
        // Configure attributes ...
        attributes.alpha = 0.0;
        attributes.center = CGPointMake(_center.x, _center.y);
        attributes.transform3D = CATransform3DMakeScale(0.1f, 0.1f, 1.0);
    }
    
    return attributes;
}

@end
