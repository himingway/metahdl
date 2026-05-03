# Comprehensive test suite for mhdlc compiler
# Usage:
#   make test        - run all tests
#   make test_vpp    - run VPP preprocessor test only
#   make test_sv     - run SV parser test only
#   make test_mhdl   - run MHDL parser test only
#   make test_mpp    - run MPP preprocessor test only
#   make test_ip     - run IP module test only
#   make clean       - remove output directory

MHDL    = ../src/mhdlc
INPUTS  = inputs
OUTDIR  = output
OPTS    = -mb $(INPUTS) -o $(OUTDIR)

# Test files
VPP_TEST    = $(INPUTS)/test_vpp.vh
SV_TEST     = $(INPUTS)/test_sv_module.v
MHDL_TEST   = $(INPUTS)/test_mh_basic.mhdl
MPP_TEST    = $(INPUTS)/test_mpp.mhdl
IP_TEST     = $(INPUTS)/one_hot_mux_2d.v
UNPK_TEST   = $(INPUTS)/test_unpacked_array.v

.PHONY: test test_vpp test_sv test_mhdl test_mpp test_ip test_unpacked clean

test: $(OUTDIR)
	@echo "========================================"
	@echo "  mhdlc Comprehensive Test Suite"
	@echo "========================================"
	@pass=0; fail=0; \
	for f in $(VPP_TEST) $(SV_TEST) $(MHDL_TEST) $(MPP_TEST) $(IP_TEST) $(UNPK_TEST); do \
	  printf "  %-40s " "$$f"; \
	  if $(MHDL) $(OPTS) $$f >$(OUTDIR)/$$(basename $$f).log 2>&1; then \
	    echo "PASS"; pass=$$((pass + 1)); \
	  else \
	    echo "FAIL (exit $$?)"; fail=$$((fail + 1)); \
	  fi; \
	done; \
	echo "========================================"; \
	echo "  Results: $$pass passed, $$fail failed"; \
	echo "========================================"; \
	if [ $$fail -ne 0 ]; then exit 1; fi

test_vpp: $(OUTDIR)
	$(MHDL) $(OPTS) $(VPP_TEST)

test_sv: $(OUTDIR)
	$(MHDL) $(OPTS) $(SV_TEST)

test_mhdl: $(OUTDIR)
	$(MHDL) $(OPTS) $(MHDL_TEST)

test_mpp: $(OUTDIR)
	$(MHDL) $(OPTS) $(MPP_TEST)

test_ip: $(OUTDIR)
	$(MHDL) $(OPTS) $(IP_TEST)

test_unpacked: $(OUTDIR)
	$(MHDL) $(OPTS) $(UNPK_TEST)

$(OUTDIR):
	mkdir -p $(OUTDIR)

clean:
	rm -rf $(OUTDIR)
