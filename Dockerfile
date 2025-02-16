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
        qemu-system \
        elfutils \
        debuginfod \
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

# RUN git clone --depth 1 https://github.com/niklasb/libc-database.git libc-database && \
#     cd libc-database && ./get ubuntu debian || echo "/libc-database/" > ~/.libcdb_path && \
#     rm -rf /tmp/*

RUN git clone --depth 1 https://github.com/pwndbg/pwndbg ~/pwndbg && \
    cd ~/pwndbg && chmod +x setup.sh && ./setup.sh

RUN git clone --depth 1 https://github.com/scwuaptx/Pwngdb.git ~/Pwngdb && \
    cd ~/Pwngdb && sed -i "s?source ~/peda/peda.py?# source ~/peda/peda.py?g" .gdbinit

RUN git clone --depth 1 https://github.com/zolutal/pwn_gadget ~/pwn_gadget && \
    python3 -m pip install --no-cache-dir ~/pwn_gadget/

RUN git clone --depth 1 https://github.com/marin-m/vmlinux-to-elf.git ~/vmlinux-to-elf && \
    python3 -m pip install --no-cache-dir ~/vmlinux-to-elf/

RUN python3 -m compileall /usr/lib/python3 /root

RUN echo "export PATH=/root/scripts:$PATH" >> ~/.bashrc
COPY gdbinit /root/.gdbinit
COPY tmux.conf /root/.tmux.conf
COPY scripts /root/scripts
COPY gdb-extras /root/gdb-extras

WORKDIR /ctf/
ENV PWNDBG_NO_AUTOUPDATE=1

CMD ["/usr/bin/tmux", "new", "/bin/bash", "-o", "ignoreeof"]
