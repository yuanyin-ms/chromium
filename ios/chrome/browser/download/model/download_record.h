// Copyright 2025 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#ifndef IOS_CHROME_BROWSER_DOWNLOAD_MODEL_DOWNLOAD_RECORD_H_
#define IOS_CHROME_BROWSER_DOWNLOAD_MODEL_DOWNLOAD_RECORD_H_

#import <string>

#import "base/time/time.h"
#import "ios/web/public/download/download_task.h"

struct DownloadRecord {
  DownloadRecord();
  explicit DownloadRecord(web::DownloadTask* task);
  DownloadRecord(const DownloadRecord& other);
  DownloadRecord& operator=(const DownloadRecord& other);
  ~DownloadRecord();

  std::string download_id;
  std::string url;
  std::string file_name;
  std::string mime_type;
  base::Time created_time;
  base::Time completed_time;
  int64_t file_size = 0;
  int64_t received_bytes = 0;
  int64_t total_bytes = 0;
  int progress_percent = -1;  // -1 indicates unknown progress
  web::DownloadTask::State state = web::DownloadTask::State::kNotStarted;
};

#endif  // IOS_CHROME_BROWSER_DOWNLOAD_MODEL_DOWNLOAD_RECORD_H_
