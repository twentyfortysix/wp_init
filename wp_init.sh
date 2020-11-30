!/bin/bash -e
clear

echo "================================================================="
echo "Let's go"
echo "================================================================="

#accept the name of our website
echo "Site Name: "
read -e sitename

# accept user input for site url
echo "Site url (example.com/wp): "
read -e wpurl

# accept user input for user name
# echo "Admin name: "
# read -e wpuser
echo "admin name"
wpuser="2046"

echo "Admin email 2046@2046.cz"
wpemail="2046@2046.cz"

# accept user input for the databse name
echo "Database User: "
read -e dbuser

# accept user input for the databse name
echo "Database Name: "
read -e dbname

# accept user input for the databse name
echo "Database Password: "
read -s dbpass

# accept user input for the databse name
echo "Database Prefix: "
read -e dbprefix

# accept a comma separated list of pages
echo "Discurage searchengines (0 - yes, 1 - no): "
read -e discourage

# create pages right away
#echo "Add Pages: "
#read -e allpages

# DB location.. on macs the localhost has to be 127.0.0.1
echo "DB location: Localhost - 1 or Mac os environment - 2"
read -e environment
if [ $environment == 1 ]
then
	dhost="localhost"
else
	dhost="127.0.0.1"
fi

# add a simple yes/no confirmation before we proceed
echo "Run Install? (y/n)"
read -e run


# if the user didn't say no, then go ahead an install
if [ "$run" == n ] ; then
exit
else

# download the WordPress core files
wp core download

# create the wp-config file with our standard setup
wp core config --dbname=$dbname --dbuser=$dbuser --dbpass=$dbpass --locale=en_US --dbprefix=$dbprefix --dbhost=$dhost --extra-php <<PHP
define( 'WP_DEBUG', true );
define( 'DISALLOW_FILE_EDIT', true );
PHP

# generate random 12 character password
password=$(LC_CTYPE=C tr -dc A-Za-z0-9_\!\@\#\$\%\^\&\*\(\)-+= < /dev/urandom | head -c 12)

# create database
# wp db create

#install WordPress
wp core install  --url="http://$wpurl/" --title="$sitename" --admin_user="$wpuser" --admin_password="$password" --admin_email="$wpemail"

# discourage search engines
wp option update blog_public $discourage

# show only 6 posts on an archive page
#wp option update posts_per_page 10

# delete sample page, and create homepage
wp post delete $(wp post list --post_type=page --posts_per_page=10 --post_status=any --field=ID --format=ids)
wp post create --post_type=page --post_title=Home --post_status=publish --post_author=$(wp user get $wpuser --field=ID --format=ids)

# set homepage as front page
wp option update show_on_front 'page'

# set homepage to be the new page
wp option update page_on_front $(wp post list --post_type=page --post_status=publish --posts_per_page=1 --pagename=home --field=ID --format=ids)

# create all of the pages
export IFS=","
for page in $allpages; do
	wp post create --post_type=page --post_status=publish --post_author=$(wp user get $wpuser --field=ID --format=ids) --post_title="$(echo $page | sed -e 's/^ *//' -e 's/ *$//')"
done

# set pretty urls
wp option update permalink_structure '/%post_id%/%postname%'
#wp rewrite structure '/%post_id%/%postname%/' --hard
wp rewrite flush --hard

# delete all comments.
wp comment delete $(wp comment list)

#disable all comments
wp post list --format=ids | xargs wp post update --comment_status=closed

#disable pings
wp post list --format=ids | xargs wp post update --ping_status=closed

#disallow pingback
wp option update default_pingback_flag 0

#anyone can't post comment
wp option update comments_notify 0

#ping back status
wp option update  default_ping_status closed

#trun off comments
wp option update page_comments 0
wp option update default_comment_status closed
wp option update comment_moderation 1

# delete akismet and hello dolly
wp plugin delete akismet
wp plugin delete hello

#delete all default themes
wp theme delete --all --force 

#download the Amond milk first and activate
cd wp-content/themes/
git clone https://github.com/twentyfortysix/almond-milk.git
cd ../../


# install plugins
wp plugin install timber-library --activate
wp plugin install advanced-access-manager
wp plugin install post-type-switcher
wp plugin install codepress-admin-columns --activate
wp plugin install adminimize --activate
# wp plugin install advanced-custom-fields --activate
#wp plugin install wp-smushit --activate
wp plugin install disable-xml-rpc --activate
#wp plugin install posts-to-posts --activate
#wp plugin install simple-image-sizes --activate
wp plugin install clean-image-filenames --activate
wp plugin install simple-custom-post-order --activate
wp plugin install paste-as-plain-text --activate
wp plugin install imsanity --activate
wp plugin install classic-editor --activate
#just download plugins
wp plugin install wp-migrate-db
wp plugin install wordfence
wp plugin install w3-total-cache
wp plugin install theme-test-drive
wp plugin install debug-bar 
wp plugin install debug-bar-timber


wp theme activate almond-milk

#delete themes
wp theme delete twentyfifteen
wp theme delete twentysixteen
wp theme delete twentyfourteen

# clear

# create a navigation bar
wp menu create "top_menu_"

# add pages to navigation
export IFS=" "
for pageid in $(wp post list --order="ASC" --orderby="date" --post_type=page --post_status=publish --posts_per_page=-1 --field=ID --format=ids); do
	wp menu item add-post main-navigation $pageid
done

# assign navigaiton to primary location
wp menu location assign main-navigation primary


# clear

echo "================================================================="
echo "Installation is complete. Your username/password is listed below."
echo ""
echo "Username: $wpuser"
echo "Password: $password"
echo "Go to: $wpurl/wp-admin"
echo ""
echo "================================================================="


fi
