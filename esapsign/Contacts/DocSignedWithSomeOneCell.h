//
//  DocSignedWithSomeOneCell.h
//  PdfEditor
//
//  Created by MinwenYi on 14-4-1.
//  Copyright (c) 2014年 MinwenYi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DocSignedWithSomeOneCell : UITableViewCell

@property (retain, nonatomic) IBOutlet UIImageView *docFaceImageView;
@property (retain, nonatomic) IBOutlet UILabel *docNameLabel;
//@property (retain, nonatomic) IBOutlet UILabel *firstSignerLabel;
//@property (retain, nonatomic) IBOutlet UILabel *docSumarryLabel;
@property (retain, nonatomic) IBOutlet UILabel *dateLabel;
//@property (retain, nonatomic) IBOutlet UILabel *docSizeLabel;

@end
