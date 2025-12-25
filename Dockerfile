FROM node:24-slim AS base

WORKDIR /app

RUN corepack enable

COPY package.json yarn.lock .yarnrc.yml ./
COPY .yarn ./.yarn
COPY packages ./packages

RUN yarn install --immutable

FROM base AS dev-ui

ENV NODE_ENV=development
WORKDIR /app/packages/ui

EXPOSE 5173

CMD ["yarn", "start:dev"]

FROM base AS dev-server

ENV NODE_ENV=development
WORKDIR /app/packages/server

EXPOSE 3000

CMD ["yarn", "dev"]

FROM base AS build

ENV NODE_ENV=production
WORKDIR /app

RUN yarn workspace @opencpm/ui build && yarn workspace @opencpm/server build

FROM node:24-slim AS prod

WORKDIR /app

RUN corepack enable

COPY package.json yarn.lock .yarnrc.yml ./
COPY .yarn ./.yarn
COPY packages ./packages
COPY --from=base /app/node_modules ./node_modules
COPY --from=build /app/packages/ui/dist /app/ui
COPY --from=build /app/packages/server/dist ./packages/server/dist

ENV NODE_ENV=production
ENV PORT=3000
ENV UI_DIST_PATH=/app/ui

WORKDIR /app/packages/server

EXPOSE 3000

CMD ["yarn", "start"]
