# Dockerfile — GLPI em UBI9 PHP 8.2 (Apache + PHP-FPM)
FROM registry.access.redhat.com/ubi9/php-82@sha256:65f8b34ce48219be1178ce74a19d1338c96a27417bddbe3ca5d5a8b99208b0f3 
 
# (Opcional) trave a versão do GLPI aqui
ENV GLPI_VER=10.0.18
# Docroot da imagem S2I (Apache) — deixe assim para compatibilidade
ENV HTTPD_DOCUMENT_ROOT=/opt/app-root/src
 
# Precisamos de root só para instalar utilitários e baixar o GLPI
USER 0
 
# Utilitários básicos + cliente MariaDB (nome nos repositórios RHEL)
# microdnf para imagens minimal; dnf para standard (fallback)
RUN (microdnf -y install wget tar gzip unzip which findutils mariadb-connector-c \
     || dnf -y install wget tar gzip unzip which findutils mariadb-connector-c) \
&& (microdnf clean all || dnf clean all)
 
# Baixa e instala o GLPI direto no docroot S2I
WORKDIR /opt/app-root/src
RUN curl -fsSL -o glpi.tgz https://github.com/glpi-project/glpi/releases/download/${GLPI_VER}/glpi-${GLPI_VER}.tgz \
&& tar -xzf glpi.tgz --strip-components=1 \
&& rm -f glpi.tgz
 
# Garante diretórios exigidos
RUN mkdir -p config files marketplace
 
# Permissões para rodar sem root (padrão OpenShift/S2I: UID arbitrário no grupo 0)
RUN chown -R 1001:0 /opt/app-root/src \
&& chmod -R g+rwX /opt/app-root/src
 
# Guarda cópia "orig" para popular um volume vazio na 1ª execução
RUN mkdir -p /opt/app-root/glpi-orig \
&& cp -a /opt/app-root/src/. /opt/app-root/glpi-orig/. \
&& chown -R 1001:0 /opt/app-root/glpi-orig \
&& chmod -R g+rwX /opt/app-root/glpi-orig
 
# Entrypoint que semeia o volume/pasta montada e depois inicia o serviço padrão S2I
COPY entrypoint.sh /usr/local/bin/entrypoint-glpi.sh
RUN chmod +x /usr/local/bin/entrypoint-glpi.sh
 
# Volta para usuário sem privilégios
USER 1001
 
# A imagem S2I do PHP/Apache expõe 8080
EXPOSE 8080
 
# Mantém o run script da imagem como CMD; usamos o nosso ENTRYPOINT para semear
ENTRYPOINT ["/usr/local/bin/entrypoint-glpi.sh"]
CMD ["/usr/libexec/s2i/run"]

