#
#   <Quantitative project management tool.>
#
#   Copyright (C) 2012 IPA, Japan.
#
#   This program is free software: you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

.PHONY: all
all: installer


-include Makefile.cfg


prefix			= /opt/ipftools

revision		= $(shell test -f REVISION && cat REVISION || LC_ALL=C svn info | sed -n 's/^Last Changed Rev: //p')
version			= 1.0.0.$(revision)
release			= 1
arch			= $(shell rpmbuild --nobuild --eval '%{_arch}' 2>/dev/null)
ifeq ($(arch),i386)
arch_jre		= i586
else
arch_jre		= x64
endif

url-ruby		= ftp://ftp.ruby-lang.org/pub/ruby/1.8/ruby-1.8.7-p352.tar.gz
url-rubygems		= http://rubyforge.org/frs/download.php/74235/rubygems-1.5.2.zip
url-redmine		= http://rubyforge.org/frs/download.php/75099/redmine-1.2.1.zip
url-perl-git		= http://pkgs.repoforge.org/git/perl-Git-1.7.6.4-1.el5.rf.$(arch).rpm
url-git			= http://pkgs.repoforge.org/git/git-1.7.6.4-1.el5.rf.$(arch).rpm
url-jre			= http://download.oracle.com/otn-pub/java/jdk/6u30-b12/jre-6u30-linux-$(arch_jre).bin
url-tomcat		= http://archive.apache.org/dist/tomcat/tomcat-6/v6.0.35/bin/apache-tomcat-6.0.35.tar.gz
url-ipafont		= http://info.openlab.ipa.go.jp/ipafont/fontdata/IPAexfont00103.zip
url-pentaho-di		= http://downloads.sourceforge.net/project/pentaho/Data%20Integration/4.1.0-stable/pdi-ce-4.1.0-stable.zip
url-yamlbeans		= http://yamlbeans.googlecode.com/files/yamlbeans-1.06.zip

# rubygems
url-gem-actionmailer		= http://rubygems.org/gems/actionmailer-2.3.11.gem
url-gem-actionpack		= http://rubygems.org/gems/actionpack-2.3.11.gem
url-gem-activerecord		= http://rubygems.org/gems/activerecord-2.3.11.gem
url-gem-activeresource		= http://rubygems.org/gems/activeresource-2.3.11.gem
url-gem-activesupport		= http://rubygems.org/gems/activesupport-2.3.11.gem
url-gem-addressable		= http://rubygems.org/gems/addressable-2.2.6.gem
url-gem-choice			= http://rubygems.org/gems/choice-0.1.4.gem
url-gem-daemon_controller	= http://rubygems.org/gems/daemon_controller-0.2.6.gem
url-gem-faraday			= http://rubygems.org/gems/faraday-0.7.6.gem
url-gem-fastercsv		= http://rubygems.org/gems/fastercsv-1.5.4.gem
url-gem-fastthread		= http://rubygems.org/gems/fastthread-1.0.7.gem
url-gem-google-spreadsheet-ruby	= http://rubygems.org/gems/google-spreadsheet-ruby-0.1.6.gem
url-gem-i18n			= http://rubygems.org/gems/i18n-0.4.2.gem
url-gem-log4r			= http://rubygems.org/gems/log4r-1.1.10.gem
url-gem-multi_json		= http://rubygems.org/gems/multi_json-1.0.4.gem
url-gem-multipart-post		= http://rubygems.org/gems/multipart-post-1.1.4.gem
url-gem-nokogiri		= http://rubygems.org/gems/nokogiri-1.5.0.gem
url-gem-oauth			= http://rubygems.org/gems/oauth-0.4.5.gem
url-gem-oauth2			= http://rubygems.org/gems/oauth2-0.5.2.gem
url-gem-passenger		= http://rubygems.org/gems/passenger-3.0.8.gem
url-gem-pg			= http://rubygems.org/gems/pg-0.11.0.gem
url-gem-rack-1.1.1		= http://rubygems.org/gems/rack-1.1.1.gem
url-gem-rack-1.4.1		= http://rubygems.org/gems/rack-1.4.1.gem
url-gem-rails			= http://rubygems.org/gems/rails-2.3.11.gem
url-gem-rake			= http://rubygems.org/gems/rake-0.9.2.2.gem
url-gem-roo			= http://rubygems.org/gems/roo-1.10.0.gem
url-gem-ruby-ole		= http://rubygems.org/gems/ruby-ole-1.2.11.2.gem
url-gem-spreadsheet		= http://rubygems.org/gems/spreadsheet-0.6.5.7.gem
url-gem-todonotes		= http://rubygems.org/gems/todonotes-0.1.0.gem
url-gem-zip			= http://rubygems.org/gems/zip-2.0.2.gem
url-gem-zipruby			= http://rubygems.org/gems/zipruby-0.3.6.gem


mkdir-prefix-cmd	?= sudo /bin/mkdir -p $(prefix); sudo /bin/chown $(shell id -un) $(prefix)
rmdir-prefix-cmd	?= sudo /bin/rm -r $(prefix)


help-tasks		+= help
help-help		= Print this message.


# macro: make an empty directory.
define make-empty-dir
	$(RM) -r $(1); mkdir -p $(1)
endef


# macro: check rpm installed.
define check-rpm
	@$(foreach rpm,$(1),msg=`rpm -q "$(rpm)"` || (echo $$msg; false);)
endef


# macro: define a download task.
define download-rule
basename-$(1)	?= $(or $(2),$$(lastword $$(subst /, ,$$(url-$(1)))))
downloaded-$(1) ?= downloaded/$$(basename-$(1))
$$(downloaded-$(1)):
	$(call check-rpm,wget)
	mkdir -p $$(dir $$@)
	wget -nv -O $$@ "$$(url-$(1))"
endef

$(eval $(call download-rule,ruby))
$(eval $(call download-rule,rubygems))
$(eval $(call download-rule,perl-git))
$(eval $(call download-rule,git))

define download-gem-rule
basename-gem-$(1) ?= $(or $(2),$$(lastword $$(subst /, ,$$(url-gem-$(1)))))
downloaded-gem-$(1) ?= downloaded/$$(basename-gem-$(1))
$$(downloaded-gem-$(1)):
	mkdir -p $$(dir $$@)
	wget -nv -O $$@ "$$(url-gem-$(1))"
built/ruby.tgz: $$(downloaded-gem-$(1))
endef

$(eval $(call download-gem-rule,actionmailer))
$(eval $(call download-gem-rule,actionpack))
$(eval $(call download-gem-rule,activerecord))
$(eval $(call download-gem-rule,activeresource))
$(eval $(call download-gem-rule,activesupport))
$(eval $(call download-gem-rule,addressable))
$(eval $(call download-gem-rule,choice))
$(eval $(call download-gem-rule,daemon_controller))
$(eval $(call download-gem-rule,faraday))
$(eval $(call download-gem-rule,fastercsv))
$(eval $(call download-gem-rule,fastthread))
$(eval $(call download-gem-rule,google-spreadsheet-ruby))
$(eval $(call download-gem-rule,i18n))
$(eval $(call download-gem-rule,log4r))
$(eval $(call download-gem-rule,multi_json))
$(eval $(call download-gem-rule,multipart-post))
$(eval $(call download-gem-rule,nokogiri))
$(eval $(call download-gem-rule,oauth))
$(eval $(call download-gem-rule,oauth2))
$(eval $(call download-gem-rule,passenger))
$(eval $(call download-gem-rule,pg))
$(eval $(call download-gem-rule,rack-1.1.1))
$(eval $(call download-gem-rule,rack-1.4.1))
$(eval $(call download-gem-rule,rails))
$(eval $(call download-gem-rule,rake))
$(eval $(call download-gem-rule,roo))
$(eval $(call download-gem-rule,ruby-ole))
$(eval $(call download-gem-rule,spreadsheet))
$(eval $(call download-gem-rule,todonotes))
$(eval $(call download-gem-rule,zip))
$(eval $(call download-gem-rule,zipruby))


# macro: define a download and source task.
define download-and-source-rule
$(eval $(call download-rule,$(1),$(2)))
source-$(1)	?= build/SOURCES/$$(basename-$(1))
$$(source-$(1)): $$(downloaded-$(1))
	mkdir -p $$(dir $$@)
	cp $$(downloaded-$(1)) $$@
endef

$(eval $(call download-and-source-rule,redmine))
$(eval $(call download-and-source-rule,jre))
$(eval $(call download-and-source-rule,tomcat))
$(eval $(call download-and-source-rule,ipafont))
$(eval $(call download-and-source-rule,pentaho-di))
$(eval $(call download-and-source-rule,yamlbeans))


rpm-ipftools-redmine			= build/RPMS/$(arch)/ipftools-redmine-$(version)-$(release).$(arch).rpm
installer				= build/ipftools-redmine-$(version)-setup-centos.$(arch).bin
source-ipftools-redmine-files		= build/SOURCES/ipftools-redmine-files-$(version).tgz
source-ipftools-redmine-patch		= build/SOURCES/ipftools-redmine-patch-$(version).patch
source-ipftools-redmine-templates	= build/SOURCES/ipftools-redmine-templates-$(version).lst
source-ipftools-redmine-ipfdb		= build/SOURCES/ipftools-redmine-ipfdb-$(version).tgz
source-ipftools-redmine-ipf-plugins	= build/SOURCES/ipftools-redmine-ipf-plugins-$(version).zip
source-ipftools-redmine-ipf-script	= build/SOURCES/ipftools-redmine-ipf-script-$(version).zip
source-ipftools-redmine-ipf-help	= build/SOURCES/ipftools-redmine-ipf-help-$(version).zip
source-ipftools-birt-viewer		= build/SOURCES/ipftools-birt-viewer-$(version).zip
source-ipftools-redmine-ipf-batch	= build/SOURCES/ipftools-redmine-ipf-batch-$(version).zip
source-ipftools-redmine-ruby		= build/SOURCES/ipftools-redmine-ruby-$(version).tgz
source-ipftools-tomcat-sh		= build/SOURCES/ipftools-tomcat-$(version).sh


files-srcs			+= $(filter-out %~,$(shell find files -type d -name .svn -prune -o -type f -print))
$(source-ipftools-redmine-files): $(files-srcs) $(mo-files)
	$(call make-empty-dir,build/tmp/)
	tar cf - $(files-srcs) | tar xf - -C build/tmp
	mkdir -p build/tmp/files/share
	tar cf - $(mo-files) | tar xf - -C build/tmp/files/share
	mkdir -p $(dir $@)
	tar cfz $@ -C build/tmp/files .


patch-srcs			+= $(filter-out %~,$(shell find patches -type f))
$(source-ipftools-redmine-patch): patch-check
$(source-ipftools-redmine-patch): $(patch-srcs)
	(cd patches; LC_ALL=C diff -ruN -x .svn -x "*~" original customized; true) > $@



$(source-ipftools-redmine-templates): $(filter-out %~,$(shell find patches/customized -type f))
	($(foreach i,$(template-files),echo $(i);)) > $@

ipfdb-srcs			+= $(wildcard externals/IPFDB*.sql)
$(source-ipftools-redmine-ipfdb): $(ipfdb-srcs)
	mkdir -p $(dir $@)
	tar cfz $@ -C externals $(notdir $(ipfdb-srcs))


$(source-ipftools-redmine-ipf-plugins): externals/plugins.zip
	mkdir -p $(dir $@)
	cp $< $@


$(source-ipftools-redmine-ipf-script): externals/script.zip
	mkdir -p $(dir $@)
	cp $< $@


$(source-ipftools-redmine-ipf-help): externals/help.zip
	mkdir -p $(dir $@)
	cp $< $@


$(source-ipftools-birt-viewer): externals/birt-viewer.zip
	mkdir -p $(dir $@)
	cp $< $@


$(source-ipftools-redmine-ipf-batch): externals/batch.zip
	mkdir -p $(dir $@)
	cp $< $@


$(source-ipftools-redmine-ruby): built/ruby.tgz
	mkdir -p $(dir $@)
	cp $< $@


$(source-ipftools-tomcat-sh): sysfiles/ipftools-tomcat.sh
	mkdir -p $(dir $@)
	cp $< $@


# Build ruby+gems execution image.
built/ruby.tgz: $(downloaded-ruby)
built/ruby.tgz: $(downloaded-rubygems)
	$(call check-rpm,unzip tar sudo) # requires for making
	$(call check-rpm,glibc-devel autoconf gcc byacc) # requires for ruby
	$(call check-rpm,readline-devel ncurses-devel gdbm-devel openssl-devel db4-devel zlib-devel) # requires for ruby-ext
	$(call check-rpm,libxml2-devel libxslt-devel) # requires for roo
	$(call check-rpm,gcc-c++ curl-devel openssl-devel zlib-devel "httpd-2.*" httpd-devel apr-devel apr-util-devel) # requires for passenger
	@if [ -d $(prefix) ]; then \
		echo "Ruby and gems can't be built on <buildroot>. so must be built on empty <prefix> directory." 1>&2; \
		echo -n "Re-create \`${prefix}'?(y/n) " 1>&2; \
		read ans; \
		case "$$ans" in [yY]) ;; *) exit 1; esac; \
		(set -ex; $(rmdir-prefix-cmd)); \
	fi
	@set -ex; $(mkdir-prefix-cmd)
	# start building
	$(call make-empty-dir,build/tmp)
	mkdir build/tmp/ruby
	tar xfz $(downloaded-ruby) --directory=build/tmp/ruby
	( \
		set -e; \
		cd build/tmp/ruby/$(shell basename $(basename-ruby) .tar.gz); \
		./configure --prefix=$(prefix); \
		make; \
		make test; \
		make install; \
	)
	mkdir build/tmp/rubygems
	unzip -q $(downloaded-rubygems) -d build/tmp/rubygems
	( \
		set -e; \
		cd build/tmp/rubygems/$(shell basename $(basename-rubygems) .zip); \
		$(prefix)/bin/ruby setup.rb --no-rdoc --no-ri; \
	)
	$(prefix)/bin/gem install -l --no-rdoc --no-ri --no-update-sources $(downloaded-gem-fastercsv)
	$(prefix)/bin/gem install -l --no-rdoc --no-ri --no-update-sources $(downloaded-gem-ruby-ole)
	$(prefix)/bin/gem install -l --no-rdoc --no-ri --no-update-sources $(downloaded-gem-spreadsheet)
	$(prefix)/bin/gem install -l --no-rdoc --no-ri --no-update-sources $(downloaded-gem-nokogiri)
	$(prefix)/bin/gem install -l --no-rdoc --no-ri --no-update-sources $(downloaded-gem-oauth)
	$(prefix)/bin/gem install -l --no-rdoc --no-ri --no-update-sources $(downloaded-gem-addressable)
	$(prefix)/bin/gem install -l --no-rdoc --no-ri --no-update-sources $(downloaded-gem-rack-1.1.1)
	$(prefix)/bin/gem install -l --no-rdoc --no-ri --no-update-sources $(downloaded-gem-rack-1.4.1)
	$(prefix)/bin/gem install -l --no-rdoc --no-ri --no-update-sources $(downloaded-gem-multipart-post)
	$(prefix)/bin/gem install -l --no-rdoc --no-ri --no-update-sources $(downloaded-gem-faraday)
	$(prefix)/bin/gem install -l --no-rdoc --no-ri --no-update-sources $(downloaded-gem-multi_json)
	$(prefix)/bin/gem install -l --no-rdoc --no-ri --no-update-sources $(downloaded-gem-oauth2)
	$(prefix)/bin/gem install -l --no-rdoc --no-ri --no-update-sources $(downloaded-gem-google-spreadsheet-ruby)
	$(prefix)/bin/gem install -l --no-rdoc --no-ri --no-update-sources $(downloaded-gem-choice)
	$(prefix)/bin/gem install -l --no-rdoc --no-ri --no-update-sources $(downloaded-gem-log4r)
	$(prefix)/bin/gem install -l --no-rdoc --no-ri --no-update-sources $(downloaded-gem-todonotes)
	$(prefix)/bin/gem install -l --no-rdoc --no-ri --no-update-sources $(downloaded-gem-roo)
	$(prefix)/bin/gem install -l --no-rdoc --no-ri --no-update-sources $(downloaded-gem-zip)
	$(prefix)/bin/gem install -l --no-rdoc --no-ri --no-update-sources $(downloaded-gem-zipruby)
	$(prefix)/bin/gem install -l --no-rdoc --no-ri --no-update-sources $(downloaded-gem-pg)
	$(prefix)/bin/gem install -l --no-rdoc --no-ri --no-update-sources $(downloaded-gem-i18n)
	$(prefix)/bin/gem install -l --no-rdoc --no-ri --no-update-sources $(downloaded-gem-rake)
	$(prefix)/bin/gem install -l --no-rdoc --no-ri --no-update-sources $(downloaded-gem-activesupport)
	$(prefix)/bin/gem install -l --no-rdoc --no-ri --no-update-sources $(downloaded-gem-actionpack)
	$(prefix)/bin/gem install -l --no-rdoc --no-ri --no-update-sources $(downloaded-gem-actionmailer)
	$(prefix)/bin/gem install -l --no-rdoc --no-ri --no-update-sources $(downloaded-gem-activeresource)
	$(prefix)/bin/gem install -l --no-rdoc --no-ri --no-update-sources $(downloaded-gem-activerecord)
	$(prefix)/bin/gem install -l --no-rdoc --no-ri --no-update-sources $(downloaded-gem-rails)
	$(prefix)/bin/gem install -l --no-rdoc --no-ri --no-update-sources $(downloaded-gem-fastthread)
	$(prefix)/bin/gem install -l --no-rdoc --no-ri --no-update-sources $(downloaded-gem-daemon_controller)
	$(prefix)/bin/gem install -l --no-rdoc --no-ri --no-update-sources $(downloaded-gem-passenger)
	$(prefix)/bin/passenger-install-apache2-module --auto
	mkdir -p $(prefix)/etc
	$(prefix)/bin/passenger-install-apache2-module --snippet > $(prefix)/etc/httpd-passenger.conf
	$(RM) -r $(prefix)/share
	mkdir -p $(dir $@)
	tar cfz $@ -C / `echo $(prefix) | sed 's|^/||'`
	@set -ex; $(rmdir-prefix-cmd)


build/SPECS/ipftools-redmine.spec: ipftools-redmine.spec.in
	$(call check-rpm,perl)
	mkdir -p $(dir $@)
	( \
		export PREFIX="$(prefix)"; \
		export VERSION="$(version)"; \
		export RELEASE="$(release)"; \
		export URL_REDMINE="$(url-redmine)"; \
		export URL_JRE="${url-jre}"; \
		export URL_TOMCAT="${url-tomcat}"; \
		export URL_IPAFONT="${url-ipafont}"; \
		export URL_PENTAHO_DI="${url-pentaho-di}"; \
		export URL_YAMLBEANS="${url-yamlbeans}"; \
		perl -pe 's/\@\@([A-Z0-9_]+)\@\@/$$ENV{$$1}/g' ipftools-redmine.spec.in > $@; \
	)


$(rpm-ipftools-redmine): $(source-ipftools-redmine-ruby)
$(rpm-ipftools-redmine): $(source-ipftools-redmine-files)
$(rpm-ipftools-redmine): $(source-ipftools-redmine-patch)
$(rpm-ipftools-redmine): $(source-ipftools-redmine-templates)
$(rpm-ipftools-redmine): $(source-ipftools-redmine-ipfdb)
$(rpm-ipftools-redmine): $(source-ipftools-redmine-ipf-plugins)
$(rpm-ipftools-redmine): $(source-ipftools-redmine-ipf-script)
$(rpm-ipftools-redmine): $(source-ipftools-redmine-ipf-help)
$(rpm-ipftools-redmine): $(source-ipftools-redmine-ipf-batch)
$(rpm-ipftools-redmine): $(source-ipftools-birt-viewer)
$(rpm-ipftools-redmine): $(source-ipftools-tomcat-sh)
$(rpm-ipftools-redmine): $(source-redmine)
$(rpm-ipftools-redmine): $(source-jre)
$(rpm-ipftools-redmine): $(source-tomcat)
$(rpm-ipftools-redmine): $(source-ipafont)
$(rpm-ipftools-redmine): $(source-pentaho-di)
$(rpm-ipftools-redmine): $(source-yamlbeans)
$(rpm-ipftools-redmine): build/SPECS/ipftools-redmine.spec
	$(call check-rpm,rpm-build)
	mkdir -p build/BUILD
	mkdir -p build/RPMS
	rpmbuild -v \
		--define "_topdir `pwd`/build" \
		--define "buildroot `pwd`/build/root" \
		-bb \
		build/SPECS/ipftools-redmine.spec


########################################################################
#
# message catalog tasks.
#
########################################################################
gettext_srcs	+= installer/bootstrap.sh
gettext_srcs	+= installer/install.sh
gettext_srcs	+= files/bin/uninstall-ipftools-redmine
gettext_srcs	+= files/libexec/setup.sh


locale/ipftools.pot: $(gettext_srcs)
	$(call check-rpm,gettext)
	xgettext -L Shell -o $@ $^


define catalog-rule
locale/$(1)/LC_MESSAGES/ipftools.po: locale/ipftools.pot
	$(call check-rpm,gettext)
	mkdir -p locale/$(1)/LC_MESSAGES
	@if [ -f $$@ ]; then \
		(set -x; msgmerge -U $$@ $$<); \
	else \
		(set -x; msginit --locale=$(1) --input=$$< --output=$$@ --no-translator); \
	fi
locale/$(1)/LC_MESSAGES/ipftools.mo: locale/$(1)/LC_MESSAGES/ipftools.po
	$(call check-rpm,gettext)
	msgfmt --output-file=$$@ $$<
po-files += locale/$(1)/LC_MESSAGES/ipftools.po
mo-files += locale/$(1)/LC_MESSAGES/ipftools.mo
endef

locales		+= ja
$(foreach locale,$(locales),$(eval $(call catalog-rule,$(locale))))


.PHONY: catalog catalog-ls
catalog: $(po-files)
	$(call check-rpm,gettext)
	@for po in $(po-files); do \
		echo -n "$$po ... "; \
		msgfmt --statistics --output-file=/dev/null $$po; \
	done

catalog-ls:
	@ls -l $(po-files)

clean::
	$(RM) $(mo-files)


help-tasks		+= - catalog catalog-ls
catalog-help		= Check message catalog files.
catalog-ls-help		= List catalog files.


########################################################################
#
# Patch related tasks.
#
########################################################################
patch-original-files		= $(filter-out %~,$(shell cd patches/original; find . -type d -name .svn -prune -o -type f -print))
patch-customized-files		= $(filter-out %~,$(shell cd patches/customized; find . -type d -name .svn -prune -o -type f -print))
patch-original-no-files		+= ./redmine/config/initializers/ipftools.rb
patch-original-no-files		+= ./redmine/config/configuration.yml
patch-original-no-files		+= ./redmine/config/database.yml
patch-customized-no-files	=


.PHONY: patch-check-exists patch-check-current patch-ls patch-cat patch-show patch-check
patch-check-exists:
	@$(call make-empty-dir,build/tmp)
	@($(foreach i,$(patch-original-files) $(patch-original-no-files),echo $(i);)) | sort > build/tmp/original
	@($(foreach i,$(patch-customized-files) $(patch-customized-no-files),echo $(i);)) | sort > build/tmp/customized
	diff build/tmp/original build/tmp/customized


patch-check-current: base1=$(subst .tar.gz,,$(basename-tomcat))
patch-check-current: externals/batch.zip
patch-check-current: externals/script.zip
patch-check-current: $(downloaded-tomcat)  
	@$(call make-empty-dir,build/tmp)
	@unzip -q externals/batch.zip -d build/tmp $(filter-out %~,$(shell cd patches/original; find batch -type d -name .svn -prune -o -type f -print))
	@unzip -q externals/script.zip -d build/tmp $(filter-out %~,$(shell cd patches/original; find script -type d -name .svn -prune -o -type f -print))
	@tar xfvz $(downloaded-tomcat) -C build/tmp $(subst ./,$(base1)/,$(filter-out %~,$(shell cd patches/original/tomcat; find . -type d -name .svn -prune -o -type f -print | grep -v /birt-viewer/)))
	@mv build/tmp/$(base1) build/tmp/tomcat
	@mkdir -p build/tmp/tomcat/webapps
	@unzip -q externals/birt-viewer.zip -d build/tmp/tomcat/webapps $(filter-out %~,$(shell cd patches/original/tomcat/webapps; find birt-viewer -type d -name .svn -prune -o -type f -print))
	diff -r -x .svn patches/original build/tmp


patch-ls:
	@echo "[patches/original]"
	@cd patches/original; ls -l $(patch-original-files)
	@echo "[paches/customized]"
	@cd patches/customized; ls -l $(patch-customized-files)


patch-cat:
	@cd patches; grep '' /dev/null $(foreach i,$(patch-customized-files),customized/$(i))


patch-show:
	cd patches; diff -ruN -x .svn -x "*~" original customized; :


patch-check: patch-check-exists
patch-check: patch-check-current


help-tasks		+= - patch-check patch-ls patch-cat patch-show
patch-check-help	= Check patch files.
patch-ls-help		= List original and customized files.
patch-cat-help		= Show customized files.
patch-show-help		= Show content of patch file.


########################################################################
#
# Template relates tasks.
#
########################################################################
template-files	+= $(foreach i,$(patch-customized-files),$(shell grep -q -E '@@[A-Z0-9_]+@@' patches/customized/$(i) && echo $(i)))

template-ls:
	@cd patches/customized; ls -l $(template-files)


template-cat:
	@cd patches/customized; grep '' /dev/null $(template-files)


template-keywords:
	cd patches/customized; perl -lne 's/\@\@([A-Z0-9_]+)\@\@/print $$1/eg' $(template-files) | sort | uniq


help-tasks		+= - template-ls template-cat template-keywords
template-ls-help	= List template files.
template-cat-help	= Show content of template files.
template-keywords-help	= Show template keywords in template files.



########################################################################
#
# Build installer tasks
#
########################################################################
$(installer): installer/bootstrap.sh
$(installer): installer/install.sh
$(installer): installer/build.sh
$(installer): $(mo-files)
$(installer): $(rpm-ipftools-redmine)
$(installer): $(downloaded-perl-git)
$(installer): $(downloaded-git)
	$(call check-rpm,gzip tar perl)
	installer/build.sh \
		$@ \
		installer/bootstrap.sh \
		installer/install.sh \
		"$(mo-files)" \
		$(downloaded-git) \
		$(downloaded-perl-git) \
		$(rpm-ipftools-redmine)


.PHONY: installer
installer: $(installer)


help-tasks		+= - installer
installer-help		= Buld installer.


########################################################################
#
# Packaging related tasks
#
########################################################################
export: export-basename		?= ipf-redmine-installer-centos
export: export-url		?= $(shell LC_ALL=C svn info | sed -n 's/^URL: //p')
export: export-revision		?= $(shell LC_ALL=C svn info | sed -n 's/^Last Changed Rev: //p')
export: export-dirname		?= $(export-basename)-r$(export-revision)
export: export-target		= build/$(export-dirname).tgz
export:
	$(call make-empty-dir,build/tmp)
	svn export -q -r$(export-revision) $(export-url) build/tmp/$(export-dirname)
	echo $(export-revision) > build/tmp/$(export-dirname)/REVISION
	tar cfz $(export-target) -C build/tmp $(export-dirname)


help-tasks		+= - export
export-help		= Create tarball which contains repository files.


########################################################################
#
# Clean tasks.
#
########################################################################
.PHONY: clean
clean::
	$(RM) -r build
	find . -name "*~" -print -exec $(RM) {} \;



.PHONY: clean-all
clean-all:: clean
	$(RM) -r downloaded
	$(RM) -r built


help-tasks		+= - clean clean-all
clean-help		= Delete built and backup files.
clean-all-help		= Execute "clean" and delete some more files.



########################################################################
#
# Help task.
#
########################################################################
help:
	@echo 'Usage: make [defines] <task>'
	@echo ''
	@echo 'tasks:'
	@$(foreach task,$(help-tasks),[ x$(task) == x- ] && echo "" || printf "  %-20s %s\\n" '$(task)'  '$(value $(task)-help)';)


-include Makefile.ext


# Local Variables: ***
# mode: makefile ***
# coding: utf-8 ***
# End: ***
