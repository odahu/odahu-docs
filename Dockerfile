FROM ubuntu:18.04

# Install native dependencies
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y software-properties-common build-essential wget bzip2 ca-certificates curl git \
                       bash coreutils make ttf-dejavu graphviz wget \
                       python3-dev libjpeg-dev zlib1g-dev zip python3-pip openjdk-8-jre && \
    apt-get clean && rm -rf /var/lib/apt/lists/*



COPY requirements.txt /
RUN pip3 install -r /requirements.txt

RUN wget https://deac-ams.dl.sourceforge.net/project/plantuml/plantuml.jar

ADD generate.sh /
RUN chmod +x /generate.sh
