
#
#    CentOS 7 (centos7) Minimal10 System (dockerfile)
#    Copyright (C) 2016-2017 Stafli
#    Luís Pedro Algarvio
#    This file is part of the Stafli Application Stack.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

#
# Build
#

# Base image to use
FROM centos:centos7

# Labels to apply
LABEL description="Stafli Minimal System (stafli/stafli.system.minimal), based on Upstream distributions" \
      maintainer="lp@algarvio.org" \
      org.label-schema.schema-version="1.0.0-rc.1" \
      org.label-schema.name="Stafli Minimal System (stafli/stafli.system.minimal)" \
      org.label-schema.description="Based on Upstream distributions" \
      org.label-schema.keywords="stafli, minimal, system, debian, centos" \
      org.label-schema.url="https://stafli.org/" \
      org.label-schema.license="GPLv3" \
      org.label-schema.vendor-name="Stafli" \
      org.label-schema.vendor-email="info@stafli.org" \
      org.label-schema.vendor-website="https://www.stafli.org" \
      org.label-schema.authors.lpalgarvio.name="Luis Pedro Algarvio" \
      org.label-schema.authors.lpalgarvio.email="lp@algarvio.org" \
      org.label-schema.authors.lpalgarvio.homepage="https://lp.algarvio.org" \
      org.label-schema.authors.lpalgarvio.role="Maintainer" \
      org.label-schema.registry-url="https://hub.docker.com/r/stafli/stafli.system.minimal" \
      org.label-schema.vcs-url="https://github.com/stafli-org/stafli.system.minimal" \
      org.label-schema.vcs-branch="master" \
      org.label-schema.os-id="centos" \
      org.label-schema.os-version-id="7" \
      org.label-schema.os-architecture="amd64" \
      org.label-schema.version="1.0"

#
# Arguments
#

ARG os_terminal="linux"
ARG os_timezone="Etc/UTC"
ARG os_locale="en_GB"
ARG os_charset="UTF-8"

#
# Environment
#

# Suppress warnings about the terminal
ENV TERM="${os_terminal}"

# Working directory to use when executing build and run instructions
# Defaults to /.
#WORKDIR /

# User and group to use when executing build and run instructions
# Defaults to root.
#USER root:root

#
# Packages
#

# Install Package Manager related packages
#  - yum-plugin-ovl: to provide workarounds for OverlayFS issues in yum
#  - yum-plugin-priorities: to provide priorities for packages from different repos in yum
#  - yum-plugin-fastestmirror: to provide fastest mirror selection from a mirrorlist in yum
# Install crypto packages
#  - gnupg: for gnupg, the GNU privacy guard cryptographic utility required by yum
# Add foreign repositories and GPG keys and refresh the GPG keys
#  - epel-release: for Extra Packages for Enterprise Linux (EPEL)
# Install base packages
#  - bash: for bash, the GNU Bash shell
#  - tzdata: to provide time zone and daylight-saving time data
#  - glibc-common: to provide common files for locale support
# Install administration packages
#  - which: for which, basic administration packages
#  - procps: for kill, top and others, basic administration packages
# Install programming packages
#  - sed: for sed, the GNU stream editor
#  - perl: for perl, an interpreter for the Perl Programming Language
#  - python: for python, an interpreter for the Python Programming Language
# Install find and revision control packages
#  - grep: for grep/egrep/fgrep, the GNU utilities to search text in files
#  - findutils: for find, the file search utility
# Install archive and compression packages
#  - tar: for tar, the GNU tar archiving utility
#  - gzip: for gzip, the GNU compression utility which uses DEFLATE algorithm
# Install network diagnosis packages
#  - fping: for fping/6, tools to test the reachability of network hosts that requires less dependencies as iputils ping
#  - nc: for netcat, the OpenBSD rewrite of netcat - the TCP/IP swiss army knife
# Install network transfer packages
#  - curl: for curl, a network utility to transfer data via FTP, HTTP, SCP, and other protocols
# Install misc packages
#  - nano: for nano, a tiny editor based on pico
#  - vim-minimal: for vim editor, an almost compatible version of the UNIX editor Vi
# Reinstall and clean locale archives
#  - glibc-common: to provide common files for locale support
RUN printf "Installing repositories and packages...\n" && \
    \
    printf "Install the Package Manager related packages...\n" && \
    yum makecache && yum install -y \
      yum-plugin-ovl \
      yum-plugin-priorities yum-plugin-fastestmirror \
      gnupg && \
    \
    printf "Install the repositories...\n" && \
    yum makecache && yum install -y \
      epel-release && \
    \
    printf "Refresh the GPG keys...\n" && \
    gpg --refresh-keys && \
    \
    printf "Install the required packages...\n" && \
    yum makecache && yum install -y \
      bash tzdata glibc-common \
      which procps \
      sed perl python \
      grep findutils \
      tar gzip \
      fping nc \
      curl \
      nano vim-minimal && \
    \
    printf "Reinstall and clean locale archives...\n" && \
    yum makecache && yum reinstall -y glibc-common && \
    localedef --list-archive | grep -v -i ^${os_locale} | xargs localedef --delete-from-archive && \
    mv -f /usr/lib/locale/locale-archive /usr/lib/locale/locale-archive.tmpl && \
    build-locale-archive && rm -Rf /usr/lib/locale/tmp && \
    \
    printf "Cleanup the Package Manager...\n" && \
    yum clean all && rm -Rf /var/lib/yum/* && \
    \
    printf "Finished installing repositories and packages...\n";

#
# Configuration
#

# Configure SELinux (permissive), accounts and internationalization
RUN printf "Configuring SELinux (permissive), accounts and internationalization...\n" && \
    \
    printf "Configure SELinux (permissive) if present in system...\n" && \
    if [ hash setenforce 2>/dev/null ]; then \
      setenforce Permissive; \
      if [ -f /etc/selinux/config ]; then \
        perl -0p -i -e "s>\nSELINUX=.*>\nSELINUX=permissive>" /etc/selinux/config; \
      else \
        mkdir -p /etc/selinux && \
        touch /etc/selinux/config && \
        printf "SELINUX=permissive\n" > /etc/selinux/config; \
      fi; \
    fi && \
    \
    printf "Configure root account...\n" && \
    cp -R /etc/skel/. /root && \
    \
    printf "Configure timezone...\n" && \
    echo "${os_timezone}" > /etc/timezone && \
    \
    printf "Configure locales...\n" && \
    localedef -c -i ${os_locale} -f ${os_charset} ${os_locale}.${os_charset} && \
    \
    printf "Finished configuring SELinux (permissive), accounts and internationalization...\n";
ENV TZ="${os_timezone}" \
    LANGUAGE="${os_locale}.${os_charset}" LANG="${os_locale}.${os_charset}" LC_ALL="${os_locale}.${os_charset}"

#
# Run
#

# Command to execute
# Defaults to /bin/bash.
#CMD ["/bin/bash"]

# Ports to expose
# Defaults to none.
#EXPOSE ...

