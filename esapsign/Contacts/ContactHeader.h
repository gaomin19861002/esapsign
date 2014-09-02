//
//  ContactHeader.h
//  esapsign
//
//  Created by Suzic on 14-7-29.
//  Copyright (c) 2014年 Caland. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContactHeader : UIView

+ (ContactHeader *)headSection:(UIStoryboard *)storyboard;

@property (retain, nonatomic) IBOutlet UILabel *sectionName;

@property(nonatomic, retain) IBOutlet UILabel *countLabel;

@end
