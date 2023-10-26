YGOT_GO ?= $(GOPATH)/src/github.com/openconfig/ygot/generator/generator.go
YGOT_PROTO ?= $(GOPATH)/src/github.com/openconfig/ygot/proto_generator/protogenerator.go
YANG_DIR ?= yang
MODELS ?= models
FAKEROOT ?= managed_element
YGOT_PKG_NAME ?= gen
YGOT_GEN_DIR ?= pkg/$(YGOT_PKG_NAME)
YGOT_GO_FLAGS ?= -shorten_enum_leaf_names -typedef_enum_with_defmod -generate_fakeroot -fakeroot_name=$(FAKEROOT) -compress_paths=true -exclude_modules=ietf-interfaces -generate_simple_unions=true
YGOT_PROTO_FLAGS ?= -generate_fakeroot -fakeroot_name=managed_element -compress_paths=true -exclude_modules=ietf-interfaces

YANG_FILES = $(wildcard $(YANG_DIR)/*.yang)
YGOT_GO_FILES = $(patsubst $(YANG_DIR)/%.yang, $(YGOT_GEN_DIR)/go/%.go, $(YANG_FILES))
YGOT_PROTO_FILES = $(patsubst $(YANG_DIR)/%.yang, $(YGOT_GEN_DIR)/proto/%.proto, $(YANG_FILES))

PREFIX ?= /usr/local
PROTOC ?= protoc
GO ?=go

$(YGOT_GEN_DIR)/go/%.go: $(YANG_DIR)/%.yang
	@mkdir -p $(@D)
	$(GO) run $(YGOT_GO) -path=$(MODELS) -output_file=$@ -package_name=$(FAKEROOT) $(YGOT_GO_FLAGS) $<

$(YGOT_GEN_DIR)/proto/%.proto: $(YANG_DIR)/%.yang
	@mkdir -p $(@D)
	$(GO) run $(YGOT_PROTO) -path=$(MODELS) -output_dir=$(YGOT_GEN_DIR)/proto -package_name=$(FAKEROOT) $(YGOT_PROTO_FLAGS) $<

.PHONY: generate
generate: $(YGOT_GO_FILES) $(YGOT_PROTO_FILES)

.PHONY: clean
clean:
	rm -rf $(YGOT_GEN_DIR)