FROM node:18.13-alpine

RUN npm install -g \
  @redocly/cli@latest \
  redoc-cli@0.13.16 \
  hbs-cli

# redocly serve
EXPOSE 8080

COPY scripts/render-template.sh /usr/local/bin/render-template.sh

CMD [ "/bin/sh" ]
