
AUTOMAKE_OPTIONS= -Wno-portability
EXTRA_DIST = debian DESCRIPTION inst src
CURRDATE := $(shell date +"%Y-%d-%m")

#octave tools expect hardwired dir name
INST_DIR=inst
SRC_DIR=src

BUILT_SOURCES = DESCRIPTION $(SRC_DIR)/dijkstra.mex

dist_doc_DATA=COPYING LICENSE README COPYRIGHTS ChangeLog

DESCRIPTION: ALWAYS
	sed -e "s/Version:.*/Version: $(VERSION)/" -e "s/Date:.*/Date: $(CURRDATE)/" DESCRIPTION > DES.tmp && mv DES.tmp DESCRIPTION 
ALWAYS:

$(SRC_DIR)/dijkstra.mex: Makefile
	(cd $(SRC_DIR); \
	mkoctfile --mex dijkstra.cpp; \
	cd ..)

checkin_files=$(INST_DIR) $(dist_doc_DATA) DESCRIPTION $(SRC_DIR)/dijkstra.cpp Makefile.am configure.ac

checkin_release:
	git add $(checkin_files) && git commit -uno -S -m "Release files for version $(VERSION)"

checkpoint:
	git add $(checkin_files) && git commit -uno -S -q -m "checkpoint files for version $(VERSION)"

checkpoint_withcomment:
	git add $(checkin_files) && git commit -uno -S -q


deb:
	@echo 'Making debian packages'
	make distdir &&\
	cd $(distdir) &&\
	dpkg-buildpackage -Zgzip -uc -us && \
	cd .. && \
	rm -rf $(distdir)

