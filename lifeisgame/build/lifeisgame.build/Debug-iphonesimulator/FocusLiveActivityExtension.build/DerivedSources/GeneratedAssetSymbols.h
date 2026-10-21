#import <Foundation/Foundation.h>

#if __has_attribute(swift_private)
#define AC_SWIFT_PRIVATE __attribute__((swift_private))
#else
#define AC_SWIFT_PRIVATE
#endif

/// The resource bundle ID.
static NSString * const ACBundleID AC_SWIFT_PRIVATE = @"com.Gleb.lifeisgame.FocusLiveActivityExtension";

/// The "BackgroundColor" asset catalog color resource.
static NSString * const ACColorNameBackgroundColor AC_SWIFT_PRIVATE = @"BackgroundColor";

/// The "FocusPrimaryTextColor" asset catalog color resource.
static NSString * const ACColorNameFocusPrimaryTextColor AC_SWIFT_PRIVATE = @"FocusPrimaryTextColor";

/// The "FocusSecondaryTextColor" asset catalog color resource.
static NSString * const ACColorNameFocusSecondaryTextColor AC_SWIFT_PRIVATE = @"FocusSecondaryTextColor";

/// The "MainColor" asset catalog color resource.
static NSString * const ACColorNameMainColor AC_SWIFT_PRIVATE = @"MainColor";

#undef AC_SWIFT_PRIVATE
