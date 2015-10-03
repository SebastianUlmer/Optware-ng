###########################################################
#
# perl-html-template
#
###########################################################

PERL-HTML-TEMPLATE_SITE=http://search.cpan.org/CPAN/authors/id/S/SA/SAMTREGAR
PERL-HTML-TEMPLATE_VERSION=2.8
PERL-HTML-TEMPLATE_SOURCE=HTML-Template-$(PERL-HTML-TEMPLATE_VERSION).tar.gz
PERL-HTML-TEMPLATE_DIR=HTML-Template-$(PERL-HTML-TEMPLATE_VERSION)
PERL-HTML-TEMPLATE_UNZIP=zcat

PERL-HTML-TEMPLATE_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PERL-HTML-TEMPLATE_DESCRIPTION=Perl module to use HTML Templates from CGI scripts
PERL-HTML-TEMPLATE_SECTION=util
PERL-HTML-TEMPLATE_PRIORITY=optional
PERL-HTML-TEMPLATE_DEPENDS=perl

PERL-HTML-TEMPLATE_IPK_VERSION=2

PERL-HTML-TEMPLATE_CONFFILES=

PERL-HTML-TEMPLATE_PATCHES=

PERL-HTML-TEMPLATE_BUILD_DIR=$(BUILD_DIR)/perl-html-template
PERL-HTML-TEMPLATE_SOURCE_DIR=$(SOURCE_DIR)/perl-html-template
PERL-HTML-TEMPLATE_IPK_DIR=$(BUILD_DIR)/perl-html-template-$(PERL-HTML-TEMPLATE_VERSION)-ipk
PERL-HTML-TEMPLATE_IPK=$(BUILD_DIR)/perl-html-template_$(PERL-HTML-TEMPLATE_VERSION)-$(PERL-HTML-TEMPLATE_IPK_VERSION)_$(TARGET_ARCH).ipk

PERL-HTML-TEMPLATE_BUILD_DIR=$(BUILD_DIR)/perl-html-template
PERL-HTML-TEMPLATE_SOURCE_DIR=$(SOURCE_DIR)/perl-html-template
PERL-HTML-TEMPLATE_IPK_DIR=$(BUILD_DIR)/perl-html-template-$(PERL-HTML-TEMPLATE_VERSION)-ipk
PERL-HTML-TEMPLATE_IPK=$(BUILD_DIR)/perl-html-template_$(PERL-HTML-TEMPLATE_VERSION)-$(PERL-HTML-TEMPLATE_IPK_VERSION)_$(TARGET_ARCH).ipk

$(DL_DIR)/$(PERL-HTML-TEMPLATE_SOURCE):
	$(WGET) -P $(DL_DIR) $(PERL-HTML-TEMPLATE_SITE)/$(PERL-HTML-TEMPLATE_SOURCE)

perl-html-template-source: $(DL_DIR)/$(PERL-HTML-TEMPLATE_SOURCE) $(PERL-HTML-TEMPLATE_PATCHES)

$(PERL-HTML-TEMPLATE_BUILD_DIR)/.configured: $(DL_DIR)/$(PERL-HTML-TEMPLATE_SOURCE) $(PERL-HTML-TEMPLATE_PATCHES)
	$(MAKE) perl-stage
	rm -rf $(BUILD_DIR)/$(PERL-HTML-TEMPLATE_DIR) $(PERL-HTML-TEMPLATE_BUILD_DIR)
	$(PERL-HTML-TEMPLATE_UNZIP) $(DL_DIR)/$(PERL-HTML-TEMPLATE_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PERL-HTML-TEMPLATE_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(PERL-HTML-TEMPLATE_DIR) -p1
	mv $(BUILD_DIR)/$(PERL-HTML-TEMPLATE_DIR) $(PERL-HTML-TEMPLATE_BUILD_DIR)
	(cd $(PERL-HTML-TEMPLATE_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		PERL5LIB="$(STAGING_LIB_DIR)/perl5/site_perl" \
		$(PERL_HOSTPERL) Makefile.PL \
		PREFIX=$(TARGET_PREFIX) \
	)
	touch $(PERL-HTML-TEMPLATE_BUILD_DIR)/.configured

perl-html-template-unpack: $(PERL-HTML-TEMPLATE_BUILD_DIR)/.configured

$(PERL-HTML-TEMPLATE_BUILD_DIR)/.built: $(PERL-HTML-TEMPLATE_BUILD_DIR)/.configured
	rm -f $(PERL-HTML-TEMPLATE_BUILD_DIR)/.built
	$(MAKE) -C $(PERL-HTML-TEMPLATE_BUILD_DIR) \
	PERL5LIB="$(STAGING_LIB_DIR)/perl5/site_perl"
	touch $(PERL-HTML-TEMPLATE_BUILD_DIR)/.built

perl-html-template: $(PERL-HTML-TEMPLATE_BUILD_DIR)/.built

$(PERL-HTML-TEMPLATE_BUILD_DIR)/.staged: $(PERL-HTML-TEMPLATE_BUILD_DIR)/.built
	rm -f $(PERL-HTML-TEMPLATE_BUILD_DIR)/.staged
	$(MAKE) -C $(PERL-HTML-TEMPLATE_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(PERL-HTML-TEMPLATE_BUILD_DIR)/.staged

perl-html-template-stage: $(PERL-HTML-TEMPLATE_BUILD_DIR)/.staged

$(PERL-HTML-TEMPLATE_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(PERL-HTML-TEMPLATE_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: perl-html-template" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PERL-HTML-TEMPLATE_PRIORITY)" >>$@
	@echo "Section: $(PERL-HTML-TEMPLATE_SECTION)" >>$@
	@echo "Version: $(PERL-HTML-TEMPLATE_VERSION)-$(PERL-HTML-TEMPLATE_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PERL-HTML-TEMPLATE_MAINTAINER)" >>$@
	@echo "Source: $(PERL-HTML-TEMPLATE_SITE)/$(PERL-HTML-TEMPLATE_SOURCE)" >>$@
	@echo "Description: $(PERL-HTML-TEMPLATE_DESCRIPTION)" >>$@
	@echo "Depends: $(PERL-HTML-TEMPLATE_DEPENDS)" >>$@

$(PERL-HTML-TEMPLATE_IPK): $(PERL-HTML-TEMPLATE_BUILD_DIR)/.built
	rm -rf $(PERL-HTML-TEMPLATE_IPK_DIR) $(BUILD_DIR)/perl-html-template_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PERL-HTML-TEMPLATE_BUILD_DIR) DESTDIR=$(PERL-HTML-TEMPLATE_IPK_DIR) install
	find $(PERL-HTML-TEMPLATE_IPK_DIR)$(TARGET_PREFIX) -name 'perllocal.pod' -exec rm -f {} \;
	(cd $(PERL-HTML-TEMPLATE_IPK_DIR)/opt/lib/perl5 ; \
		find . -name '*.so' -exec chmod +w {} \; ; \
		find . -name '*.so' -exec $(STRIP_COMMAND) {} \; ; \
		find . -name '*.so' -exec chmod -w {} \; ; \
	)
	find $(PERL-HTML-TEMPLATE_IPK_DIR)$(TARGET_PREFIX) -type d -exec chmod go+rx {} \;
	$(MAKE) $(PERL-HTML-TEMPLATE_IPK_DIR)/CONTROL/control
#	$(INSTALL) -m 755 $(PERL-HTML-TEMPLATE_SOURCE_DIR)/postinst $(PERL-HTML-TEMPLATE_IPK_DIR)/CONTROL/postinst
#	$(INSTALL) -m 755 $(PERL-HTML-TEMPLATE_SOURCE_DIR)/prerm $(PERL-HTML-TEMPLATE_IPK_DIR)/CONTROL/prerm
	echo $(PERL-HTML-TEMPLATE_CONFFILES) | sed -e 's/ /\n/g' > $(PERL-HTML-TEMPLATE_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PERL-HTML-TEMPLATE_IPK_DIR)

perl-html-template-ipk: $(PERL-HTML-TEMPLATE_IPK)

perl-html-template-clean:
	-$(MAKE) -C $(PERL-HTML-TEMPLATE_BUILD_DIR) clean

perl-html-template-dirclean:
	rm -rf $(BUILD_DIR)/$(PERL-HTML-TEMPLATE_DIR) $(PERL-HTML-TEMPLATE_BUILD_DIR) $(PERL-HTML-TEMPLATE_IPK_DIR) $(PERL-HTML-TEMPLATE_IPK)
