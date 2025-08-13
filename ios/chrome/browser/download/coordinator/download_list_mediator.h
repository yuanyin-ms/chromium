// Copyright 2025 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#ifndef IOS_CHROME_BROWSER_DOWNLOAD_COORDINATOR_DOWNLOAD_LIST_MEDIATOR_H_
#define IOS_CHROME_BROWSER_DOWNLOAD_COORDINATOR_DOWNLOAD_LIST_MEDIATOR_H_

#import <Foundation/Foundation.h>

#import "ios/chrome/browser/download/model/download_record_service.h"

@protocol DownloadListConsumer;

// Mediator for download list view controller.
class DownloadListMediator : public DownloadRecordObserver {
 public:
  DownloadListMediator();
  ~DownloadListMediator() override;

  DownloadListMediator(const DownloadListMediator&) = delete;
  DownloadListMediator& operator=(const DownloadListMediator&) = delete;

  // Sets the consumer for UI updates.
  void SetConsumer(id<DownloadListConsumer> consumer);

  // Sets the download record service.
  void SetDownloadRecordService(DownloadRecordService* service);

  // Removes a download record by ID.
  void RemoveDownloadTask(const std::string& download_id);
  // Cancels a download task by ID.
  void CancelDownloadTask(const std::string& download_id);

  // Loads download records.
  void LoadDownloadRecords();
  // Syncs download records if needed.
  void SyncRecordsIfNeeded();

  // Search by keyword.
  void SearchByKeyword(const std::string& keyword);

  // DownloadRecordObserver implementation
  void OnDownloadAdded(const DownloadRecord& record) override;
  void OnDownloadUpdated(const std::string& download_id,
                         web::DownloadTask::State new_state) override;

 private:
  // Updates the consumer with current records.
  void UpdateConsumer();

  raw_ptr<DownloadRecordService> download_record_service_ = nullptr;
  __weak id<DownloadListConsumer> consumer_ = nil;
};

#endif  // IOS_CHROME_BROWSER_DOWNLOAD_COORDINATOR_DOWNLOAD_LIST_MEDIATOR_H_
