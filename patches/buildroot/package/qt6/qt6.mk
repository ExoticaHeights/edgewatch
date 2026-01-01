################################################################################
#
# Qt 6 common definitions
#
################################################################################

QT6_VERSION_MAJOR = 6.8
QT6_VERSION = $(QT6_VERSION_MAJOR).1
QT6_SOURCE_TARBALL_PREFIX = everywhere-src

# Ordered Qt source mirrors (fastest first)
# Buildroot will try these in order and stop at the first success
QT6_SITE = \
  https://ftp.jaist.ac.jp/pub/qtproject/archive/qt/$(QT6_VERSION_MAJOR)/$(QT6_VERSION)/submodules \
  https://mirrors.ocf.berkeley.edu/qt/archive/qt/$(QT6_VERSION_MAJOR)/$(QT6_VERSION)/submodules \
  https://download.qt.io/archive/qt/$(QT6_VERSION_MAJOR)/$(QT6_VERSION)/submodules

QT6_GIT = git://code.qt.io

# Include all Qt6 module definitions
include $(sort $(wildcard package/qt6/*/*.mk))

