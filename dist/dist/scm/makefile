.SUFFIXES: .scm .o1 .o2 .js .o1.js

all: macros.o1 util.o1 objs.o1

.scm.o1:
	@rm -f $@
	gsc -target js $< && cp $@ $@.js

clean:
	rm -f *.o? *.o?.js \#*\# *~

install: all
	rsync -av --del . ../dist/scm


watch:
	fswatch * | xargs -n 1 make all install 
