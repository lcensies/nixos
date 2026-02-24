FROM alpine/openclaw:latest

USER root

# Install clawhub CLI
RUN npm install -g clawhub

# Install gogcli (steipete/gogcli) Linux amd64 binary as `gog`
RUN curl -fsSL https://github.com/steipete/gogcli/releases/download/v0.11.0/gogcli_0.11.0_linux_amd64.tar.gz \
    | tar -xz -C /usr/local/bin gog \
    && chmod +x /usr/local/bin/gog

# Pre-install skills into /opt/openclaw-skills so they survive the .openclaw volume mount.
# compose.yml mounts this as an extra read-only bind over workspace/skills.
RUN mkdir -p /opt/openclaw-skills \
    && clawhub install gog-calendar \
        --workdir /opt/openclaw-skills-tmp \
        --dir skills \
        --no-input --force \
    && mv /opt/openclaw-skills-tmp/skills/* /opt/openclaw-skills/ \
    && rm -rf /opt/openclaw-skills-tmp \
    && clawhub install soul-md \
        --workdir /opt/openclaw-skills-tmp \
        --dir skills \
        --no-input --force \
    && mv /opt/openclaw-skills-tmp/skills/* /opt/openclaw-skills/ \
    && rm -rf /opt/openclaw-skills-tmp

USER node
