SUMMARY = "Simple watchdog kicker service"
DESCRIPTION = "Systemd service and script to keep /dev/watchdog3 alive"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://LICENSE;md5=954ed4abd6e8085731bbdb3904c9e64f"

SRC_URI = "file://watchdog-kick.sh \
           file://watchdog-kick.service \
           file://LICENSE"

S = "${WORKDIR}"

inherit systemd

SYSTEMD_SERVICE:${PN} = "watchdog-kick.service"
SYSTEMD_AUTO_ENABLE:${PN} = "enable"

do_install() {
    install -d ${D}${sbindir}
    install -m 0755 ${WORKDIR}/watchdog-kick.sh ${D}${sbindir}/watchdog-kick.sh

    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${WORKDIR}/watchdog-kick.service \
        ${D}${systemd_system_unitdir}/watchdog-kick.service

    install -d ${D}${docdir}/watchdog-kick
    install -m 0644 ${WORKDIR}/LICENSE ${D}${docdir}/watchdog-kick/LICENSE
}

FILES:${PN} += "${sbindir}/watchdog-kick.sh \
               ${systemd_system_unitdir}/watchdog-kick.service \
               ${docdir}/watchdog-kick/LICENSE"
