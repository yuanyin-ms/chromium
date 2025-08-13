// Copyright 2025 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "ios/chrome/browser/download/coordinator/download_list_mediator.h"

#import "base/logging.h"
#import "ios/chrome/browser/download/ui/download_list_consumer.h"

DownloadListMediator::DownloadListMediator() {
  DLOG(INFO) << "DownloadListMediator created";
}

DownloadListMediator::~DownloadListMediator() {
  if (download_record_service_) {
    download_record_service_->RemoveObserver(this);
  }
  DLOG(INFO) << "DownloadListMediator destroyed";
}

void DownloadListMediator::SetConsumer(id<DownloadListConsumer> consumer) {
  consumer_ = consumer;
}

void DownloadListMediator::SetDownloadRecordService(
    DownloadRecordService* service) {
  if (download_record_service_) {
    download_record_service_->RemoveObserver(this);
  }

  download_record_service_ = service;

  if (download_record_service_) {
    download_record_service_->AddObserver(this);
  }
}

void DownloadListMediator::RemoveDownloadTask(const std::string& download_id) {
  if (!download_record_service_) {
    DLOG(WARNING) << "RemoveDownloadTask: missing download record service";
    return;
  }
  web::DownloadTask* task =
      download_record_service_->GetDownloadTask(download_id);
  if (task) {
    task->Cancel();
    download_record_service_->RemoveDownload(download_id);
  }
}

void DownloadListMediator::CancelDownloadTask(const std::string& download_id) {
  if (!download_record_service_) {
    DLOG(WARNING) << "RemoveDownloadTask: missing download record service";
    return;
  }
  web::DownloadTask* task =
      download_record_service_->GetDownloadTask(download_id);
  if (task) {
    task->Cancel();
  }
}

void DownloadListMediator::LoadDownloadRecords() {
  if (!download_record_service_ || !consumer_) {
    DLOG(WARNING) << "LoadDownloadRecords: missing service or consumer";
    return;
  }

  [consumer_ setLoadingState:YES];

  // Get all download records
  std::vector<DownloadRecord> records =
      download_record_service_->GetAllDownloads();

  // Directly pass the C++ vector to the consumer
  [consumer_ setDownloadRecords:records];
  [consumer_ setLoadingState:NO];
  [consumer_ setEmptyState:(records.size() == 0)];
}

void DownloadListMediator::SyncRecordsIfNeeded() {
  if (!download_record_service_) {
    DLOG(WARNING) << "SyncRecordsIfNeeded: missing download record service";
    return;
  }

  // Sync records with the service
  // Get all download records
  std::vector<DownloadRecord> records =
      download_record_service_->GetAllDownloads();
  // TODO: Implement logic to sync records with the file system
  [consumer_ setDownloadRecords:records];
}

void DownloadListMediator::UpdateConsumer() {
  LoadDownloadRecords();
}

#pragma mark - Search and Filter
void DownloadListMediator::SearchByKeyword(const std::string& keyword) {
  if (!download_record_service_ || !consumer_) {
    DLOG(WARNING) << "SearchByKeyword: missing service or consumer";
    return;
  }

  // Perform the search
  std::vector<DownloadRecord> results;
  for (const auto& record : download_record_service_->GetAllDownloads()) {
    if (record.file_name.find(keyword) != std::string::npos) {
      results.push_back(record);
    }
  }

  // Update the consumer with the search results
  [consumer_ setDownloadRecords:results];
}

#pragma mark - DownloadRecordObserver

void DownloadListMediator::OnDownloadAdded(const DownloadRecord& record) {
  DLOG(INFO) << "Download added: " << record.file_name;
  UpdateConsumer();
}

void DownloadListMediator::OnDownloadUpdated(
    const std::string& download_id,
    web::DownloadTask::State new_state) {
  DLOG(INFO) << "Download updated: " << download_id;
  UpdateConsumer();
}
