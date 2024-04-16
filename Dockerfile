# pull official base image
FROM python:3.10.14-alpine

# This prevents Python from writing out pyc files
ENV PYTHONDONTWRITEBYTECODE 1

# This keeps Python from buffering stdin/stdout
ENV PYTHONUNBUFFERED 1

EXPOSE 22 8888
COPY docker_entrypoint.sh /

# install ssh server
RUN apk add --update --no-cache openssh \
    && echo 'PasswordAuthentication yes' >> /etc/ssh/sshd_config \
    && echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config \
    && echo -n 'root:default_pass' | chpasswd


# install jupyter
COPY requirements.txt /
RUN apk add gcc python3-dev musl-dev linux-headers \
    && pip install --upgrade pip setuptools wheel \
    && pip install -r requirements.txt \
    && jupyter notebook --generate-config \
    && sed -i -e \
        "s/# c.ServerApp.allow_origin = ''/c.ServerApp.allow_origin = '*'/g" \
        /root/.jupyter/jupyter_notebook_config.py \
    && sed -i -e \
        "s/# c.LabServerApp.open_browser = False/c.LabServerApp.open_browser = False/g" \
        /root/.jupyter/jupyter_notebook_config.py \
    && sed -i -e \
        "s/# c.ServerApp.allow_root = False/# c.ServerApp.allow_root = True/g" \
        /root/.jupyter/jupyter_notebook_config.py \ 
    && sed -i -e \   
        "s/# c.ServerApp.token = '<DEPRECATED>'/c.ServerApp.token = ''/g" \
        /root/.jupyter/jupyter_notebook_config.py \
    && sed -i -e \   
        "s/# c.ServerApp.password = ''/c.ServerApp.password = ''/g" \
        /root/.jupyter/jupyter_notebook_config.py

ENTRYPOINT ["/docker_entrypoint.sh"]