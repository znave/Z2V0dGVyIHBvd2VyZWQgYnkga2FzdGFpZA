# getter < https://t.me/kastaid >
# Copyright (C) 2022-present kastaid
#
# This file is a part of < https://github.com/kastaid/getter/ >
# PLease read the GNU Affero General Public License in
# < https://github.com/kastaid/getter/blob/main/LICENSE/ >.

FROM python:3.10-slim-bullseye

ENV PROJECT=getter \
    BRANCH=main \
    ORG=kastaid \
    TZ=Asia/Jakarta \
    TERM=xterm-256color \
    DEBIAN_FRONTEND=noninteractive \
    PIP_NO_CACHE_DIR=1 \
    VIRTUAL_ENV=/venv \
    PATH=/venv/bin:/app/bin:$PATH \
    CHROME_BIN=/usr/bin/google-chrome \
    DISPLAY=:99

WORKDIR /app
COPY . .

RUN set -ex \
    && apt-get -qqy update \
    && apt-get -qqy install --no-install-recommends \
        gnupg2 \
        git \
        curl \
        wget \
        tree \
        neofetch \
        fonts-roboto \
        fonts-hack-ttf \
        fonts-noto-color-emoji \
        locales \
        tzdata \
        ffmpeg \
        cairosvg \
        libjpeg-dev \
        libpng-dev \
        libnss3 \
        unzip \
        build-essential \
    && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8 \
    && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone \
    && dpkg-reconfigure --force -f noninteractive tzdata \
    && echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list \
    && wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && apt-get -qqy update \
    && apt-get -qqy install --no-install-recommends google-chrome-stable \
    && wget -qN https://chromedriver.storage.googleapis.com/$(curl -sS chromedriver.storage.googleapis.com/LATEST_RELEASE)/chromedriver_linux64.zip -P ~/ \
    && unzip -qq ~/chromedriver_linux64.zip -d ~/ \
    && rm -rf ~/chromedriver_linux64.zip \
    && mv -f ~/chromedriver /usr/bin/chromedriver \
    && chmod +x /usr/bin/chromedriver \
    && git clone -qb $BRANCH https://github.com/$ORG/$PROJECT . \
    && cp -rf .config ~/ \
    && python3 -m pip install -Uq pip \
    && python3 -m venv $VIRTUAL_ENV \
    && pip3 install --no-cache-dir -r https://raw.githubusercontent.com/$ORG/$PROJECT/$BRANCH/requirements.txt \
    && apt-get -qqy purge --auto-remove \
        curl \
        wget \
        tzdata \
        unzip \
        build-essential \
    && apt-get -qqy clean \
    && rm -rf -- ~/.cache /var/lib/apt/lists/* /var/cache/apt/archives/* /etc/apt/sources.list.d/* /usr/share/man/* /usr/share/doc/* /var/log/* /tmp/* /var/tmp/* ~/.npm

CMD ["/bin/bash", "start.sh"]
