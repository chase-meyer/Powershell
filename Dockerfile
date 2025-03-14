FROM mcr.microsoft.com/powershell

# Install Git
RUN apt-get update && apt-get install -y git && apt-get clean

# Set the default shell to PowerShell
CMD ["pwsh"]