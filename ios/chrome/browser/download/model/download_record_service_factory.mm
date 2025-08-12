// Copyright 2025 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "ios/chrome/browser/download/model/download_record_service_factory.h"

#import <memory>

<<<<<<< HEAD
#import "base/no_destructor.h"
=======
>>>>>>> 3d6110c25c644 ([iOS] Add DownloadRecordService to track download records)
#import "ios/chrome/browser/download/model/download_record_service.h"
#import "ios/chrome/browser/shared/model/profile/profile_ios.h"

DownloadRecordServiceFactory* DownloadRecordServiceFactory::GetInstance() {
  static base::NoDestructor<DownloadRecordServiceFactory> instance;
  return instance.get();
}

DownloadRecordService* DownloadRecordServiceFactory::GetForProfile(
    ProfileIOS* profile) {
  CHECK(profile);
  return static_cast<DownloadRecordService*>(
      GetInstance()->GetServiceForBrowserState(profile, true));
}

DownloadRecordServiceFactory::DownloadRecordServiceFactory()
<<<<<<< HEAD
    : ProfileKeyedServiceFactoryIOS("DownloadRecordService") {}
=======
    : ProfileKeyedServiceFactoryIOS("IOSDownloadRecordService",
                                    ProfileSelection::kOwnInstanceInIncognito) {
}
>>>>>>> 3d6110c25c644 ([iOS] Add DownloadRecordService to track download records)

DownloadRecordServiceFactory::~DownloadRecordServiceFactory() = default;

std::unique_ptr<KeyedService>
DownloadRecordServiceFactory::BuildServiceInstanceFor(
    web::BrowserState* context) const {
  return std::make_unique<DownloadRecordService>();
}
