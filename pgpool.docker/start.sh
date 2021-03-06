#!/bin/sh

# Setting environment variables
export POSTGRES_USER=${POSTGRES_USER:-"postgres"}
export POSTGRES_PASSWORD=${POSTGRES_PASSWORD:-"postgres"}

export PGPOOL_PARAMS_PORT=${PGPOOL_PARAMS_PORT:-$PGPOOL_PORT}
export PGPOOL_PARAMS_BACKEND_HOSTNAME0=${PGPOOL_PARAMS_BACKEND_HOSTNAME0:-$HOT_POSTGRES_SERVICE_HOST}
export PGPOOL_PARAMS_BACKEND_PORT0=${PGPOOL_PARAMS_BACKEND_PORT0:-5432}
export PGPOOL_PARAMS_BACKEND_WEIGHT0=${PGPOOL_PARAMS_BACKEND_WEIGHT0:-1}
export PGPOOL_PARAMS_BACKEND_DATA_DIRECTORY0=/var/pv/data
export PGPOOL_PARAMS_BACKEND_FLAG0="ALWAYS_PRIMARY|DISALLOW_TO_FAILOVER"
export PGPOOL_PARAMS_BACKEND_HOSTNAME1=${PGPOOL_PARAMS_BACKEND_HOSTNAME1:-$HOT_POSTGRES_REPLICAS_SERVICE_HOST}
export PGPOOL_PARAMS_BACKEND_PORT1=${PGPOOL_PARAMS_BACKEND_PORT1:-5432}
export PGPOOL_PARAMS_BACKEND_WEIGHT1=${PGPOOL_PARAMS_BACKEND_WEIGHT1:-1}
export PGPOOL_PARAMS_BACKEND_DATA_DIRECTORY1=/var/pv/data
export PGPOOL_PARAMS_BACKEND_FLAG1=DISALLOW_TO_FAILOVER
export PGPOOL_PARAMS_LISTEN_ADDRESSES=*
export PGPOOL_PARAMS_SR_CHECK_PERIOD=${PGPOOL_PARAMS_SR_CHECK_PERIOD:-0}
export PGPOOL_PARAMS_SR_CHECK_USER=${POSTGRES_USER:-"postgres"}
export PGPOOL_PARAMS_SOCKET_DIR=/var/run/postgresql
export PGPOOL_PARAMS_PCP_SOCKET_DIR=/var/run/postgresql
export PGPOOL_PARAMS_WD_IPC_SOCKET_DIR=/var/run/postgresql

# Setting pool_passwd of postgres user
${PGPOOL_BINARY_DIR}/pg_md5 -m -f ${PGPOOLCONF} -u ${POSTGRES_USER} ${POSTGRES_PASSWORD}

# Setting pool_hba.conf
echo "host    all    all    0.0.0.0/0    md5" >> ${POOL_HBA_CONF}

# Setting pcp.conf
echo "${POSTGRES_USER}:"`${PGPOOL_BINARY_DIR}/pg_md5 ${POSTGRES_PASSWORD}` >> ${PCP_CONF}


# Setting pgpool.conf using environment variables with "PGPOOL_PARAMS_*"
# For example, environment variable "PGPOOL_PARAMS_PORT=9999" is converted to "port = '9999'"
printenv | sed -nr "s/^PGPOOL_PARAMS_(.*)=(.*)/\L\1 = '\E\2'/p" >> ${PGPOOLCONF}

# Start Pgpool-II
${PGPOOL_BINARY_DIR}/pgpool -n -f ${PGPOOLCONF} -F ${PCP_CONF} -a ${POOL_HBA_CONF}
