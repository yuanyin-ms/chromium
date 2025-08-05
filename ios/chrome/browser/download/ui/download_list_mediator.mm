// Copyright 2025 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "ios/chrome/browser/download/ui/download_list_mediator.h"

#import "ios/chrome/browser/download/ui/download_list_consumer.h"
#import "base/logging.h"

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

void DownloadListMediator::SetDownloadRecordService(DownloadRecordService* service) {
  if (download_record_service_) {
    download_record_service_->RemoveObserver(this);
  }
  
  download_record_service_ = service;
  
  if (download_record_service_) {
    download_record_service_->AddObserver(this);
  }
}

void DownloadListMediator::LoadDownloadRecords() {
  if (!download_record_service_ || !consumer_) {
    return;
  }
  
  [consumer_ setLoadingState:YES];
  
  // Get all download records and pass directly to consumer
  std::vector<DownloadRecord> records = download_record_service_->GetAllDownloads();
  
  [consumer_ setLoadingState:NO];
  [consumer_ setDownloadRecords:records];
  [consumer_ setEmptyState:(records.size() == 0)];
  
  DLOG(INFO) << "Loaded " << records.size() << " download records";
}

void DownloadListMediator::UpdateConsumer() {
  LoadDownloadRecords();
}

#pragma mark - DownloadRecordObserver

void DownloadListMediator::OnDownloadAdded(const DownloadRecord& record) {
  DLOG(INFO) << "Download added: " << record.file_name;
  UpdateConsumer();
}

void DownloadListMediator::OnDownloadUpdated(const std::string& download_id,
                                           web::DownloadTask::State new_state) {
  DLOG(INFO) << "Download updated: " << download_id;
  UpdateConsumer();
}
