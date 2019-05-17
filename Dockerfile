FROM perl:5.28.1-threaded
ENV LANG C.UTF-8

WORKDIR /app

RUN cpanm Carton
COPY cpanfile /app
COPY cpanfile.snapshot /app
RUN carton install

COPY . /app

CMD [ "carton", "exec", "perl", "main.pl" ]