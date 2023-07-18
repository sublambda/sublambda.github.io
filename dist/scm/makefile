.SUFFIXES: .scm .o1 .o2 .js .o1.js

all: macros.o1 util.o1 objs.o1 nlibs.o1

foo:
	gsc -target js -c macros.scm util.scm objs.scm init.scm

.scm.o1:
	@rm -f $@
	gsc -target js $< && cp $@ $@.js
#	gsc -target js -c $<

clean:
	rm -f *.o? *.o?.js \#*\# *~

install: all
	rsync -av --del . ../dist/scm


watch:
	fswatch * | xargs -n 1 make all install 
