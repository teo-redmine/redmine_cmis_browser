# CMIS Browser plugin for Redmine

## Description

This [Redmine](http://www.redmine.org) plugin is a CMIS document browser for Redmine; It is aimed to replace current Redmine's Documents module.


## Requirements

CMIS API must implements CMIS 1.1 standard, we need Alfresco 5.0 or higher and CMIS Attachments plugin installed.


## Installation

1. Make sure Redmine is installed and cd into it's root directory

2. `git clone` this plugin into redmine/plugins/redmine_cmis_browser

3. Make sure that files and folders permissions are correct

4. Install Xapian:

On Debian use:

```sudo apt-get install xapian-omega libxapian-dev xpdf xpdf-utils \
 antiword unzip catdoc libwpd-tools libwps-tools gzip unrtf catdvi \
 djview djview3 uuid uuid-dev xz-utils```

On Ubuntu use:

```sudo apt-get install xapian-omega libxapian-dev xpdf xpdf-utils antiword \
 unzip catdoc libwpd-tools libwps-tools gzip unrtf catdvi djview djview3 \
 uuid uuid-dev xz-utils```

On CentOS user:
```sudo yum install xapian-omega libxapian-dev xpdf xpdf-utils antiword \
 unzip catdoc libwpd-tools libwps-tools gzip unrtf catdvi djview djview3 \
 uuid uuid-dev xz```

5. `bundle install --without development test` for installing this plugin dependencies (if you already did it, doing a `bundle install` again whould do no harm)

6. `rm -Rf plugins/redmine_cmis_browser/.git`

7. Restart mongrel/upload to production/whatever

## Uninstall

1. Delete plugin folder redmine/plugins/redmine_cmis_browser

2. Restart mongrel/upload to production/whatever


## Configuration

* Maximum files download: Maximum file limit for a single zip download. 0 is unlimited. (e.g. 0)


## License

This plugin is released under the [MIT License](http://www.opensource.org/licenses/MIT).
