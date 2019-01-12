FROM continuumio/miniconda3

RUN apt-get update --fix-missing && \
 apt-get install -y build-essential libboost-all-dev && \
 apt-get clean && \
 rm -rf /var/lib/apt/lists/*

ARG processors=6
ARG quantlib_version=1.14
ENV quantlib_version ${quantlib_version}

RUN wget https://dl.bintray.com/quantlib/releases/QuantLib-${quantlib_version}.tar.gz -nv \
    && tar xfz QuantLib-${quantlib_version}.tar.gz \
    && rm QuantLib-${quantlib_version}.tar.gz \
    && cd QuantLib-${quantlib_version} \
    && ./configure --prefix=/usr --disable-static CXXFLAGS=-O3 \
    && make -j ${processors} && make check && make install \
    && cd .. && rm -rf QuantLib-${quantlib_version} && ldconfig

ARG quantlib_swig_version=1.14

RUN wget https://dl.bintray.com/quantlib/releases/QuantLib-SWIG-${quantlib_swig_version}.tar.gz -nv \
    && tar xfz QuantLib-SWIG-${quantlib_swig_version}.tar.gz \
    && rm QuantLib-SWIG-${quantlib_swig_version}.tar.gz \
    && cd QuantLib-SWIG-${quantlib_swig_version} \
    && ./configure CXXFLAGS='-g0 -O3' PYTHON=/opt/conda/bin/python3 \
    && make -C Python -j ${processors} && make -C Python check && make -C Python install \
    && cd .. && rm -rf QuantLib-SWIG-${quantlib_swig_version}

WORKDIR /app
COPY environment.yml environment.yml

RUN conda install --yes --file environment.yml
