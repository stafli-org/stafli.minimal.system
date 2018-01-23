
#
#    Debian 7 (wheezy) Minimal10 System (dockerfile)
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
FROM debian:wheezy

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
      org.label-schema.os-version-id="wheezy" \
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

# Configure the package manager
#  - Disable installation of optional apt packages
#  - Enable contrib and non-free components in debian repositories
# Refresh the package manager
# Install the package manager packages
#  - apt-utils: for apt-extracttemplates, used by debconf to provide defaults for prompts (1301 kB, optional)
#  - apt-transport-https: to allow HTTPS connections to sources in apt (163 kB + 10 mB, optional) (shares dependencies with curl)
# Install the selected packages
#   Install the base packages
#    - bash: for bash, the GNU Bash shell (3941 kB, essential)
#    - tzdata: to provide time zone and daylight-saving time data (1779 kB, essential)
#    - locales: to provide common files for locale support (15121 kB, optional)
#   Install the administration packages
#    - debianutils: for which and others, basic administration packages (223 kB, essential)
#    - procps: for kill, top and others, basic administration packages (612 kB, optional)
#   Install the programming packages
#    - sed: for sed, the GNU stream editor (847 kB, essential)
#    - perl-base: for perl, an interpreter for the Perl Programming Language (4812 kB, essential)
#    - python-minimal: for python, an interpreter for the Python Programming Language (161 kB + 5461 kB, optional)
#   Install the find and replace packages
#    - grep: for grep/egrep/fgrep, the GNU utilities to search text in files (1407 kB, essential)
#    - findutils: for find, the file search utility (1406 kB, essential)
#   Install the archive and compression packages
#    - tar: for tar, the GNU tar archiving utility (2464 kB, essential)
#    - gzip: for gzip, the GNU compression utility which uses DEFLATE algorithm (202 kB, essential)
#   Install the network diagnosis packages
#    - inetutils-ping: for ping/6, the portable GNU implementation of ping (278 kB + 65 kB, optional)
#    - netcat-openbsd: for netcat, the OpenBSD rewrite of netcat - the TCP/IP swiss army knife (68 kB, optional)
#   Install the network transfer packages
#    - curl: for curl, a network utility to transfer data via FTP, HTTP, SCP, and other protocols (367 kB + ... 10 mB, optional) (shares dependencies with apt-transport-https)
#   Install the crypto packages
#    - gnupg: for gnupg, the GNU privacy guard cryptographic utility (4629 kB, essential)
#    - gnupg-curl: to add support for secure HKPS keyservers (99 kB, optional) (shares dependencies with curl)
#    - gpgv: for gpgv, the GNU privacy guard signature verification tool (403 kB, essential)
#   Install the misc packages
#    - nano: for nano, a tiny editor based on pico (1664 kB + 364 kB, optional)
#    - vim-tiny: for vim editor, an almost compatible version of the UNIX editor Vi (830 kB + 288 kB, optional)
# Cleanup the package manager
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
    printf "Refresh the package manager...\n" && \
    apt-get update && \
    \
    printf "Install the package manager packages...\n" && \
    apt-get install -qy \
      apt-utils apt-transport-https && \
    \
    printf "Install the selected packages...\n" && \
    apt-get install -qy \
      bash tzdata locales \
      debianutils procps \
      sed perl-base python-minimal \
      grep findutils \
      tar gzip \
      inetutils-ping netcat-openbsd \
      curl \
      gnupg gnupg-curl gpgv \
      nano vim-tiny && \
    \
    printf "Cleanup the package manager...\n" && \
    apt-get clean && rm -rf /var/lib/apt/lists/* && rm -Rf /var/cache/apt/* && \
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

