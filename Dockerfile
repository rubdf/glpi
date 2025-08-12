FROM ubi9/php-82

USER 0

# Copiar arquivos do contexto de build para /tmp/src/
COPY . /tmp/src/

# Verificar conteúdo de /tmp/src/ para debug
RUN ls -la /tmp/src/

USER 1001

# Executar o script de montagem
RUN /usr/libexec/s2i/assemble
