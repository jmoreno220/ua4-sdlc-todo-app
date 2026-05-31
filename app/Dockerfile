FROM node:18-alpine
WORKDIR /usr/src/app
ENV NODE_ENV=production
COPY package*.json ./
RUN npm ci --only=production
COPY . .

# Usamos un usuario sin privilegios en lugar de root
USER node
EXPOSE 3000
CMD ["node", "src/index.js"]