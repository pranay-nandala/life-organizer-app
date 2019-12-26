FROM microsoft/dotnet:2.1-aspnetcore-runtime AS base
WORKDIR /app
EXPOSE 80

FROM microsoft/dotnet:2.1-sdk AS build
WORKDIR /src
COPY *.sln ./
COPY ./WebApplication2.csproj ./
RUN dotnet restore
COPY . .
WORKDIR /src
RUN dotnet build -c Release -o /app

FROM build AS publish
RUN dotnet publish -c Release -o /app

#Angular build
FROM node as nodebuilder

# set working directory
RUN mkdir /usr/src/app
WORKDIR /usr/src/app

# add `/usr/src/app/node_modules/.bin` to $PATH
ENV PATH /usr/src/app/node_modules/.bin:$PATH


# install and cache app dependencies
COPY ClientApp/package.json /usr/src/app/package.json
RUN npm install
RUN npm install -g @angular/cli@1.7.0 --unsafe

# add app

COPY ClientApp/. /usr/src/app

RUN npm run build

#End Angular build

FROM base AS final
WORKDIR /app
COPY --from=publish /l/linux/libuv.so .
COPY --from=publish /app .
RUN mkdir -p /app/ClientApp/dist
COPY --from=nodebuilder /usr/src/app/dist/. /app/ClientApp/dist/
ENTRYPOINT ["dotnet", "WebApplication2.dll"]