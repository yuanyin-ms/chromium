// Copyright 2025 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "ios/chrome/browser/download/coordinator/download_list_coordinator.h"

#include <memory>

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "base/logging.h"
#include "ios/chrome/browser/download/coordinator/download_list_mediator.h"
#include "ios/chrome/browser/download/model/download_record.h"
#import "ios/chrome/browser/download/model/download_record_service.h"
#import "ios/chrome/browser/download/model/download_record_service_factory.h"
#import "ios/chrome/browser/download/ui/download_list_view_controller.h"
#import "ios/chrome/browser/shared/model/browser/browser.h"
#import "ios/chrome/browser/shared/model/profile/profile_ios.h"
#import "ios/web/public/download/download_task.h"

@interface DownloadListCoordinator () <DownloadListViewControllerDelegate>
@property(nonatomic, strong) DownloadListViewController* viewController;
@property(nonatomic, strong) UINavigationController* navigationController;
@property(nonatomic, assign) BOOL isRecoveringFromBackground;
@end

@implementation DownloadListCoordinator {
  std::unique_ptr<DownloadListMediator> _mediator;
}

- (void)start {
  [super start];

  // Create view controller
  self.viewController = [[DownloadListViewController alloc] init];
  self.viewController.delegate = self;

  // Create mediator
  _mediator = std::make_unique<DownloadListMediator>();

  // Get download record service
  ProfileIOS* profile = self.browser->GetProfile();
  DownloadRecordService* downloadRecordService =
      DownloadRecordServiceFactory::GetForProfile(profile);

  // Configure mediator
  _mediator->SetDownloadRecordService(downloadRecordService);
  _mediator->SetConsumer(self.viewController);

  // Add observer for becoming active
  [[NSNotificationCenter defaultCenter]
      addObserver:self
         selector:@selector(applicationDidBecomeActive:)
             name:UIApplicationDidBecomeActiveNotification
           object:nil];
  // Add observer for resigning active
  [[NSNotificationCenter defaultCenter]
      addObserver:self
         selector:@selector(applicationWillResignActive:)
             name:UIApplicationWillResignActiveNotification
           object:nil];

  DLOG(INFO) << "DownloadListCoordinator started";
}

- (void)stop {
  [super stop];

  if (self.navigationController.presentingViewController) {
    [self.navigationController dismissViewControllerAnimated:YES
                                                  completion:nil];
  }

  _mediator.reset();
  self.viewController = nil;
  self.navigationController = nil;
  // Remove observers
  [[NSNotificationCenter defaultCenter]
      removeObserver:self
                name:UIApplicationDidBecomeActiveNotification
              object:nil];
  [[NSNotificationCenter defaultCenter]
      removeObserver:self
                name:UIApplicationWillResignActiveNotification
              object:nil];
  DLOG(INFO) << "DownloadListCoordinator stopped";
}

#pragma mark - Public methods

- (void)showDownloadList {
  if (!self.viewController) {
    [self start];
  }

  // Create navigation controller if needed
  if (!self.navigationController) {
    self.navigationController = [[UINavigationController alloc]
        initWithRootViewController:self.viewController];

    // Add close button
    UIBarButtonItem* closeButton = [[UIBarButtonItem alloc]
        initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                             target:self
                             action:@selector(closeButtonTapped)];
    self.viewController.navigationItem.rightBarButtonItem = closeButton;
  }

  // Present the view controller
  [self.baseViewController presentViewController:self.navigationController
                                        animated:YES
                                      completion:^{
                                        // Load download records after
                                        // presentation
                                        self->_mediator->LoadDownloadRecords();
                                      }];

  DLOG(INFO) << "DownloadListCoordinator presented";
}

#pragma mark - Private methods

- (void)closeButtonTapped {
  [self stop];
}
#pragma mark - Notification

- (void)applicationDidBecomeActive:(NSNotification*)notification {
  if (self.isRecoveringFromBackground) {
    self.isRecoveringFromBackground = NO;
    // Sync records if needed.
    _mediator->SyncRecordsIfNeeded();
  }
}

- (void)applicationWillResignActive:(NSNotification*)notification {
  // Set flag to indicate we are resigning active state
  self.isRecoveringFromBackground = YES;
}

#pragma mark - DownloadListViewControllerDelegate

- (void)downloadListViewControllerDidSelectRecord:(const DownloadRecord&)record {
  DLOG(INFO) << "Download selected: " << record.file_name;
  // TODO: Handle download selection (e.g., open file, show details)
}

- (void)downloadListViewControllerDidFilterByFileType:(NSString*)fileType {
  DLOG(INFO) << "Filter by file type: " << [fileType UTF8String];
  if (_mediator) {
    // TODO: Implement filtering logic in mediator
  }
}

- (void)downloadListViewControllerDidSearchByKeyword:(NSString*)keyword {
  DLOG(INFO) << "Search by keyword: " << [keyword UTF8String];
  // TODO: Implement search logic in mediator
}

- (void)downloadListViewControllerDidClickCancelRecord:(const DownloadRecord&)record {
  DLOG(INFO) << "Cancel download requested for: " << record.file_name;
  if (!_mediator) {
    DLOG(WARNING) << "Cancel download failed: mediator is null";
    return;
  }
  _mediator->CancelDownloadTask(record.download_id);
}

- (void)downloadListViewControllerDidDeleteRecord:(const DownloadRecord&)record {
  if (!_mediator) {
    DLOG(WARNING) << "Delete download failed: mediator is null";
    return;
  }
  _mediator->RemoveDownloadTask(record.download_id);
}

- (void)downloadListViewControllerDidClickShareRecord:(const DownloadRecord&)record {
  DLOG(INFO) << "Share download requested for: " << record.file_name;
  // TODO: Implement sharing functionality
}

- (void)downloadListViewControllerDidClickShowInFilesAppForRecord:
    (const DownloadRecord&)record {
  DLOG(INFO) << "Show in Files App requested for: " << record.file_name;
  // TODO: Implement showing file in Files app
}

@end
