###########################################################
#
# discount
#
###########################################################
#
# DISCOUNT_VERSION, DISCOUNT_SITE and DISCOUNT_SOURCE define
# the upstream location of the source code for the package.
# DISCOUNT_DIR is the directory which is created when the source
# archive is unpacked.
# DISCOUNT_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
# Please make sure that you add a description, and that you
# list all your packages' dependencies, seperated by commas.
#
# If you list yourself as MAINTAINER, please give a valid email
# address, and indicate your irc nick if it cannot be easily deduced
# from your name or email address.  If you leave MAINTAINER set to
# "NSLU2 Linux" other developers will feel free to edit.
#
DISCOUNT_SITE=http://www.pell.portland.or.us/~orc/Code/markdown
DISCOUNT_VERSION=2.1.1.2
DISCOUNT_SOURCE=discount-$(DISCOUNT_VERSION).tar.bz2
DISCOUNT_DIR=discount-$(DISCOUNT_VERSION)
DISCOUNT_UNZIP=bzcat
DISCOUNT_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
DISCOUNT_DESCRIPTION=Markdown text to HTML, in C.
DISCOUNT_SECTION=text
DISCOUNT_PRIORITY=optional
DISCOUNT_DEPENDS=sed
DISCOUNT_SUGGESTS=
DISCOUNT_CONFLICTS=

#
# DISCOUNT_IPK_VERSION should be incremented when the ipk changes.
#
DISCOUNT_IPK_VERSION=1

#
# DISCOUNT_CONFFILES should be a list of user-editable files
#DISCOUNT_CONFFILES=/opt/etc/discount.conf /opt/etc/init.d/SXXdiscount

#
# DISCOUNT_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
DISCOUNT_PATCHES=$(DISCOUNT_SOURCE_DIR)/configure.inc.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
DISCOUNT_CPPFLAGS=
DISCOUNT_LDFLAGS=-I. -L.

#
# DISCOUNT_BUILD_DIR is the directory in which the build is done.
# DISCOUNT_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# DISCOUNT_IPK_DIR is the directory in which the ipk is built.
# DISCOUNT_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
DISCOUNT_BUILD_DIR=$(BUILD_DIR)/discount
DISCOUNT_SOURCE_DIR=$(SOURCE_DIR)/discount
DISCOUNT_IPK_DIR=$(BUILD_DIR)/discount-$(DISCOUNT_VERSION)-ipk
DISCOUNT_IPK=$(BUILD_DIR)/discount_$(DISCOUNT_VERSION)-$(DISCOUNT_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: discount-source discount-unpack discount discount-stage discount-ipk discount-clean discount-dirclean discount-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(DISCOUNT_SOURCE):
	$(WGET) -P $(@D) $(DISCOUNT_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
discount-source: $(DL_DIR)/$(DISCOUNT_SOURCE) $(DISCOUNT_PATCHES)

#
# This target unpacks the source code in the build directory.
# If the source archive is not .tar.gz or .tar.bz2, then you will need
# to change the commands here.  Patches to the source code are also
# applied in this target as required.
#
# This target also configures the build within the build directory.
# Flags such as LDFLAGS and CPPFLAGS should be passed into configure
# and NOT $(MAKE) below.  Passing it to configure causes configure to
# correctly BUILD the Makefile with the right paths, where passing it
# to Make causes it to override the default search paths of the compiler.
#
# If the compilation of the package requires other packages to be staged
# first, then do that first (e.g. "$(MAKE) <bar>-stage <baz>-stage").
#
# If the package uses  GNU libtool, you should invoke $(PATCH_LIBTOOL) as
# shown below to make various patches to it.
#
$(DISCOUNT_BUILD_DIR)/.configured: $(DL_DIR)/$(DISCOUNT_SOURCE) $(DISCOUNT_PATCHES) make/discount.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(DISCOUNT_DIR) $(@D)
	$(DISCOUNT_UNZIP) $(DL_DIR)/$(DISCOUNT_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(DISCOUNT_PATCHES)" ; \
		then cat $(DISCOUNT_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(DISCOUNT_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(DISCOUNT_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(DISCOUNT_DIR) $(@D) ; \
	fi
	sed -i -e '/$$(CC)/s| -lmarkdown| $$(LDFLAGS) &|' $(@D)/Makefile.in
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(DISCOUNT_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(DISCOUNT_LDFLAGS)" \
		./configure.sh \
		--prefix=$(TARGET_PREFIX) \
		--confdir=/opt/etc \
		--enable-all-features \
	)
	sed -i -e 's:@DWORD@:unsigned long:g' $(@D)/mkdio.h
	sed -i -e '/PATH_SED/{s:".*":"/opt/bin/sed"\n#define DWORD unsigned long:}' $(@D)/config.h
#	$(PATCH_LIBTOOL) $(@D)/libtool
#		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--disable-nls \
		--disable-static \
		;
	touch $@

discount-unpack: $(DISCOUNT_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(DISCOUNT_BUILD_DIR)/.built: $(DISCOUNT_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) CC=$(HOSTCC) mktags
	$(MAKE) -C $(@D) \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(DISCOUNT_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(DISCOUNT_LDFLAGS)" \
		;
	touch $@

#
# This is the build convenience target.
#
discount: $(DISCOUNT_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
#$(DISCOUNT_BUILD_DIR)/.staged: $(DISCOUNT_BUILD_DIR)/.built
#	rm -f $@
#	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
#	touch $@
#
#discount-stage: $(DISCOUNT_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/discount
#
$(DISCOUNT_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: discount" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(DISCOUNT_PRIORITY)" >>$@
	@echo "Section: $(DISCOUNT_SECTION)" >>$@
	@echo "Version: $(DISCOUNT_VERSION)-$(DISCOUNT_IPK_VERSION)" >>$@
	@echo "Maintainer: $(DISCOUNT_MAINTAINER)" >>$@
	@echo "Source: $(DISCOUNT_SITE)/$(DISCOUNT_SOURCE)" >>$@
	@echo "Description: $(DISCOUNT_DESCRIPTION)" >>$@
	@echo "Depends: $(DISCOUNT_DEPENDS)" >>$@
	@echo "Suggests: $(DISCOUNT_SUGGESTS)" >>$@
	@echo "Conflicts: $(DISCOUNT_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(DISCOUNT_IPK_DIR)/opt/sbin or $(DISCOUNT_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(DISCOUNT_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(DISCOUNT_IPK_DIR)/opt/etc/discount/...
# Documentation files should be installed in $(DISCOUNT_IPK_DIR)/opt/doc/discount/...
# Daemon startup scripts should be installed in $(DISCOUNT_IPK_DIR)/opt/etc/init.d/S??discount
#
# You may need to patch your application to make it use these locations.
#
$(DISCOUNT_IPK): $(DISCOUNT_BUILD_DIR)/.built
	rm -rf $(DISCOUNT_IPK_DIR) $(BUILD_DIR)/discount_*_$(TARGET_ARCH).ipk
	$(INSTALL) -d $(DISCOUNT_IPK_DIR)/opt/bin $(DISCOUNT_IPK_DIR)/opt/include $(DISCOUNT_IPK_DIR)/opt/lib
	$(MAKE) -C $(DISCOUNT_BUILD_DIR) DESTDIR=$(DISCOUNT_IPK_DIR) install.everything
	$(STRIP_COMMAND) $(DISCOUNT_IPK_DIR)/opt/bin/*
	$(MAKE) $(DISCOUNT_IPK_DIR)/CONTROL/control
	echo $(DISCOUNT_CONFFILES) | sed -e 's/ /\n/g' > $(DISCOUNT_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(DISCOUNT_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
discount-ipk: $(DISCOUNT_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
discount-clean:
	rm -f $(DISCOUNT_BUILD_DIR)/.built
	-$(MAKE) -C $(DISCOUNT_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
discount-dirclean:
	rm -rf $(BUILD_DIR)/$(DISCOUNT_DIR) $(DISCOUNT_BUILD_DIR) $(DISCOUNT_IPK_DIR) $(DISCOUNT_IPK)
#
#
# Some sanity check for the package.
#
discount-check: $(DISCOUNT_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
