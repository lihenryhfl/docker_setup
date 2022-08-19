#FROM pytorch/pytorch:latest
FROM nvidia/cuda:11.3.0-cudnn8-devel-ubuntu20.04

ARG UNAME
ARG UID
ARG GID
WORKDIR /home/$UNAME/projects
SHELL ["/bin/bash", "-c"]
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends software-properties-common dialog apt-utils
RUN DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt-get install -y --no-install-recommends \
    vim-gtk3 \
    tmux \
    git \
    python3-tk \
    python3-dev \
    build-essential \
    ffmpeg \
    python3-venv \
    texlive-xetex \
    pandoc \
    software-properties-common \
    curl \
    python3-setuptools \
    sudo \
    python3-pip \
    wget

#RUN echo "UNAME: $UNAME, UID: $UID, GID: $GID"
RUN groupadd -g $GID -o $UNAME
RUN useradd -m -o -u $UID -g $GID $UNAME && echo "$UNAME:$UNAME" | chpasswd
RUN usermod -aG sudo $UNAME
RUN sudo chown -R $UNAME:$UNAME /home/$UNAME/
USER $UNAME

RUN sudo dpkg -i /projects/gcm-linux_amd64.2.0.785.deb
RUN sh <(curl https://j.mp/spf13-vim3 -L)
RUN printf "imap jk <Esc>\nset mouse=a\nlet mapleader=';'\nset autoindent\nset expandtab\nset wrap" >> ~/.vimrc.local
RUN python3 -m pip install --upgrade pip
COPY requirements.txt /projects/requirements.txt
ENV HOME="/home/$UNAME"
ENV PATH="$HOME/.local/bin:${PATH}"
RUN pip install -r /projects/requirements.txt
RUN $HOME/.local/bin/jupyter notebook --generate-config
RUN printf "\nc.NotebookApp.password = u'argon2:\$argon2id\$v=19\$m=10240,t=10,p=8\$vBR5GSzutggf1gn6f/yZyA\$B/NHZh1X/sA4H0sYjaUyQQ'\nc.NotebookApp.ip = '0.0.0.0'\n" >> /home/$UNAME/.jupyter/jupyter_notebook_config.py
RUN tmux show -g | cat > /home/$UNAME/.tmux.conf
RUN printf "\nset-option -g history-limit 10000\nset-option -g default-shell /bin/bash\n" >> /home/$UNAME/.tmux.conf
