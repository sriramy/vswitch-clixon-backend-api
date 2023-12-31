
YGOT_GO ?= $(GOPATH)/src/github.com/openconfig/ygot/generator/generator.go
YGOT_PROTO ?= $(GOPATH)/src/github.com/openconfig/ygot/proto_generator/protogenerator.go

DOCS_DIR ?= docs
IMPORTS_DIR ?= proto
YANG_DIR ?= yang
MODELS_DIR ?= models

FAKEROOT ?= managed_element
YGOT_PKG_NAME ?= gen
YGOT_GEN_DIR ?= pkg/$(YGOT_PKG_NAME)
PROTO_DIR = $(YGOT_GEN_DIR)/proto
PROTO2GO_DIR = $(YGOT_GEN_DIR)/go

PREFIX ?= /usr/local
PROTOC ?= protoc
GO ?=go

YANG_EXCLUDE_MODULES ?= ietf-interfaces,openconfig-segment-routing-types
YANG_FILES = $(wildcard $(YANG_DIR)/*.yang)
YGOT_PROT_FILES = $(patsubst $(YANG_DIR)/%.yang, $(YGOT_GEN_DIR)/proto/%.proto, $(YANG_FILES))
YGOT_FLAGS ?= -generate_fakeroot -fakeroot_name=$(FAKEROOT) -package_name=$(FAKEROOT) -go_package_base=github.com/sriramy/vswitch-api/$(PROTO2GO_DIR) \
	-compress_paths=true -exclude_modules=$(YANG_EXCLUDE_MODULES) -yext_path=ygot -ywrapper_path=ygot

all: generate

$(YGOT_GEN_DIR)/proto/%.proto: $(YANG_DIR)/%.yang
	@mkdir -p $(@D)
	$(GO) run $(YGOT_PROTO) -path=$(MODELS_DIR) -output_dir=$(YGOT_GEN_DIR)/proto  $(YGOT_FLAGS) $<

$(DOCS_DIR):
	mkdir -p $(DOCS_DIR)

$(PROTO2GO_DIR):
	mkdir -p $(PROTO2GO_DIR)

.PHONY: proto2go
proto2go: $(PROTO2GO_DIR) $(DOCS_DIR)
	$(PROTOC) -I $(IMPORTS_DIR) -I $(PROTO_DIR) \
	--go_out=$(PROTO2GO_DIR) --go_opt=paths=source_relative \
	--doc_out=$(DOCS_DIR) --doc_opt=markdown,proto.md \
	$(PROTO_DIR)/$(FAKEROOT)/$(FAKEROOT).proto $(PROTO_DIR)/$(FAKEROOT)/enums/enums.proto

.PHONY: generate
generate: $(YGOT_PROT_FILES) proto2go

.PHONY: clean
clean:
	rm -rf $(YGOT_GEN_DIR)