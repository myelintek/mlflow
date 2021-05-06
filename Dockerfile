FROM ubuntu:18.04

# WORKDIR /app

# ADD . /app

ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8

# requires valgrind
RUN apt-get update && apt-get install -y \
    # install prequired modules to support install of mlflow and related components
    default-libmysqlclient-dev \
    build-essential \
    curl \
    python3 \
    python3-pip \
    # cmake and protobuf-compiler required for onnx install
    cmake \
    protobuf-compiler

# mkdir required to support install openjdk-11-jre-headless
RUN mkdir -p /usr/share/man/man1 && apt-get install -y openjdk-11-jre-headless

# install npm for node.js support
RUN curl -sL https://deb.nodesource.com/setup_10.x | bash - && \
    apt-get update && apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/*

# expects "python" executable (not python3).
RUN rm -f /usr/bin/python && \
    ln -s /usr/bin/python3 /usr/bin/python

# install required python packages
# RUN pip3 install -r dev-requirements.txt --no-cache-dir && \
    # pip3 install -r test-requirements.txt --no-cache-dir && \
    # install mlflow in editable form
    # pip3 install --no-cache-dir -e .

# mlflow build
# RUN cd mlflow/server/js && \
#     npm install && \
#     npm run build

# mlflow install
RUN mkdir -p /root/mlflow
RUN pip3 install mlflow

# docker binary file
RUN curl -O https://download.docker.com/linux/static/stable/x86_64/docker-19.03.14.tgz && \
    tar zxvf docker-19.03.14.tgz && \
    cp docker/docker /usr/bin/docker && \
    rm -rf docker-19.03.14.tgz

EXPOSE 5000
CMD mlflow server \
  --host 0.0.0.0 \
  --port 5000 \
  --backend-store-uri=sqlite:////root/mlflow/mlflow.db \
  --default-artifact-root=file:///root/mlflow/mlruns/
