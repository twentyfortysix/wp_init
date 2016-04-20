WP-CLI script that interactively install Wordpress,
Disable some unwanted stuff, install bucnh of plugins and resert the Wo to a normal working state.

Make it more CMS like not blog like auto-disable all comments. Install CMS usefull plugins such as Timber, ACF, posts 2 post, wp-pagnavi, simple image sizes, w3tc, wordfence, etc.

Requirments:
- SSH
- PHP 5.6 (wp-cli is not compatible with PHP 7 just yet)
- WP-CLI
- (MySQL Database ready)

In terminal run:
```
wget https://raw.githubusercontent.com/twentyfortysix/wp_init/master/wp_init.sh
chmod +x wp_init.sh
./wp_init.sh
```
respond to questions:
 - Site Name:
 - Site url (example.com/wp):
 - Admin name:
 - Admin email:
 - Database User:
 - Database Name:
 - Database Password:
 - Database Prefix:
 - Discurage searchengines (0 - yes, 1 - no):
 - Add Pages:
 - DB location: Localhost - 1 or Mac os environment - 2
 - Run Install? (y/n)

(If you wanna know what plugins are installed on the way, check the script)

Tired of answering questions one by one?
(send them straight each answer is wrapped by \n)
```
echo -e "site\nlocalhost\n2046\n2046@2046.cz\ndbuser\ndb\npass\nwp_\n0\nContact\n1\ny" | ./wp_init.sh
```

(Among others, the script deletes WP themes and loads the <a href="https://github.com/twentyfortysix/almond-milk">Almond milk</a> Timber template starter)


Done. I mean - Lets go work now.
