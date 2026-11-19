
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build

WORKDIR /src

COPY Fluxo_GS_2026_2TDSPR.csproj ./
RUN dotnet restore Fluxo_GS_2026_2TDSPR.csproj

COPY . .
RUN dotnet publish Fluxo_GS_2026_2TDSPR.csproj -c Release -o /app/publish --no-restore

FROM mcr.microsoft.com/dotnet/aspnet:8.0

WORKDIR /app

COPY --from=build /app/publish .

ENV ASPNETCORE_URLS=http://+:8080

EXPOSE 8080

USER $APP_UID

ENTRYPOINT ["dotnet", "Fluxo_GS_2026_2TDSPR.dll"]
