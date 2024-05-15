FROM python:3.9-alpine3.13

LABEL maintainer="londonappdeveloper.com"

# ENV PYTHONDONTWRITEBYTECODE=1  - Saying python Do Not write the buffer code, .pyc files wont be written

ENV PYTHONUNBUFFERED 1 

# we are copying from source to destination 
COPY ./requirements.txt /tmp/requirements.txt
# we are copying from source to destination 
COPY ./requirements.dev.txt /tmp/requirements.dev.txt
# we are copying from source to destination
COPY ./app /app
# which is our working directory
WORKDIR /app


EXPOSE 8001

ARG DEV=false

RUN python -m venv /py && \
    /py/bin/pip install --upgrade pip && \
    apk add --update --no-cache postgresql-client && \
    apk add --update --no-cache --virtual .tmp-build-deps \
        build-base postgresql-dev musl-dev && \
    /py/bin/pip install -r /tmp/requirements.txt && \
    # it will install dev dependencies otherwise we only install requirements
    if [$DEV = "true"]; \
        then /py/bin/pip install -r /tmp/requirements.dev.txt ; \
    fi && \    
    rm -rf /tmp && \
    apk del .tmp-build-deps && \
    adduser \
    --disabled-password \
    --no-create-home \
    django-user
    
ENV PATH="/py/bin:$PATH"

USER django-user