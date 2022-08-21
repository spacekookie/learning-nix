FROM ubuntu:latest

RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y emacs curl

RUN mkdir /ci
COPY setup.el /ci/
COPY export-course.el /ci/

RUN yes | emacs --batch -l /ci/setup.el
