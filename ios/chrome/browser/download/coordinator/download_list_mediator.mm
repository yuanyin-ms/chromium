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

  DLOG(INFO) << "LoadDownloadRecords: got " << records.size()
             << " records from service";

  // Directly pass the C++ vector to the consumer
  [consumer_ setDownloadRecords:records];
  [consumer_ setLoadingState:NO];
  [consumer_ setEmptyState:(records.size() == 0)];

  DLOG(INFO) << "Loaded " << records.size() << " download records";
}

void DownloadListMediator::SyncRecordsIfNeeded() {
  if (!download_record_service_) {
    DLOG(WARNING) << "SyncRecordsIfNeeded: missing download record service";
    return;
  }

  // Sync records with the service
  download_record_service_->SyncRecords();

  DLOG(INFO) << "Download records synced";
}

void DownloadListMediator::UpdateConsumer() {
  LoadDownloadRecords();
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
