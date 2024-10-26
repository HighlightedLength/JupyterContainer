# pull official base image
FROM ubuntu:latest

LABEL maintainer="allen.h@outlook.com"
LABEL description="A container for running jupyter locally"
LABEL "docker.cmd"="docker run -p 127.0.0.1:8888:8888 -v .\notebook:/root/notebook jupyter-container:latest"
LABEL url="https://github.com/HighlightedLength/JupyterContainer"

ARG PASS="default_pass"

# This prevents Python from writing out pyc files
ENV PYTHONDONTWRITEBYTECODE 1

# This keeps Python from buffering stdin/stdout
ENV PYTHONUNBUFFERED 1

EXPOSE 22 8888
COPY docker_entrypoint.sh /tmp/

# install ssh server
# setting update time because windows can be silly
RUN apt -o Acquire::Max-FutureTime=86400 update \
 && apt install -y openssh-server net-tools \
 && mkdir /run/sshd \
 && chmod 755 /run/sshd

# set authentication
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/g' /etc/ssh/sshd_config \
 && echo "export VISIBLE=now" >> /etc/profile \
 && echo 'root:default_pass' | chpasswd

# install jupyter
COPY requirements.txt /tmp/
RUN apt install -y python3-pip python3-dev libcairo2-dev pkg-config \
    && pip install --upgrade pip setuptools wheel \
    && pip install -r /tmp/requirements.txt \
    && pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu \
    && jupyter-lab --generate-config \
    && sed -i -e \
        "s/# c.ServerApp.allow_origin = ''/c.ServerApp.allow_origin = '*'/g" \
        /root/.jupyter/jupyter_lab_config.py \
    && sed -i -e \
        "s/# c.LabServerApp.open_browser = False/c.LabServerApp.open_browser = False/g" \
        /root/.jupyter/jupyter_lab_config.py \
    && sed -i -e \
        "s/# c.ServerApp.allow_root = False/c.ServerApp.allow_root = True/g" \
        /root/.jupyter/jupyter_lab_config.py \ 
    && sed -i -e \   
        "s/# c.ServerApp.token = '<DEPRECATED>'/c.ServerApp.token = ''/g" \
        /root/.jupyter/jupyter_lab_config.py \
    && sed -i -e \   
        "s/# c.ServerApp.password = ''/c.ServerApp.password = ''/g" \
        /root/.jupyter/jupyter_lab_config.py \
    && echo "c.FileContentsManager.delete_to_trash = False" >> /root/.jupyter/jupyter_lab_config.py

ENTRYPOINT [ "/tmp/docker_entrypoint.sh" ]
