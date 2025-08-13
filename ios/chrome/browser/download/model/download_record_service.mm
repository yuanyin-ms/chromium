// Copyright 2025 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "ios/chrome/browser/download/model/download_record_service.h"

#import <algorithm>

#import "base/logging.h"
#import "base/strings/sys_string_conversions.h"
#import "base/strings/utf_string_conversions.h"
#import "base/time/time.h"
#import "ios/chrome/browser/download/model/download_record.h"
#import "ios/web/public/download/download_task.h"
#import "ios/web/public/download/download_task_observer.h"
#import "url/gurl.h"

DownloadRecordService::DownloadRecordService() = default;

DownloadRecordService::~DownloadRecordService() = default;

void DownloadRecordService::RecordDownload(web::DownloadTask* task) {
  if (!task) {
    return;
  }

  DownloadRecord record = CreateRecordFromTask(task);

  // Check if this download already exists (avoid duplicates)
  auto it = std::find_if(downloads_.begin(), downloads_.end(),
                         [&record](const DownloadRecord& existing) {
                           return existing.download_id == record.download_id;
                         });

  if (it == downloads_.end()) {
    downloads_.push_back(record);
    NotifyDownloadAdded(record);
    task->AddObserver(this);
  }
}

web::DownloadTask* DownloadRecordService::GetDownloadTask(
    const std::string& download_id) const {
  // TODO: Implement logic to retrieve the download task by ID
  return nullptr;
}

void DownloadRecordService::RemoveDownload(const std::string& download_id) {
  auto it = std::remove_if(downloads_.begin(), downloads_.end(),
                           [&download_id](const DownloadRecord& record) {
                             return record.download_id == download_id;
                           });
  if (it != downloads_.end()) {
    downloads_.erase(it, downloads_.end());
  } else {
    DLOG(WARNING) << "RemoveDownload: download not found: " << download_id;
  }
}

std::vector<DownloadRecord> DownloadRecordService::GetAllDownloads() const {
  return downloads_;
}

void DownloadRecordService::AddObserver(DownloadRecordObserver* observer) {
  if (observer && std::find(observers_.begin(), observers_.end(), observer) ==
                      observers_.end()) {
    observers_.push_back(observer);
  }
}

void DownloadRecordService::RemoveObserver(DownloadRecordObserver* observer) {
  auto it = std::find(observers_.begin(), observers_.end(), observer);
  if (it != observers_.end()) {
    observers_.erase(it);
  }
}

void DownloadRecordService::NotifyDownloadAdded(const DownloadRecord& record) {
  for (auto* observer : observers_) {
    observer->OnDownloadAdded(record);
  }
}

void DownloadRecordService::NotifyDownloadUpdated(
    const std::string& download_id,
    web::DownloadTask::State new_state) {
  for (auto* observer : observers_) {
    observer->OnDownloadUpdated(download_id, new_state);
  }
}

DownloadRecord DownloadRecordService::CreateRecordFromTask(
    web::DownloadTask* task) {
  DownloadRecord record;

  if (!task) {
    return record;
  }

  record.download_id = base::SysNSStringToUTF8(task->GetIdentifier());
  record.url = task->GetOriginalUrl().spec();
  record.file_name = task->GenerateFileName().value();
  record.mime_type = task->GetMimeType();
  record.created_time = base::Time::Now();
  record.file_size = task->GetTotalBytes();
  record.received_bytes = task->GetReceivedBytes();
  record.total_bytes = task->GetTotalBytes();
  record.progress_percent = task->GetPercentComplete();
  record.state = task->GetState();

  return record;
}

#pragma mark - web::DownloadTaskObserver

void DownloadRecordService::OnDownloadUpdated(web::DownloadTask* task) {
  if (!task) {
    return;
  }

  DownloadRecord* record = FindRecordByTask(task);
  if (!record) {
    return;
  }

  web::DownloadTask::State old_state = record->state;
  record->state = task->GetState();
  record->received_bytes = task->GetReceivedBytes();
  record->total_bytes = task->GetTotalBytes();
  record->progress_percent = task->GetPercentComplete();

  if (old_state != web::DownloadTask::State::kComplete &&
      task->GetState() == web::DownloadTask::State::kComplete) {
    record->completed_time = base::Time::Now();
  }

  if (task->GetTotalBytes() > 0) {
    record->file_size = task->GetTotalBytes();
  }

  NotifyDownloadUpdated(record->download_id, task->GetState());
}

void DownloadRecordService::OnDownloadDestroyed(web::DownloadTask* task) {
  if (!task) {
    return;
  }

  task->RemoveObserver(this);
}

DownloadRecord* DownloadRecordService::FindRecordByTask(
    web::DownloadTask* task) {
  if (!task) {
    return nullptr;
  }

  std::string task_id = base::SysNSStringToUTF8(task->GetIdentifier());
  auto it = std::find_if(downloads_.begin(), downloads_.end(),
                         [&task_id](DownloadRecord& record) {
                           return record.download_id == task_id;
                         });

  return (it != downloads_.end()) ? &(*it) : nullptr;
}
