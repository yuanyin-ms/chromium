// Copyright 2025 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#ifndef IOS_CHROME_BROWSER_DOWNLOAD_MODEL_DOWNLOAD_RECORD_SERVICE_H_
#define IOS_CHROME_BROWSER_DOWNLOAD_MODEL_DOWNLOAD_RECORD_SERVICE_H_

#import <string>
#import <map>
#import <vector>

#import "base/memory/weak_ptr.h"
#import "base/observer_list.h"
#import "base/observer_list_types.h"
#import "components/keyed_service/core/keyed_service.h"
#import "ios/chrome/browser/download/model/download_record.h"
#import "ios/web/public/download/download_task.h"
#import "ios/web/public/download/download_task_observer.h"

// Observer interface for download record changes.
class DownloadRecordObserver : public base::CheckedObserver {
 public:
  // Called when a new download started.
  virtual void OnDownloadAdded(const DownloadRecord& record) {}

  // Called when a download's state changed.
  virtual void OnDownloadUpdated(const std::string& download_id,
                                 web::DownloadTask::State new_state) {}
};

// Service that manages download records.
class DownloadRecordService : public KeyedService,
                              public web::DownloadTaskObserver {
 public:
  DownloadRecordService();

  DownloadRecordService(const DownloadRecordService&) = delete;
  DownloadRecordService& operator=(const DownloadRecordService&) = delete;

  ~DownloadRecordService() override;

  // Records a new download and start observing it.
  void RecordDownload(web::DownloadTask* task);

  // Returns all downloads.
  std::vector<DownloadRecord> GetAllDownloads() const;

  // Observer management.
  void AddObserver(DownloadRecordObserver* observer);
  void RemoveObserver(DownloadRecordObserver* observer);

 private:
  // web::DownloadTaskObserver implementation.
  void OnDownloadUpdated(web::DownloadTask* task) override;
  void OnDownloadDestroyed(web::DownloadTask* task) override;

  // Notify observers of changes.
  void NotifyDownloadAdded(const DownloadRecord& record);
  void NotifyDownloadUpdated(const std::string& download_id,
                             web::DownloadTask::State new_state);

  // Find download record by task pointer.
  DownloadRecord* FindRecordByTask(web::DownloadTask* task);

  // In-memory storage for now (we'll add persistence in next CL).
  std::map<std::string, DownloadRecord> downloads_;

  // ObserverList for download record changes.
  base::ObserverList<DownloadRecordObserver> observers_;

  base::WeakPtrFactory<DownloadRecordService> weak_ptr_factory_{this};
};

#endif  // IOS_CHROME_BROWSER_DOWNLOAD_MODEL_DOWNLOAD_RECORD_SERVICE_H_
