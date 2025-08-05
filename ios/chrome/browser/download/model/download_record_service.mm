// Copyright 2025 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "ios/chrome/browser/download/model/download_record_service.h"

#import <algorithm>

#import "base/logging.h"
#import "base/strings/sys_string_conversions.h"
#import "base/strings/utf_string_conversions.h"
#import "ios/web/public/download/download_task.h"
#import "ios/web/public/download/download_task_observer.h"

// Implementation of DownloadRecord constructor and destructor
DownloadRecord::DownloadRecord() = default;
DownloadRecord::DownloadRecord(const DownloadRecord& other) = default;
DownloadRecord& DownloadRecord::operator=(const DownloadRecord& other) = default;
DownloadRecord::~DownloadRecord() = default;

DownloadRecordService::DownloadRecordService() {
  DLOG(INFO) << "DownloadRecordService created";
}

DownloadRecordService::~DownloadRecordService() {
  DLOG(INFO) << "DownloadRecordService destroyed";
}

void DownloadRecordService::RecordDownload(web::DownloadTask* task) {
  DLOG(INFO) << "RecordDownload called, current downloads_.size() = " << downloads_.size();
  
  if (!task) {
    DLOG(WARNING) << "RecordDownload: task is null, returning";
    return;
  }
  
  DLOG(INFO) << "Task ID: " << base::SysNSStringToUTF8(task->GetIdentifier());
  
  DownloadRecord record = CreateRecordFromTask(task);
  DLOG(INFO) << "Created record - ID: " << record.download_id 
             << ", filename: " << record.file_name 
             << ", URL: " << record.url;
  
  // Check if this download already exists (avoid duplicates)
  auto it = std::find_if(downloads_.begin(), downloads_.end(),
                         [&record](const DownloadRecord& existing) {
                           return existing.download_id == record.download_id;
                         });
  
  if (it == downloads_.end()) {
    // New download, add it
    downloads_.push_back(record);
    DLOG(INFO) << "Added download to history: " << record.file_name 
               << ", new size: " << downloads_.size();
    NotifyDownloadAdded(record);
    
    // Start observing this task
    task->AddObserver(this);
  } else {
    DLOG(INFO) << "Download already exists in history, skipping: " << record.download_id;
  }
}

std::vector<DownloadRecord> DownloadRecordService::GetAllDownloads() const {
  DLOG(INFO) << "GetAllDownloads called, returning " << downloads_.size() << " downloads";
  return downloads_;
}

void DownloadRecordService::AddObserver(DownloadRecordObserver* observer) {
  if (observer && std::find(observers_.begin(), observers_.end(), observer) == observers_.end()) {
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

void DownloadRecordService::NotifyDownloadUpdated(const std::string& download_id,
                                                 web::DownloadTask::State new_state) {
  for (auto* observer : observers_) {
    observer->OnDownloadUpdated(download_id, new_state);
  }
}

DownloadRecord DownloadRecordService::CreateRecordFromTask(web::DownloadTask* task) {
  DownloadRecord record;
  
  if (!task) {
    DLOG(WARNING) << "CreateRecordFromTask: task is null";
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
  
  DLOG(INFO) << "CreateRecordFromTask: created record with ID=" << record.download_id 
             << ", isEmpty=" << (record.download_id.empty() ? "YES" : "NO")
             << ", filename=" << record.file_name
             << ", filesize=" << record.file_size;
  
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
  
  // Update the record with new state
  web::DownloadTask::State old_state = record->state;
  record->state = task->GetState();
  
  // Update progress information
  record->received_bytes = task->GetReceivedBytes();
  record->total_bytes = task->GetTotalBytes();
  record->progress_percent = task->GetPercentComplete();
  
  // Update completion time if download just finished
  if (old_state != web::DownloadTask::State::kComplete && 
      task->GetState() == web::DownloadTask::State::kComplete) {
    record->completed_time = base::Time::Now();
  }
  
  // Update file size if available
  if (task->GetTotalBytes() > 0) {
    record->file_size = task->GetTotalBytes();
  }
  
  DLOG(INFO) << "Updated download state: " << record->file_name 
             << " to " << static_cast<int>(task->GetState());
  
  NotifyDownloadUpdated(record->download_id, task->GetState());
}

void DownloadRecordService::OnDownloadDestroyed(web::DownloadTask* task) {
  if (!task) {
    return;
  }
  
  // Must remove observer before task is destroyed to avoid dangling pointer
  task->RemoveObserver(this);
  
  DLOG(INFO) << "Download task destroyed, observer removed";
  // Note: We don't remove the record from our history when the task is destroyed
  // as we want to keep the download history even after the task is gone
}

DownloadRecord* DownloadRecordService::FindRecordByTask(web::DownloadTask* task) {
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
