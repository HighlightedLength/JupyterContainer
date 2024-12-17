# JupyterContainer
A container for jupyter notebook. This should only be used for local or development purposes. Do not use this in production environments!

The dockerfile builds an image with an encapsulated jupyter notebook that operates independently of the host's environment. This way, the operator does not need to worry about how python, environmental variables, or the OS in general is set up. 

### Setup
1. Install [WSL for Windows](https://learn.microsoft.com/en-us/windows/wsl/install)
2. Install Rancher
  - Download the latest version from [Github](https://github.com/rancher-sandbox/rancher-desktop/releases) by clicking on `Windows` under `Installers`
  - After installing Rancher, hook up Rancher to WSL
    - On Rancher [1.16](https://docs.rancherdesktop.io/1.16/ui/preferences/wsl/integrations):
      - Open Rancher
      - Click on Preferences on the left navigation pane
      - Click on WSL
      - Check the checkbox next to your wsl distro
      - Hit Apply and wait for Rancher to restart
3. Build the docker image
Make sure that WSL is running.
    - Typically do this by running `Ubuntu` from the start menu 
  - Run `Windows Powershell` (from the start menu)
  - Browse to this project folder (where the project is cloned/extracted)
    - ex: `cd ~/Downloads/JupyterContainer`
  - Run the following command to create the docker image
```bash
docker build -t jupyter_container .
```
  - The `docker build` command only needs to be run once as long as there is no additional external python libraries.

4. Run the docker image while mounting the notebook folder so that it accessible to jupyter

```bash
# run the image as a container while mounting the notebook folder
docker run --name my_notebook -p 127.0.0.1:8888:8888 -v .\notebook:/root/notebook jupyter_container:latest
```
  - the name of the container can be changed from `my_notebook` to to a more descriptive name
  - to run multiple notebooks at the same time, change to the port
    - ex: `-p 127.0.0.1:8500:8888`
  - the folder available to jupyter can be changed
    - ex: `-v ~/Documents/my_project:/root/notebook`
  - Once the docker container is up, access the jupyter lab console at [127.0.0.1:8888/lab](http://127.0.0.1:8888/lab).
  - To close
    - exit the browser tabs with the jupyter notebook open
    - on Powershell, hit `Ctrl-C`

### Subsequent Runs
1. Open up Rancher
2. Click on `Containers` on the navigation pane to the left
3. Check the row with `my_notebook`
4. Press `Start`

Alternatively, run `docker start my_notebook` from Powershell

### Maintainence
- If any new pip packages are installed, please update requirements.txt and rebuild the docker image. 
- `docker exec -it my_notebook bash` allows for root access
