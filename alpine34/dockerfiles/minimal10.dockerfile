
#
#    Alpine 3.4 (alpine34) Minimal10 System (dockerfile)
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
FROM alpine:3.4

# Labels to apply
LABEL description="Stafli Minimal System (stafli/stafli.system.minimal), based on Upstream distributions" \
      maintainer="lp@algarvio.org" \
      org.label-schema.schema-version="1.0.0-rc.1" \
      org.label-schema.name="Stafli Minimal System (stafli/stafli.system.minimal)" \
      org.label-schema.description="Based on Upstream distributions" \
      org.label-schema.keywords="stafli, minimal, system, debian, centos, ubuntu, alpine" \
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
      org.label-schema.os-id="alpine" \
      org.label-schema.os-version-id="34" \
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

# Refresh the package manager
# Install the package manager packages
#  - apt-utils: for apt-extracttemplates, used by debconf to provide defaults for prompts (950 kB, optional)
#  - apt-transport-https: to allow HTTPS connections to sources in apt (190 kB + 10 mB, optional) (shares dependencies with curl)
# Install the selected packages
#   Install the base packages
#    - bash: for bash, the GNU Bash shell (5010 kB, essential)
#    - tzdata: to provide time zone and daylight-saving time data (1712 kB, essential)
#    - glib: to provide common files for locale support (16266 kB, optional)
#   Install the administration packages
#    - which: for which and others, basic administration packages (147 kB, essential)
#    - procps: for kill, top and others, basic administration packages (670 kB, optional)
#   Install the programming packages
#    - sed: for sed, the GNU stream editor (575 kB, essential)
#    - perl: for perl, an interpreter for the Perl Programming Language (4657 kB, essential)
#    - python: for python, an interpreter for the Python Programming Language (163 kB + 3825 kB + 2687 kB, optional)
#   Install the find and replace packages
#    - grep: for grep/egrep/fgrep, the GNU utilities to search text in files (1272 kB, essential)
#    - findutils: for find, the file search utility, and locate, which maintains and queries an index of a directory tree (1406 kB, essential)
#    - tree: for tree, displays directory tree, in color (112 kB, optional)
#   Install the archive and compression packages
#    - tar: for tar, the GNU tar archiving utility (2261 kB, essential)
#    - gzip: for gzip, the GNU compression utility which uses DEFLATE algorithm (239KB, essential)
#   Install the network diagnosis packages
#    - iputils: for ping and traceroute, an implementation of ping and tracepath (307 kB + 66 kB, optional)
#    - netcat-openbsd: for netcat, the OpenBSD rewrite of netcat - the TCP/IP swiss army knife (68 kB, optional)
#   Install the network transfer packages
#    - curl: for curl, a network utility to transfer data via FTP, HTTP, SCP, and other protocols (290 kB + ... 10 mB, optional) (shares dependencies with apt-transport-https)
#   Install the crypto packages
#    - gnupg: for gnupg, the GNU privacy guard cryptographic utility, gpgv, the GNU privacy guard signature verification tool and dirmngr, the GNU privacy guard network certificate management service (4893 kB, essential)
#    - openssl: for openssl, the OpenSSL cryptographic utility required for many packages (1119 kB, optional)
#    - ca-certificates: adds trusted PEM files of CA certificates to the system (376 kB, optional)
#   Install the misc packages
#    - nano: for nano, a tiny editor based on pico (1667 kB + 357 kB, optional)
#    - vim: for vim editor, an almost compatible version of the UNIX editor Vi (1051 kB + 405 kB, optional)
# Cleanup the package manager
RUN printf "Installing repositories and packages...\n" && \
    \
    printf "Refresh the package manager...\n" && \
    apk update && \
    \
    printf "Install the selected packages...\n" && \
    apk add -q \
      bash tzdata glib \
      which procps \
      sed perl python \
      grep findutils tree \
      tar gzip \
      iputils netcat-openbsd \
      curl \
      gnupg openssl ca-certificates \
      nano vim && \
    \
    printf "Cleanup the package manager...\n" && \
    rm -Rf /var/cache/apk/* && \
    \
    printf "Finished installing repositories and packages...\n";

#
# Configuration
#

# Configure accounts and internationalization
RUN printf "Configuring accounts and internationalization...\n" && \
    \
    printf "Configure timezone...\n" && \
    cp /usr/share/zoneinfo/${os_timezone} /etc/localtime && \
    echo "${os_timezone}" > /etc/timezone && \
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

