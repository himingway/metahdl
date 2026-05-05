# Comprehensive test suite for mhdlc compiler
# Usage:
#   make test        - run all tests (positive + negative)
#   make test_vpp    - run VPP preprocessor test only
#   make test_sv     - run SV parser test only
#   make test_mhdl   - run MHDL parser test only (with golden reference)
#   make test_vpp_adv- run advanced VPP test only
#   make test_ip     - run IP module test only
#   make test_negative - run negative tests (expect errors)
#   make clean       - remove output directory

MHDL    = ../src/mhdlc
INPUTS  = inputs
OUTDIR  = output
GOLDEN  = golden
OPTS    = -mb $(INPUTS) -o $(OUTDIR)

# Positive test files
VPP_TEST    = $(INPUTS)/test_vpp.vh
SV_TEST     = $(INPUTS)/test_sv_module.v
MHDL_TEST   = $(INPUTS)/test_mh_basic.mhdl
VPP_ADV_TEST = $(INPUTS)/test_vpp_advanced.mhdl
IP_TEST     = $(INPUTS)/one_hot_mux_2d.v
UNPK_TEST   = $(INPUTS)/test_unpacked_array.v
SV_BODY_TEST = $(INPUTS)/test_sv_body.v

# Negative test files (should fail)
SYNTAX_ERR_TEST = $(INPUTS)/test_syntax_error.mhdl

# Golden reference files
MHDL_GOLDEN = $(GOLDEN)/test_mh_basic.sv.golden

.PHONY: test test_vpp test_sv test_mhdl test_vpp_adv test_ip test_unpacked test_negative clean

test: $(OUTDIR) $(GOLDEN)
	@echo "========================================"
	@echo "  mhdlc Comprehensive Test Suite"
	@echo "========================================"
	@pass=0; fail=0; \
	for f in $(VPP_TEST) $(SV_TEST) $(VPP_ADV_TEST) $(IP_TEST) $(UNPK_TEST) $(SV_BODY_TEST); do \
	  printf "  %-40s " "$$f"; \
	  if $(MHDL) $(OPTS) $$f >$(OUTDIR)/$$(basename $$f).log 2>&1; then \
	    echo "PASS"; pass=$$((pass + 1)); \
	  else \
	    echo "FAIL (exit $$?)"; fail=$$((fail + 1)); \
	  fi; \
	done; \
	echo ""; \
	printf "  %-40s " "$(MHDL_TEST) [golden]"; \
	if $(MHDL) $(OPTS) $(MHDL_TEST) >$(OUTDIR)/$$(basename $(MHDL_TEST)).log 2>&1; then \
	  if diff -q $(OUTDIR)/test_mh_basic.sv $(MHDL_GOLDEN) >/dev/null 2>&1; then \
	    echo "PASS (golden match)"; pass=$$((pass + 1)); \
	  else \
	    echo "FAIL (golden mismatch)"; fail=$$((fail + 1)); \
	    diff $(OUTDIR)/test_mh_basic.sv $(MHDL_GOLDEN) | head -20; \
	  fi; \
	else \
	  echo "FAIL (exit $$?)"; fail=$$((fail + 1)); \
	fi; \
	echo ""; \
	printf "  %-40s " "$(SYNTAX_ERR_TEST) [negative]"; \
	if $(MHDL) $(OPTS) $(SYNTAX_ERR_TEST) >$(OUTDIR)/$$(basename $(SYNTAX_ERR_TEST)).log 2>&1; then \
	  echo "FAIL (expected error, got success)"; fail=$$((fail + 1)); \
	else \
	  echo "PASS (expected error, exit $$?)"; pass=$$((pass + 1)); \
	fi; \
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
	@if [ -f $(MHDL_GOLDEN) ]; then \
	  diff $(OUTDIR)/test_mh_basic.sv $(MHDL_GOLDEN) && echo "Golden reference match" || echo "Golden reference MISMATCH"; \
	fi

test_vpp_adv: $(OUTDIR)
	$(MHDL) $(OPTS) $(VPP_ADV_TEST)

test_ip: $(OUTDIR)
	$(MHDL) $(OPTS) $(IP_TEST)

test_unpacked: $(OUTDIR)
	$(MHDL) $(OPTS) $(UNPK_TEST)

test_negative: $(OUTDIR)
	@printf "  %-40s " "$(SYNTAX_ERR_TEST)"; \
	if $(MHDL) $(OPTS) $(SYNTAX_ERR_TEST) 2>&1; then \
	  echo "FAIL (expected error)"; \
	else \
	  echo "PASS (expected error)"; \
	fi

$(OUTDIR):
	mkdir -p $(OUTDIR)

$(GOLDEN):
	mkdir -p $(GOLDEN)

clean:
	rm -rf $(OUTDIR)
