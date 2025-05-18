FROM node:lts-alpine3.18

WORKDIR /app

COPY package.json .

COPY prisma ./prisma/

ARG NODE_ENV
RUN if [ "$NODE_ENV" = "development" ]; \
    then npm install; \
    else npm install --only=production; \
    fi
COPY . ./

ENV PORT 80
EXPOSE $PORT

CMD ["npm", "run", 'start']
