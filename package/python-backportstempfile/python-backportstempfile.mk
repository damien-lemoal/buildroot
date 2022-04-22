################################################################################
#
# python-backportstempfile
#
################################################################################

PYTHON_BACKPORTSTEMPFILE_VERSION = 1.0
PYTHON_BACKPORTSTEMPFILE_SOURCE = backports.tempfile-$(PYTHON_BACKPORTSTEMPFILE_VERSION).tar.gz
PYTHON_BACKPORTSTEMPFILE_SITE = https://files.pythonhosted.org/packages/0d/f9/fa432ec3d185a63d39c20c49e37e163633aaae4009cc79574aecc064d2d0
PYTHON_BACKPORTSTEMPFILE_SETUP_TYPE = setuptools
PYTHON_BACKPORTSTEMPFILE_LICENSE = PSF-2.0
PYTHON_BACKPORTSTEMPFILE_LICENSE_FILES = LICENSE
HOST_PYTHON_BACKPORTSTEMPFILE_DEPENDENCIES = host-python-backportsweakref

$(eval $(host-python-package))
