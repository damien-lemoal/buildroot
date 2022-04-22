################################################################################
#
# python-kflash
#
################################################################################

PYTHON_KFLASH_VERSION = 1.0.9
PYTHON_KFLASH_SOURCE = kflash-$(PYTHON_KFLASH_VERSION).tar.gz
PYTHON_KFLASH_SITE = https://files.pythonhosted.org/packages/76/c6/36de539bc741f5cbf988fef84dc61e6ba4471ae769e1396e5712eecea31b
PYTHON_KFLASH_SETUP_TYPE = setuptools
PYTHON_KFLASH_LICENSE = MIT
PYTHON_KFLASH_LICENSE_FILES = LICENSE
HOST_PYTHON_KFLASH_DEPENDENCIES = host-python-backportstempfile host-python-serial host-python-pyelftools

$(eval $(host-python-package))
