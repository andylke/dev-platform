#!/usr/bin/env bash

set -euo pipefail

SHARED_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../shared" && pwd)"
source "${SHARED_DIR}/set-env.sh"

SERVICE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RUNTIME_DIR="${SERVICE_DIR}/runtime"
INIT_DIR="${RUNTIME_DIR}/init.groovy.d"

prepare_init_scripts() {

    mkdir -p "${INIT_DIR}"

    cat > "${INIT_DIR}/01-create-admin.groovy" <<EOF
import jenkins.model.*
import hudson.security.*

def instance = Jenkins.get()

def hudsonRealm = new HudsonPrivateSecurityRealm(false)

hudsonRealm.createAccount("${JENKINS_ADMIN_USERNAME}", "${JENKINS_ADMIN_PASSWORD}")

instance.setSecurityRealm(hudsonRealm)

def strategy = new FullControlOnceLoggedInAuthorizationStrategy()
strategy.setAllowAnonymousRead(false)

instance.setAuthorizationStrategy(strategy)
instance.save()

println "--> Jenkins admin user created"
EOF

}

prepare_init_scripts
