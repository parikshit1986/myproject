//
//  NLCPlayerPersonCell.h
//  MyProjects
//
//  Created by Madhvi on 30/07/15.
//  Copyright (c) 2015 Gaige B. Paulsen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NLCPlayerPersonCell : UICollectionViewCell
@property(strong) IBOutlet UILabel *name;
@property(strong) IBOutlet UIImageView *imageView;
@property(strong) id representedObject;
@property(strong) IBOutlet UIButton *btnDelete;
@end
