// Copyright 2025 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "ios/chrome/browser/download/model/download_record_service_factory.h"

#import <memory>

#import "base/no_destructor.h"
#import "ios/chrome/browser/download/model/download_record_service.h"
#import "ios/chrome/browser/shared/model/profile/profile_ios.h"

// static
DownloadRecordServiceFactory* DownloadRecordServiceFactory::GetInstance() {
  static base::NoDestructor<DownloadRecordServiceFactory> instance;
  return instance.get();
}

// static  
DownloadRecordService* DownloadRecordServiceFactory::GetForProfile(
    ProfileIOS* profile) {
  CHECK(profile);
  return static_cast<DownloadRecordService*>(
      GetInstance()->GetServiceForBrowserState(profile, true));
}

DownloadRecordServiceFactory::DownloadRecordServiceFactory()
    : ProfileKeyedServiceFactoryIOS("DownloadRecordService") {}

DownloadRecordServiceFactory::~DownloadRecordServiceFactory() = default;

std::unique_ptr<KeyedService>
DownloadRecordServiceFactory::BuildServiceInstanceFor(
    web::BrowserState* context) const {
  return std::make_unique<DownloadRecordService>();
}
