// Copyright 2024 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "ios/chrome/browser/download/ui/download_list_table_view_controller.h"

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "ios/chrome/browser/download/model/download_record.h"
#import "ios/chrome/browser/download/model/download_list_item.h"
#import "ios/chrome/browser/download/ui/download_list_consumer.h"
#import "ios/chrome/browser/download/ui/download_list_table_view_cell.h"
#import "ios/chrome/browser/shared/ui/table_view/table_view_model.h"
#import "ios/chrome/browser/shared/ui/table_view/table_view_utils.h"
#import "ios/chrome/browser/net/model/crurl.h"
#import "ios/chrome/grit/ios_strings.h"
#import "ui/base/l10n/l10n_util.h"

typedef NS_ENUM(NSInteger, SectionIdentifier) {
  SectionIdentifierDownloads = 1000,  // Use a high value to avoid conflicts
};

typedef NS_ENUM(NSInteger, ItemType) {
  ItemTypeDownload = 100,   // Must be >= kItemTypeEnumZero (100)
};

@interface DownloadListTableViewController ()

// Array of download records to display.
@property(nonatomic, assign) std::vector<DownloadRecord> downloads;

@end

@implementation DownloadListTableViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.title = l10n_util::GetNSString(IDS_IOS_DOWNLOAD_LIST_TITLE);
  
  // Configure navigation bar for large titles
  self.navigationController.navigationBar.prefersLargeTitles = YES;

  [self loadModel];
}

- (void)loadModel {
  [super loadModel];
  
  // Add a single section for all downloads
  [self.tableViewModel addSectionWithIdentifier:SectionIdentifierDownloads];
  
  // Add all downloads to the single section
  for (const auto& downloadRecord : self.downloads) {
    DownloadListItem* item = [[DownloadListItem alloc] initWithType:ItemTypeDownload
                                                     downloadRecord:downloadRecord];
    // Set the cell class here in the UI layer to avoid circular dependency
    item.cellClass = [DownloadListTableViewCell class];
    [self.tableViewModel addItem:item toSectionWithIdentifier:SectionIdentifierDownloads];
  }
}

#pragma mark - DownloadListConsumer

- (void)setDownloadRecords:(const std::vector<DownloadRecord>&)records {
  self.downloads = records;
  
  [self loadModel];
}

- (void)setLoadingState:(BOOL)loading {
}

- (void)setEmptyState:(BOOL)empty {
  if (empty) {
    // Empty downloads: show small title
    self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
  } else {
    // Non-empty downloads: show large title initially
    self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeAlways;
  }
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath {
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
  
  // Get the selected item directly from the downloads vector
  NSUInteger rowIndex = indexPath.row;
  
  if (rowIndex < self.downloads.size()) {
    DownloadRecord selectedRecord = self.downloads[rowIndex];
    [self.delegate downloadListTableViewControllerDidSelectRecord:selectedRecord];
  }
}

@end
