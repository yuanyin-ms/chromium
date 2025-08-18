// Copyright 2024 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#ifndef IOS_CHROME_BROWSER_DOWNLOAD_UI_DOWNLOAD_LIST_TABLE_VIEW_CONTROLLER_H_
#define IOS_CHROME_BROWSER_DOWNLOAD_UI_DOWNLOAD_LIST_TABLE_VIEW_CONTROLLER_H_

#import "ios/chrome/browser/shared/ui/table_view/legacy_chrome_table_view_controller.h"
#import "ios/chrome/browser/download/model/download_record.h"
#import "ios/chrome/browser/download/ui/download_list_consumer.h"

#include <vector>

@protocol DownloadListTableViewControllerDelegate;

// Table view controller for displaying a list of downloads with date grouping.
@interface DownloadListTableViewController : LegacyChromeTableViewController <DownloadListConsumer>

// Delegate for handling download list events.
@property(nonatomic, weak) id<DownloadListTableViewControllerDelegate> delegate;

@end

// Delegate protocol for download list table view controller events.
@protocol DownloadListTableViewControllerDelegate <NSObject>

#pragma mark - Download List Actions
// Notifies the delegate that a download was selected.
- (void)downloadListTableViewControllerDidSelectRecord:(const DownloadRecord&)record;
// Notifies the delegate that the download list needs refresh by file type.
- (void)downloadListTableViewControllerDidFilterByFileType:(NSString*)fileType;
// Notifies the delegate that the download list needs refresh by keyword.
- (void)downloadListTableViewControllerDidSearchByKeyword:(NSString*)keyword;
// Notifies the delegate that the user clicked on the "Cancel" for a download
// record.
- (void)downloadListTableViewControllerDidClickCancelRecord:(const DownloadRecord&)record;
// Notifies the delegate that the user clicked on the "Delete" button for a
// download record.
- (void)downloadListTableViewControllerDidDeleteRecord:(const DownloadRecord&)record;
#pragma mark - Download List More Actions
// Notifies the delegate that the user clicked on the "Share" button for a
// download record.
- (void)downloadListTableViewControllerDidClickShareRecord:(const DownloadRecord&)record;
// Notifies the delegate that the user clicked on the "Show in Files App"
// button for a download record.
- (void)downloadListTableViewControllerDidClickShowInFilesAppForRecord:(const DownloadRecord&)record;

@end

#endif  // IOS_CHROME_BROWSER_DOWNLOAD_UI_DOWNLOAD_LIST_TABLE_VIEW_CONTROLLER_H_
