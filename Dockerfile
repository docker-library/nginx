FROM debian:jessie

ADD . /usr/src/nginx
WORKDIR /usr/src/nginx

# All our build dependencies, in alphabetical order (to ease maintenance)
RUN nginxRunDeps="fontconfig-config fonts-dejavu-core geoip-database init-system-helpers libarchive-extract-perl libexpat1 libfontconfig1 libfreetype6 libgcrypt11 libgd3 libgdbm3 libgeoip1 libgpg-error0 libjbig0 libjpeg8 liblog-message-perl liblog-message-simple-perl libmodule-pluggable-perl libpng12-0 libpod-latex-perl libssl1.0.0 libterm-ui-perl libtext-soundex-perl libtiff5 libvpx1 libx11-6 libx11-data libxau6 libxcb1 libxdmcp6 libxml2 libxpm4 libxslt1.1 perl perl-modules rename sgml-base ucf xml-core"; \
		nginxBuildDeps="gcc libc6-dev libgd2-dev libgeoip-dev libpcre3-dev libperl-dev libssl-dev libxslt1-dev make perl"; \
		nginxConfig="--user=www-data --group=www-data --prefix=/usr/local/nginx --conf-path=/etc/nginx.conf --http-log-path=/proc/self/fd/1 --error-log-path=/proc/self/fd/2 --with-http_addition_module --with-http_auth_request_module --with-http_dav_module --with-http_geoip_module --with-http_gzip_static_module --with-http_image_filter_module --with-http_perl_module --with-http_realip_module --with-http_spdy_module --with-http_ssl_module --with-http_stub_status_module --with-http_sub_module --with-http_xslt_module --with-ipv6 --with-mail --with-mail_ssl_module --with-pcre-jit"; \
		apt-get update \
		&& DEBIAN_FRONTEND=noninteractive apt-get install -y $nginxRunDeps $nginxBuildDeps \
		&& ./configure $nginxConfig \
		&& make -j"$(nproc)" \
		&& make install \
		&& ln -vs ../nginx/sbin/nginx /usr/local/sbin/ \
		&& chown -R www-data:www-data /usr/local/nginx ; \
		libgd2DevDeps="libc-dev-bin libc6-dev libexpat1-dev libfontconfig1-dev libfreetype6-dev libgd-dev libice-dev libjbig-dev libjpeg8-dev liblzma-dev libpng12-dev libpthread-stubs0-dev libsm-dev libtiff5-dev libvpx-dev libx11-dev libxau-dev libxcb1-dev libxdmcp-dev libxpm-dev libxt-dev linux-libc-dev manpages-dev x11proto-core-dev x11proto-input-dev x11proto-kb-dev xtrans-dev zlib1g-dev"; \
		libgeoipDevDeps="libgeoip-dev"; \
		libpcre3DevDeps="libc-dev-bin libc6-dev libpcre3-dev linux-libc-dev manpages-dev"; \
		libperlDevDeps="libc-dev-bin libc6-dev libperl-dev linux-libc-dev manpages-dev"; \
		libsslDevDeps="libc-dev-bin libc6-dev libssl-dev linux-libc-dev manpages-dev zlib1g-dev"; \
		libxslt1DevDeps="libxml2-dev libxslt1-dev"; \
		buildDeps="gcc libc6-dev make"; \
		apt-get purge -y $libgd2DevDeps $libgeoipDevDeps $libpcre3DevDeps $libperlDevDeps $libsslDevDeps $libxslt1DevDeps $buildDeps \
		&& apt-get autoremove -y \
		&& rm -rf /usr/src/nginx

RUN { \
		echo; \
		echo '# stay in the foreground so Docker has a process to track'; \
		echo 'daemon off;'; \
	} >> /etc/nginx.conf

WORKDIR /usr/local/nginx/html

EXPOSE 80
CMD ["nginx"]
