// Copyright 2025 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "ios/chrome/browser/download/coordinator/download_list_coordinator.h"

#import "ios/chrome/browser/download/ui/download_list_view_controller.h"
#import "ios/chrome/browser/download/coordinator/download_list_mediator.h"
#import "ios/chrome/browser/download/model/download_record_service_factory.h"
#import "ios/chrome/browser/shared/model/browser/browser.h"
#import "ios/chrome/browser/shared/model/profile/profile_ios.h"
#import "base/logging.h"

@interface DownloadListCoordinator ()
@property(nonatomic, strong) DownloadListViewController* viewController;
@property(nonatomic, strong) UINavigationController* navigationController;
@end

@implementation DownloadListCoordinator {
  std::unique_ptr<DownloadListMediator> _mediator;
}

- (void)start {
  [super start];
  
  // Create view controller
  self.viewController = [[DownloadListViewController alloc] init];
  
  // Create mediator
  _mediator = std::make_unique<DownloadListMediator>();
  
  // Get download record service
  ProfileIOS* profile = self.browser->GetProfile();
  DownloadRecordService* downloadRecordService = 
      DownloadRecordServiceFactory::GetForProfile(profile);
  
  // Configure mediator
  _mediator->SetDownloadRecordService(downloadRecordService);
  _mediator->SetConsumer(self.viewController);
  
  DLOG(INFO) << "DownloadListCoordinator started";
}

- (void)stop {
  [super stop];
  
  if (self.navigationController.presentingViewController) {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
  }
  
  _mediator.reset();
  self.viewController = nil;
  self.navigationController = nil;
  
  DLOG(INFO) << "DownloadListCoordinator stopped";
}

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
    // Load download records after presentation
    self->_mediator->LoadDownloadRecords();
  }];
  
  DLOG(INFO) << "DownloadListCoordinator presented";
}

- (void)closeButtonTapped {
  [self stop];
}

@end
