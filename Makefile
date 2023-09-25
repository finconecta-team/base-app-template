export PROJECT ?= $(shell basename $(shell pwd))

-include $(shell curl -sSL -o .tronador "https://cowk.io/acc"; echo .tronador)
