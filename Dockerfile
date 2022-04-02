FROM postgres:14

# RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN apt-get update \
 && apt-get install -y \
    libical-dev \
     wget \
     git \
     lsb-release

RUN sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'\
 && wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - \
 && apt-get update \
 && apt-get -y install postgresql-server-dev-14 make gcc g++ qt5-qmake unzip
ENV QT_SELECT=qt5

RUN mkdir /tmp/pg_rrule \
 && cd /tmp/pg_rrule \
 && wget https://github.com/Karpovich-alex/pg_rrule/archive/refs/heads/master.zip \
 && unzip master.zip -d /tmp/pg_rrule
WORKDIR /tmp/pg_rrule/pg_rrule-master

RUN ln -s /usr/include/postgresql/${PG_MAJOR}/server/ /usr/include/postgresql/server \
 && qmake ./src/pg_rrule.pro \
 && make \
 && cp ./libpg_rrule.so /usr/lib/postgresql/${PG_MAJOR}/lib/pg_rrule.so \
 && cp ./pg_rrule.control /usr/share/postgresql/${PG_MAJOR}/extension \
 && cp ./sql/pg_rrule.sql.in /usr/share/postgresql/${PG_MAJOR}/extension/pg_rrule--0.2.0.sql \
 && make install

WORKDIR .
RUN apt-get purge -y --auto-remove \
  postgresql-server-dev-$PG_MAJOR=$PG_VERSION \
  unzip \
  qt5-qmake \
  make \
  gcc \
  g++ \
  git \
  wget \
 && rm -dr /tmp

CMD ["postgres"]