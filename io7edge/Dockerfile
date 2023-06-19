FROM node:16-slim

# Set to a non-root built-in user `node`
USER node

# Create app directory (with user `node`)
WORKDIR /home/node/app
RUN mkdir -p /home/node/app
COPY package.json /home/node/app
RUN npm install
COPY gateway.js /home/node/app

ENV NODE_PATH=/home/node/app/node_modules:/usr/src/node-red/node_modules:/data/node_modules

CMD [ "node", "gateway.js" ]
