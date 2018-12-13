# escape=`
FROM microsoft/dotnet-framework:sdk AS builder
#WORKDIR /Console.Worker.Role
COPY . .
#RUN msbuild Legacy.CloudService.sln /p:OutputPath=/out
RUN msbuild Console.Worker.Role/Console.Worker.Role.csproj /p:OutputPath=console-out

# app image
FROM microsoft/dotnet-framework:4.6.2-runtime-windowsservercore-ltsc2016
ADD Console.Worker.Role/setup /setup
# https://stackoverflow.com/questions/50347388/docker-for-windows-ms-access-database-jet-oledb-4-0
RUN C:\setup\Jet40SP8_9xNT.exe /Q
WORKDIR C:\legacy-cloudservice
COPY --from=builder console-out .
CMD Console.Worker.Role.exe