FROM python:3.6

COPY requirements* /

ARG REQUIREMENTS_FILE=requirements.txt

RUN apt-get update && \
  apt-get install -y \
    unzip \
    postgresql-client && \
  rm -rf /var/lib/apt/lists/*

RUN pip install -r ${REQUIREMENTS_FILE}

ARG NYCDB_REPO=https://github.com/nycdb/nycdb
ARG NYCDB_REV=630f2d8b4322b96bcf0b145cbe306a010c03960d

# We need to retrieve the source directly from the repository
# because we need access to the test data, which isn't part of
# the pypi distribution.
RUN curl -L ${NYCDB_REPO}/archive/${NYCDB_REV}.zip > nycdb.zip \
  && unzip nycdb.zip \
  && rm nycdb.zip \
  && mv nycdb-${NYCDB_REV} nycdb \
  && cd nycdb/src \
  && pip install -e .

ARG WOW_REPO=https://github.com/justFixNYC/who-owns-what
ARG WOW_REV=ff23fc0065d7deca3a0f89cdf2bf234b0bb68f62
RUN curl -L ${WOW_REPO}/archive/${WOW_REV}.zip > wow.zip \
  && unzip wow.zip \
  && rm wow.zip \
  && mv who-owns-what-${WOW_REV} who-owns-what

COPY . /app

WORKDIR /app

CMD ["python", "load_dataset.py"]

ENV PATH /var/pydev/bin:$PATH
ENV PYTHONPATH /var/pydev
ENV PYTHONUNBUFFERED yup
