FROM ufoym/deepo
ARG UNAME
ARG UID
ARG GID
WORKDIR /home/$UNAME/projects
SHELL ["/bin/bash", "-c"]
RUN whoami
RUN add-apt-repository ppa:jonathonf/vim && apt-get update && apt-get install -y vim-gtk3 tmux git python3-tk build-essential ffmpeg python3-venv texlive-xetex pandoc

RUN echo "UNAME: $UNAME, UID: $UID, GID: $GID"
RUN groupadd -g $GID -o $UNAME
RUN useradd -m -u $UID -g $GID -o -s /bin/bash $UNAME
RUN usermod -aG sudo $UNAME
RUN sudo chown -R $UNAME:$UNAME /home/$UNAME/
RUN sudo passwd -d $UNAME
RUN whoami
USER $UNAME
RUN whoami

RUN curl https://j.mp/spf13-vim3 -L > spf13-vim.sh && sh spf13-vim.sh && printf 'imap jk <Esc>\nset mouse=a\nlet mapleader= ";"' >> ~/.vimrc.local
COPY requirements.txt /projects/requirements.txt
RUN export PATH="$PATH:/home/$UNAME/.local/bin"
RUN pip install --upgrade pip
RUN pip install -r /projects/requirements.txt
RUN whoami
RUN jupyter notebook --generate-config
RUN printf "\nc.NotebookApp.password = u'argon2:\$argon2id\$v=19\$m=10240,t=10,p=8\$vBR5GSzutggf1gn6f/yZyA\$B/NHZh1X/sA4H0sYjaUyQQ'\nc.NotebookApp.ip = '0.0.0.0'\n" >> /home/$UNAME/.jupyter/jupyter_notebook_config.py
RUN curl -L https://iterm2.com/shell_integration/install_shell_integration_and_utilities.sh | bash


