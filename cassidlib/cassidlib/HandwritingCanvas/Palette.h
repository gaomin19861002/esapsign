//
//  Palette.h
//  MyPalette
//
//  Created by xiaozhu on 11-6-23.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface Palette : UIView
{
	float x;
	float y;
	//-------------------------
	int             Intsegmentcolor;
	float           Intsegmentwidth;
	CGColorRef      segmentColor;
	//-------------------------
	NSMutableArray* myallpoint;
	NSMutableArray* myallline;
	NSMutableArray* myallColor;
	NSMutableArray* myallwidth;
	
	CGPoint MyBeganpoint;
	CGPoint MyMovepoint;
    
    
    CGPoint                 minPoint;
    CGPoint                 maxPoint;
}
@property float x;
@property float y;
@property(nonatomic, assign)int     curSegmentColor;
@property(nonatomic, assign)int     curSegmentWidth;

-(void)Introductionpoint1;
-(void)Introductionpoint2;
-(void)Introductionpoint3:(CGPoint)sender;
-(void)Introductionpoint4:(int)sender;
-(void)Introductionpoint5:(int)sender;

//=====================================
-(void)myalllineclear;
-(void)myLineFinallyRemove;
//-(void)myrubbereraser;

-(UIImage *)save;
-(CGRect)imageFrame;
@end
