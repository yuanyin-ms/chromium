// Copyright 2025 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#ifndef IOS_CHROME_BROWSER_DOWNLOAD_UI_DOWNLOAD_LIST_CONSUMER_H_
#define IOS_CHROME_BROWSER_DOWNLOAD_UI_DOWNLOAD_LIST_CONSUMER_H_

#import <Foundation/Foundation.h>
#include <vector>

#import "ios/chrome/browser/download/model/download_record_service.h"

// Consumer for the download list mediator.
@protocol DownloadListConsumer <NSObject>

// Updates the download list with new records.
- (void)setDownloadRecords:(const std::vector<DownloadRecord>&)records;

// Shows loading state.
- (void)setLoadingState:(BOOL)loading;

// Shows empty state when no downloads exist.
- (void)setEmptyState:(BOOL)empty;

@end

#endif  // IOS_CHROME_BROWSER_DOWNLOAD_UI_DOWNLOAD_LIST_CONSUMER_H_
