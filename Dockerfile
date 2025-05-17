# We build with .NET 9 to get the latest compiler and CA settings
ARG DOTNET_BUILD_VERSION=9.0-alpine
# We run with .NET 9 because that is the only version we compile the project for
ARG DOTNET_RUNTIME_VERSION=9.0-alpine

#############################

# Build C# server

FROM --platform=$BUILDPLATFORM mcr.microsoft.com/dotnet/sdk:${DOTNET_BUILD_VERSION} AS builder
ENV docker=true

WORKDIR /app

RUN apk update && apk add \
    git

# Restoring nuget dependencies
COPY Web/Web.csproj Web/Web.csproj
RUN dotnet restore Web/Web.csproj

COPY . .

RUN dotnet publish -c Release -o out Web/Web.csproj

#############################

# Production image

FROM mcr.microsoft.com/dotnet/aspnet:${DOTNET_RUNTIME_VERSION} AS server-runtime

ENV DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=false
ENV HTTP_PORTS=80

WORKDIR /app

RUN apk update && apk add \
	icu-libs \
	tzdata

COPY --from=builder /app/out ./

EXPOSE 80

ENTRYPOINT ["dotnet", "Web.dll"]

#############################
