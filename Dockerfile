# Using multistage-build to optimize the container image size.
# Thanks to the multi-stage build feature, we can keep our final image (here
# called production) as slim as possible by keeping all the unnecessary  bloat
# in the development image.

# The first FROM tells Docker to use the latest LTS node version as base image
# to build the container.
FROM node:14 AS development

# Create the working directory for the application which stores the code. All
# commands (RUN, COPY) are executed inside this directory
WORKDIR /app

# Copy and install your app dependencies inside the Docker image. Also copy the
# whole prisma directory in case you need the migrations and for the Prisma
# Client (which requires the schema.prisma file).
COPY package*.json ./
COPY prisma ./prisma/

# Here we install only devDependencies due to the container being used as a
# “builder” that takes all the necessary tools to build the application and 
# later send a clean /dist folder to the production image.
RUN npm install

# Copy all of your source files (exceptions in .dockerignore file) into the 
# Docker image and build the application. The order of statements is very
# important here due to how Docker caches layers. Each statement in the
# Dockerfile generates a new image layer, which is cached. If we copied all
# files at once and then ran npm install, each file change would cause Docker
# to think it should run npm install all over again. By first copying only 
# package*.json files, we are telling Docker that it should run npm install
# and all the commands appearing afterwards only when either package.json or 
# package-lock.json files change.
COPY . .

# Finally, we make sure the app is built in the /dist folder. Since our 
# application uses TypeScript and other build-time dependencies, we have to
# execute this command in the development image.
RUN npm run build


# This is the second stage in the multi-stage build and is used to run the
# application. By using the FROM statement again, we are telling Docker that it
# should create a new, fresh image without any connection to the previous one. 
# This time we are naming it production
FROM node:14 AS production

# Here we are using the ARG statement to define the default value for NODE_ENV,
# even though the default value is only available during the build time
# (not when we start the application). Then we use the ENV statement to set it
# to either the default value or the user-set value.
ARG NODE_ENV=production
ENV NODE_ENV=${NODE_ENV}

# Now this part is exactly the same as the one above, but this time, we are
# making sure that we install only dependencies defined in dependencies in
# package.json by using the --only=production argument. This way we don’t
# install packages such as TypeScript that would cause our final image to
# increase in size.
WORKDIR /app

COPY package*.json ./

RUN npm install --only=production

COPY . .

# Here we copy the built /dist folder from the development image. This way we
# are only getting the /dist directory, without the devDependencies, installed
# in our final image.
COPY --from=development /app/dist ./dist

EXPOSE 3000
CMD ["node", "dist/main"]
# CMD [ "npm", "run", "start:dev" ]

# Now, the Dockerfile is ready to be used to run our application in a container.
# We can build the image by running:
# `docker build -t app-name .`
# (The -t option is for giving our image a name, i.e., tagging it.)
# And then run it:
# `docker run app-name`
#
# But this is not a development-ready solution. What about hot reloading? What
# if our application depended on some external tools like Postgres and Redis? 
# We wouldn’t want to have each developer individually install them on their 
# machine.
# All these problems can be solved using docker-compose — a tool that wraps
# everything together for local development.
