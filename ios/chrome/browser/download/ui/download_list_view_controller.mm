// Copyright 2025 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "ios/chrome/browser/download/ui/download_list_view_controller.h"

#import "ios/chrome/browser/download/model/download_record_service.h"
#import "base/logging.h"

@interface DownloadListViewController () {
  std::vector<DownloadRecord> downloadRecords_;
}
@end

@implementation DownloadListViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.title = @"Downloads";
  
  // Configure table view
  self.tableView.estimatedRowHeight = 80.0;
  self.tableView.rowHeight = UITableViewAutomaticDimension;
  
  // Don't register cell class - we'll create it manually with subtitle style
  
  DLOG(INFO) << "DownloadListViewController loaded";
}

#pragma mark - DownloadListConsumer

- (void)setDownloadRecords:(const std::vector<DownloadRecord>&)records {
  downloadRecords_ = records;
  
  DLOG(INFO) << "DownloadListViewController: setDownloadRecords called with " 
             << records.size() << " records";
  
  dispatch_async(dispatch_get_main_queue(), ^{
    [self.tableView reloadData];
  });
}

- (void)setLoadingState:(BOOL)loading {
  self.isLoading = loading;
  // TODO: Show loading indicator
}

- (void)setEmptyState:(BOOL)empty {
  self.isEmpty = empty;
  // TODO: Show empty state view
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section {
  NSInteger count = static_cast<NSInteger>(downloadRecords_.size());
  DLOG(INFO) << "numberOfRowsInSection returning: " << count;
  return count;
}

- (UITableViewCell*)tableView:(UITableView*)tableView 
        cellForRowAtIndexPath:(NSIndexPath*)indexPath {
  
  static NSString* cellIdentifier = @"DownloadCell";
  UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
  
  if (!cell) {
    // Create cell with subtitle style to enable detailTextLabel
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                   reuseIdentifier:cellIdentifier];
  }
  
  NSInteger row = indexPath.row;
  if (row >= 0 && static_cast<size_t>(row) < downloadRecords_.size()) {
    const DownloadRecord& record = downloadRecords_[row];
    
    // Set file name as main text
    cell.textLabel.text = [NSString stringWithUTF8String:record.file_name.c_str()];
    
    // Create detailed status text with download progress and state
    NSString* stateText = [self stateTextForDownloadState:record.state];
    NSString* sizeText = [self formatFileSizeText:record.file_size];
    NSString* progressText = [self formatProgressText:record];
    
    // Combine status, progress, and file size information
    NSString* detailText;
    if (record.state == web::DownloadTask::State::kInProgress) {
      // For in-progress downloads, show progress percentage and size info
      if (progressText) {
        detailText = [NSString stringWithFormat:@"%@ • %@ • %@", stateText, progressText, sizeText];
      } else {
        detailText = [NSString stringWithFormat:@"%@ • %@", stateText, sizeText];
      }
    } else {
      // For completed/failed downloads, show state and size
      detailText = [NSString stringWithFormat:@"%@ • %@", stateText, sizeText];
    }
    
    cell.detailTextLabel.text = detailText;
    
    // Set text color based on download state
    cell.detailTextLabel.textColor = [self colorForDownloadState:record.state];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
  }
  
  return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath {
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
  
  NSInteger row = indexPath.row;
  if (row >= 0 && static_cast<size_t>(row) < downloadRecords_.size()) {
    const DownloadRecord& record = downloadRecords_[row];
    
    DLOG(INFO) << "Selected download: " << record.file_name;
    // TODO: Handle download selection
  }
}

#pragma mark - Helper Methods

- (NSString*)stateTextForDownloadState:(web::DownloadTask::State)state {
  switch (state) {
    case web::DownloadTask::State::kNotStarted:
      return @"Not Started";
    case web::DownloadTask::State::kInProgress:
      return @"Downloading";
    case web::DownloadTask::State::kComplete:
      return @"Completed";
    case web::DownloadTask::State::kFailed:
      return @"Failed";
    case web::DownloadTask::State::kFailedNotResumable:
      return @"Failed (Not Resumable)";
    case web::DownloadTask::State::kCancelled:
      return @"Cancelled";
    default:
      return @"Unknown";
  }
}

- (NSString*)formatFileSizeText:(int64_t)fileSize {
  if (fileSize == 0) {
    return @"Unknown size";
  }
  
  // Format file size in human-readable format
  if (fileSize < 1024) {
    return [NSString stringWithFormat:@"%lld B", fileSize];
  } else if (fileSize < 1024 * 1024) {
    return [NSString stringWithFormat:@"%.1f KB", fileSize / 1024.0];
  } else if (fileSize < 1024 * 1024 * 1024) {
    return [NSString stringWithFormat:@"%.1f MB", fileSize / (1024.0 * 1024.0)];
  } else {
    return [NSString stringWithFormat:@"%.1f GB", fileSize / (1024.0 * 1024.0 * 1024.0)];
  }
}

- (NSString*)formatProgressText:(const DownloadRecord&)record {
  if (record.state != web::DownloadTask::State::kInProgress) {
    return nil;
  }
  
  // Use progress_percent if available, similar to DownloadManagerMediator::GetDownloadManagerProgress()
  if (record.progress_percent >= 0 && record.progress_percent <= 100) {
    return [NSString stringWithFormat:@"%d%%", record.progress_percent];
  }
  
  // Fall back to bytes-based progress if percentage is not available
  if (record.total_bytes > 0 && record.received_bytes >= 0) {
    float progress = (float)record.received_bytes / (float)record.total_bytes * 100.0f;
    return [NSString stringWithFormat:@"%.0f%%", progress];
  }
  
  // If no progress info available, return nil
  return nil;
}

- (UIColor*)colorForDownloadState:(web::DownloadTask::State)state {
  switch (state) {
    case web::DownloadTask::State::kInProgress:
      return [UIColor systemBlueColor];
    case web::DownloadTask::State::kComplete:
      return [UIColor systemGreenColor];
    case web::DownloadTask::State::kFailed:
    case web::DownloadTask::State::kFailedNotResumable:
      return [UIColor systemRedColor];
    case web::DownloadTask::State::kCancelled:
      return [UIColor systemOrangeColor];
    case web::DownloadTask::State::kNotStarted:
    default:
      return [UIColor systemGrayColor];
  }
}

@end
