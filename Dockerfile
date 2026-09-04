# Stage 1: Build the application
FROM node:20 AS builder
WORKDIR /app

# 1. Optimize caching: Copy package files first so npm install doesn't re-run 
# unless your dependencies actually change.
COPY package*.json ./
RUN npm install

# 2. Copy the rest of your source code and build the app
COPY . .

RUN npm run build
# In your builder stage, you run npm install. 
# This downloads both production dependencies (like express) and development 
# Tools (like nodemon and rimraf).
# If we copy that raw node_modules folder directly over to the final runner, 
# We are accidentally dragging along heavy development tools 
# That a live server doesn't need to run.
# So we delete these from node_modules after build is done at build stage end
RUN npm prune --production

# Stage 2: Run the application
FROM gcr.io/distroless/nodejs20-debian12 AS runner
WORKDIR /app

#Copy everything from the builder's dist directory to the runner's app directory
COPY --from=builder /app/dist .
COPY --from=builder /app/node_modules ./node_modules

# 6. Execute the entry point file from /app/src/index.js
# Node.js will automatically look up one level to find /app/node_modules
CMD ["src/index.js"]
