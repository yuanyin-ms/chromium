// Copyright 2025 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#ifndef IOS_CHROME_BROWSER_DOWNLOAD_UI_DOWNLOAD_LIST_VIEW_CONTROLLER_H_
#define IOS_CHROME_BROWSER_DOWNLOAD_UI_DOWNLOAD_LIST_VIEW_CONTROLLER_H_

#import <UIKit/UIKit.h>
#include <vector>

#import "ios/chrome/browser/download/ui/download_list_consumer.h"
#import "ios/chrome/browser/download/model/download_record_service.h"

// View controller for displaying download list.
@interface DownloadListViewController : UITableViewController <DownloadListConsumer>

@property(nonatomic, assign) BOOL isLoading;
@property(nonatomic, assign) BOOL isEmpty;

@end

#endif  // IOS_CHROME_BROWSER_DOWNLOAD_UI_DOWNLOAD_LIST_VIEW_CONTROLLER_H_
