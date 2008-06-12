all: 
	cd xml-light;       make all;  make allopt; sudo make install
	cd type-conv;       make all; sudo make install
	cd sexplib;         make all; sudo make install
	cd fileinfo;        make all; sudo make install
	cd vec;             make all; sudo make install
	cd hashtbl_bounded; make all; sudo make install
	cd intvmap;         make all; sudo make install
	cd mapmin;          make all; sudo make install

uninstall:
	cd sexplib; sudo make uninstall
	cd type-conv; sudo make uninstall
	cd fileinfo; sudo make uninstall
	cd vec; sudo make uninstall
	cd hashtbl_bounded; sudo make uninstall
	cd intvmap; sudo make uninstall
	cd mapmin; sudo make uninstall

clean:
	cd xml-light; make clean
	cd type-conv; make clean
	cd sexplib; make clean
	cd fileinfo; make clean
	cd vec; make clean
	cd hashtbl_bounded; make clean
	cd intvmap; make clean
	cd mapmin; make clean
