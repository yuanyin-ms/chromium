// Copyright 2024 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "ios/chrome/browser/download/model/download_list_item.h"

#import "base/apple/foundation_util.h"
#import "base/strings/sys_string_conversions.h"
#import "base/time/time.h"
#import "ios/chrome/browser/download/model/download_record.h"
#import "ios/chrome/browser/net/model/crurl.h"
#import "ios/chrome/browser/shared/ui/table_view/cells/table_view_cell.h"
#import "ios/chrome/browser/shared/ui/table_view/cells/table_view_url_item.h"
#import "ios/chrome/common/ui/colors/semantic_color_names.h"
#import "ios/chrome/grit/ios_strings.h"
#import "ui/base/l10n/l10n_util.h"
#import "ui/base/l10n/time_format.h"

namespace {
// String constants for UI formatting
NSString* const kBulletSeparator = @" · ";
NSString* const kSlashSeparator = @"/";
}  // namespace

@class ChromeTableViewStyler;

@interface DownloadListItem ()

// Internal reference to the download record (hidden from external access)
@property(nonatomic, assign) DownloadRecord downloadRecord;

@end

@implementation DownloadListItem

#pragma mark - Initialization

- (instancetype)initWithType:(NSInteger)type downloadRecord:(const DownloadRecord&)downloadRecord {
  self = [super initWithType:type];
  if (self) {
    // Store the download record and configure the table view item properties
    self.downloadRecord = downloadRecord;
    [self configureForDownloadRecord];
  }
  return self;
}

#pragma mark - Configuration

/// Configures the table view item properties based on the download record.
/// Sets the title to the filename and detail text based on download state.
- (void)configureForDownloadRecord {
  self.title = [self filename];
  self.detailText = [self detailTextForDownloadState];
  self.accessibilityTraits = UIAccessibilityTraitButton;
}

#pragma mark - UI Properties

/// Returns the filename from the download record.
/// @return The filename as an NSString, or empty string if unavailable.
- (NSString*)filename {
  if (self.downloadRecord.file_name.empty()) {
    return @"";
  }
  NSString* filename = [NSString stringWithUTF8String:self.downloadRecord.file_name.c_str()];
  return (filename && filename.length > 0) ? filename : @"";
}

/// Returns an icon representing the file type based on the filename.
/// @return A UIImage icon for the file type, or nil if no icon is available.
- (UIImage*)fileTypeIcon {
  NSString* filename = [NSString stringWithUTF8String:self.downloadRecord.file_name.c_str()];
  return [self fileTypeIconForFilename:filename];
}

/// Returns a human-readable formatted string for the total file size.
/// @return Formatted size string (e.g., "1.5 MB") using NSByteCountFormatter.
- (NSString*)formattedTotalSize {
  return [self formattedSizeFromBytes:self.downloadRecord.total_bytes];
}

/// Returns a human-readable formatted string for the downloaded bytes.
/// @return Formatted size string showing how much has been downloaded.
- (NSString*)formattedDownloadedSize {
  return [self formattedSizeFromBytes:self.downloadRecord.received_bytes];
}

/// Extracts and returns the host name from the download's source URL.
/// @return The host name as an NSString, or empty string if URL is invalid.
- (NSString*)hostFromURL {
  if (self.downloadRecord.url.empty()) {
    return @"";
  }
  
  GURL gurl(self.downloadRecord.url);
  if (!gurl.is_valid()) {
    return @"";
  }
  
  std::string host = gurl.host();
  if (host.empty()) {
    return @"";
  }
  
  NSString* hostString = [NSString stringWithUTF8String:host.c_str()];
  return hostString ? hostString : @"";
}

/// Calculates and returns the estimated time remaining for an active download.
/// Only applies to downloads in progress with known total size.
/// @return Formatted time string (e.g., "2 min left") or empty string if not applicable.
- (NSString*)estimatedTimeRemaining {
  // Only calculate for downloads in progress with valid data
  if (self.downloadRecord.state != web::DownloadTask::State::kInProgress ||
      self.downloadRecord.received_bytes <= 0 ||
      self.downloadRecord.total_bytes <= 0) {
    return @"";
  }
  
  int64_t remainingBytes = self.downloadRecord.total_bytes - self.downloadRecord.received_bytes;
  if (remainingBytes <= 0) {
    return @"";
  }
  
  // Calculate elapsed time since download started
  NSTimeInterval elapsedTime = [[NSDate date] timeIntervalSinceDate:
      [NSDate dateWithTimeIntervalSince1970:self.downloadRecord.created_time.InSecondsFSinceUnixEpoch()]];
  
  if (elapsedTime <= 0) {
    return @"";
  }
  
  // Calculate download speed and estimate remaining time
  double downloadSpeed = (double)self.downloadRecord.received_bytes / elapsedTime;
  if (downloadSpeed <= 0) {
    return @"";
  }
  
  base::TimeDelta remaining = base::Seconds(remainingBytes / downloadSpeed);
  std::u16string time_remaining_text = ui::TimeFormat::Simple(
      ui::TimeFormat::FORMAT_REMAINING, ui::TimeFormat::LENGTH_SHORT, remaining);
  
  return base::SysUTF16ToNSString(time_remaining_text);
}

#pragma mark - TableViewItem

/// Configures the table view cell with download-specific styling and content.
/// Sets text color based on download state and replaces favicon with file type icon.
/// @param tableCell The table view cell to configure.
/// @param styler The styler for applying visual styling.
- (void)configureCell:(TableViewCell*)tableCell
           withStyler:(ChromeTableViewStyler*)styler {
  [super configureCell:tableCell withStyler:styler];
  
  TableViewURLCell* urlCell = (TableViewURLCell*)tableCell;
  // Set text color based on download state (red for failed, normal for others)
  urlCell.URLLabel.textColor = [self textColorForDownloadState];
  
  // Replace the default favicon with a file type icon if available
  UIImage* fileTypeIcon = [self fileTypeIcon];
  if (fileTypeIcon) {
    [urlCell replaceFaviconWithSymbol:fileTypeIcon];
  }
  
  [urlCell configureUILayout];
}

/// Generates the detail text string based on the current download state.
/// Returns different information depending on whether the download is in progress,
/// completed, failed, or in another state.
/// @return Formatted detail text string appropriate for the download state.
- (NSString*)detailTextForDownloadState {
  switch (self.downloadRecord.state) {
    case web::DownloadTask::State::kFailed: {
      // For failed downloads, show file size and status
      if (self.downloadRecord.total_bytes > 0) {
        return [NSString stringWithFormat:@"%@%@%@",
                [self formattedTotalSize],
                kBulletSeparator,
                [self statusTextForDownloadState:self.downloadRecord.state]];
      } else {
        // No file size available, just show status
        return [self statusTextForDownloadState:self.downloadRecord.state];
      }
    }
      
    case web::DownloadTask::State::kComplete: {
      // For completed downloads, show file size and/or source host
      NSString* hostFromURL = [self hostFromURL];
      if (self.downloadRecord.total_bytes > 0) {
        // Show file size, optionally with source host
        if (hostFromURL && hostFromURL.length > 0) {
          return [NSString stringWithFormat:@"%@%@%@",
                  [self formattedTotalSize],
                  kBulletSeparator,
                  hostFromURL];
        } else {
          return [self formattedTotalSize];
        }
      } else {
        // No file size available, show status and optionally host
        if (hostFromURL && hostFromURL.length > 0) {
          return [NSString stringWithFormat:@"%@%@%@",
                  [self statusTextForDownloadState:self.downloadRecord.state],
                  kBulletSeparator,
                  hostFromURL];
        } else {
          return [self statusTextForDownloadState:self.downloadRecord.state];
        }
      }
    }
      
    case web::DownloadTask::State::kInProgress: {
      // For downloads in progress, show progress and optionally time remaining
      if (self.downloadRecord.total_bytes > 0) {
        NSString* progressText = [NSString stringWithFormat:@"%@%@%@",
                                 [self formattedDownloadedSize],
                                 kSlashSeparator,
                                 [self formattedTotalSize]];
        
        NSString* timeRemaining = [self estimatedTimeRemaining];
        if (timeRemaining && timeRemaining.length > 0) {
          return [NSString stringWithFormat:@"%@%@%@",
                  progressText, kBulletSeparator, timeRemaining];
        } else {
          return progressText;
        }
      } else {
        // No total size known, just show status
        return [self statusTextForDownloadState:self.downloadRecord.state];
      }
    }
      
    default:
      // For all other states, show the localized status text
      return [self statusTextForDownloadState:self.downloadRecord.state];
  }
}

/// Returns the appropriate text color based on the download state.
/// Failed downloads use red color, all others use secondary text color.
/// @return UIColor for the text based on download state.
- (UIColor*)textColorForDownloadState {
  if (self.downloadRecord.state == web::DownloadTask::State::kFailed) {
    return [UIColor colorNamed:kRedColor];
  } else {
    return [UIColor colorNamed:kTextSecondaryColor];
  }
}

#pragma mark - Private Helper Methods

/// Formats a byte count into a human-readable string using system formatting.
/// @param bytes The number of bytes to format.
/// @return A formatted string like "1.5 MB" or "234 KB".
- (NSString*)formattedSizeFromBytes:(int64_t)bytes {
  NSByteCountFormatter* formatter = [[NSByteCountFormatter alloc] init];
  formatter.countStyle = NSByteCountFormatterCountStyleFile;
  return [formatter stringFromByteCount:bytes];
}

/// Returns a localized status text string for the given download state.
/// Maps download task states to user-friendly localized strings.
/// @param state The download task state to get text for.
/// @return Localized status text (e.g., "Downloading", "Complete", "Failed").
- (NSString*)statusTextForDownloadState:(web::DownloadTask::State)state {
  switch (state) {
    case web::DownloadTask::State::kInProgress:
      return l10n_util::GetNSString(IDS_IOS_DOWNLOAD_STATE_IN_PROGRESS);
    case web::DownloadTask::State::kComplete:
      return l10n_util::GetNSString(IDS_IOS_DOWNLOAD_STATE_COMPLETED);
    case web::DownloadTask::State::kFailed:
      return l10n_util::GetNSString(IDS_IOS_DOWNLOAD_STATE_FAILED);
    case web::DownloadTask::State::kCancelled:
      return l10n_util::GetNSString(IDS_IOS_DOWNLOAD_STATE_CANCELLED);
    case web::DownloadTask::State::kNotStarted:
      return l10n_util::GetNSString(IDS_IOS_DOWNLOAD_STATE_PAUSED);
    default:
      return @"";
  }
}

/// Returns an icon representing the file type based on the filename extension.
/// Currently returns nil as file type icon functionality is not yet implemented.
/// @param filename The filename to determine the icon for.
/// @return A UIImage icon for the file type, or nil if not available.
- (UIImage*)fileTypeIconForFilename:(NSString*)filename {
  // TODO: File type icon implementation will be added separately
  return nil;
}

@end