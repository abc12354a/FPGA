all: clean comp simv
comp:
	bsub -I vcs -f ../rtl/file_lst.f -l comp.log +v2k -debug_all -debug_access -full64
sim:
	bsub -I ./simv
run:
	bsub -I verdi -f ../rtl/file_lst.f -ssf tb.fsdb +v2k &
clean:
	rm -rf ./csrc *.daidir *.log simv* *.key