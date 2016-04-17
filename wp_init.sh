!/bin/bash -e
clear

echo "================================================================="
echo "Let's go"
echo "================================================================="

# accept the name of our website
echo "Site Name: "
read -e sitename

# accept user input for site url
echo "Site url: "
read -e wpurl

# accept user input for user name
echo "User name: "
read -e wpuser

# accept user input for the databse name
echo "Database User: "
read -e dbuser

# accept user input for the databse name
echo "Database Name: "
read -e dbname

# accept user input for the databse name
echo "Database Password: "
read -e dbpass

# accept a comma separated list of pages
echo "Discurage searchengines (0 - yes, 1 - no): "
read -e discourage

# 
echo "Add Pages: "
read -e allpages

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
wp core config --dbname=$dbname --dbuser=$dbuser --dbpass=$dbpass --extra-php <<PHP
define( 'WP_DEBUG', true );
define( 'DISALLOW_FILE_EDIT', true );
PHP

# parse the current directory name
currentdirectory=${PWD##*/}

# generate random 12 character password
password=$(LC_CTYPE=C tr -dc A-Za-z0-9_\!\@\#\$\%\^\&\*\(\)-+= < /dev/urandom | head -c 12)

# copy password to clipboard
echo $password | pbcopy

# create database, and install WordPress
wp db create
wp core install --url="http://$wpurl/$currentdirectory" --title="$sitename" --admin_user="$wpuser" --admin_password="$password" --admin_email="user@example.org"

# discourage search engines
wp option update blog_public $discourage

# show only 6 posts on an archive page
#wp option update posts_per_page 10

# delete sample page, and create homepage
wp post delete $(wp post list --post_type=page --posts_per_page=1 --post_status=publish --pagename="sample-page" --field=ID --format=ids)
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
wp rewrite structure '/%post_id%/%postname%/' --hard
wp rewrite flush --hard

# delete all comments.
wp comment delete $(wp comment list)

#disable all comments
wp post list --format=ids | xargs wp post update --comment_status=closed

#disable pings
wp post list --format=ids | xargs wp post update --ping_status=closed

# delete akismet and hello dolly
wp plugin delete akismet
wp plugin delete hello


# install plugins
wp plugin install timber-library --activate
wp plugin install codepress-admin-columns --activate
wp plugin install adminimize --activate
wp plugin install advanced-custom-fields --activate
wp plugin install disable-wordpress-updates --activate
wp plugin install disable-xml-rpc --activate
wp plugin install posts-to-posts --activate
wp plugin install simple-image-sizes --activate
wp plugin install simple-page-ordering --activate
wp plugin install wp-pagenavi --activate
#just download plugins
wp plugin install wp-migrate-db
wp plugin install wordfence
wp plugin install w3-total-cache
wp plugin install theme-test-drive

# install the company starter theme
#wp theme install ~/Documents/lt-theme.zip --activate

clear

# create a navigation bar
wp menu create "Top menu"

# add pages to navigation
export IFS=" "
for pageid in $(wp post list --order="ASC" --orderby="date" --post_type=page --post_status=publish --posts_per_page=-1 --field=ID --format=ids); do
	wp menu item add-post main-navigation $pageid
done

# assign navigaiton to primary location
wp menu location assign main-navigation primary

clear

echo "================================================================="
echo "Installation is complete. Your username/password is listed below."
echo ""
echo "Username: $wpuser"
echo "Password: $password"
echo ""
echo "================================================================="

# Open the new website with Google Chrome
#/usr/bin/open -a "/Applications/Google Chrome.app" "http://localhost/$currentdirectory/wp-login.php"

# Open the project in TextMate
#/Applications/TextMate.app/Contents/Resources/mate /Applications/MAMP/htdocs/$currentdirectory/wp-content/themes/lt-theme

fi