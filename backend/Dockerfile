FROM node:20-alpine

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY prisma ./prisma
RUN npx prisma generate

COPY . .

ENV NODE_ENV=production
ENV PORT=8081

EXPOSE 8081

CMD ["sh", "-c", "npx prisma migrate deploy && node ./src/app.js"]