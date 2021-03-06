# docker_setup

I have modified a standard machine learning docker container (see https://github.com/ufoym/deepo) with some vim configurations, a Jupyter Notebook server, and with `uid/gid/uname` initialized to agree with your server uid/gid/uname configuration.

To set this up...

**Step 0 (Optional):** Create an account on [Docker Hub](https://hub.docker.com). Your username will be referred to below as `[DOCKER_ID]`. This step is not necessary*, but it makes reusing dockers across machines quite convenient. Now login to your dockerhub account by typing

`docker login`

and entering your username and password.

*If you skip this step, replace `[DOCKER_ID]` in subsequent steps with any identifier you'd like, or don't use an identifier at all. However, note that your image names will be shared across the entire machine, so name responsibly!

**Step 1:** Clone this repo and `cd` into the directory containing this repository. Add any pip packages to `requirements.txt`.

**Step 2:** Build your docker container and upload it to your Docker Hub by running

`docker build --build-arg UID=$(id -u) --build-arg GID=$(id -g) --build-arg UNAME=$(id -u -n) -f Dockerfile -t [DOCKER_ID]/[IMAGE_NAME] .`

where `[IMAGE_NAME]` is the name you choose to give the resulting docker image. If you had followed Step 0 and created a docker hub account, you can now push your docker to the hub via `docker push [DOCKER_ID]/[IMAGE_NAME]`*. 

*After pushing, if you later want to run this docker image on a different machine, you can skip Steps 1 and 2 and simply call `docker pull [DOCKER_ID]/[IMAGE_NAME]`. Note that you will still have to login via `docker login`.

**Step 3:** Finally, run your docker image via

`docker run -u $(id -u):$(id -g) -it -d --runtime=nvidia --name $(id -u -n) -p [PORT_NUMBER]:8888 [VOLUME_ARGS] [DOCKER_ID]/[IMAGE_NAME] /bin/bash`

where you replace two things: 
1. `[PORT_NUMBER]` with an open port (server-side) you would like to forward the jupyter notebook port (docker-side) to.
2. `[VOLUME_ARGS]` with any volumes you want to attach to your docker. These volumes will persist after you end your Docker instance. The format for  is `-v [SERVER_DIR]:[DOCKER_DIR]`. For example, I always have the arguments:
`-v ~/projects/docker_bashrc:/home/henry/.bashrc -v ~/projects:/home/henry/projects -v /data/henry:/data`
3. And of course `[DOCKER_ID]/[IMAGE_NAME]` with your docker hub id and your newly christened docker image from Step 3.

And voila! You have a running docker with name `$(id -u -n)` (your server `uname`).

Extra notes:

Attaching to Docker:
I found it convenient to name my docker after my username, so I just attach via docker attach henry. Of course, you can change this with the `--name` flag in `docker run`

Jupyter Notebook:
To connect to the jupyter notebook server,
1. make sure you have port forwarding set up correctly, (i.e. `[PORT_NUMBER]` on the server is forwarded to your local shell), 
2. attach to your docker instance, 
3. run jupyter notebook as usual, and then enter the URL into your browser (substituting the original port in the URL with your local forwarded port).
