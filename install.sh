# Define
SRC="/data/src"
PREFIX="/usr/local"
NGINX_USER="nginx"
NGINX_GROUP="nginx"
NGINX_HACK="/data/logs/hack"

# Check Source Dir
[ -d "$SRC" ]||mkdir -p $SRC

# Check LuaJIT TarBall
[ -x "$SRC/LuaJIT-2.0.0.tar.gz" ]||wget http://luajit.org/download/LuaJIT-2.0.0.tar.gz -P $SRC/
# Install LiaJIT
tar -zxvf $SRC/LuaJIT-2.0.0.tar.gz -C $SRC/
cd $SRC/LuaJIT-2.0.0
make
make install PREFIX=$PREFIX/lj2
ln -s $PREFIX/lj2/lib/libluajit-5.1.so.2 /lib64/

# Install 
[ -f "$SRC/v0.2.17rc2.zip" ]||wget https://github.com/simpl/ngx_devel_kit/archive/v0.2.17rc2.zip -P $SRC/
unzip $SRC/v0.2.17rc2.zip -d $SRC/

[ -f "$SRC/v0.7.4.zip" ]||wget https://github.com/chaoslawful/lua-nginx-module/archive/v0.7.4.zip -P $SRC/
unzip $SRC/v0.7.4.zip -d $SRC/

[ -f "$SRC/pcre-8.10.tar.gz" ]||wget http://blog.s135.com/soft/linux/nginx_php/pcre/pcre-8.10.tar.gz -P $SRC/
tar -zxvf $SRC/pcre-8.10.tar.gz -d $SRC/
cd $SRC/pcre-8.10/
./configure
make && make install

[ -f "$SRC/nginx-1.2.4.tar.gz" ]||wget http://nginx.org/download/nginx-1.2.4.tar.gz -P $SRC/
tar -xzvf $SRC/nginx-1.2.4.tar.gz -d $SRC/
cd $SRC/nginx-1.2.4/
export LUAJIT_LIB=/usr/local/lj2/lib/
export LUAJIT_INC=/usr/local/lj2/include/luajit-2.0/
./configure \
--user=$NGINX_USER \
--group=$NGINX_GROUP \
--prefix=$PREFIX/nginx/ \
--with-http_stub_status_module \
--with-http_sub_module \
--with-http_gzip_static_module \
--without-mail_pop3_module \
--without-mail_imap_module \
--without-mail_smtp_module  \
--add-module=$SRC/ngx_devel_kit-0.2.17rc2/ \
--add-module=$SRC/lua-nginx-module-0.7.4/
make -j8
make install 

cd $PREFIX/nginx/conf/
wget https://github.com/loveshell/ngx_lua_waf/archive/master.zip --no-check-certificate
unzip master.zip
mv ngx_lua_waf-master/* $PREFIX/nginx/conf/
[ -d "" ]||mkdir -p $NGINX_HACK
chmod -R 775 $NGINX_HACK

rm -rf ngx_lua_waf-master
rm -rf $SRC/*
