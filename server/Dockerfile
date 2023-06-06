# Use the official Node.js image as the base image
FROM node:14

# Set the working directory inside the container
WORKDIR /app

# Copy package.json and package-lock.json to the working directory
COPY package*.json ./

# Copy the Prisma schema to the working directory
COPY prisma ./prisma/

# Copy the rest of the application code to the working directory
COPY . .

# Install the dependencies
RUN npm install

# Generate the Prisma client
RUN npm run prisma_gen

# Expose the port the application will run on
EXPOSE 3000

# Start the application
CMD ["npm", "start"]