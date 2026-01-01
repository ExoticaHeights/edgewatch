################################################################################
#
# Qt 6 common definitions
#
################################################################################

# ------------------------------------------------------------------------------
# Qt versioning
# ------------------------------------------------------------------------------
QT6_VERSION_MAJOR = 6.8
QT6_VERSION = $(QT6_VERSION_MAJOR).1
QT6_SOURCE_TARBALL_PREFIX = everywhere-src

# ------------------------------------------------------------------------------
# Mirror override (Buildroot-supported way)
#
# NOTE:
#  - QT6_SITE MUST contain exactly ONE URL
#  - Multiple mirrors MUST be provided via BR2_PRIMARY_SITE
#  - Order matters: fastest mirror first
#
# This prevents slow redirects from download.qt.io
# ------------------------------------------------------------------------------

BR2_PRIMARY_SITE ?= \
  https://ftp.jaist.ac.jp/pub/qtproject \
  https://mirrors.ocf.berkeley.edu/qt

# ------------------------------------------------------------------------------
# Official Qt upstream (kept for correctness & fallback)
# ------------------------------------------------------------------------------

QT6_SITE = https://download.qt.io/archive/qt/$(QT6_VERSION_MAJOR)/$(QT6_VERSION)/submodules

# Qt git (used only if tarballs are unavailable)
QT6_GIT = git://code.qt.io

# ------------------------------------------------------------------------------
# Include all Qt6 module makefiles
# ------------------------------------------------------------------------------

include $(sort $(wildcard package/qt6/*/*.mk))
