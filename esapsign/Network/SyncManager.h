//
//  SyncManager.h
//  esapsign
//
//  Created by Suzic on 14-9-2.
//  Copyright (c) 2014年 Caland. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface SyncManager : NSObject
{
@public
    BOOL reqireSignMark;
}

DefaultInstanceForClassHeader(SyncManager);

@property(nonatomic, retain) UIViewController *parentController;

- (void)startSync;

@end
