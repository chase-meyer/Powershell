FROM mcr.microsoft.com/powershell

# Install Git
RUN apt-get update && apt-get install -y git && apt-get clean

# Create a non-root user and set permissions
RUN useradd -ms /bin/bash vscode \
    && mkdir -p /workspace \
    && chown -R vscode:vscode /workspace

# Set the default user to the non-root user
USER vscode

# Set the default shell to PowerShell
CMD ["pwsh"]