all: 
	cd type-conv;       make all; sudo make install
	cd sexplib;         make all; sudo make install
	cd fileinfo;        make all; sudo make install
	cd vec;             make all; sudo make install
	cd hashtbl_bounded; make all; sudo make install
	cd intvmap;         make all; sudo make install
	cd mapmin;          make all; sudo make install

all-godi: 
	cd type-conv;       make all; make install
	cd sexplib;         make all; make install
	cd fileinfo;        make all; make install
	cd vec;             make all; make install
	cd hashtbl_bounded; make all; make install
	cd intvmap;         make all; make install
	cd mapmin;          make all; make install

uninstall:
	cd sexplib; sudo make uninstall
	cd type-conv; sudo make uninstall
	cd fileinfo; sudo make uninstall
	cd vec; sudo make uninstall
	cd hashtbl_bounded; sudo make uninstall
	cd intvmap; sudo make uninstall
	cd mapmin; sudo make uninstall

uninstall-godi:
	cd sexplib; make uninstall
	cd type-conv; make uninstall
	cd fileinfo; make uninstall
	cd vec; make uninstall
	cd hashtbl_bounded; make uninstall
	cd intvmap; make uninstall
	cd mapmin; make uninstall

clean:
	cd type-conv; make clean
	cd sexplib; make clean
	cd fileinfo; make clean
	cd vec; make clean
	cd hashtbl_bounded; make clean
	cd intvmap; make clean
	cd mapmin; make clean
