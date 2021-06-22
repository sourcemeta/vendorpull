.PHONY: vendor

vendor-pull:
	./vendor/vendorpull/vendorpull pull

vendor-pull-%:
	./vendor/vendorpull/vendorpull pull $(subst vendor-,,$@)
