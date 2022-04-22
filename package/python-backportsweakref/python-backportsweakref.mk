################################################################################
#
# python-backportsweakref
#
################################################################################

PYTHON_BACKPORTSWEAKREF_VERSION = 1.0.post1
PYTHON_BACKPORTSWEAKREF_SOURCE = backports.weakref-$(PYTHON_BACKPORTSWEAKREF_VERSION).tar.gz
PYTHON_BACKPORTSWEAKREF_SITE = https://files.pythonhosted.org/packages/12/ab/cf35cf43a4a6215e3255cf2e49c77d5ba1e9c733af2aa3ec1ca9c4d02592
PYTHON_BACKPORTSWEAKREF_SETUP_TYPE = setuptools
PYTHON_BACKPORTSWEAKREF_LICENSE = PSF-2.0
PYTHON_BACKPORTSWEAKREF_LICENSE_FILES = LICENSE
HOST_PYTHON_BACKPORTSWEAKREF_DEPENDENCIES = host-python-pip

$(eval $(host-python-package))
