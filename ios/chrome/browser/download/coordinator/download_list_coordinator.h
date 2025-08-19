// Copyright 2025 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#ifndef IOS_CHROME_BROWSER_DOWNLOAD_COORDINATOR_DOWNLOAD_LIST_COORDINATOR_H_
#define IOS_CHROME_BROWSER_DOWNLOAD_COORDINATOR_DOWNLOAD_LIST_COORDINATOR_H_

#import "ios/chrome/browser/shared/coordinator/chrome_coordinator/chrome_coordinator.h"

// Coordinates presentation of Download List UI.
@interface DownloadListCoordinator : ChromeCoordinator

// Shows the download list.
- (void)showDownloadList;

// Closes the download list.
- (void)closeDownloadList;

@end

#endif  // IOS_CHROME_BROWSER_DOWNLOAD_COORDINATOR_DOWNLOAD_LIST_COORDINATOR_H_
