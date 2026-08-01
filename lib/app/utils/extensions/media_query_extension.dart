import 'dart:io';

import 'package:flutter/widgets.dart';

extension MediaQueryExtension on BuildContext {
  double get getPlatformExtraSpace {
    return Platform.isAndroid ? 16 : 0;
  }

  double get mediaQueryBottomPadding {
    return MediaQuery.paddingOf(this).bottom + getPlatformExtraSpace;
  }

  double get mediaQueryViewInsetsBottom {
    return MediaQuery.viewInsetsOf(this).bottom;
  }

  double get mediaQueryViewInsetsTop {
    return MediaQuery.viewInsetsOf(this).top;
  }

  bool get isKeyboardVisible => mediaQueryViewInsetsBottom > 0;
  double get mediaQueryTopPadding {
    return MediaQuery.paddingOf(this).top;
  }

  bool get isTablet => MediaQuery.sizeOf(this).width >= 600;

  bool get isHorizontalTablet => MediaQuery.sizeOf(this).width >= 900;

  double get mediaQuerySizeHeight {
    return MediaQuery.sizeOf(this).height;
  }

  double get mediaQuerySizeWidth {
    return MediaQuery.sizeOf(this).width;
  }

  double get largeBottomSheetHeight {
    return mediaQuerySizeHeight * 0.9;
  }

  double get defaultBottomSheetHeight {
    return mediaQuerySizeHeight * 0.8;
  }

  double get mediumBottomSheetHeight {
    return mediaQuerySizeHeight * 0.5;
  }

  double get smallBottomSheetHeight {
    return mediaQuerySizeHeight * 0.22;
  }
}
