//
//  NLCActionTableViewCell.h
//  MyProjects
//
//  Created by Gaige B. Paulsen on 9/5/14.
//  Copyright (c) 2014 Gaige B. Paulsen. All rights reserved.
//

#import "NLCEditableTextTableViewCell.h"

@interface NLCActionTableViewCell : NLCEditableTextTableViewCell
@property(strong) IBOutlet UILabel *scheduleInfo1;
- (void)addScheduleTapTarget:(id)target selector:(SEL)selector;
@end
