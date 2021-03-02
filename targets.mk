.PHONY: vendor

vendor:
	./vendor/vendorpull/update

vendor-%:
	./vendor/vendorpull/update $(subst vendor-,,$@)
