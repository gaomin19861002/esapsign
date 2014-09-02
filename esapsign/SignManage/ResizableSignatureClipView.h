//
//  ResizableSignatureClipView.h
//  esapsign
//
//  Created by Suzic on 14-8-28.
//  Copyright (c) 2014年 Caland. All rights reserved.
//

#import "SignatureClipView.h"

@interface ResizableSignatureClipView : SignatureClipView

@property (nonatomic, assign) float maxWidth;
@property (nonatomic, assign) float minWidth;

@end
