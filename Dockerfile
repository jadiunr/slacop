FROM perl:5.28.1-threaded
ENV LANG C.UTF-8

WORKDIR /tmp

# Install MeCab
RUN curl -Lo mecab-0.996.tar.gz 'https://drive.google.com/uc?export=download&id=0B4y35FiV1wh7cENtOXlicTFaRUE' && \
    tar xzf mecab-0.996.tar.gz && \
    cd mecab-0.996/ && \
    ./configure --enable-utf8-only && \
    make && \
    make install && \
    echo '/usr/local/lib' >> /etc/ld.so.conf && \
    ldconfig && \
    rm -rf /tmp/*

# Install IPA Dictionary
RUN curl -Lo mecab-ipadic-2.7.0-20070801.tar.gz 'https://drive.google.com/uc?export=download&id=0B4y35FiV1wh7MWVlSDBCSXZMTXM' && \
    tar xzf mecab-ipadic-2.7.0-20070801.tar.gz && \
    cd mecab-ipadic-2.7.0-20070801/ && \
    ./configure --with-charset=utf8 && \
    make && \
    make install && \
    rm -rf /tmp/*

# Install NEologd
RUN git clone --depth 1 https://github.com/neologd/mecab-ipadic-neologd.git && \
    cd mecab-ipadic-neologd && \
    ./bin/install-mecab-ipadic-neologd -n -a -y && \
    rm -rf /tmp/*

WORKDIR /app

RUN cpanm Carton
COPY cpanfile /app
COPY cpanfile.snapshot /app
RUN carton install

COPY . /app

CMD [ "carton", "exec", "perl", "main.pl" ]