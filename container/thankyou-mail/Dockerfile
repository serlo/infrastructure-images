FROM node:18-alpine

COPY ./script.js /tmp/
COPY ./package.json /tmp/
COPY ./Serlo_Logo.svg.png /tmp/
COPY ./smiley.png /tmp/
COPY ./package-lock.json /tmp/

WORKDIR /tmp
RUN npm install

ENV API_KEY $API_KEY
ENV MAIL_PASSWORD $MAIL_PASSWORD

CMD ["node", "/tmp/script.js"]

