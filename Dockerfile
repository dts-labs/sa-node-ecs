FROM debian:jessie

RUN apt-get update

RUN apt-get install -y curl

RUN curl -sL https://deb.nodesource.com/setup_4.x | bash -

RUN apt-get install -y nodejs

WORKDIR /src
ADD . /src
RUN . ~/.bashrc

RUN npm install

EXPOSE 8080

CMD [ "npm", "start" ]