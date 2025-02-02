FROM phusion/baseimage:jammy-1.0.4

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe/Warsaw

RUN dpkg --add-architecture i386 && \
    apt-get -y update && \
    apt install -y --fix-missing \
        libc6:i386 \
        libc6-dbg:i386 \
        libc6-dbg \
        lib32stdc++6 \
        g++-multilib \
        cmake \
        ipython3 \
        vim \
        net-tools \
        iputils-ping \
        libffi-dev \
        libssl-dev \
        python3-dev \
        python3-pip \
        build-essential \
        ruby \
        ruby-dev \
        tmux \
        strace \
        ltrace \
        nasm \
        wget \
        gdb \
        gdb-multiarch \
        netcat \
        socat \
        git \
        patchelf \
        gawk \
        file \
        python3-distutils \
        bison \
        rpm2cpio cpio \
        zstd \
        tzdata && \
    rm -rf /var/lib/apt/list/*

RUN ln -fs /usr/share/zoneinfo/$TZ /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata

RUN python3 -m pip install -U pip && \
    python3 -m pip install --no-cache-dir \
        ropgadget \
        z3-solver \
        smmap2 \
        apscheduler \
        ropper \
        unicorn \
        keystone-engine \
        capstone \
        angr \
        pebble \
        pwntools

RUN gem install one_gadget seccomp-tools && rm -rf /var/lib/gems/2.*/cache/*

RUN git clone --depth 1 https://github.com/pwndbg/pwndbg && \
    cd pwndbg && chmod +x setup.sh && ./setup.sh

RUN git clone --depth 1 https://github.com/scwuaptx/Pwngdb.git ~/Pwngdb && \
    cd ~/Pwngdb && mv .gdbinit .gdbinit-pwngdb && \
    sed -i "s?source ~/peda/peda.py?# source ~/peda/peda.py?g" .gdbinit-pwngdb && \
    echo "source ~/Pwngdb/.gdbinit-pwngdb" >> ~/.gdbinit

RUN git clone --depth 1 https://github.com/niklasb/libc-database.git libc-database && \
    cd libc-database && ./get ubuntu debian || echo "/libc-database/" > ~/.libcdb_path && \
    rm -rf /tmp/*

COPY --from=skysider/glibc_builder64:2.19 /glibc/2.19/64 /glibc/2.19/64
COPY --from=skysider/glibc_builder32:2.19 /glibc/2.19/32 /glibc/2.19/32

COPY --from=skysider/glibc_builder64:2.23 /glibc/2.23/64 /glibc/2.23/64
COPY --from=skysider/glibc_builder32:2.23 /glibc/2.23/32 /glibc/2.23/32

COPY --from=skysider/glibc_builder64:2.24 /glibc/2.24/64 /glibc/2.24/64
COPY --from=skysider/glibc_builder32:2.24 /glibc/2.24/32 /glibc/2.24/32

COPY --from=skysider/glibc_builder64:2.27 /glibc/2.27/64 /glibc/2.27/64
COPY --from=skysider/glibc_builder32:2.27 /glibc/2.27/32 /glibc/2.27/32

COPY --from=skysider/glibc_builder64:2.28 /glibc/2.28/64 /glibc/2.28/64
COPY --from=skysider/glibc_builder32:2.28 /glibc/2.28/32 /glibc/2.28/32

COPY --from=skysider/glibc_builder64:2.29 /glibc/2.29/64 /glibc/2.29/64
COPY --from=skysider/glibc_builder32:2.29 /glibc/2.29/32 /glibc/2.29/32

COPY --from=skysider/glibc_builder64:2.30 /glibc/2.30/64 /glibc/2.30/64
COPY --from=skysider/glibc_builder32:2.30 /glibc/2.30/32 /glibc/2.30/32

COPY --from=skysider/glibc_builder64:2.33 /glibc/2.33/64 /glibc/2.33/64
COPY --from=skysider/glibc_builder32:2.33 /glibc/2.33/32 /glibc/2.33/32

COPY --from=skysider/glibc_builder64:2.34 /glibc/2.34/64 /glibc/2.34/64
COPY --from=skysider/glibc_builder32:2.34 /glibc/2.34/32 /glibc/2.34/32

COPY --from=skysider/glibc_builder64:2.35 /glibc/2.35/64 /glibc/2.35/64
COPY --from=skysider/glibc_builder32:2.35 /glibc/2.35/32 /glibc/2.35/32

COPY --from=skysider/glibc_builder64:2.36 /glibc/2.36/64 /glibc/2.36/64
COPY --from=skysider/glibc_builder32:2.36 /glibc/2.36/32 /glibc/2.36/32

WORKDIR /ctf/work/
ENV PWNDBG_NO_AUTOUPDATE=1

CMD ["/bin/bash"]
