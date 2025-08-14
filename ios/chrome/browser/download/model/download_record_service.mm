// Copyright 2025 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "ios/chrome/browser/download/model/download_record_service.h"

#import <algorithm>

#import "base/strings/sys_string_conversions.h"
#import "ios/chrome/browser/download/model/download_record.h"
#import "ios/web/public/download/download_task.h"
#import "ios/web/public/download/download_task_observer.h"
#import "ios/chrome/browser/shared/public/features/features.h"

#pragma mark - Public

DownloadRecordService::DownloadRecordService() {
  CHECK(IsDownloadListEnabled());
}

DownloadRecordService::~DownloadRecordService() = default;

void DownloadRecordService::RecordDownload(web::DownloadTask* task) {
  if (!task) {
    return;
  }

  DownloadRecord record = DownloadRecord(task);

  // Check if this download already exists (avoid duplicates).
  if (downloads_.find(record.download_id) == downloads_.end()) {
    downloads_[record.download_id] = record;
    NotifyDownloadAdded(record);
    download_task_observations_.AddObservation(task);
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
  std::vector<DownloadRecord> records;
  records.reserve(downloads_.size());
  for (const auto& [id, record] : downloads_) {
    records.push_back(record);
  }
  return records;
}

void DownloadRecordService::AddObserver(DownloadRecordObserver* observer) {
  observers_.AddObserver(observer);
}

void DownloadRecordService::RemoveObserver(DownloadRecordObserver* observer) {
  observers_.RemoveObserver(observer);
}

#pragma mark - Private

#pragma mark - web::DownloadTaskObserver
void DownloadRecordService::OnDownloadUpdated(web::DownloadTask* task) {
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
  download_task_observations_.RemoveObservation(task);
}

void DownloadRecordService::NotifyDownloadAdded(const DownloadRecord& record) {
  observers_.Notify(&DownloadRecordObserver::OnDownloadAdded, record);
}

void DownloadRecordService::NotifyDownloadUpdated(
    const std::string& download_id,
    web::DownloadTask::State new_state) {
  observers_.Notify(&DownloadRecordObserver::OnDownloadUpdated, download_id, new_state);
}

DownloadRecord* DownloadRecordService::FindRecordByTask(
    web::DownloadTask* task) {
  DCHECK(task);

  std::string task_id = base::SysNSStringToUTF8(task->GetIdentifier());
  auto it = downloads_.find(task_id);
  return (it != downloads_.end()) ? &it->second : nullptr;
}
