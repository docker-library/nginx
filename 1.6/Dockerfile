FROM debian:jessie
# note: we use jessie instead of wheezy because our deps are easier to get here

# runtime dependencies
# (packages are listed alphabetically to ease maintenence)
RUN apt-get update && apt-get install -y --no-install-recommends \
		fontconfig-config \
		fonts-dejavu-core \
		geoip-database \
		init-system-helpers \
		libarchive-extract-perl \
		libexpat1 \
		libfontconfig1 \
		libfreetype6 \
		libgcrypt11 \
		libgd3 \
		libgdbm3 \
		libgeoip1 \
		libgpg-error0 \
		libjbig0 \
		libjpeg8 \
		liblog-message-perl \
		liblog-message-simple-perl \
		libmodule-pluggable-perl \
		libpng12-0 \
		libpod-latex-perl \
		libssl1.0.0 \
		libterm-ui-perl \
		libtext-soundex-perl \
		libtiff5 \
		libvpx1 \
		libx11-6 \
		libx11-data \
		libxau6 \
		libxcb1 \
		libxdmcp6 \
		libxml2 \
		libxpm4 \
		libxslt1.1 \
		perl \
		perl-modules \
		rename \
		sgml-base \
		ucf \
		xml-core \
	&& rm -rf /var/lib/apt/lists/*

# see http://nginx.org/en/pgp_keys.html
RUN gpg --keyserver pgp.mit.edu --recv-key \
	A09CD539B8BB8CBE96E82BDFABD4D3B3F5806B4D \
	4C2C85E705DC730833990C38A9376139A524C53E \
	B0F4253373F8F6F510D42178520A9993A1C052F8 \
	65506C02EFC250F1B7A3D694ECF0E90B2C172083 \
	7338973069ED3F443F4D37DFA64FD5B17ADB39A8 \
	6E067260B83DCF2CA93C566F518509686C7E5E82 \
	573BFD6B3D8FBC641079A6ABABF5BD827BD9BF62

ENV NGINX_VERSION 1.6.1

# All our runtime and build dependencies, in alphabetical order (to ease maintenance)
RUN buildDeps=" \
		ca-certificates \
		curl \
		gcc \
		libc-dev-bin \
		libc6-dev \
		libexpat1-dev \
		libfontconfig1-dev \
		libfreetype6-dev \
		libgd-dev \
		libgd2-dev \
		libgeoip-dev \
		libice-dev \
		libjbig-dev \
		libjpeg8-dev \
		liblzma-dev \
		libpcre3-dev \
		libperl-dev \
		libpng12-dev \
		libpthread-stubs0-dev \
		libsm-dev \
		libssl-dev \
		libssl-dev \
		libtiff5-dev \
		libvpx-dev \
		libx11-dev \
		libxau-dev \
		libxcb1-dev \
		libxdmcp-dev \
		libxml2-dev \
		libxpm-dev \
		libxslt1-dev \
		libxt-dev \
		linux-libc-dev \
		make \
		manpages-dev \
		x11proto-core-dev \
		x11proto-input-dev \
		x11proto-kb-dev \
		xtrans-dev \
		zlib1g-dev \
	"; \
	apt-get update && apt-get install -y --no-install-recommends $buildDeps && rm -rf /var/lib/apt/lists/* \
	&& curl -SL "http://nginx.org/download/nginx-$NGINX_VERSION.tar.gz" -o nginx.tar.gz \
	&& curl -SL "http://nginx.org/download/nginx-$NGINX_VERSION.tar.gz.asc" -o nginx.tar.gz.asc \
	&& gpg --verify nginx.tar.gz.asc \
	&& mkdir -p /usr/src/nginx \
	&& tar -xvf nginx.tar.gz -C /usr/src/nginx --strip-components=1 \
	&& rm nginx.tar.gz* \
	&& cd /usr/src/nginx \
	&& ./configure \
		--user=www-data \
		--group=www-data \
		--prefix=/usr/local/nginx \
		--conf-path=/app/conf/nginx.conf \
		--http-log-path=/proc/self/fd/1 \
		--error-log-path=/proc/self/fd/2 \
		--with-http_addition_module \
		--with-http_auth_request_module \
		--with-http_dav_module \
		--with-http_geoip_module \
		--with-http_gzip_static_module \
		--with-http_image_filter_module \
		--with-http_perl_module \
		--with-http_realip_module \
		--with-http_spdy_module \
		--with-http_ssl_module \
		--with-http_stub_status_module \
		--with-http_sub_module \
		--with-http_xslt_module \
		--with-ipv6 \
		--with-mail \
		--with-mail_ssl_module \
		--with-pcre-jit \
	&& make -j"$(nproc)" \
	&& make install \
	&& cd / \
	&& rm -r /usr/src/nginx \
	&& apt-get purge -y --auto-remove $buildDeps
# Modify nginx.conf file for Docker use	
RUN mkdir -p /app \
	&& mkdir -p /app/logs \
	&& mkdir -p /usr/local/nginx/conf.d \
	&& chown -R www-data:www-data /usr/local/nginx \
	&& chown -R www-data:www-data /app \
	&& { \
		echo; \
		echo '# stay in the foreground so Docker has a process to track'; \
		echo 'daemon off;'; \
	} >> /app/conf/nginx.conf \
	&& sed -i '0,/server {/s/server {/include \/nginx\/conf.d\/*.conf;\n    server {/' /app/conf/nginx.conf 

# Add nginx to PATH (both immediately and as part of any future shell attachments)
ENV PATH /usr/local/nginx/sbin:$PATH 
RUN { \
		echo; \
		echo '# Adding nginx to PATH'; \
		echo 'export PATH=/usr/local/nginx/sbin:$PATH'; \
	} >> /etc/bash.bashrc

# TODO USER www-data

# Create symlinks so that volume shares can use compact and consistent pattern
RUN ln -s /usr/local/nginx/conf.d /app/conf.d \
	&& ln -s /usr/local/nginx/sockets /app/sockets \
	&& ln -s /usr/local/nginx/logs /app/logs \
	&& ln -s /usr/local/nginx/html /app/html
# Provide host ability to add server directives to configuration
VOLUME ["/app/conf.d"]
# Provide host ability to take over all aspects of configuration
# >	Note: when a user overrides the default config directory is it typical that they only really only want to manipulate
# 		  the `nginx.conf` file but currently they will need to provide all default configuration files
VOLUME ["/app/conf"]
# The "root" directory for all content
VOLUME ["/app/html"]
# The directory for all Unix socket files, allowing host to pass socket files as a mutex point (rather than just TCP port)
VOLUME ["/app/sockets"]
# Allow host to attach to log file directory
VOLUME ["/app/logs"]

EXPOSE 80
ENTRYPOINT ["nginx"]
