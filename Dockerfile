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
        qemu-user \
        elfutils \
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

RUN git clone --depth 1 https://github.com/zolutal/pwn_gadget ~/pwn_gadget && \
    python3 -m pip install --no-cache-dir ~/pwn_gadget/ && \
    sed -i '1isource ~/pwn_gadget/pwn_gadget.py' ~/.gdbinit

RUN apt-get -y update && \
    apt install -y --fix-missing debuginfod && \
    rm -rf /var/lib/apt/list/*

RUN echo "source ~/.gdb.conf" >> ~/.gdbinit
RUN echo "export PATH=/root/scripts:$PATH" >> ~/.bashrc
COPY gdb.conf /root/.gdb.conf
COPY tmux.conf /root/.tmux.conf
COPY scripts /root/scripts

WORKDIR /ctf/
ENV PWNDBG_NO_AUTOUPDATE=1

CMD ["/usr/bin/tmux", "new", "/bin/bash", "-o", "ignoreeof"]
