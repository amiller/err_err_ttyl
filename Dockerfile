FROM ubuntu:22.04

RUN apt-get update #1
RUN apt-get install -y python3-pip
RUN apt-get install -y curl

RUN curl -LO http://packages.linuxmint.com/pool/upstream/c/chromium/chromium_130.0.6723.116~linuxmint1%2Bvirginia_amd64.deb
RUN apt-get install -y ./chromium_130.0.6723.116~linuxmint1%2Bvirginia_amd64.deb
RUN apt-get install -y libasound2

RUN curl https://sh.rustup.rs -sSf | bash -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

RUN apt-get install -y pkg-config libssl-dev
RUN apt-get install -y jq logrotate

RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash

# Python dependencies
WORKDIR /workdir
ENV PYTHONUNBUFFERED=1

COPY requirements.txt ./
RUN pip install -r requirements.txt

# Install node
RUN curl -sL https://deb.nodesource.com/setup_23.x -o nodesource_setup.sh
RUN bash nodesource_setup.sh
RUN apt-get -y install nodejs
RUN npm install -g pnpm@9.4.0

# Build just the dependencies (shorcut)
RUN mkdir client
COPY client/Cargo.lock client/Cargo.toml client/
WORKDIR client
RUN mkdir src && echo "fn main() {}" > src/main.rs
RUN cargo build --release
RUN rm -r src
WORKDIR /workdir

# Copy the real files
COPY client/ ./client/
WORKDIR client/
RUN cargo build --release
WORKDIR /workdir


# Set the working directory
WORKDIR /app

# Add configuration files and install dependencies
ADD nousflash-agents/pnpm-workspace.yaml /app/pnpm-workspace.yaml
ADD nousflash-agents/package.json /app/package.json
ADD nousflash-agents/.npmrc /app/.npmrc
ADD nousflash-agents/tsconfig.json /app/tsconfig.json
ADD nousflash-agents/pnpm-lock.yaml /app/pnpm-lock.yaml
RUN pnpm i

RUN apt-get install -y git

# Add the rest of the application code
RUN npm install express
ADD nousflash-agents/packages /app/packages
RUN pnpm i

# Add the environment variables
ADD nousflash-agents/scripts /app/scripts
#ADD nousflash-agents/characters /app/characters
RUN touch /app/.env

WORKDIR /workdir
COPY run.sh ./
COPY refresh.sh ./
COPY run.py ./
COPY redacter.py ./
COPY logrotate-post.sh ./
COPY logrotate.conf ./
RUN chmod 0644 logrotate.conf

COPY scripts/ ./scripts/

RUN mkdir -p /data

ENTRYPOINT [ ]
# CMD [ "bash", "run.sh" ]
CMD [ "python3", "run.py" ]
