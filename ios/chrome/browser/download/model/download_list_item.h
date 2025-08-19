// Copyright 2024 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#ifndef IOS_CHROME_BROWSER_DOWNLOAD_MODEL_DOWNLOAD_LIST_ITEM_H_
#define IOS_CHROME_BROWSER_DOWNLOAD_MODEL_DOWNLOAD_LIST_ITEM_H_

#import "ios/chrome/browser/shared/ui/table_view/cells/table_view_url_item.h"
#import "ios/chrome/browser/download/model/download_record.h"

// Table view item for download list entries.
// This item extends Chrome's standard TableViewURLItem to add download-specific
// functionality while maintaining consistency with Chrome's UI framework.
@interface DownloadListItem : TableViewURLItem

// Designated initializer.
- (instancetype)initWithType:(NSInteger)type downloadRecord:(const DownloadRecord&)downloadRecord;

@end

#endif  // IOS_CHROME_BROWSER_DOWNLOAD_MODEL_DOWNLOAD_LIST_ITEM_H_