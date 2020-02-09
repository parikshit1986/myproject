//
//  NLCPeopleViewCell.h
//  MyProjects
//
//  Created by Gaige B. Paulsen on 9/4/14.
//  Copyright (c) 2014 Gaige B. Paulsen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NLCPeopleViewCell : UICollectionViewCell
@property(strong) IBOutlet UILabel *name;
@property(strong) IBOutlet UIImageView *imageView;
@property(strong) id representedObject;
@property(strong) IBOutlet UIButton *btnDelete;

@property(nonatomic,strong)IBOutlet UIButton *btnAddPhoto;
@end
