# Build Stage
FROM node:20-alpine AS build
WORKDIR /usr/src/app
COPY package.json package-lock.json ./
RUN npm ci
COPY . .
RUN npm run build

# Test Stage
FROM cypress/browsers:node-18.16.0-chrome-114.0.5735.133-1-ff-114.0.2-edge-114.0.1823.51-1 AS test
WORKDIR /usr/src/app

## Create a non-root user
RUN useradd --create-home nonroot
USER nonroot

ENV CHROME_BIN=/usr/bin/google-chrome
COPY --from=build --chown=nonroot /usr/src/app /usr/src/app
RUN npm run test:ci

# Serve
FROM nginx:1.25.1-alpine AS serve
COPY nginx.conf /etc/nginx/nginx.conf
COPY --from=build /usr/src/app/dist /usr/share/nginx/html