# pay.b4u

#### Important! All accounts - fake.

## Installing payment proxy

This is the installation documentation for b4u.

### Requirements

Unix, Linux, Mac, Mac Server, Windows systems as long as perl is available.
Perl >= 5.20
Nginx (perlembed)
Mysql >= 5.5

### Dependencies installation

apt-get

<pre>
add-apt-repository 'deb [arch=amd64,i386,ppc64el] http://mirrors.coreix.net/mariadb/repo/10.1/ubuntu trusty main'
apt-get install libwww-curl-perl software-properties-common libconfig-inifiles-perl libyaml-syck-perl gcc atop libwww-curl-perl libmail-checkuser-perl libnumber-phone-perl libnet-smtp-ssl-perl libnet-ping-external-perl libnet-dns-perl libio-handle-util-perl libemail-valid-perl nginx-extras mariadb-server-10.1
</pre>

cpan

<pre>
cpan install URI YAML Crypt::Digest::SHA512 JSON::Parse Log::Log4perl JSON::Syck::Dump Data::Table
</pre>

### configure

<pre>
tar -xzf perl.tar.gz 
cp perl/perl.conf /etc/nginx/conf.d/
cp perl/ /etc/nginx/
chown -R www-data:www-data /etc/nginx/perl && chmod -R 775 /etc/nginx/perl
/etc/init.d/nginx restart
</pre>

### cfg.ini

This configuration file contain settings specific to an application.

#### cfg.ini location.

<pre>
ls -la /etc/nginx/perl/cfg.ini
</pre>

#### cfg.ini contents.

<pre>
cat /etc/nginx/perl/cfg.ini
</pre>

#### cfg.ini description.

<pre>
##### Merchant code

[MPOLO]
MerchantCode=ACOS
Key=978y8ygbyv8
url=http://tp.moneypolo.com/process.php

##### MerchantCOde for transite account

[MPOLOA]
MerchantCode=ACOS
Key=ijh9767t899bh809vy
url=http://tp.mpolo.com/api.openaccount.php

##### Default settings

[DEF]
SPTestMode=1			# активировать тестовый режим
CountryCode=GB			# страна по умолчанию (если не указна клиентом в форме)
SPCurrency=EUR			# валюта по умолчанию (если не указна клиентом в форме)
PostalCode=zip			# аналогично zip
ClientIP=55.28.27.66	# ip клиента, я поставил ip сервера
SPDetails=order										# детализация
SPPaymentMethod=CC									# тип оплаты (в данном случае, переход сразу на форму ввода СС)
SPSuccessURL=http://bla.com/paments/mpr-url.html 	# тут понятно 
SPFailURL=http://bla.com/payents/mpc-url.html 		# тут, тоже понятно

##### DB MySQL

[DB4U]
h=127.0.0.1
n=brand
u=de
p=Tf

##### Logger (ALL, DEBUG, ERROR, NONE)

[LOG]
file=/var/log/perl.log 	# файл
level=DEBUG 					# детализация
</pre>

### Example.

#### Merchant key VANYAB2.

#### [MPOLO] [MPOLOA]:

<pre>
[MPOLO]
MerchantCode=VANYAB2
Key=sdfgsepirtgjpdsigjdsigjsiergj4564!!!@@##$$%%$$#@!$
url=https://pt.mpolo.com/process.php

[MPOLOA]
MerchantCode=VANYAB2
Key=sdfgsepirtgjpdsigjdsigjsiergj45645657*&^*^
url=https://pt.mpolo.com/api.openaccount.php
</pre>

### After making changes.

<pre>
chown -R www-data:www-data /etc/nginx/perl && chmod -R 775 /etc/nginx/perl
/etc/init.d/nginx restart
</pre>

## Debuging 

<pre>
tail -n100 /var/log/nginx/error.log
</pre>
