.PHONY: vendor

vendor-pull:
	./vendor/vendorpull/update pull

vendor-pull-%:
	./vendor/vendorpull/update pull $(subst vendor-,,$@)
