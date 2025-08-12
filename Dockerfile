FROM registry.access.redhat.com/ubi9/php-82:latest

# Instalar extensões PHP necessárias para o GLPI
USER 0
RUN dnf install -y php-mysqlnd php-gd php-ldap php-opcache php-zip php-mbstring php-json php-curl php-xml php-intl php-bcmath && \
    dnf clean all

# Copiar os arquivos do GLPI para o diretório esperado pelo S2I
ADD glpi /tmp/src
RUN chown -R 1001:0 /tmp/src

# Configurar permissões específicas para pastas do GLPI
RUN chmod -R 755 /tmp/src && \
    chmod -R 775 /tmp/src/files /tmp/src/config

# Executar o script S2I assemble
RUN /usr/libexec/s2i/assemble

# Configurar usuário não-root
USER 1001

# Definir o comando padrão para rodar a aplicação
CMD /usr/libexec/s2i/run
