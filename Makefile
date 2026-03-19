.PHONY: help dev-up dev-down dev-restart dev-stop dev-start dev-build dev-ps dev-clean dev-validate logs logs-follow logs-tail shell exec stop-container start-container remove-container list-containers dev-env

# Docker Compose file location
DOCKER_COMPOSE_FILE := dev/docker-compose.yml

# Colors for output
GREEN := \033[0;32m
YELLOW := \033[1;33m
RED := \033[0;31m
BLUE := \033[0;34m
PURPLE := \033[0;35m
NC := \033[0m # No Color

# Default target
help:
	@echo "$(BLUE)╔════════════════════════════════════════════════════════════╗$(NC)"
	@echo "$(BLUE)║     Kamera Backend - Docker Compose Management System      ║$(NC)"
	@echo "$(BLUE)╚════════════════════════════════════════════════════════════╝$(NC)"
	@echo ""
	@echo "$(GREEN)📦 LIFECYCLE MANAGEMENT:$(NC)"
	@echo "  $(PURPLE)make dev-up$(NC)              - Start all development containers"
	@echo "  $(PURPLE)make dev-down$(NC)            - Stop and remove all containers"
	@echo "  $(PURPLE)make dev-stop$(NC)            - Stop all containers without removing"
	@echo "  $(PURPLE)make dev-start$(NC)           - Start all stopped containers"
	@echo "  $(PURPLE)make dev-restart$(NC)         - Restart all development containers"
	@echo "  $(PURPLE)make dev-build$(NC)           - Build/rebuild container images"
	@echo "  $(PURPLE)make dev-ps$(NC)              - Show running containers"
	@echo "  $(PURPLE)make dev-clean$(NC)           - Remove containers, volumes, networks"
	@echo ""
	@echo "$(GREEN)🔧 UNIFIED CONTAINER COMMANDS:$(NC)"
	@echo "  $(PURPLE)make logs$(NC)                 - View container logs (interactive menu)"
	@echo "  $(PURPLE)make logs CONTAINER=db$(NC)    - View logs for specific container"
	@echo "  $(PURPLE)make logs-follow$(NC)          - Follow logs in real-time (interactive)"
	@echo "  $(PURPLE)make logs-tail$(NC)            - View last N lines (interactive)"
	@echo ""
	@echo "  $(PURPLE)make shell$(NC)                - Open shell in container (interactive menu)"
	@echo "  $(PURPLE)make shell CONTAINER=db$(NC)   - Open shell in specific container"
	@echo ""
	@echo "  $(PURPLE)make exec$(NC)                 - Execute command in container"
	@echo "  $(PURPLE)make exec CONTAINER=db CMD=ls$(NC) - Execute command in specific container"
	@echo ""
	@echo "  $(PURPLE)make stop-container$(NC)       - Stop specific container (interactive)"
	@echo "  $(PURPLE)make start-container$(NC)      - Start specific container (interactive)"
	@echo "  $(PURPLE)make remove-container$(NC)     - Remove specific container (interactive)"
	@echo ""
	@echo "$(GREEN)📋 UTILITIES:$(NC)"
	@echo "  $(PURPLE)make list-containers$(NC)      - List all available containers"
	@echo "  $(PURPLE)make dev-validate$(NC)        - Validate docker-compose config"
	@echo "  $(PURPLE)make dev-env$(NC)              - Show environment variables"
	@echo ""

# ============================================================================
# LIFECYCLE MANAGEMENT
# ============================================================================

dev-up:
	@echo "$(GREEN)▶ Starting development containers...$(NC)"
	docker-compose -f $(DOCKER_COMPOSE_FILE) up -d
	@echo "$(GREEN)✓ Development containers started$(NC)"
	@make dev-ps

dev-down:
	@echo "$(YELLOW)⊘ Stopping and removing development containers...$(NC)"
	docker-compose -f $(DOCKER_COMPOSE_FILE) down
	@echo "$(GREEN)✓ Development containers stopped and removed$(NC)"

dev-stop:
	@echo "$(YELLOW)⊘ Stopping development containers...$(NC)"
	docker-compose -f $(DOCKER_COMPOSE_FILE) stop
	@echo "$(GREEN)✓ Development containers stopped$(NC)"

dev-start:
	@echo "$(GREEN)▶ Starting development containers...$(NC)"
	docker-compose -f $(DOCKER_COMPOSE_FILE) start
	@echo "$(GREEN)✓ Development containers started$(NC)"
	@make dev-ps

dev-restart: dev-stop dev-start
	@echo "$(GREEN)✓ Development containers restarted$(NC)"

dev-build:
	@echo "$(BLUE)⚙ Building/rebuilding container images...$(NC)"
	docker-compose -f $(DOCKER_COMPOSE_FILE) build
	@echo "$(GREEN)✓ Container images built successfully$(NC)"

dev-ps:
	@echo ""
	@echo "$(BLUE)Container Status:$(NC)"
	@docker-compose -f $(DOCKER_COMPOSE_FILE) ps
	@echo ""

dev-clean:
	@echo "$(RED)⚠ Cleaning up development environment...$(NC)"
	@echo "$(RED)This will remove containers, volumes, and networks$(NC)"
	@printf "$(YELLOW)Are you sure? (y/N)$(NC) "; \
	read confirm; \
	if [ "$$confirm" != "y" ]; then echo "$(YELLOW)Cancelled$(NC)"; exit 1; fi; \
	docker-compose -f $(DOCKER_COMPOSE_FILE) down -v; \
	echo "$(GREEN)✓ Development environment cleaned$(NC)"

list-containers:
	@echo "$(BLUE)Available containers:$(NC)"
	@docker-compose -f $(DOCKER_COMPOSE_FILE) config --services

# ============================================================================
# UNIFIED CONTAINER COMMANDS
# ============================================================================

logs:
	@if [ -z "$(CONTAINER)" ]; then \
		echo "$(BLUE)Available containers:$(NC)"; \
		docker-compose -f $(DOCKER_COMPOSE_FILE) config --services; \
		echo ""; \
		printf "$(YELLOW)Enter container name or ID:$(NC) "; \
		read CONTAINER_NAME; \
		docker-compose -f $(DOCKER_COMPOSE_FILE) logs $$CONTAINER_NAME; \
	else \
		docker-compose -f $(DOCKER_COMPOSE_FILE) logs $(CONTAINER); \
	fi

logs-follow:
	@if [ -z "$(CONTAINER)" ]; then \
		echo "$(BLUE)Available containers:$(NC)"; \
		docker-compose -f $(DOCKER_COMPOSE_FILE) config --services; \
		echo ""; \
		printf "$(YELLOW)Enter container name or ID:$(NC) "; \
		read CONTAINER_NAME; \
		docker-compose -f $(DOCKER_COMPOSE_FILE) logs -f $$CONTAINER_NAME; \
	else \
		docker-compose -f $(DOCKER_COMPOSE_FILE) logs -f $(CONTAINER); \
	fi

logs-tail:
	@if [ -z "$(CONTAINER)" ]; then \
		echo "$(BLUE)Available containers:$(NC)"; \
		docker-compose -f $(DOCKER_COMPOSE_FILE) config --services; \
		echo ""; \
		printf "$(YELLOW)Enter container name or ID:$(NC) "; \
		read CONTAINER_NAME; \
		printf "$(YELLOW)Number of lines to show (default 50):$(NC) "; \
		read LINES; \
		LINES=$${LINES:-50}; \
		docker-compose -f $(DOCKER_COMPOSE_FILE) logs --tail $$LINES $$CONTAINER_NAME; \
	else \
		LINES=$(LINES:-50); \
		docker-compose -f $(DOCKER_COMPOSE_FILE) logs --tail $$LINES $(CONTAINER); \
	fi

shell:
	@if [ -z "$(CONTAINER)" ]; then \
		echo "$(BLUE)Available containers:$(NC)"; \
		docker-compose -f $(DOCKER_COMPOSE_FILE) config --services; \
		echo ""; \
		printf "$(YELLOW)Enter container name or ID:$(NC) "; \
		read CONTAINER_NAME; \
		$(MAKE) _open_shell CONTAINER=$$CONTAINER_NAME; \
	else \
		$(MAKE) _open_shell CONTAINER=$(CONTAINER); \
	fi

_open_shell:
	@case "$(CONTAINER)" in \
		db|postgres) \
			echo "$(BLUE)Opening PostgreSQL shell...$(NC)"; \
			docker-compose -f $(DOCKER_COMPOSE_FILE) exec db psql -U $${POSTGRES_USER:-postgres} -d $${POSTGRES_DB:-postgres}; \
			;; \
		cache|redis) \
			echo "$(BLUE)Opening Redis CLI...$(NC)"; \
			docker-compose -f $(DOCKER_COMPOSE_FILE) exec cache redis-cli; \
			;; \
		*) \
			echo "$(BLUE)Opening shell in $(CONTAINER)...$(NC)"; \
			docker-compose -f $(DOCKER_COMPOSE_FILE) exec $(CONTAINER) /bin/bash 2>/dev/null || docker-compose -f $(DOCKER_COMPOSE_FILE) exec $(CONTAINER) /bin/sh; \
			;; \
	esac

exec:
	@if [ -z "$(CONTAINER)" ]; then \
		echo "$(BLUE)Available containers:$(NC)"; \
		docker-compose -f $(DOCKER_COMPOSE_FILE) config --services; \
		echo ""; \
		printf "$(YELLOW)Enter container name or ID:$(NC) "; \
		read CONTAINER_NAME; \
		printf "$(YELLOW)Enter command to execute:$(NC) "; \
		read CMD_INPUT; \
		docker-compose -f $(DOCKER_COMPOSE_FILE) exec $$CONTAINER_NAME $$CMD_INPUT; \
	else \
		if [ -z "$(CMD)" ]; then \
			printf "$(YELLOW)Enter command to execute:$(NC) "; \
			read CMD_INPUT; \
			docker-compose -f $(DOCKER_COMPOSE_FILE) exec $(CONTAINER) $$CMD_INPUT; \
		else \
			docker-compose -f $(DOCKER_COMPOSE_FILE) exec $(CONTAINER) $(CMD); \
		fi \
	fi

stop-container:
	@if [ -z "$(CONTAINER)" ]; then \
		echo "$(BLUE)Available containers:$(NC)"; \
		docker-compose -f $(DOCKER_COMPOSE_FILE) config --services; \
		echo ""; \
		printf "$(YELLOW)Enter container name to stop:$(NC) "; \
		read CONTAINER_NAME; \
		docker-compose -f $(DOCKER_COMPOSE_FILE) stop $$CONTAINER_NAME; \
		echo "$(GREEN)✓ Container stopped$(NC)"; \
	else \
		docker-compose -f $(DOCKER_COMPOSE_FILE) stop $(CONTAINER); \
		echo "$(GREEN)✓ Container $(CONTAINER) stopped$(NC)"; \
	fi

start-container:
	@if [ -z "$(CONTAINER)" ]; then \
		echo "$(BLUE)Available containers:$(NC)"; \
		docker-compose -f $(DOCKER_COMPOSE_FILE) config --services; \
		echo ""; \
		printf "$(YELLOW)Enter container name to start:$(NC) "; \
		read CONTAINER_NAME; \
		docker-compose -f $(DOCKER_COMPOSE_FILE) start $$CONTAINER_NAME; \
		echo "$(GREEN)✓ Container started$(NC)"; \
	else \
		docker-compose -f $(DOCKER_COMPOSE_FILE) start $(CONTAINER); \
		echo "$(GREEN)✓ Container $(CONTAINER) started$(NC)"; \
	fi

remove-container:
	@if [ -z "$(CONTAINER)" ]; then \
		echo "$(BLUE)Available containers:$(NC)"; \
		docker-compose -f $(DOCKER_COMPOSE_FILE) config --services; \
		echo ""; \
		printf "$(YELLOW)Enter container name to remove:$(NC) "; \
		read CONTAINER_NAME; \
		printf "$(RED)Are you sure? (y/N)$(NC) "; \
		read confirm; \
		if [ "$$confirm" != "y" ]; then echo "$(YELLOW)Cancelled$(NC)"; exit 1; fi; \
		docker-compose -f $(DOCKER_COMPOSE_FILE) rm -f $$CONTAINER_NAME; \
		echo "$(GREEN)✓ Container removed$(NC)"; \
	else \
		printf "$(RED)Are you sure? (y/N)$(NC) "; \
		read confirm; \
		if [ "$$confirm" != "y" ]; then echo "$(YELLOW)Cancelled$(NC)"; exit 1; fi; \
		docker-compose -f $(DOCKER_COMPOSE_FILE) rm -f $(CONTAINER); \
		echo "$(GREEN)✓ Container $(CONTAINER) removed$(NC)"; \
	fi

# ============================================================================
# UTILITIES
# ============================================================================

dev-validate:
	@echo "$(BLUE)Validating docker-compose configuration...$(NC)"
	@docker-compose -f $(DOCKER_COMPOSE_FILE) config > /dev/null 2>&1 && echo "$(GREEN)✓ Configuration is valid$(NC)" || echo "$(RED)✗ Configuration is invalid$(NC)"

dev-env:
	@echo "$(BLUE)Environment variables required for docker-compose:$(NC)"
	@grep -E '\$\{' $(DOCKER_COMPOSE_FILE) | sed 's/.*\${\([^}]*\)}.*/\1/' | sort -u | sed 's/^/  - /'
