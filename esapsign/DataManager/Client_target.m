//
//  Client_target.m
//  esapsign
//
//  Created by Suzic on 14-8-11.
//  Copyright (c) 2014年 Caland. All rights reserved.
//

#import "Client_target.h"
#import "Client_file.h"
#import "Client_file.h"
#import "DataManager.h"
#import "DataManager+Targets.h"

@implementation Client_target

@dynamic account_id;
@dynamic target_id;
@dynamic create_time;
@dynamic display_name;
@dynamic file_id;
@dynamic last_time_stamp;
@dynamic parent_id;
@dynamic record_status;
@dynamic type;
@dynamic update_time;
@dynamic clientFile;
@synthesize manager = _manager;
@synthesize subFolders = _subFolders;
@synthesize subFiles = _subFiles;

- (NSArray *)subFolders
{
    if (!_subFolders)
    {
        NSArray *folders = [self.manager foldersWithParentTarget:self.target_id];
        _subFolders = folders;
    }
    return _subFolders;
}

- (NSArray *)subFiles
{
    if (!_subFiles)
    {
        NSArray *files = [self.manager filesWithParentTarget:self.target_id];
        _subFiles = files;
    }
    return _subFiles;
}

@end
