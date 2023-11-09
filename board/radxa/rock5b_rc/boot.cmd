setenv bootargs root=/dev/mmcblk1p2 clkin_hz=(25000000) earlycon clk_ignore_unused earlyprintk console=ttyS2,1500000n8 rootwait loglevel=7 oops=panic panic=10 sysrq_always_enabled
fatload mmc 1:1 ${loadaddr} image.itb
bootm ${loadaddr}
