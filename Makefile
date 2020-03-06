.DEFAULT_GOAL := help

DEPLOYMENT := cluster-zwei
NOMAD_ADDR := cluster.hs
NOMAD_URL := http://$(NOMAD_ADDR):4646
JOBS := $(shell find jobs -type f -name '*.nomad')

# TODO: phonies

#.PHONY: cluster-up cluster-down cluster-reboot
#cluster-up:
#	grep host < inventory | cut -d'=' -f 3 | xargs wakeonlan
#cluster-down:
#	ansible all -i inventory -b -K -m command -a poweroff

#upfs: ## setup main gluster volume
#	./setup-glusterfs-cluster
#	./mount-glusterfs

deploy: ## apply changes
	nixops deploy --deployment $(DEPLOYMENT)
	./isoltate-mutli-user-target # ensure congruent deployment

.PHONY: $(JOBS)
workload: $(JOBS) ## apply latest jobs configuration

$(JOBS):
	nomad job run -address=$(NOMAD_URL) $@

init: ## one time setup
	direnv allow .

#tunnel: ## setup local port forwarding for Consul UI
#	ssh root@$(NODE_IP) -L :8500:localhost:8500 -T

.PHONY: restart-nomad
restart-nomad: ## restart nomad service on all hosts
	nixops ssh-for-each -p systemctl restart nomad-server.service
	sleep 3
	nixops ssh-for-each -p systemctl restart nomad-client.service

.PHONY: help
help: ## print this message
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
