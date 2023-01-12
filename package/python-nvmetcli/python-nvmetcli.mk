################################################################################
#
# python-nvmetcli
#
################################################################################

PYTHON_NVMETCLI_VERSION = origin/master
PYTHON_NVMETCLI_SITE = git://git.infradead.org/users/hch/nvmetcli.git
PYTHON_NVMETCLI_SITE_METHOD = git
PYTHON_NVMETCLI_SETUP_TYPE = distutils
PYTHON_NVMETCLI_LICENSE = Apache-2.0
PYTHON_NVMETCLI_LICENSE_FILES = COPYING
PYTHON_NVMETCLI_DEPENDENCIES = python-configshell-fb python-urwid python-pyparsing

$(eval $(python-package))
