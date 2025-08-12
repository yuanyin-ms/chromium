// Copyright 2025 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#ifndef IOS_CHROME_BROWSER_DOWNLOAD_UI_DOWNLOAD_LIST_VIEW_CONTROLLER_H_
#define IOS_CHROME_BROWSER_DOWNLOAD_UI_DOWNLOAD_LIST_VIEW_CONTROLLER_H_

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#include <vector>

#import "ios/chrome/browser/download/model/download_record_service.h"
#import "ios/chrome/browser/download/ui/download_list_consumer.h"
#include "ios/chrome/browser/download/model/download_record.h"

@protocol DownloadListViewControllerDelegate <NSObject>
#pragma mark - Download List Actions
  // Notifies the delegate that a download was selected.
  - (void)downloadListViewControllerDidSelectRecord:(const DownloadRecord&)record;
  // Notifies the delegate that the download list needs refresh by file type.
  - (void)downloadListViewControllerDidFilterByFileType:(NSString*)fileType;
  // Notifies the delegate that the download list needs refresh by keyword.
  - (void)downloadListViewControllerDidSearchByKeyword:(NSString*)keyword;
  // Notifies the delegate that the user clicked on the "Cancel" for a download
  // record.
  - (void)downloadListViewControllerDidClickCancelRecord:(const DownloadRecord&)record;
  // Notifies the delegate that the user clicked on the "Delete" button for a
  // download record.
  - (void)downloadListViewControllerDidDeleteRecord:(const DownloadRecord&)record;
#pragma mark - Download List More Actions
  // Notifies the delegate that the user clicked on the "Share" button for a
  // download record.
  - (void)downloadListViewControllerDidClickShareRecord:(const DownloadRecord&)record;
  // Notifies the delegate that the user clicked on the "Show in Files App"
  // button for a download record.
  - (void)downloadListViewControllerDidClickShowInFilesAppForRecord:(const DownloadRecord&)record;
@end

// View controller for displaying download list.
@interface DownloadListViewController
    : UITableViewController <DownloadListConsumer>
@property(nonatomic, weak) id<DownloadListViewControllerDelegate> delegate;
@property(nonatomic, assign) BOOL isLoading;
@property(nonatomic, assign) BOOL isEmpty;

@end

#endif  // IOS_CHROME_BROWSER_DOWNLOAD_UI_DOWNLOAD_LIST_VIEW_CONTROLLER_H_
