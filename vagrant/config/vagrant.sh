## Composer - composer parallel install plugin (Composer is faster when checking dependencies)
composer global require hirak/prestissimo

## Composer - unlimited PHP memory
#echo -e "\n# Composer - unlimited PHP memory
#if [ -x /usr/bin/composer ]; then
#  alias composer='php -d memory_limit=-1 /usr/bin/composer \$1'
#fi" >> /home/vagrant/.bashrc

#if [ ! alias composer 2>/dev/null ]; then
#fi
