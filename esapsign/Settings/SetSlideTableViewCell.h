//
//  SetSlideTableViewCell.h
//  esapsign
//
//  Created by Caland on 14-8-29.
//  Copyright (c) 2014年 Caland. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SetSlideTableViewCellDelegate <NSObject>

@required
- (void) setSlideChanged:(CGFloat) value withType:(NSString *) type;


@end

@interface SetSlideTableViewCell : UITableViewCell

@property (nonatomic, retain) NSString *type;

@property (nonatomic, assign) id<SetSlideTableViewCellDelegate> delegate;

@property (nonatomic, retain) IBOutlet UISlider *slider;

@property (nonatomic, retain) IBOutlet UILabel *nameLabel;

@property (nonatomic, retain) IBOutlet UILabel *numLabel;

- (IBAction) slideValueChanged:(id)sender;

@end
