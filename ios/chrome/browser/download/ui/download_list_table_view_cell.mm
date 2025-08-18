// Copyright 2024 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "ios/chrome/browser/download/ui/download_list_table_view_cell.h"

#import "ios/chrome/common/ui/colors/semantic_color_names.h"
#import "ios/chrome/common/ui/favicon/favicon_view.h"

namespace {
// Accessibility constants
NSString* const kAccessibilityCommaSeparator = @", ";
NSString* const kTruncationEllipsis = @"...";
const NSUInteger kMaxAccessibilityTextLength = 200;
}  // namespace

@interface DownloadListTableViewCell ()

@end

@implementation DownloadListTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString*)reuseIdentifier {
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  if (self) {
    // No additional setup needed
  }
  return self;
}

// Note: Cell configuration is now handled entirely by DownloadListItem's configureCell:withStyler: method
// which leverages the built-in TableViewURLItem properties for consistency with the framework.

- (void)prepareForReuse {
  [super prepareForReuse];
  
  // Clear cell-specific state to prevent data from previous cell reuse
  self.titleLabel.text = nil;
  self.URLLabel.text = nil;
  self.URLLabel.textColor = [UIColor colorNamed:kTextSecondaryColor];
  
  // Reset favicon to default state
  [self.faviconView configureWithAttributes:nil];
}

#pragma mark - UIAccessibility

- (NSString*)accessibilityLabel {
  NSMutableString* accessibilityText = [[NSMutableString alloc] init];
  
  if (self.titleLabel.text.length > 0) {
    [accessibilityText appendString:self.titleLabel.text];
  }
  
  if (self.URLLabel.text.length > 0) {
    if (accessibilityText.length > 0) {
      [accessibilityText appendString:kAccessibilityCommaSeparator];
    }
    [accessibilityText appendString:self.URLLabel.text];
  }
  
  // Limit accessibility text length for better user experience
  NSString* result = [accessibilityText copy];
  if (result.length > kMaxAccessibilityTextLength) {
    result = [result substringToIndex:kMaxAccessibilityTextLength];
    result = [result stringByAppendingString:kTruncationEllipsis];
  }
  
  return result;
}

- (NSArray<NSString*>*)accessibilityUserInputLabels {
  NSMutableArray<NSString*>* userInputLabels = [[NSMutableArray alloc] init];
  
  if (self.titleLabel.text) {
    [userInputLabels addObject:self.titleLabel.text];
  }
  
  return userInputLabels;
}


@end