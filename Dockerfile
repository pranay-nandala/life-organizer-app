FROM microsoft/dotnet:2.1-sdk AS build
WORKDIR /src
COPY ["WebApplication2.csproj", "./"]
RUN dotnet restore "./WebApplication2.csproj"
COPY . .
RUN dotnet build "WebApplication2.csproj" -c Release -o /app

FROM build AS publish
RUN dotnet publish "WebApplication2.csproj" -c Release -o /app

FROM microsoft/dotnet:2.1-aspnetcore-runtime AS base
WORKDIR /app
EXPOSE 80

FROM base AS final
WORKDIR /app
COPY --from=publish /app .
ENTRYPOINT ["dotnet", "WebApplication2.dll"]