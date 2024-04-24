# pull official base image
FROM python:3.10.14-alpine

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
RUN apk add --update --no-cache openssh \
    && echo 'PasswordAuthentication yes' >> /etc/ssh/sshd_config \
    && echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config \
    && echo -n "root:$PASS" | chpasswd

# install jupyter
COPY requirements.txt /tmp/
RUN apk add gcc python3-dev musl-dev linux-headers build-base \
    && pip install --upgrade pip setuptools wheel \
    && apk add py3-scikit-learn \
    && pip install -r /tmp/requirements.txt \
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
        /root/.jupyter/jupyter_lab_config.py

ENTRYPOINT ["/tmp/docker_entrypoint.sh"]