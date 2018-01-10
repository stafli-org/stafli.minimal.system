
#
#    Debian 8 (jessie) Minimal10 System (dockerfile)
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
FROM debian:jessie

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
      org.label-schema.os-id="debian" \
      org.label-schema.os-version-id="jessie" \
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

# Suppress warnings about the terminal and frontend and avoid prompts
ENV TERM="${os_terminal}" \
    DEBIAN_FRONTEND="noninteractive"

# Working directory to use when executing build and run instructions
# Defaults to /.
#WORKDIR /

# User and group to use when executing build and run instructions
# Defaults to root.
#USER root:root

#
# Packages
#

# Disable installation of optional apt packages and enable contrib and non-free components in debian repositories
# Install Package Manager related packages
#  - apt-utils: for apt-extracttemplates, used by debconf and to improve compatibility in docker
#  - apt-transport-https: to allow HTTPS connections to sources in apt
# Install crypto packages
#  - gnupg: for gnupg, the GNU privacy guard cryptographic utility required by apt
#  - gnupg-curl: to add support for secure HKPS keyservers
# Add foreign repositories and GPG keys and refresh the GPG keys
#  - N/A
# Install base packages
#  - bash: for bash, the GNU Bash shell
#  - locales: to provide common files for locale support
#  - tzdata: to provide time zone and daylight-saving time data
# Install administration packages
#  - debianutils: for which and others, basic administration packages
#  - procps: for kill, top and others, basic administration packages
# Install programming packages
#  - sed: for sed, the GNU stream editor
#  - perl-base: for perl, an interpreter for the Perl Programming Language
#  - python-minimal: for python, an interpreter for the Python Programming Language
# Install find and revision control packages
#  - grep: for grep/egrep/fgrep, the GNU utilities to search text in files
#  - findutils: for find, the file search utility
# Install archive and compression packages
#  - tar: for tar, the GNU tar archiving utility
#  - gzip: for gzip, the GNU compression utility which uses DEFLATE algorithm
# Install network diagnosis packages
#  - iputils-ping: for ping/6, tools to test the reachability of network hosts
#  - netcat-openbsd: for netcat, the OpenBSD rewrite of netcat - the TCP/IP swiss army knife
# Install network transfer packages
#  - curl: for curl, a network utility to transfer data via FTP, HTTP, SCP, and other protocols
# Install misc packages
#  - nano: for nano, a tiny editor based on pico
#  - vim-tiny: for vim editor, an almost compatible version of the UNIX editor Vi
RUN printf "Installing repositories and packages...\n" && \
    \
    printf "Disable installation of optional apt packages...\n" && \
    printf "\n# Disable recommended and suggested packages\n\
APT::Install-Recommends "\""false"\"";\n\
APT::Install-Suggests "\""false"\"";\n\
\n" >> /etc/apt/apt.conf && \
    \
    printf "Enable contrib and non-free components in debian repositories...\n" && \
    sed -i "s>main>main contrib non-free>" /etc/apt/sources.list && \
    \
    printf "Install the Package Manager related packages...\n" && \
    apt-get update && apt-get install -qy \
      apt-utils apt-transport-https \
      gnupg gnupg-curl && \
    \
    printf "Install the repositories and refresh the APT and GPG keys...\n" && \
    apt-key update && \
    gpg --refresh-keys && \
    \
    printf "Install the required packages...\n" && \
    apt-get update && apt-get install -qy \
      bash locales tzdata \
      debianutils procps \
      sed perl-base python-minimal \
      grep findutils \
      tar gzip \
      iputils-ping netcat-openbsd \
      curl \
      nano vim-tiny && \
    \
    printf "Cleanup the Package Manager...\n" && \
    apt-get clean && rm -rf /var/lib/apt/lists/* && \
    \
    printf "Finished installing repositories and packages...\n";

#
# Configuration
#

# Configure accounts and internationalization
RUN printf "Configuring accounts and internationalization...\n" && \
    \
    printf "Configure root account...\n" && \
    cp -R /etc/skel/. /root && \
    \
    printf "Configure timezone...\n" && \
    echo "${os_timezone}" > /etc/timezone && \
    \
    printf "Configure locales...\n" && \
    sed -i "s># ${os_locale}.${os_charset} ${os_charset}>${os_locale}.${os_charset} ${os_charset}>" /etc/locale.gen && \
    locale-gen && \
    \
    printf "Finished configuring accounts and internationalization...\n";
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

