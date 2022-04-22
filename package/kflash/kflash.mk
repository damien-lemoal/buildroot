################################################################################
#
# python-kflash
#
################################################################################

HOST_KFLASH_SOURCE = master.zip
HOST_KFLASH_SITE = https://github.com/sipeed/kflash.py/archive/refs/heads
HOST_KFLASH_LICENSE = MIT
HOST_KFLASH_LICENSE_FILES = LICENSE
HOST_KFLASH_SETUP_TYPE = setuptools
HOST_KFLASH_DEPENDENCIES = host-python-serial host-python-pyelftools

define HOST_KFLASH_EXTRACT_CMDS
        $(UNZIP) -d $(@D) $(HOST_KFLASH_DL_DIR)/$(HOST_KFLASH_SOURCE)
        mv $(@D)/kflash.py-master/* $(@D)
        rm -rf $(@D)/kflash.py-master
endef

$(eval $(host-python-package))
