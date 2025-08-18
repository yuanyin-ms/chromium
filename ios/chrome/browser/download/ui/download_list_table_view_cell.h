// Copyright 2024 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#ifndef IOS_CHROME_BROWSER_DOWNLOAD_UI_DOWNLOAD_LIST_TABLE_VIEW_CELL_H_
#define IOS_CHROME_BROWSER_DOWNLOAD_UI_DOWNLOAD_LIST_TABLE_VIEW_CELL_H_

#import "ios/chrome/browser/shared/ui/table_view/cells/table_view_url_item.h"

// Table view cell for displaying download items.
// This cell extends Chrome's standard TableViewURLCell and is configured
// entirely through the DownloadListItem's configureCell:withStyler: method
// which leverages TableViewURLItem's built-in properties for consistency.
@interface DownloadListTableViewCell : TableViewURLCell

// Note: Cell configuration is handled by DownloadListItem using TableViewURLItem properties.
// No additional methods are needed as the parent class functionality is sufficient.

@end

#endif  // IOS_CHROME_BROWSER_DOWNLOAD_UI_DOWNLOAD_LIST_TABLE_VIEW_CELL_H_