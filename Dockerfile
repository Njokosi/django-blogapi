### Build and install packages
FROM python:3.9


RUN apt-get -y update \
    && apt-get install -y gettext \
    # Cleanup apt cache
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*


### Set environment variables
# PYTHONDONTWRITEBYTECODE means Python will not try to write .pyc files
# PYTHONUNBUFFERED ensures our console output looks familiar and is not buffered by Docker
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

### Set working directory
WORKDIR /app

# Install python dependencies
COPY requirements.txt /app/
RUN pip install -r requirements.txt

### Create system group and account
# groupadd -r Create a system group
# useradd -r -g: Create a system account -g The group name or number of the user's initial login group.
RUN groupadd -r innvvo && useradd -r -g innvvo innvvo


RUN apt-get update \
    && apt-get install -y \
    libcairo2 \
    libgdk-pixbuf2.0-0 \
    liblcms2-2 \
    libopenjp2-7 \
    libpango-1.0-0 \
    libpangocairo-1.0-0 \
    libssl1.1 \
    libtiff5 \
    libwebp6 \
    libxml2 \
    libpq5 \
    shared-mime-info \
    mime-support \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*



RUN mkdir -p /app/media /app/static \
    && chown -R innvvo:innvvo /app/


# Copy project
COPY . /app

ARG STATIC_URL
ENV STATIC_URL ${STATIC_URL:-/static/}
RUN SECRET_KEY=dummy STATIC_URL=${STATIC_URL} python3 manage.py collectstatic --no-input


EXPOSE 8000

ARG COMMIT_ID
ARG PROJECT_VERSION
ENV PROJECT_VERSION="${PROJECT_VERSION}"


# Label the project docker
LABEL org.opencontainers.image.title="innvvo/njokosi"                                  \
    org.opencontainers.image.description="\
    A modular, high performance, headless blogging platform built with Python, \
    DjangoRestFramework, Django, and NextJS."                                                         \
    org.opencontainers.image.url="https://github.com/Njokosi/django-blogapi"                                \
    org.opencontainers.image.source="https://github.com/Njokosi/django-blogapi"              \
    org.opencontainers.image.revision="$COMMIT_ID"                                   \
    org.opencontainers.image.version="$PROJECT_VERSION"                              \
    org.opencontainers.image.authors="Innvvo Inc (https://innvvo.com)"        \
    org.opencontainers.image.licenses="BSD 3"



