#import <Foundation/Foundation.h>

#if __has_attribute(swift_private)
#define AC_SWIFT_PRIVATE __attribute__((swift_private))
#else
#define AC_SWIFT_PRIVATE
#endif

/// The resource bundle ID.
static NSString * const ACBundleID AC_SWIFT_PRIVATE = @"com.Gleb.lifeisgame";

/// The "BackgroundColor" asset catalog color resource.
static NSString * const ACColorNameBackgroundColor AC_SWIFT_PRIVATE = @"BackgroundColor";

/// The "LightMainColor" asset catalog color resource.
static NSString * const ACColorNameLightMainColor AC_SWIFT_PRIVATE = @"LightMainColor";

/// The "MainColor" asset catalog color resource.
static NSString * const ACColorNameMainColor AC_SWIFT_PRIVATE = @"MainColor";

/// The "Arrow - Left" asset catalog image resource.
static NSString * const ACImageNameArrowLeft AC_SWIFT_PRIVATE = @"Arrow - Left";

/// The "Calendar" asset catalog image resource.
static NSString * const ACImageNameCalendar AC_SWIFT_PRIVATE = @"Calendar";

/// The "File_Document" asset catalog image resource.
static NSString * const ACImageNameFileDocument AC_SWIFT_PRIVATE = @"File_Document";

/// The "Hide" asset catalog image resource.
static NSString * const ACImageNameHide AC_SWIFT_PRIVATE = @"Hide";

/// The "Lol" asset catalog image resource.
static NSString * const ACImageNameLol AC_SWIFT_PRIVATE = @"Lol";

/// The "Show" asset catalog image resource.
static NSString * const ACImageNameShow AC_SWIFT_PRIVATE = @"Show";

/// The "Time Circle" asset catalog image resource.
static NSString * const ACImageNameTimeCircle AC_SWIFT_PRIVATE = @"Time Circle";

/// The "Time_sleep" asset catalog image resource.
static NSString * const ACImageNameTimeSleep AC_SWIFT_PRIVATE = @"Time_sleep";

/// The "User" asset catalog image resource.
static NSString * const ACImageNameUser AC_SWIFT_PRIVATE = @"User";

/// The "Vector" asset catalog image resource.
static NSString * const ACImageNameVector AC_SWIFT_PRIVATE = @"Vector";

/// The "notification" asset catalog image resource.
static NSString * const ACImageNameNotification AC_SWIFT_PRIVATE = @"notification";

#undef AC_SWIFT_PRIVATE
