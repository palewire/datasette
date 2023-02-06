#
# Colors
#

# Define ANSI color codes
RESET_COLOR   = \033[m

BLUE       = \033[1;34m
YELLOW     = \033[1;33m
GREEN      = \033[1;32m
RED        = \033[1;31m
BLACK      = \033[1;30m
MAGENTA    = \033[1;35m
CYAN       = \033[1;36m
WHITE      = \033[1;37m

DBLUE      = \033[0;34m
DYELLOW    = \033[0;33m
DGREEN     = \033[0;32m
DRED       = \033[0;31m
DBLACK     = \033[0;30m
DMAGENTA   = \033[0;35m
DCYAN      = \033[0;36m
DWHITE     = \033[0;37m

BG_WHITE   = \033[47m
BG_RED     = \033[41m
BG_GREEN   = \033[42m
BG_YELLOW  = \033[43m
BG_BLUE    = \033[44m
BG_MAGENTA = \033[45m
BG_CYAN    = \033[46m

# Name some of the colors
COM_COLOR   = $(DBLUE)
OBJ_COLOR   = $(DCYAN)
OK_COLOR    = $(DGREEN)
ERROR_COLOR = $(DRED)
WARN_COLOR  = $(DYELLOW)
NO_COLOR    = $(RESET_COLOR)

OK_STRING    = "[OK]"
ERROR_STRING = "[ERROR]"
WARN_STRING  = "[WARNING]"

define banner
    @echo "  $(WHITE)__________$(RESET_COLOR)"
    @echo "$(WHITE) |$(DWHITE) PALEWIRE $(RESET_COLOR)$(WHITE)|$(RESET_COLOR)"
    @echo "$(WHITE) |&&& ======|$(RESET_COLOR)"
    @echo "$(WHITE) |=== ======|$(RESET_COLOR)  $(DWHITE)This is a $(RESET_COLOR)$(DBLACK)$(BG_WHITE)palewire$(RESET_COLOR)$(DWHITE) automation$(RESET_COLOR)"
    @echo "$(WHITE) |=== == %%%|$(RESET_COLOR)"
    @echo "$(WHITE) |[_] ======|$(RESET_COLOR)  $(1)"
    @echo "$(WHITE) |=== ===!##|$(RESET_COLOR)"
    @echo "$(WHITE) |__________|$(RESET_COLOR)"
    @echo ""
endef

#
# Python helpers
#

PIPENV := pipenv run
PYTHON := python -W ignore -m

#
# Commands
#

all: cedar-rapids-buildings-unsafe-after-derecho-2020.db \
	chicago-regions.db \
	la-county-election-precinct-maps-2016-primary.db \
	la-county-election-precinct-maps-2018-primary.db \
	la-county-election-precinct-maps-2018-general.db \
	la-county-election-precinct-maps-2020-general.db

cedar-rapids-buildings-unsafe-after-derecho-2020.db:
	@curl -L https://raw.githubusercontent.com/palewire/cedar-rapids-buildings-unsafe-after-derecho-2020/master/output/placards.csv | $(PIPENV) sqlite-utils insert cedar-rapids-buildings-unsafe-after-derecho-2020.db placards - --csv

chicago-regions.db:
	curl -L https://raw.githubusercontent.com/palewire/chicago-regions-map/main/output/regions.geojson | $(PIPENV) geojson-to-sqlite chicago-regions.db regions - --spatial-index

la-county-election-precinct-maps-2016-primary.db:
	curl -L https://raw.githubusercontent.com/datadesk/la-county-2016-primary-precinct-maps/master/Consolidations.geojson | $(PIPENV) geojson-to-sqlite la-county-election-precinct-maps-2016-primary.db precincts - --spatial-index

la-county-election-precinct-maps-2018-primary.db:
	curl -L https://raw.githubusercontent.com/datadesk/la-county-election-precincts-2018/master/geojson/primary.geojson | $(PIPENV) geojson-to-sqlite la-county-election-precinct-maps-2018-primary.db precincts - --spatial-index

la-county-election-precinct-maps-2018-general.db:
	curl -L https://raw.githubusercontent.com/datadesk/la-county-election-precincts-2018/master/geojson/general.geojson | $(PIPENV) geojson-to-sqlite la-county-election-precinct-maps-2018-general.db precincts - --spatial-index

la-county-election-precinct-maps-2020-general.db:
	curl -L https://github.com/datadesk/la-county-election-precincts-2020/raw/main/json/la-precincts.json | $(PIPENV) geojson-to-sqlite la-county-election-precinct-maps-2020-general.db precincts - --spatial-index

clean:
	@rm -f ./*.db
	@rm -f ./*.geojson
	@rm -f ./*.csv

install_plugins: ## Install datasette plugins
	@$(PIPENV) datasette install \
		datasette-cluster-map \
		datasette-vega \
		datasette-search-all \
		datasette-configure-fts \
		datasette-geojson \
		datasette-geojson-map

serve: ## Serve a local test site
	@$(PIPENV) datasette \
		./cedar-rapids-buildings-unsafe-after-derecho-2020.db \
		./chicago-regions.db \
		./la-county-election-precinct-maps-2016-primary.db \
		./la-county-election-precinct-maps-2018-primary.db \
		./la-county-election-precinct-maps-2018-general.db \
		./la-county-election-precinct-maps-2020-general.db \
		-m metadata.yml \
		--load-extension spatialite \
		--template-dir=./templates/ \
		--static assets:./static-files/ \
		--setting allow_download on

deploy: ## Deploy to fly.io
	$(call banner,  🚢 Deploying the site 🚢)
	@$(PIPENV) datasette publish fly \
		./cedar-rapids-buildings-unsafe-after-derecho-2020.db \
		./chicago-regions.db \
		./la-county-election-precinct-maps-2016-primary.db \
		./la-county-election-precinct-maps-2018-primary.db \
		./la-county-election-precinct-maps-2018-general.db \
		./la-county-election-precinct-maps-2020-general.db \
		-m metadata.yml \
		--app="datasette-palewi-re" \
		--install datasette-cluster-map \
		--install datasette-vega \
		--install datasette-search-all \
		--install datasette-configure-fts \
		--install datasette-geojson \
		--install datasette-geojson-map \
		--spatialite \
		--template-dir=./templates/ \
		--static assets:./static-files/ \
		--setting base_url https://palewi.re/data/

#
# Extras
#

help: ## Show this help. Example: make help
	@egrep -h '\s##\s' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'


# Mark all the commands that don't have a target
.PHONY: help deploy install_plugins serve
