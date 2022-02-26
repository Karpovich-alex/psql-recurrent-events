FROM postgres:14

RUN set -ex; \
# pub   4096R/ACCC4CF8 2011-10-13 [expires: 2019-07-02]
#       Key fingerprint = B97B 0AFC AA1A 47F0 44F2  44A0 7FCC 7D46 ACCC 4CF8
# uid                  PostgreSQL Debian Repository
	key='B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8'; \
	export GNUPGHOME="$(mktemp -d)"; \
	gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$key"; \
	gpg --export "$key" > /etc/apt/trusted.gpg.d/postgres.gpg; \
	rm -r "$GNUPGHOME"; \
	apt-key list

RUN echo 'deb http://apt.postgresql.org/pub/repos/apt/ jessie-pgdg main' $PG_MAJOR > /etc/apt/sources.list.d/pgdg.list

RUN apt-get update \
	&& apt-get install -y \
    postgresql-server-dev-$PG_MAJOR=$PG_VERSION \
    pwgen \
    unzip \
    qt4-qmake \
    make \
    gcc \
    g++ \
    libical1a \
    libical-dev \
    libc6-dev \
    wget \
	&& rm -rf /var/lib/apt/lists/*

RUN mkdir /tmp/pg_rrule \
 && cd /tmp/pg_rrule \
 && wget https://github.com/petropavel13/pg_rrule/archive/master.zip \
 && unzip master.zip \
 && cd pg_rrule-master/src \
 && ln -s /usr/include/postgresql/${PG_MAJOR}/server/ /usr/include/postgresql/server \
 && qmake-qt4 pg_rrule.pro \
 && make \
 && cp libpg_rrule.so /usr/lib/postgresql/${PG_MAJOR}/lib/pg_rrule.so \
 && cp ../pg_rrule.control /usr/share/postgresql/${PG_MAJOR}/extension \
 && cp ../sql/pg_rrule.sql.in /usr/share/postgresql/${PG_MAJOR}/extension/pg_rrule--0.2.0.sql

RUN apt-get purge -y --auto-remove \
  postgresql-server-dev-$PG_MAJOR=$PG_VERSION \
  pwgen \
  unzip \
  qt4-qmake \
  make \
  gcc \
  g++ \
  libical-dev \
  libc6-dev \
  wget